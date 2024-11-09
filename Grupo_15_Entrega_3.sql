--ENTREGA 3: Creaciòn de la base de datos. 
--FECHA DE ENTREGA: 01/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 

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
--Tablas
CREATE TABLE Venta.MedioPago(
	idMedioPago int IDENTITY(1,1) PRIMARY KEY,
	descripcion nvarchar(255)
);

CREATE TABLE Producto.Categoria(
	idCategoria int IDENTITY(1,1) PRIMARY KEY,
	nombre nvarchar(255)
);

CREATE TABLE Super.Sucursal(
	idSucursal int IDENTITY(1,1) PRIMARY KEY,
	ciudad nvarchar(255),
	ciudadAnterior nvarchar(255),
	direccion nvarchar(max),
	horario nvarchar(max),
	telefono nvarchar(255)
);
-- es necesario empleado?
CREATE TABLE Super.Empleado(
	idEmpleado int PRIMARY KEY,
	sucursal int REFERENCES Super.Sucursal(idSucursal),
	dni varchar(9)
);

CREATE TABLE Producto.Origen(
	idOrigen int PRIMARY KEY,
	descripcion nvarchar(255)
);

CREATE TABLE Producto.Producto(
	idProducto int,
	origen int REFERENCES Producto.Origen,
	nombre nvarchar(255),
	precio DECIMAL(10, 2),
	categoria int REFERENCES Producto.Categoria(idCategoria),
	CONSTRAINT PK_Producto PRIMARY KEY (idProducto, origen)

);

CREATE TABLE Super.TipoCliente(
	idTipoCliente int IDENTITY(1,1) PRIMARY KEY,
	descripcion nvarchar(255),
	genero nvarchar(50)
);

CREATE TABLE Venta.Venta(
	idVenta int IDENTITY(1,1) PRIMARY KEY,
	idFactura varchar(11),
	tipoFactura char,
	fecha date,
	hora time,
	idPago nvarchar(50),
	tipoCliente int REFERENCES Super.TipoCliente(idTipoCliente),
	producto int,
	origen int,
	medioPago int REFERENCES Venta.MedioPago(idMedioPago),
	empleado int REFERENCES Super.Empleado(idEmpleado),
	CONSTRAINT FK_VentaProducto FOREIGN KEY (producto, origen) REFERENCES Producto.Producto(idProducto, origen)
);


--STORE PROCEDURE INSERCIÓN DATOS
GO
CREATE PROCEDURE Venta.InsertarMedioPago(
	@Descripcion nvarchar(255) )
AS
BEGIN
	INSERT INTO Venta.MedioPago(descripcion)
	VALUES (@Descripcion);
END
GO


GO
CREATE PROCEDURE Producto.InsertarCategoria(
	@Nombre nvarchar(255) )
AS
BEGIN
	INSERT INTO Producto.Categoria(nombre)
	VALUES (@Nombre);
END
GO


GO
CREATE PROCEDURE Super.InsertarSucursal(
	@Ciudad nvarchar(255),
	@ciudadAnterior nvarchar(255),
	@direccion nvarchar(max),
	@horario nvarchar(max),
	@telefono nvarchar(255)
	)
AS
BEGIN
	INSERT INTO Super.Sucursal(ciudad, ciudadAnterior, direccion, horario, telefono)
	VALUES (@Ciudad, @ciudadAnterior, @direccion, @horario, @telefono);
END
GO



GO
CREATE PROCEDURE Super.InsertarEmpleado(
	@id int,
	@idSucursal int,
	@Dni nvarchar(9))
AS
BEGIN
	INSERT INTO Super.Empleado(idEmpleado, sucursal, dni)
	VALUES (@id, @idSucursal, @Dni);
END
GO


GO
CREATE PROCEDURE Producto.InsertarOrigen(
	@descripcion nvarchar(255))
AS
BEGIN
	INSERT INTO Producto.InsertarOrigen(descripcion)
	VALUES (@descripcion);
END
GO


GO
CREATE PROCEDURE Producto.InsertarProducto(
	@idProducto int,
	@idOrigen int,
	@nombre nvarchar(255),
	@precio DECIMAL(10,2),
	@idCategoria int)
AS
BEGIN
	INSERT INTO Producto.Producto(idProducto, origen, nombre, precio, categoria)
	VALUES (@idProducto, @idOrigen, @nombre, @precio, @idCategoria);
END
GO


GO
CREATE PROCEDURE Super.InsertarTipoCliente(
	@descripcion nvarchar(255),
	@genero nvarchar(50))
AS
BEGIN
	INSERT INTO Super.TipoCliente(descripcion, genero)
	VALUES (@descripcion, @genero);
END
GO


GO
CREATE PROCEDURE Venta.InsertarVenta(
	@idFactura varchar(11),
	@tipoFactura char(5),
	@fecha date,
	@hora time,
	@idPago nvarchar(50),
	@idTipoCliente int,
	@idProducto int,
	@idOrigen int,
	@idMedioPago int,
	@idEmpleado int
	)
AS
BEGIN
	INSERT INTO Venta.Venta (idFactura, tipoFactura, fecha, hora, idPago, tipoCliente, producto, origen, medioPago, empleado)
	VALUES (@idFactura, @tipoFactura, @fecha, @hora, @idPago, @idTipoCliente, @idProducto,@idOrigen, @idMedioPago, @idEmpleado);
END
GO




