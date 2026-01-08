USE HotelPlus;

-- Limpieza (re-ejecutable)
DROP TRIGGER IF EXISTS tr_no_solapamiento_habitacion_ins;
DROP TRIGGER IF EXISTS tr_total_reserva_rh_ins;
DROP TRIGGER IF EXISTS tr_total_reserva_rs_ins;
DROP TRIGGER IF EXISTS tr_actualizar_estado_reserva;

DROP PROCEDURE IF EXISTS sp_reporte_reservas_por_hotel;
DROP PROCEDURE IF EXISTS sp_reservas_por_cliente;
DROP PROCEDURE IF EXISTS sp_recalcular_total_reserva;

DROP FUNCTION IF EXISTS fn_saldo_pendiente_reserva;
DROP FUNCTION IF EXISTS fn_total_pagado_por_reserva;

DROP VIEW IF EXISTS vw_ocupacion_por_hotel;
DROP VIEW IF EXISTS vw_ingresos_por_hotel;
DROP VIEW IF EXISTS vw_servicios_por_reserva;
DROP VIEW IF EXISTS vw_resumen_pagos;
DROP VIEW IF EXISTS vw_reservas_detalle;

-- =========================
-- VISTAS (5)
-- =========================

CREATE VIEW vw_reservas_detalle AS
SELECT
    r.id_reserva,
    c.nombre AS nombre_cliente,
    c.apellido AS apellido_cliente,
    h.nombre AS nombre_hotel,
    hab.numero_habitacion,
    r.fecha_checkin,
    r.fecha_checkout,
    r.estado,
    r.precio_total
FROM reservas r
JOIN clientes c            ON r.id_cliente = c.id_cliente
JOIN reserva_habitacion rh ON r.id_reserva = rh.id_reserva
JOIN habitaciones hab      ON rh.id_habitacion = hab.id_habitacion
JOIN hoteles h             ON hab.id_hotel = h.id_hotel;

CREATE VIEW vw_resumen_pagos AS
SELECT
    r.id_reserva,
    r.precio_total,
    IFNULL(SUM(CASE WHEN p.estado_pago = 'Pagado' THEN p.monto ELSE 0 END), 0) AS total_pagado,
    (r.precio_total - IFNULL(SUM(CASE WHEN p.estado_pago = 'Pagado' THEN p.monto ELSE 0 END), 0)) AS saldo_pendiente
FROM reservas r
LEFT JOIN pagos p ON p.id_reserva = r.id_reserva
GROUP BY r.id_reserva, r.precio_total;

CREATE VIEW vw_servicios_por_reserva AS
SELECT
    rs.id_reserva,
    sa.nombre_servicio,
    rs.cantidad,
    rs.precio_unitario,
    (rs.cantidad * rs.precio_unitario) AS subtotal
FROM reserva_servicio rs
JOIN servicios_adicionales sa ON sa.id_servicio = rs.id_servicio;

-- Ingresos pagados por hotel (sin duplicar por múltiples habitaciones)
CREATE VIEW vw_ingresos_por_hotel AS
SELECT
    x.id_hotel,
    x.nombre_hotel,
    IFNULL(SUM(x.pagos_pagados), 0) AS ingresos_pagados
FROM (
    SELECT
        h.id_hotel,
        h.nombre AS nombre_hotel,
        r.id_reserva,
        IFNULL((
            SELECT SUM(p.monto)
            FROM pagos p
            WHERE p.id_reserva = r.id_reserva
              AND p.estado_pago = 'Pagado'
        ), 0) AS pagos_pagados
    FROM reservas r
    JOIN reserva_habitacion rh ON rh.id_reserva = r.id_reserva
    JOIN habitaciones hab      ON hab.id_habitacion = rh.id_habitacion
    JOIN hoteles h             ON h.id_hotel = hab.id_hotel
    GROUP BY h.id_hotel, h.nombre, r.id_reserva
) x
GROUP BY x.id_hotel, x.nombre_hotel;

CREATE VIEW vw_ocupacion_por_hotel AS
SELECT
    h.id_hotel,
    h.nombre AS nombre_hotel,
    COUNT(DISTINCT r.id_reserva) AS reservas_asociadas
FROM hoteles h
LEFT JOIN habitaciones hab       ON hab.id_hotel = h.id_hotel
LEFT JOIN reserva_habitacion rh  ON rh.id_habitacion = hab.id_habitacion
LEFT JOIN reservas r             ON r.id_reserva = rh.id_reserva
GROUP BY h.id_hotel, h.nombre;

-- =========================
-- FUNCIONES (2)
-- =========================
DELIMITER $$

