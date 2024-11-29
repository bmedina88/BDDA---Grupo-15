--ENTREGA 3: Creaciòn de la base de datos. 
--FECHA DE ENTREGA: 01/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

USE tempdb;
GO

IF (EXISTS (SELECT * FROM sys.databases WHERE name='Com5600G15')  )
BEGIN
	ALTER DATABASE Com5600G15 set single_user with rollback immediate;
	DROP DATABASE Com5600G15;
END;
GO


CREATE DATABASE Com5600G15;
GO
USE Com5600G15;

--Esquemas
GO
CREATE SCHEMA Venta;
GO
CREATE SCHEMA Producto;
GO
CREATE SCHEMA Super;
GO
create schema NotaCredito;
go
--Tablas

-- Verificar si la tabla existe y eliminarla
IF OBJECT_ID(N'Super.Sucursal', N'U') IS NOT NULL
BEGIN
    DROP TABLE Super.Sucursal;
END;

CREATE TABLE Super.Sucursal(
	idSucursal int IDENTITY(1,1) PRIMARY KEY,
	sucursal varchar(30),
	ciudad varchar(30),
	direccion varchar(100),
	horario varchar(80),
	telefono varchar(20)
);
go

IF OBJECT_ID(N'Venta.MedioPago', N'U') IS NOT NULL
BEGIN
    DROP TABLE Venta.MedioPago;
END;
CREATE TABLE Venta.MedioPago(
	idMedioPago int IDENTITY(1,1) PRIMARY KEY,
	descripcion varchar(50)
);
go

IF OBJECT_ID(N'Super.TipoCliente', N'U') IS NOT NULL
BEGIN
    DROP TABLE Super.TipoCliente;
END;
CREATE TABLE Super.TipoCliente(
	idTipoCliente int IDENTITY(1,1) PRIMARY KEY,
	descripcion varchar(50),
	genero varchar(50)
);
go
IF OBJECT_ID(N'Producto.Categoria', N'U') IS NOT NULL
BEGIN
    DROP TABLE Producto.Categoria;
END;
CREATE TABLE Producto.Categoria(
	idCategoria int IDENTITY(1,1) PRIMARY KEY,
	nombre varchar(50)
);
go
IF OBJECT_ID(N'Super.Empleado', N'U') IS NOT NULL
BEGIN
    DROP TABLE Super.Empleado;
END;
CREATE TABLE Super.Empleado(
	idEmpleado int PRIMARY KEY,
	dni varchar(max),
	cuil varchar(max),
	email varchar(max),
	cargo varchar(30),
	turno varchar(30),
	sucursal int REFERENCES Super.Sucursal(idSucursal)
);
go
IF OBJECT_ID(N'Producto.Producto', N'U') IS NOT NULL
BEGIN
    DROP TABLE Producto.Producto;
END;
CREATE TABLE Producto.Producto(
	idProducto int IDENTITY(1,1) primary key,
	categoria int REFERENCES Producto.Categoria(idCategoria),
	nombre varchar(150),
	precio DECIMAL(10, 2),
	moneda varchar(10)

);
go
IF OBJECT_ID(N'Venta.Factura', N'U') IS NOT NULL
BEGIN
    DROP TABLE Venta.Factura;
END;
CREATE TABLE Venta.Factura(
	id int IDENTITY(1,1) PRIMARY KEY,
	idfactura varchar(11),
	fecha date,
	hora time,
	idpago varchar(50),
	medioPago int REFERENCES Venta.MedioPago(idMedioPago),
	empleado int REFERENCES Super.Empleado(idEmpleado),
	cliente int REFERENCES Super.TipoCliente,
	tipoFactura char(2)
	);
go

IF OBJECT_ID(N'Venta.VentaDetalle', N'U') IS NOT NULL
BEGIN
    DROP TABLE Venta.VentaDetalle;
END;
CREATE TABLE Venta.VentaDetalle(
	idVenta int IDENTITY(1,1) PRIMARY KEY,
	producto int References producto.producto(idProducto),
	idfactura int REFERENCES Venta.Factura(id),
	cantidad int,
	precioUnitario DECIMAL(10, 2),
	moneda varchar(10)
);
go



IF OBJECT_ID(N'NotaCredito.NotaCredito', N'U') IS NOT NULL
BEGIN
    DROP TABLE NotaCredito.NotaCredito;
