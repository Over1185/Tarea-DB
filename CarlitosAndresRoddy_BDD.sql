/* ==========================================================================
   1. CREACIÓN DE LAS 4 BASES DE DATOS (SEDES)
   ========================================================================== */
DROP DATABASE IF EXISTS delegacion_madrid;
CREATE DATABASE delegacion_madrid;

DROP DATABASE IF EXISTS delegacion_barcelona;
CREATE DATABASE delegacion_barcelona;

DROP DATABASE IF EXISTS delegacion_coruna;
CREATE DATABASE delegacion_coruna;

DROP DATABASE IF EXISTS delegacion_sevilla;
CREATE DATABASE delegacion_sevilla;

/* ==========================================================================
   2. CREACIÓN DE TABLAS - SEDE 1: MADRID (Centro)
   Comunidades: Castilla-León, Castilla-La Mancha, Aragón, Madrid, La Rioja
   ========================================================================== */
USE delegacion_madrid;

-- 2.1 Tablas Base
CREATE TABLE PRODUCTOR (
    CodProductor VARCHAR(10) PRIMARY KEY,
    DNI VARCHAR(15) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(200)
);

CREATE TABLE VINO (
    CodVino VARCHAR(10) PRIMARY KEY,
    Marca VARCHAR(50) NOT NULL,
    Cosecha INT,
    Denominacion VARCHAR(50),
    Graduacion DECIMAL(4,2),
    Vinedo VARCHAR(50),
    Comunidad VARCHAR(50) NOT NULL,
    CantidadProd INT NOT NULL,
    Stock INT NOT NULL,
    CodProductor VARCHAR(10) NOT NULL,
    -- Restricción geográfica (Madrid solo gestiona sus vinos) [cite: 5]
    CONSTRAINT chk_vino_mad CHECK (Comunidad IN ('Castilla-León', 'Castilla-La Mancha', 'Aragón', 'Madrid', 'La Rioja')),
    CONSTRAINT fk_vino_prod FOREIGN KEY (CodProductor) REFERENCES PRODUCTOR(CodProductor),
    CONSTRAINT chk_stock_valido CHECK (Stock >= 0 AND Stock <= CantidadProd)
);

CREATE TABLE SUCURSAL (
    CodSucursal VARCHAR(10) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    Comunidad VARCHAR(50) NOT NULL,
    CodDirector VARCHAR(10), -- FK se añade luego
    -- Restricción geográfica [cite: 5]
    CONSTRAINT chk_suc_mad CHECK (Comunidad IN ('Castilla-León', 'Castilla-La Mancha', 'Aragón', 'Madrid', 'La Rioja'))
);

CREATE TABLE EMPLEADO (
    CodEmpleado VARCHAR(10) PRIMARY KEY,
    DNI VARCHAR(15) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    FechaInicio DATE NOT NULL,
    Salario DECIMAL(10, 2) NOT NULL,
    Direccion VARCHAR(200),
    CodSucursal VARCHAR(10) NOT NULL,
    CONSTRAINT fk_emp_suc FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal)
);

-- Relaciones circulares Sucursal-Empleado
ALTER TABLE SUCURSAL ADD CONSTRAINT fk_suc_dir FOREIGN KEY (CodDirector) REFERENCES EMPLEADO(CodEmpleado);
ALTER TABLE SUCURSAL ADD CONSTRAINT unq_director UNIQUE (CodDirector);

CREATE TABLE CLIENTE (
    CodCliente VARCHAR(10) PRIMARY KEY,
    DNI VARCHAR(15) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(200),
    Tipo CHAR(1) CHECK (Tipo IN ('A', 'B', 'C')),
    Comunidad VARCHAR(50) NOT NULL,
    -- Restricción geográfica [cite: 5]
    CONSTRAINT chk_cli_mad CHECK (Comunidad IN ('Castilla-León', 'Castilla-La Mancha', 'Aragón', 'Madrid', 'La Rioja'))
);

