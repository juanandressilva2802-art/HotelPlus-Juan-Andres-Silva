USE HotelPlus;

-- 1) HOTELES
INSERT INTO hoteles (nombre, direccion, ciudad, categoria, telefono, email_contacto)
VALUES
('Hotel Central', 'Av. Libertad 123', 'Montevideo', '4', '2900 1234', 'contacto@central.com'),
('Hotel Mar Azul', 'Rambla 456', 'Punta del Este', '5', '4222 5678', 'info@marazul.com'),
('Hotel Sierra', 'Ruta 8 Km 45', 'Minas', '3', '4455 9876', 'reservas@sierra.com');

-- 2) HABITACIONES
INSERT INTO habitaciones (id_hotel, numero_habitacion, tipo, capacidad, tarifa_base, estado)
VALUES
(1, '101', 'Standard', 2, 80.00, 'Disponible'),
(1, '102', 'Suite', 3, 150.00, 'Disponible'),
(2, '201', 'Vista Mar', 2, 200.00, 'Disponible'),
(2, '202', 'Premium', 4, 300.00, 'Mantenimiento'),
(3, '301', 'Standard', 2, 70.00, 'Disponible'),
(3, '302', 'Familiar', 5, 120.00, 'Disponible');

-- 3) CLIENTES
INSERT INTO clientes (nombre, apellido, documento, email, telefono)
VALUES
('Juan', 'Silva', '47583920', 'juan@gmail.com', '099123456'),
('María', 'Pérez', '48920311', 'maria@gmail.com', '098654321'),
('Carlos', 'López', '51233450', 'carlos@gmail.com', '097777888'),
('Ana', 'González', '43322109', 'ana@gmail.com', '094333222');

-- 4) RESERVAS
INSERT INTO reservas (id_cliente, fecha_reserva, fecha_checkin, fecha_checkout, estado, precio_total)
VALUES
(1, '2025-02-01 10:30:00', '2025-02-10', '2025-02-12', 'Confirmada', 160.00),
(2, '2025-02-05 14:10:00', '2025-02-20', '2025-02-23', 'Confirmada', 600.00),
(3, '2025-03-01 09:00:00', '2025-03-05', '2025-03-06', 'Pendiente', 200.00),
(1, '2025-03-10 12:40:00', '2025-03-15', '2025-03-18', 'Confirmada', 450.00),
(4, '2025-03-15 16:00:00', '2025-03-22', '2025-03-25', 'Cancelada', 0.00),
(2, '2025-04-01 11:20:00', '2025-04-10', '2025-04-12', 'Confirmada', 160.00);

-- 5) PAGOS
INSERT INTO pagos (id_reserva, fecha_pago, metodo_pago, monto, estado_pago)
VALUES
(1, '2025-02-02 14:00:00', 'Tarjeta', 160.00, 'Pagado'),
(2, '2025-02-06 09:45:00', 'Tarjeta', 600.00, 'Pagado'),
(4, '2025-03-12 18:30:00', 'Efectivo', 450.00, 'Pagado'),
(3, '2025-03-02 12:00:00', 'Tarjeta', 200.00, 'Pendiente'),
(6, '2025-04-02 10:00:00', 'Tarjeta', 160.00, 'Pagado');

-- 6) SERVICIOS ADICIONALES
INSERT INTO servicios_adicionales (nombre_servicio, descripcion, precio)
VALUES
('Desayuno Buffet', 'Servicio de desayuno completo', 15.00),
('Spa', 'Acceso al spa por 1 día', 50.00),
('Estacionamiento', 'Estacionamiento techado 24hs', 10.00),
('Traslado Aeropuerto', 'Transfer privado al aeropuerto', 40.00);

-- 7) RESERVA_SERVICIO
INSERT INTO reserva_servicio (id_reserva, id_servicio, cantidad, precio_unitario)
VALUES
(1, 1, 2, 15.00),
(2, 2, 1, 50.00),
(2, 3, 3, 10.00),
(4, 1, 2, 15.00),
(6, 4, 1, 40.00);

-- 8) RESERVA_HABITACION
INSERT INTO reserva_habitacion (id_reserva, id_habitacion, precio_unitario, observacion)
VALUES
(1, 1, 80.00, 'Vista al patio'),
(2, 3, 200.00, 'Vista al mar'),
(2, 4, 300.00, 'Habitación premium'),
(3, 5, 70.00, NULL),
(4, 6, 120.00, 'Cama adicional'),
(6, 1, 80.00, 'Check-in temprano');
