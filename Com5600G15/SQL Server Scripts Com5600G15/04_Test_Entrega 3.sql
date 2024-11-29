--Test Entrega 3
--FECHA DE ENTREGA: 15/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371



use Com5600G15;


-------Test agregar sucursal-----

EXEC Super.InsertarSucursal 
    @sucursal = 'Sucursal Central',
    @ciudad = 'Ciudad A',
    @direccion = 'Av. Principal 123',
    @horario = '08:00-18:00',
    @telefono = '123-456-789';

	---Insertar sucursal duplicado---
		EXEC Super.InsertarSucursal 
		@sucursal = 'Sucursal Central',
		@ciudad = 'Ciudad A',
		@direccion = 'Av. Illia 123',
		@horario = '08:00-18:00',
		@telefono = '123-456-789';

select * from Super.Sucursal

-----Actualizar Sucursal-----
EXEC super.ModificarSucursal 
    @idSucursal = 1,
    @sucursal = 'Sucursal Norte',
    @ciudad = 'Ciudad B',
    @direccion = 'Av. Secundaria 456',
    @horario = '08:00-17:00',
    @telefono = '987-654-321';

	-----Actualizar Sucursal inexistente
	EXEC super.ModificarSucursal 
    @idSucursal = 255,
    @sucursal = 'Villegas 1',
    @ciudad = 'Ciudad Evita',
    @direccion = 'Av. Secundaria 456',
    @horario = '08:00-17:00',
    @telefono = '987-654-321';

-----Test agregar empleado--------

EXEC Super.InsertarEmpleado 
    @idEmpleado = 1,
    @dni = '12345678',
    @cuil = '20-12345678-9',
    @email = 'empleado1@empresa.com',
    @cargo = 'Gerente',
    @turno = 'Mañana',
    @sucursal = 1; 
	go
	-----empleado duplicado-----

	EXEC Super.InsertarEmpleado 
    @idEmpleado = 1,
    @dni = '12345678',
    @cuil = '20-12345678-9',
    @email = 'empleado1@empresa.com',
    @cargo = 'Gerente',
    @turno = 'Mañana',
    @sucursal = 1; 

select * from Super.Empleado

------Actualizar Empleado--------

EXEC super.ModificarEmpleado 
    @idEmpleado = 1,
    @email = 'nuevoempleado@empresa.com',
    @cargo = 'Supervisor',
    @turno = 'Tarde',
    @sucursal = 3; 

	---Actualizar empleado inexistente ----
EXEC super.ModificarEmpleado 
    @idEmpleado = 55,
    @email = 'nuevoempleado@empresa.com',
    @cargo = 'Supervisor',
    @turno = 'Tarde',
    @sucursal = 1; 


-------------Insertar medio de Pago-----

EXEC Venta.InsertarMedioPago 
    @descripcion = 'Tarjeta de Crédito';
	---Insertar medio de Pago duplicado----

		EXEC Venta.InsertarMedioPago 
		@descripcion = 'Tarjeta de Crédito';

select * from Venta.MedioPago
-----Actualizar medio de Pago-----

EXEC venta.ModificarMedioPago 
    @idMedioPago = 1,
    @descripcion = 'Debito';
	---Actualizar medio de pago inexistente----

	EXEC venta.ModificarMedioPago 
    @idMedioPago = 22,
    @descripcion = 'Wallet';

---------Insertar tipoCliente-------

EXEC Super.InsertarTipoCliente 
    @descripcion = 'Corporativo',
    @genero = 'Masculino';

	---Insertar tipoCliente duplicado---
	EXEC Super.InsertarTipoCliente 
    @descripcion = 'Corporativo',
    @genero = 'Masculino';

-----Actualizar tipoCliente-------

select * from Super.TipoCliente

EXEC super.ModificarTipoCliente 
    @idTipoCliente = 1,
    @descripcion = 'Mayorista',
    @genero = 'Masculino';

	----Actualizar tipoCliente inexistente---
	EXEC super.ModificarTipoCliente 
    @idTipoCliente = 22,
    @descripcion = 'Minorista',
    @genero = 'Masculino';

----------Insertar Categoria--------

EXEC Producto.InsertarCategoria 
    @nombre = 'Electrodomésticos';
	-----Insertar CategoriaDuplicado------
	EXEC Producto.InsertarCategoria 
    @nombre = 'Electrodomésticos';

----Actualizar Categoria----
select * from Producto.Categoria