CREATE TABLE SUMINISTRO (
    CodCliente VARCHAR(10),
    CodSucursal VARCHAR(10),
    CodVino VARCHAR(10),
    Fecha DATE,
    Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodCliente, CodSucursal, CodVino, Fecha),
    FOREIGN KEY (CodCliente) REFERENCES CLIENTE(CodCliente),
    FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal),
    FOREIGN KEY (CodVino) REFERENCES VINO(CodVino)
);

CREATE TABLE PEDIDO (
    CodSucursal_Pide VARCHAR(10),
    CodSucursal_Recibe VARCHAR(10),
    CodVino VARCHAR(10),
    Fecha DATE,
    Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodSucursal_Pide, CodSucursal_Recibe, CodVino, Fecha)
    -- Nota: En un entorno real distribuido, las FK apuntarían a tablas remotas. 
    -- Aquí simulamos que se guardan los datos.
);

/* ==========================================================================
   3. CREACIÓN DE TABLAS - SEDE 2: BARCELONA (Levante)
   Comunidades: Cataluña, Baleares, País Valenciano, Murcia
   ========================================================================== */
USE delegacion_barcelona;

CREATE TABLE PRODUCTOR (
    CodProductor VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, Direccion VARCHAR(200)
);

CREATE TABLE VINO (
    CodVino VARCHAR(10) PRIMARY KEY, Marca VARCHAR(50) NOT NULL, Cosecha INT, Denominacion VARCHAR(50), Graduacion DECIMAL(4,2),
    Vinedo VARCHAR(50), Comunidad VARCHAR(50) NOT NULL, CantidadProd INT NOT NULL, Stock INT NOT NULL, CodProductor VARCHAR(10) NOT NULL,
    CONSTRAINT chk_vino_bcn CHECK (Comunidad IN ('Cataluña', 'Baleares', 'País Valenciano', 'Murcia')), -- [cite: 6]
    FOREIGN KEY (CodProductor) REFERENCES PRODUCTOR(CodProductor), CHECK (Stock >= 0 AND Stock <= CantidadProd)
);

CREATE TABLE SUCURSAL (
    CodSucursal VARCHAR(10) PRIMARY KEY, Nombre VARCHAR(50) NOT NULL, Ciudad VARCHAR(50) NOT NULL, Comunidad VARCHAR(50) NOT NULL,
    CodDirector VARCHAR(10),
    CONSTRAINT chk_suc_bcn CHECK (Comunidad IN ('Cataluña', 'Baleares', 'País Valenciano', 'Murcia')) -- [cite: 6]
);

CREATE TABLE EMPLEADO (
    CodEmpleado VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, FechaInicio DATE NOT NULL,
    Salario DECIMAL(10, 2) NOT NULL, Direccion VARCHAR(200), CodSucursal VARCHAR(10) NOT NULL,
    FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal)
);

ALTER TABLE SUCURSAL ADD CONSTRAINT fk_suc_dir FOREIGN KEY (CodDirector) REFERENCES EMPLEADO(CodEmpleado);
ALTER TABLE SUCURSAL ADD CONSTRAINT unq_director UNIQUE (CodDirector);

CREATE TABLE CLIENTE (
    CodCliente VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, Direccion VARCHAR(200),
    Tipo CHAR(1) CHECK (Tipo IN ('A', 'B', 'C')), Comunidad VARCHAR(50) NOT NULL,
    CONSTRAINT chk_cli_bcn CHECK (Comunidad IN ('Cataluña', 'Baleares', 'País Valenciano', 'Murcia')) -- [cite: 6]
);

CREATE TABLE SUMINISTRO (
    CodCliente VARCHAR(10), CodSucursal VARCHAR(10), CodVino VARCHAR(10), Fecha DATE, Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodCliente, CodSucursal, CodVino, Fecha),
    FOREIGN KEY (CodCliente) REFERENCES CLIENTE(CodCliente), FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal), FOREIGN KEY (CodVino) REFERENCES VINO(CodVino)
);

CREATE TABLE PEDIDO (
    CodSucursal_Pide VARCHAR(10), CodSucursal_Recibe VARCHAR(10), CodVino VARCHAR(10), Fecha DATE, Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodSucursal_Pide, CodSucursal_Recibe, CodVino, Fecha)
);