END;
CREATE TABLE NotaCredito.NotaCredito (
    idNotaCredito INT IDENTITY(1,1) PRIMARY KEY,
    idfactura INT references Venta.Factura(id),
	idproducto int references Producto.Producto(idProducto),
    cantidad int NOT NULL,
    fechaCreacion DATETIME DEFAULT GETDATE(),
	estado int not null
);
go

--STORE PROCEDURE INSERCIÓN DATOS

CREATE OR ALTER PROCEDURE Super.InsertarSucursal
    @sucursal VARCHAR(50),
    @ciudad VARCHAR(50),
    @direccion VARCHAR(50),
    @horario VARCHAR(50),
    @telefono VARCHAR(50)
AS
BEGIN
    -- Verificar si ya existe la sucursal
    IF NOT EXISTS (
        SELECT 1
        FROM Super.Sucursal
        WHERE sucursal = @sucursal AND ciudad = @ciudad
    )
    BEGIN
        INSERT INTO Super.Sucursal (sucursal, ciudad, direccion, horario, telefono)
        VALUES (@sucursal, @ciudad, @direccion, @horario, @telefono);
    END
    ELSE
    BEGIN
        RAISERROR('Error: La Sucursal ya existe.', 16, 1);

    END
END;
GO


CREATE OR ALTER PROCEDURE Venta.InsertarMedioPago
    @descripcion VARCHAR(50)
AS
BEGIN
    -- Verificar si ya existe el medio de pago
    IF NOT EXISTS (
        SELECT 1
        FROM Venta.MedioPago
        WHERE descripcion = @descripcion
    )
    BEGIN
        INSERT INTO Venta.MedioPago (descripcion)
        VALUES (@descripcion);
    END
    ELSE
    BEGIN
        RAISERROR('Error: el medio de pago ya existe.', 16, 1);
    END
END;
GO



CREATE OR ALTER PROCEDURE Super.InsertarTipoCliente
    @descripcion VARCHAR(50),
    @genero VARCHAR(50)
AS
BEGIN
    -- Verificar si ya existe el tipo de cliente
    IF NOT EXISTS (
        SELECT 1
        FROM Super.TipoCliente
        WHERE descripcion = @descripcion AND genero = @genero
    )
    BEGIN
        INSERT INTO Super.TipoCliente (descripcion, genero)
        VALUES (@descripcion, @genero);
    END
    ELSE
    BEGIN
        RAISERROR('Error: el tipo de cliente ya existe.', 16, 1);
    END
END;
GO




CREATE OR ALTER PROCEDURE Producto.InsertarCategoria
    @nombre NVARCHAR(50)
AS
BEGIN
    -- Verificar si ya existe la categoría
    IF NOT EXISTS (
        SELECT 1
        FROM Producto.Categoria
        WHERE nombre = @nombre
    )
    BEGIN
        INSERT INTO Producto.Categoria (nombre)
        VALUES (@nombre);
    END
    ELSE
    BEGIN
        RAISERROR('Error: La categoria ya existe.', 16, 1);
    END
END;
GO



CREATE OR ALTER PROCEDURE Super.InsertarEmpleado
    @idEmpleado INT,
    @dni VARCHAR(9),
    @cuil VARCHAR(15),
    @email NVARCHAR(50),
    @cargo VARCHAR(15),
    @turno VARCHAR(15),
    @sucursal INT
AS
BEGIN
    -- Verificar si el empleado ya existe
    IF NOT EXISTS (
        SELECT 1
        FROM Super.Empleado
        WHERE idEmpleado = @idEmpleado OR dni = @dni
    )
    BEGIN
        INSERT INTO Super.Empleado (idEmpleado, dni, cuil, email, cargo, turno, sucursal)
        VALUES (@idEmpleado, @dni, @cuil, @email, @cargo, @turno, @sucursal);
    END
    ELSE
    BEGIN
        RAISERROR('Error: El empleado ya existe.', 16, 1);
    END
END;
GO



CREATE OR ALTER PROCEDURE Producto.InsertarProducto
    @idProducto INT,
    @categoria INT,
    @nombre NVARCHAR(255),
    @precio DECIMAL(10, 2),
	@moneda varchar(10)
