CREATE DATABASE HotelPlus;
USE HotelPlus;

CREATE TABLE hoteles (
    id_hotel INT auto_increment PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    categoria VARCHAR(10) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    email_contacto VARCHAR(100)
);

CREATE TABLE habitaciones (
    id_habitacion INT auto_increment PRIMARY KEY,
    id_hotel INT NOT NULL,
    numero_habitacion VARCHAR(10) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL,
    tarifa_base DECIMAL(12,2) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel)
);

CREATE TABLE clientes (
    id_cliente INT auto_increment PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    documento VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(30) NOT NULL
);

CREATE TABLE reservas (
    id_reserva INT auto_increment PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_reserva DATETIME NOT NULL,
    fecha_checkin DATE NOT NULL,
    fecha_checkout DATE NOT NULL,
    estado VARCHAR(50) NOT NULL,
    precio_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE pagos (
    id_pago INT auto_increment PRIMARY KEY,
    id_reserva INT NOT NULL,
    fecha_pago DATETIME NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    estado_pago VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
);

CREATE TABLE servicios_adicionales (
    id_servicio INT auto_increment PRIMARY KEY,
    nombre_servicio VARCHAR(120) NOT NULL,
    descripcion VARCHAR(1000),
    precio DECIMAL(12,2) NOT NULL
);

CREATE TABLE reserva_servicio (
    id_reserva INT NOT NULL,
    id_servicio INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_reserva, id_servicio),
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva),
    FOREIGN KEY (id_servicio) REFERENCES servicios_adicionales(id_servicio)
);

CREATE TABLE reserva_habitacion (
    id_reserva INT NOT NULL,
    id_habitacion INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    observacion VARCHAR(200),
    PRIMARY KEY (id_reserva, id_habitacion),
    FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva),
    FOREIGN KEY (id_habitacion) REFERENCES habitaciones(id_habitacion)
);