/* ==========================================================================
   4. CREACIÓN DE TABLAS - SEDE 3: LA CORUÑA (Norte)
   Comunidades: Galicia, Asturias, Cantabria, País Vasco, Navarra
   ========================================================================== */
USE delegacion_coruna;

CREATE TABLE PRODUCTOR (
    CodProductor VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, Direccion VARCHAR(200)
);

CREATE TABLE VINO (
    CodVino VARCHAR(10) PRIMARY KEY, Marca VARCHAR(50) NOT NULL, Cosecha INT, Denominacion VARCHAR(50), Graduacion DECIMAL(4,2),
    Vinedo VARCHAR(50), Comunidad VARCHAR(50) NOT NULL, CantidadProd INT NOT NULL, Stock INT NOT NULL, CodProductor VARCHAR(10) NOT NULL,
    CONSTRAINT chk_vino_cor CHECK (Comunidad IN ('Galicia', 'Asturias', 'Cantabria', 'País Vasco', 'Navarra')), -- [cite: 7]
    FOREIGN KEY (CodProductor) REFERENCES PRODUCTOR(CodProductor), CHECK (Stock >= 0 AND Stock <= CantidadProd)
);

CREATE TABLE SUCURSAL (
    CodSucursal VARCHAR(10) PRIMARY KEY, Nombre VARCHAR(50) NOT NULL, Ciudad VARCHAR(50) NOT NULL, Comunidad VARCHAR(50) NOT NULL,
    CodDirector VARCHAR(10),
    CONSTRAINT chk_suc_cor CHECK (Comunidad IN ('Galicia', 'Asturias', 'Cantabria', 'País Vasco', 'Navarra')) -- [cite: 7]
);

CREATE TABLE EMPLEADO (
    CodEmpleado VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, FechaInicio DATE NOT NULL,
    Salario DECIMAL(10, 2) NOT NULL, Direccion VARCHAR(200), CodSucursal VARCHAR(10) NOT NULL,
    FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal)
);

ALTER TABLE SUCURSAL ADD CONSTRAINT fk_suc_dir FOREIGN KEY (CodDirector) REFERENCES EMPLEADO(CodEmpleado);
ALTER TABLE SUCURSAL ADD CONSTRAINT unq_director UNIQUE (CodDirector);

CREATE TABLE CLIENTE (
    CodCliente VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, Direccion VARCHAR(200),
    Tipo CHAR(1) CHECK (Tipo IN ('A', 'B', 'C')), Comunidad VARCHAR(50) NOT NULL,
    CONSTRAINT chk_cli_cor CHECK (Comunidad IN ('Galicia', 'Asturias', 'Cantabria', 'País Vasco', 'Navarra')) -- [cite: 7]
);

CREATE TABLE SUMINISTRO (
    CodCliente VARCHAR(10), CodSucursal VARCHAR(10), CodVino VARCHAR(10), Fecha DATE, Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodCliente, CodSucursal, CodVino, Fecha),
    FOREIGN KEY (CodCliente) REFERENCES CLIENTE(CodCliente), FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal), FOREIGN KEY (CodVino) REFERENCES VINO(CodVino)
);

CREATE TABLE PEDIDO (
    CodSucursal_Pide VARCHAR(10), CodSucursal_Recibe VARCHAR(10), CodVino VARCHAR(10), Fecha DATE, Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodSucursal_Pide, CodSucursal_Recibe, CodVino, Fecha)
);

/* ==========================================================================
   5. CREACIÓN DE TABLAS - SEDE 4: SEVILLA (Sur)
   Comunidades: Andalucía, Extremadura, Canarias, Ceuta, Melilla
   ========================================================================== */
USE delegacion_sevilla;

CREATE TABLE PRODUCTOR (
    CodProductor VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, Direccion VARCHAR(200)
);