AS
BEGIN
    -- Verificar si el producto ya existe
    IF NOT EXISTS (
        SELECT 1
        FROM Producto.Producto
        WHERE idProducto = @idProducto OR nombre = @nombre
    )
    BEGIN
        INSERT INTO Producto.Producto (idProducto, categoria, nombre, precio,moneda)
        VALUES (@idProducto, @categoria, @nombre, @precio,@moneda);
    END
    ELSE
    BEGIN
        update Producto.Producto
		set categoria = @categoria,
		nombre=@nombre,
		precio = @precio,
		moneda = @moneda
		WHERE idProducto = @idProducto OR nombre = @nombre
    END
END;
GO



CREATE OR ALTER PROCEDURE Venta.InsertarFactura
    @idFactura VARCHAR(11),
    @fecha DATE,
    @hora TIME,
    @idPago VARCHAR(50),
    @medioPago INT,
    @empleado INT,
	@cliente INT,
	@tipoFactura char(2)
AS
BEGIN
    -- Verificar si la factura ya existe
    IF NOT EXISTS (
        SELECT 1
        FROM Venta.Factura
        WHERE idFactura = @idFactura
    )
    BEGIN
        INSERT INTO Venta.Factura (idFactura, fecha, hora, idPago, medioPago, empleado,cliente,tipoFactura)
        VALUES (@idFactura, @fecha, @hora, @idPago, @medioPago, @empleado,@cliente,@tipoFactura);
    END
    ELSE
    BEGIN
        RAISERROR('Error: La factura ya existe.', 16, 1);
    END
END;
GO






CREATE OR ALTER PROCEDURE Venta.InsertarVentaDetalle
    @producto INT,
    @idFactura INT,
    @cantidad INT
AS
BEGIN
declare @precioUnitario decimal(10,2);
declare @moneda varchar(10);
select @precioUnitario = precio from Producto.Producto where idProducto = @producto
select @moneda = moneda from Producto.Producto where idProducto = @producto
    -- Verificar si el detalle de la venta ya existe
    IF NOT EXISTS (
        SELECT 1
        FROM Venta.VentaDetalle
        WHERE producto = @producto AND idFactura = @idFactura
    )
    BEGIN

        INSERT INTO Venta.VentaDetalle (producto, idFactura, cantidad,precioUnitario,moneda)
        VALUES (@producto, @idFactura, @cantidad,@precioUnitario,@moneda);
    END
    ELSE
    BEGIN
        update Venta.VentaDetalle
		set cantidad = cantidad + @cantidad
		WHERE producto = @producto AND idFactura = @idFactura
    END
END;
GO


-------stores procedures para update------

CREATE OR ALTER PROCEDURE super.ModificarSucursal
    @idSucursal INT,
    @sucursal VARCHAR(30),
    @ciudad VARCHAR(30),
    @direccion VARCHAR(50),
    @horario VARCHAR(20),
    @telefono VARCHAR(20)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Super.Sucursal
        WHERE idSucursal = @idSucursal
    )
    BEGIN
        UPDATE Super.Sucursal
        SET sucursal = @sucursal,
            ciudad = @ciudad,
            direccion = @direccion,
            horario = @horario,
            telefono = @telefono
        WHERE idSucursal = @idSucursal;
    END
    ELSE
    BEGIN
        RAISERROR('Error: La Sucursal no existe.', 16, 1);
    END
END;

go



CREATE OR ALTER PROCEDURE venta.ModificarMedioPago
    @idMedioPago INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Venta.MedioPago
        WHERE idMedioPago = @idMedioPago
    )
    BEGIN
        UPDATE Venta.MedioPago
        SET descripcion = @descripcion
        WHERE idMedioPago = @idMedioPago;
    END
    ELSE
    BEGIN
        RAISERROR('Error: el medio de pago no existe.', 16, 1);
    END
END;
go

CREATE OR ALTER PROCEDURE super.ModificarEmpleado
    @idEmpleado INT,
    @email VARCHAR(50),
    @cargo VARCHAR(15),
    @turno VARCHAR(15),
    @sucursal INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Super.Empleado
        WHERE idEmpleado = @idEmpleado
    )
    BEGIN
        UPDATE Super.Empleado
        SET email = @email,
            cargo = @cargo,
            turno = @turno,
            sucursal = @sucursal
        WHERE idEmpleado = @idEmpleado;
    END
    ELSE
    BEGIN
        RAISERROR('Error: el empleado no existe.', 16, 1);
    END
END;
go