EXEC producto.ModificarCategoria 
    @idCategoria = 1,
    @nombre = 'Electrodomésticos Pequeños';
	-----Actualizar CategoriaInexistente---
	EXEC producto.ModificarCategoria 
    @idCategoria = 22,
    @nombre = 'Electrodomésticos Pequeños';

----Insertar Producto----

EXEC Producto.InsertarProducto 
    @categoria = 1, 
    @nombre = 'Aspiradora',
    @precio = 200000.00,
	@moneda = 'ARS';

select * from Producto.Producto 

----si el producto existe actualizar

EXEC Producto.InsertarProducto 
    @categoria = 1, 
    @nombre = 'Aspiradora',
    @precio = 100.00,
	@moneda = 'USD';

----Modificar Producto-----

EXEC producto.ModificarProducto 
    @idProducto = 1,
    @categoria = 1, -- asegurarse de que la categoría con ID exista
    @nombre = 'Aspiradora Industrial',
    @precio = 250.75,
	@moneda = 'USD';
	---Modificar producto Inexistente
		EXEC producto.ModificarProducto 
		@idProducto = 66,
		@categoria = 1, -- asegurarse de que la categoría con ID exista
		@nombre = 'Aspiradora Industrial',
		@precio = 250.75,
		@moneda = 'USD';

----Procedure para cambiar de USD a pesos usando API's -------

exec Producto.pesificarProducto

-----------Test de compras-------------
begin transaction 
begin try
	declare @error INT;

	exec @error = Venta.InsertarFactura 
    @idFactura = 'F-0003',
    @fecha = '2024-11-10',
    @hora = '14:30:00',
    @idPago = 'P-12345',
    @medioPago = 1, 
    @empleado = 1, 
	@cliente = 1,
	@tipoFactura = 'A';
	if @error <> 0 --- verificar si ocurrio algun error
	begin 
		throw 50000 , 'ERROR' ,1;
	end
	------insertamos en ventas detalles los productos------

	DECLARE @idFactura INT;

	SELECT @idFactura = id 
	FROM Venta.Factura 
	WHERE idfactura = 'F-0003';

	EXEC Venta.InsertarVentaDetalle 
		@producto = 1, 
		@idFactura = @idFactura, 
		@cantidad = 2;

--------------Si insertamos un producto no existente se revierte la operacion y elimina la factura---------

/*	EXEC Venta.InsertarVentaDetalle 
		@producto = 5, 
		@idFactura = @idFactura, 
		@cantidad = 2;
*/
	------ Volvemos a ingresar el mismo producto, (se le sumara la cantidad a la venta detalle)----

/*
	EXEC Venta.InsertarVentaDetalle 
		@producto = 1, 
		@idFactura = @idFactura, 
		@cantidad = 2;
*/

------ Si el comprador se arrepiente de la compra ---
--throw 50000 , 'ERROR' ,1;

	commit transaction
	print 'Venta realizado con exito';

end try
	begin catch
	rollback transaction;
		RAISERROR('Error: no se pudo concretar la venta', 16, 1);
	end catch


select * from Venta.Factura
select * from Venta.VentaDetalle


-----------------------eliminar---------------------

EXEC NotaCredito.EliminarVentaDetalle @idVenta = 1;
go
EXEC NotaCredito.EliminarFactura @id = 1;
go
EXEC producto.EliminarProducto @idProducto = 1;
go
EXEC super.EliminarEmpleado @idEmpleado = 1;
go
EXEC super.EliminarSucursal @idSucursal = 1;
go
EXEC venta.EliminarMedioPago @idMedioPago = 1;
go
EXEC super.EliminarTipoCliente @idTipoCliente = 1;
go
EXEC producto.EliminarCategoria @idCategoria = 1;
go

-------------Eliminar inexistentes------------

EXEC NotaCredito.EliminarVentaDetalle @idVenta = 17;
go
EXEC NotaCredito.EliminarFactura @id = 17;
go
EXEC producto.EliminarProducto @idProducto = 17;
go
EXEC super.EliminarEmpleado @idEmpleado = 17;
go
EXEC super.EliminarSucursal @idSucursal = 17;
go
EXEC venta.EliminarMedioPago @idMedioPago = 17;
go
EXEC super.EliminarTipoCliente @idTipoCliente = 17;
go
EXEC producto.EliminarCategoria @idCategoria = 17;
go

---------------------------------------------------------------------------

select * from Venta.VentaDetalle
select * from Venta.Factura
select * from Producto.Producto
select * from Super.Empleado
select * from Super.Sucursal
select * from Venta.MedioPago
select * from Super.TipoCliente
select * from Producto.Categoria