CREATE TABLE VINO (
    CodVino VARCHAR(10) PRIMARY KEY, Marca VARCHAR(50) NOT NULL, Cosecha INT, Denominacion VARCHAR(50), Graduacion DECIMAL(4,2),
    Vinedo VARCHAR(50), Comunidad VARCHAR(50) NOT NULL, CantidadProd INT NOT NULL, Stock INT NOT NULL, CodProductor VARCHAR(10) NOT NULL,
    CONSTRAINT chk_vino_sev CHECK (Comunidad IN ('Andalucía', 'Extremadura', 'Canarias', 'Ceuta', 'Melilla')), -- [cite: 8]
    FOREIGN KEY (CodProductor) REFERENCES PRODUCTOR(CodProductor), CHECK (Stock >= 0 AND Stock <= CantidadProd)
);

CREATE TABLE SUCURSAL (
    CodSucursal VARCHAR(10) PRIMARY KEY, Nombre VARCHAR(50) NOT NULL, Ciudad VARCHAR(50) NOT NULL, Comunidad VARCHAR(50) NOT NULL,
    CodDirector VARCHAR(10),
    CONSTRAINT chk_suc_sev CHECK (Comunidad IN ('Andalucía', 'Extremadura', 'Canarias', 'Ceuta', 'Melilla')) -- [cite: 8]
);

CREATE TABLE EMPLEADO (
    CodEmpleado VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, FechaInicio DATE NOT NULL,
    Salario DECIMAL(10, 2) NOT NULL, Direccion VARCHAR(200), CodSucursal VARCHAR(10) NOT NULL,
    FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal)
);

ALTER TABLE SUCURSAL ADD CONSTRAINT fk_suc_dir FOREIGN KEY (CodDirector) REFERENCES EMPLEADO(CodEmpleado);
ALTER TABLE SUCURSAL ADD CONSTRAINT unq_director UNIQUE (CodDirector);

CREATE TABLE CLIENTE (
    CodCliente VARCHAR(10) PRIMARY KEY, DNI VARCHAR(15) NOT NULL, Nombre VARCHAR(100) NOT NULL, Direccion VARCHAR(200),
    Tipo CHAR(1) CHECK (Tipo IN ('A', 'B', 'C')), Comunidad VARCHAR(50) NOT NULL,
    CONSTRAINT chk_cli_sev CHECK (Comunidad IN ('Andalucía', 'Extremadura', 'Canarias', 'Ceuta', 'Melilla')) -- [cite: 8]
);

CREATE TABLE SUMINISTRO (
    CodCliente VARCHAR(10), CodSucursal VARCHAR(10), CodVino VARCHAR(10), Fecha DATE, Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodCliente, CodSucursal, CodVino, Fecha),
    FOREIGN KEY (CodCliente) REFERENCES CLIENTE(CodCliente), FOREIGN KEY (CodSucursal) REFERENCES SUCURSAL(CodSucursal), FOREIGN KEY (CodVino) REFERENCES VINO(CodVino)
);

CREATE TABLE PEDIDO (
    CodSucursal_Pide VARCHAR(10), CodSucursal_Recibe VARCHAR(10), CodVino VARCHAR(10), Fecha DATE, Cantidad INT CHECK (Cantidad > 0),
    PRIMARY KEY (CodSucursal_Pide, CodSucursal_Recibe, CodVino, Fecha)
);

USE delegacion_madrid;

DELIMITER $$

CREATE TRIGGER trg_salario_no_baja_mad
BEFORE UPDATE ON EMPLEADO
FOR EACH ROW
BEGIN
    IF NEW.Salario < OLD.Salario THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El salario de un empleado nunca puede disminuir.';
    END IF;
END$$

CREATE TRIGGER trg_fecha_suministro_mad
BEFORE INSERT ON SUMINISTRO
FOR EACH ROW
BEGIN
    DECLARE v_ultima_fecha DATE;
    
    SELECT MAX(Fecha) INTO v_ultima_fecha
    FROM SUMINISTRO
    WHERE CodCliente = NEW.CodCliente;

    IF v_ultima_fecha IS NOT NULL AND NEW.Fecha < v_ultima_fecha THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La fecha del suministro debe ser igual o posterior al último suministro.';
    END IF;
END$$

CREATE TRIGGER trg_borrar_vino_mad
BEFORE DELETE ON VINO
FOR EACH ROW
BEGIN
    DECLARE v_total INT;
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_total FROM SUMINISTRO WHERE CodVino = OLD.CodVino;
    
    IF v_total > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede eliminar vino con suministros.';
    END IF;