CREATE OR ALTER PROCEDURE producto.ModificarProducto
    @idProducto INT,
    @categoria INT,
    @nombre VARCHAR(255),
    @precio DECIMAL(10,2),
	@moneda varchar(10)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Producto.Producto
        WHERE idProducto = @idProducto
    )
    BEGIN
        UPDATE Producto.Producto
        SET categoria = @categoria,
            nombre = @nombre,
            precio = @precio,
			moneda = @moneda
        WHERE idProducto = @idProducto;
    END
    ELSE
    BEGIN
        RAISERROR('Error: el producto no existe.', 16, 1);
    END
END;
go


CREATE OR ALTER PROCEDURE NotaCredito.ModificarFactura
    @id INT,
    @fecha DATE,
    @hora TIME,
    @idPago NVARCHAR(50),
    @medioPago INT,
    @empleado INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Venta.Factura
        WHERE id = @id
    )
    BEGIN
        UPDATE Venta.Factura
        SET fecha = @fecha,
            hora = @hora,
            idPago = @idPago,
            medioPago = @medioPago,
            empleado = @empleado
        WHERE id = @id;
    END
    ELSE
    BEGIN
        RAISERROR('Error: La factura no existe.', 16, 1);
    END
END;
go


CREATE OR ALTER PROCEDURE super.ModificarTipoCliente
    @idTipoCliente INT,
    @descripcion VARCHAR(50),
    @genero VARCHAR(20)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Super.TipoCliente
        WHERE idTipoCliente = @idTipoCliente
    )
    BEGIN
        UPDATE Super.TipoCliente
        SET descripcion = @descripcion,
            genero = @genero
        WHERE idTipoCliente = @idTipoCliente;
    END
    ELSE
    BEGIN
        RAISERROR('Error: El tipo de cliente no existe.', 16, 1);
    END
END;
go

CREATE OR ALTER PROCEDURE producto.ModificarCategoria
    @idCategoria INT,
    @nombre VARCHAR(30)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Producto.Categoria
        WHERE idCategoria = @idCategoria
    )
    BEGIN
        UPDATE Producto.Categoria
        SET nombre = @nombre
        WHERE idCategoria = @idCategoria;
    END
    ELSE
    BEGIN
        RAISERROR('Error: La categoria no existe.', 16, 1);
    END
END;
go


CREATE OR ALTER PROCEDURE NotaCredito.ModificarVentaDetalle
    @idVenta INT,
    @producto INT,
    @cantidad INT
AS
BEGIN
    -- Verificar si el registro existe
    IF EXISTS (
        SELECT 1
        FROM Venta.VentaDetalle
        WHERE idVenta = @idVenta
    )
    BEGIN
	if Exists(
			select 1
			from Producto.Producto
			where @producto = idProducto
			)
			begin
				declare @precioUnitario decimal(10,2);
				declare @moneda varchar(10);
				select @precioUnitario = precio from Producto.Producto where @producto = idProducto
				select @moneda = moneda from Producto.Producto where @producto = idProducto
				UPDATE Venta.VentaDetalle
				SET producto = @producto,
				cantidad = @cantidad,
				precioUnitario = @precioUnitario,
				moneda= @moneda
				WHERE idVenta = @idVenta;
			end
			else
			begin
			RAISERROR('Error: el Producto no Existe', 16, 1);
			end
    END
    ELSE
    BEGIN
       RAISERROR('Error: el detalle de venta no existe.', 16, 1);
    END
END;
go

-----------------------------------Stores procedures para eliminar----------------

CREATE OR ALTER PROCEDURE super.EliminarSucursal
    @idSucursal INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Super.Sucursal
        WHERE idSucursal = @idSucursal
    )
    BEGIN
        DELETE FROM Super.Sucursal
        WHERE idSucursal = @idSucursal;
    END
    ELSE
    BEGIN
        RAISERROR('Error: La Sucursal no existe.', 16, 1);
    END
END;
go

CREATE OR ALTER PROCEDURE venta.EliminarMedioPago
    @idMedioPago INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Venta.MedioPago
        WHERE idMedioPago = @idMedioPago
    )
    BEGIN
        DELETE FROM Venta.MedioPago
        WHERE idMedioPago = @idMedioPago;
    END
    ELSE
    BEGIN
        RAISERROR('Error: el medio de pago no existe.', 16, 1);
    END
END;
go


CREATE OR ALTER PROCEDURE super.EliminarEmpleado
    @idEmpleado INT