CREATE FUNCTION fn_total_pagado_por_reserva(p_id_reserva INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT IFNULL(SUM(monto), 0)
      INTO v_total
      FROM pagos
     WHERE id_reserva = p_id_reserva
       AND estado_pago = 'Pagado';

    RETURN v_total;
END$$

CREATE FUNCTION fn_saldo_pendiente_reserva(p_id_reserva INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_pagado DECIMAL(12,2);

    SELECT precio_total
      INTO v_total
      FROM reservas
     WHERE id_reserva = p_id_reserva;

    SET v_pagado = fn_total_pagado_por_reserva(p_id_reserva);

    RETURN (v_total - v_pagado);
END$$

DELIMITER ;

-- =========================
-- PROCEDURES (2 + 1 auxiliar)
-- =========================
DELIMITER $$

CREATE PROCEDURE sp_recalcular_total_reserva(IN p_id_reserva INT)
BEGIN
    DECLARE v_total_hab  DECIMAL(12,2);
    DECLARE v_total_serv DECIMAL(12,2);

    SELECT IFNULL(SUM(precio_unitario), 0)
      INTO v_total_hab
      FROM reserva_habitacion
     WHERE id_reserva = p_id_reserva;

    SELECT IFNULL(SUM(cantidad * precio_unitario), 0)
      INTO v_total_serv
      FROM reserva_servicio
     WHERE id_reserva = p_id_reserva;

    UPDATE reservas
       SET precio_total = (v_total_hab + v_total_serv)
     WHERE id_reserva = p_id_reserva;
END$$

CREATE PROCEDURE sp_reservas_por_cliente(IN p_id_cliente INT)
BEGIN
    SELECT
        r.id_reserva,
        c.nombre AS nombre_cliente,
        c.apellido AS apellido_cliente,
        r.fecha_checkin,
        r.fecha_checkout,
        r.estado,
        r.precio_total,
        fn_total_pagado_por_reserva(r.id_reserva) AS total_pagado,
        fn_saldo_pendiente_reserva(r.id_reserva)  AS saldo_pendiente
    FROM reservas r
    JOIN clientes c ON r.id_cliente = c.id_cliente
    WHERE r.id_cliente = p_id_cliente;
END$$

-- Reporte por hotel (sin duplicar precio_total por múltiples habitaciones)
CREATE PROCEDURE sp_reporte_reservas_por_hotel(IN p_id_hotel INT)
BEGIN
    SELECT
        t.id_hotel,
        t.nombre_hotel,
        COUNT(*) AS cantidad_reservas,
        IFNULL(SUM(t.precio_total), 0) AS total_facturado
    FROM (
        SELECT
            h.id_hotel,
            h.nombre AS nombre_hotel,
            r.id_reserva,
            r.precio_total
        FROM reservas r
        JOIN reserva_habitacion rh ON rh.id_reserva = r.id_reserva
        JOIN habitaciones hab      ON hab.id_habitacion = rh.id_habitacion
        JOIN hoteles h             ON h.id_hotel = hab.id_hotel
        WHERE h.id_hotel = p_id_hotel
        GROUP BY h.id_hotel, h.nombre, r.id_reserva, r.precio_total
    ) t
    GROUP BY t.id_hotel, t.nombre_hotel;
END$$

DELIMITER ;

-- =========================
-- TRIGGERS (2+)
-- =========================
DELIMITER $$

CREATE TRIGGER tr_no_solapamiento_habitacion_ins
BEFORE INSERT ON reserva_habitacion
FOR EACH ROW
BEGIN
    DECLARE v_checkin_new  DATE;
    DECLARE v_checkout_new DATE;
    DECLARE v_cnt INT;

    SELECT fecha_checkin, fecha_checkout
      INTO v_checkin_new, v_checkout_new
      FROM reservas
     WHERE id_reserva = NEW.id_reserva;

    SELECT COUNT(*)
      INTO v_cnt
      FROM reserva_habitacion rh
      JOIN reservas r ON r.id_reserva = rh.id_reserva
     WHERE rh.id_habitacion = NEW.id_habitacion
       AND (v_checkin_new < r.fecha_checkout AND v_checkout_new > r.fecha_checkin);

    IF v_cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La habitación ya está reservada en esas fechas.';
    END IF;
END$$

CREATE TRIGGER tr_total_reserva_rh_ins
AFTER INSERT ON reserva_habitacion
FOR EACH ROW
BEGIN
    CALL sp_recalcular_total_reserva(NEW.id_reserva);
END$$

CREATE TRIGGER tr_total_reserva_rs_ins
AFTER INSERT ON reserva_servicio
FOR EACH ROW
BEGIN
    CALL sp_recalcular_total_reserva(NEW.id_reserva);
END$$

CREATE TRIGGER tr_actualizar_estado_reserva
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    DECLARE v_total_reserva DECIMAL(12,2);
    DECLARE v_total_pagado  DECIMAL(12,2);

    SELECT precio_total
      INTO v_total_reserva
      FROM reservas
     WHERE id_reserva = NEW.id_reserva;

    SELECT IFNULL(SUM(monto), 0)
      INTO v_total_pagado
      FROM pagos
     WHERE id_reserva = NEW.id_reserva
       AND estado_pago = 'Pagado';

    IF v_total_pagado >= v_total_reserva THEN
        UPDATE reservas
           SET estado = 'Pagada'
         WHERE id_reserva = NEW.id_reserva;
    END IF;
END$$

DELIMITER ;