END$$

DELIMITER ;


/* ==========================================================================
   CREACIÓN DE USUARIOS PARA CADA SEDE (SEGURIDAD DISTRIBUIDA)
   ========================================================================== */

-- 1. USUARIO PARA MADRID (Solo tiene poder en delegacion_madrid)
DROP USER IF EXISTS 'admin_madrid'@'localhost';
CREATE USER 'admin_madrid'@'localhost' IDENTIFIED BY 'madrid1234';
GRANT ALL PRIVILEGES ON delegacion_madrid.* TO 'admin_madrid'@'localhost';

-- 2. USUARIO PARA BARCELONA (Solo tiene poder en delegacion_barcelona)
DROP USER IF EXISTS 'admin_barcelona'@'localhost';
CREATE USER 'admin_barcelona'@'localhost' IDENTIFIED BY 'barna1234';
GRANT ALL PRIVILEGES ON delegacion_barcelona.* TO 'admin_barcelona'@'localhost';

-- 3. USUARIO PARA CORUÑA (Solo tiene poder en delegacion_coruna)
DROP USER IF EXISTS 'admin_coruna'@'localhost';
CREATE USER 'admin_coruna'@'localhost' IDENTIFIED BY 'coruna1234';
GRANT ALL PRIVILEGES ON delegacion_coruna.* TO 'admin_coruna'@'localhost';

-- 4. USUARIO PARA SEVILLA (Solo tiene poder en delegacion_sevilla)
DROP USER IF EXISTS 'admin_sevilla'@'localhost';
CREATE USER 'admin_sevilla'@'localhost' IDENTIFIED BY 'sevilla1234';
GRANT ALL PRIVILEGES ON delegacion_sevilla.* TO 'admin_sevilla'@'localhost';

-- Aplicar cambios de permisos
FLUSH PRIVILEGES;

/* ==========================================================================
   6. CREACIÓN DE VISTAS (CAPA DE TRANSPARENCIA)
   Se crean en la sede central (Madrid) o en cada una, según el diseño.
   Aquí las crearemos en delegacion_madrid para cumplir la Evidencia 4.
   ========================================================================== */
USE delegacion_madrid;

-- Vista para unificar todos los CLIENTES
CREATE OR REPLACE VIEW v_cliente AS
SELECT * FROM delegacion_madrid.cliente
UNION ALL
SELECT * FROM delegacion_barcelona.cliente
UNION ALL
SELECT * FROM delegacion_coruna.cliente
UNION ALL
SELECT * FROM delegacion_sevilla.cliente;

-- Vista para unificar todos los VINOS (Opcional, pero recomendada)
CREATE OR REPLACE VIEW v_vino AS
SELECT * FROM delegacion_madrid.vino
UNION ALL
SELECT * FROM delegacion_barcelona.vino
UNION ALL
SELECT * FROM delegacion_coruna.vino
UNION ALL
SELECT * FROM delegacion_sevilla.vino;


 -- use trg_salario_no_baja_mad
 
 -- EVIDENCIA 6:
 USE delegacion_madrid;

DROP PROCEDURE IF EXISTS PR_INS_EMPLEADO;

DELIMITER $$