AS
BEGIN
    -- Verificar si el empleado existe
    IF EXISTS (
        SELECT 1
        FROM Super.Empleado
        WHERE idEmpleado = @idEmpleado
    )
    BEGIN
        -- Eliminar el empleado
        DELETE FROM Super.Empleado
        WHERE idEmpleado = @idEmpleado;
    END
    ELSE
    BEGIN
        RAISERROR('Error: El empleado no existe.', 16, 1);
    END
END;
GO


CREATE OR ALTER PROCEDURE producto.EliminarProducto
    @idProducto INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Producto.Producto
        WHERE idProducto = @idProducto
    )
    BEGIN
        DELETE FROM Producto.Producto
        WHERE idProducto = @idProducto;
    END
    ELSE
    BEGIN
        RAISERROR('Error: El producto no existe.', 16, 1);
    END
END;
go


CREATE OR ALTER PROCEDURE NotaCredito.EliminarFactura
    @id INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Venta.Factura
        WHERE id = @id
    )
    BEGIN
        DELETE FROM Venta.Factura
        WHERE id = @id;
    END
    ELSE
    BEGIN
        RAISERROR('Error: La Factura no existe.', 16, 1);
    END
END;
go

CREATE OR ALTER PROCEDURE NotaCredito.EliminarVentaDetalle
    @idVenta INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Venta.VentaDetalle
        WHERE idVenta = @idVenta
    )
    BEGIN
        DELETE FROM Venta.VentaDetalle
        WHERE idVenta = @idVenta;
    END
    ELSE
    BEGIN
        RAISERROR('Error: El detalle de venta no existe.', 16, 1);
    END
END;
go


CREATE OR ALTER PROCEDURE super.EliminarTipoCliente
    @idTipoCliente INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Super.TipoCliente
        WHERE idTipoCliente = @idTipoCliente
    )
    BEGIN
        DELETE FROM Super.TipoCliente
        WHERE idTipoCliente = @idTipoCliente;
    END
    ELSE
    BEGIN
        RAISERROR('Error: El tipo de cliente no existe.', 16, 1);
    END
END;
go

CREATE OR ALTER PROCEDURE producto.EliminarCategoria
    @idCategoria INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Producto.Categoria
        WHERE idCategoria = @idCategoria
    )
    BEGIN
        DELETE FROM Producto.Categoria
        WHERE idCategoria = @idCategoria;
    END
    ELSE
    BEGIN
        RAISERROR('Error: La categoria no existe.', 16, 1);
    END
END;
go
----------------------------

-----pesificar los productos----

create or alter procedure producto.pesificarProducto
as
begin
-- Definir los parámetros para construir la URL de la API
DECLARE @ruta NVARCHAR(128) = 'https://dolarapi.com/v1/dolares/blue'
DECLARE @url NVARCHAR(256) = @ruta  -- En este caso no es necesario concatenar más parámetros

-- Variables para manejar el objeto OLE y la respuesta JSON
DECLARE @Object INT
DECLARE @json TABLE(DATA NVARCHAR(MAX))
DECLARE @respuesta NVARCHAR(MAX)

-- Crear el objeto OLE para realizar la solicitud HTTP
EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE' -- Definir la solicitud HTTP GET
EXEC sp_OAMethod @Object, 'SEND'                             -- Enviar la solicitud
EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT  -- Capturar la respuesta

-- Insertar la respuesta JSON en una tabla variable para procesarla
INSERT INTO @json
EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

-- Cerrar y liberar el objeto OLE
EXEC sp_OADestroy @Object

declare @ValorCambio decimal(10,2);

-- Procesar el JSON y extraer los datos relevantes
DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)
SELECT @ValorCambio=Venta FROM OPENJSON(@datos)
WITH
(
    [Compra] DECIMAL(10, 2) '$.compra',
    [Venta] DECIMAL(10, 2) '$.venta',
    [Casa] NVARCHAR(50) '$.casa',
    [Nombre] NVARCHAR(50) '$.nombre',
    [Moneda] NVARCHAR(10) '$.moneda',
    [FechaActualizacion] NVARCHAR(50) '$.fechaActualizacion'
);

UPDATE Producto.Producto
SET precio = precio * @ValorCambio,
    moneda = 'ARS'  -- Cambiar la moneda a pesos
WHERE moneda = 'USD';

end