CREATE PROCEDURE PR_INS_EMPLEADO(
    IN p_Delegacion VARCHAR(20), -- Parámetro para decidir el fragmento (Sede)
    IN p_CodEmpleado VARCHAR(10),
    IN p_DNI VARCHAR(15),
    IN p_Nombre VARCHAR(100),
    IN p_FechaInicio DATE,
    IN p_Salario DECIMAL(10, 2),
    IN p_Direccion VARCHAR(200),
    IN p_CodSucursal VARCHAR(10)
)
BEGIN
    -- Lógica de Fragmentación usando CASE como pide la evidencia
    CASE p_Delegacion
        WHEN 'Madrid' THEN
            INSERT INTO delegacion_madrid.empleado (CodEmpleado, DNI, Nombre, FechaInicio, Salario, Direccion, CodSucursal)
            VALUES (p_CodEmpleado, p_DNI, p_Nombre, p_FechaInicio, p_Salario, p_Direccion, p_CodSucursal);
            
        WHEN 'Barcelona' THEN
            INSERT INTO delegacion_barcelona.empleado (CodEmpleado, DNI, Nombre, FechaInicio, Salario, Direccion, CodSucursal)
            VALUES (p_CodEmpleado, p_DNI, p_Nombre, p_FechaInicio, p_Salario, p_Direccion, p_CodSucursal);
            
        WHEN 'Coruna' THEN
            INSERT INTO delegacion_coruna.empleado (CodEmpleado, DNI, Nombre, FechaInicio, Salario, Direccion, CodSucursal)
            VALUES (p_CodEmpleado, p_DNI, p_Nombre, p_FechaInicio, p_Salario, p_Direccion, p_CodSucursal);
            
        WHEN 'Sevilla' THEN
            INSERT INTO delegacion_sevilla.empleado (CodEmpleado, DNI, Nombre, FechaInicio, Salario, Direccion, CodSucursal)
            VALUES (p_CodEmpleado, p_DNI, p_Nombre, p_FechaInicio, p_Salario, p_Direccion, p_CodSucursal);
            
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Delegación no válida para la fragmentación.';
    END CASE;
END$$

DELIMITER ;
 
 /* ==========================================================================
   7. CARGA DE DATOS DE PRUEBA (PARA EVIDENCIA 7)
   ========================================================================== */

-- 1. Insertar PRODUCTORES (Replicación Total: Los mismos 6 en todas las sedes)
-- Se insertan en las 4 bases de datos para simular que es una tabla global.
INSERT INTO delegacion_madrid.productor (CodProductor, DNI, Nombre, Direccion) VALUES 
('P1', '111A', 'Bodegas Madrid', 'Calle A'), ('P2', '222B', 'Vinos BCN', 'Calle B'), 
('P3', '333C', 'Viñedos Galicia', 'Calle C'), ('P4', '444D', 'Sur Vinos', 'Calle D'), 
('P5', '555E', 'Rioja Alta', 'Calle E'), ('P6', '666F', 'Ribera Duero', 'Calle F');

INSERT INTO delegacion_barcelona.productor SELECT * FROM delegacion_madrid.productor;
INSERT INTO delegacion_coruna.productor SELECT * FROM delegacion_madrid.productor;
INSERT INTO delegacion_sevilla.productor SELECT * FROM delegacion_madrid.productor;

-- 2. Insertar SUCURSALES (Una por delegación para probar localidad)
INSERT INTO delegacion_madrid.sucursal (CodSucursal, Nombre, Ciudad, Comunidad) VALUES ('S-MAD', 'Sucursal Centro', 'Madrid', 'Madrid');
INSERT INTO delegacion_barcelona.sucursal (CodSucursal, Nombre, Ciudad, Comunidad) VALUES ('S-BCN', 'Sucursal Levante', 'Barcelona', 'Cataluña');
INSERT INTO delegacion_coruna.sucursal (CodSucursal, Nombre, Ciudad, Comunidad) VALUES ('S-COR', 'Sucursal Norte', 'A Coruña', 'Galicia');
INSERT INTO delegacion_sevilla.sucursal (CodSucursal, Nombre, Ciudad, Comunidad) VALUES ('S-SEV', 'Sucursal Sur', 'Sevilla', 'Andalucía');

-- 3. Insertar CLIENTES (Fragmentación: 8 clientes repartidos según su comunidad)
-- Madrid (2 Clientes)
INSERT INTO delegacion_madrid.cliente (CodCliente, DNI, Nombre, Tipo, Comunidad) VALUES 
('C1', '11A', 'Cliente Madrid 1', 'A', 'Madrid'),
('C2', '22B', 'Cliente Rioja 1', 'B', 'La Rioja');

-- Barcelona (2 Clientes)
INSERT INTO delegacion_barcelona.cliente (CodCliente, DNI, Nombre, Tipo, Comunidad) VALUES 
('C3', '33C', 'Cliente BCN 1', 'A', 'Cataluña'),
('C4', '44D', 'Cliente Valencia 1', 'C', 'País Valenciano');

-- Coruña (2 Clientes)
INSERT INTO delegacion_coruna.cliente (CodCliente, DNI, Nombre, Tipo, Comunidad) VALUES 
('C5', '55E', 'Cliente Galicia 1', 'B', 'Galicia'),
('C6', '66F', 'Cliente Asturias 1', 'A', 'Asturias');

-- Sevilla (2 Clientes)
INSERT INTO delegacion_sevilla.cliente (CodCliente, DNI, Nombre, Tipo, Comunidad) VALUES 
('C7', '77G', 'Cliente Sevilla 1', 'A', 'Andalucía'),
('C8', '88H', 'Cliente Canarias 1', 'B', 'Canarias');

USE delegacion_madrid;

-- 1. CREAR LAS VISTAS FALTANTES (Capa de Transparencia Completa)
CREATE OR REPLACE VIEW v_sucursal AS
SELECT * FROM delegacion_madrid.sucursal UNION ALL
SELECT * FROM delegacion_barcelona.sucursal UNION ALL
SELECT * FROM delegacion_coruna.sucursal UNION ALL
SELECT * FROM delegacion_sevilla.sucursal;

CREATE OR REPLACE VIEW v_suministro AS
SELECT * FROM delegacion_madrid.suministro UNION ALL
SELECT * FROM delegacion_barcelona.suministro UNION ALL
SELECT * FROM delegacion_coruna.suministro UNION ALL
SELECT * FROM delegacion_sevilla.suministro;

CREATE OR REPLACE VIEW v_productor AS
SELECT * FROM delegacion_madrid.productor; -- Como está replicada, basta leer de uno

-- 2. INSERTAR DATOS ESPECÍFICOS PARA EVIDENCIA 8 y 9
-- Cliente "Hipercor" en Andalucía (Sevilla)
INSERT INTO delegacion_sevilla.cliente (CodCliente, DNI, Nombre, Tipo, Comunidad) 
VALUES ('C-HIPER', 'B123456', 'Hipercor', 'A', 'Andalucía');

-- Sucursal "Tacita de Plata" en Cádiz (Delegación Sevilla)
INSERT INTO delegacion_sevilla.sucursal (CodSucursal, Nombre, Ciudad, Comunidad) 
VALUES ('S-CADIZ', 'Tacita de Plata', 'Cádiz', 'Andalucía');

-- Vino "Tablas de Daimiel" (Productor de Madrid/Mancha)
INSERT INTO delegacion_madrid.vino (CodVino, Marca, Cosecha, Denominacion, Graduacion, Vinedo, Comunidad, CantidadProd, Stock, CodProductor) 
VALUES ('V-DAIM', 'Tablas de Daimiel', 2015, 'D.O. Mancha', 13.5, 'La Mancha', 'Castilla-La Mancha', 1000, 500, 'P1');

-- Suministro específico del 15 de julio de 2015
INSERT INTO delegacion_sevilla.suministro (CodCliente, CodSucursal, CodVino, Fecha, Cantidad) 
VALUES ('C-HIPER', 'S-CADIZ', 'V-DAIM', '2015-07-15', 50);

-- Datos para Evidencia 9 (Productor 4 - Rias Baixas)
-- Productor 4
INSERT INTO delegacion_madrid.productor (CodProductor, DNI, Nombre, Direccion) 
VALUES ('P4', '4444D', 'Bodegas del Norte', 'Galicia'); -- Replicar si es necesario en los otros nodos
-- Vino Rias Baixas (Gestionado por Coruña)
INSERT INTO delegacion_coruna.vino (CodVino, Marca, Cosecha, Denominacion, Graduacion, Vinedo, Comunidad, CantidadProd, Stock, CodProductor)
VALUES ('V-RIAS', 'Rias Baixas', 2020, 'Albariño', 12.0, 'Salnés', 'Galicia', 500, 200, 'P4');
-- Suministro a cliente de Levante (Barcelona)
INSERT INTO delegacion_barcelona.suministro (CodCliente, CodSucursal, CodVino, Fecha, Cantidad)
VALUES ('C3', 'S-BCN', 'V-RIAS', '2023-01-01', 100);
 
 
 
 
 