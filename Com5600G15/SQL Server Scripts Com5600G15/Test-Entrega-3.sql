--Test Entrega 3
--FECHA DE ENTREGA: 15/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371



use Com5600G15;

-----stores procedures insersion--------
EXEC Super.InsertarSucursal 
    @sucursal = 'Sucursal Central',
    @ciudad = 'Ciudad A',
    @direccion = 'Av. Principal 123',
    @horario = '08:00-18:00',
    @telefono = '123-456-789';

EXEC Venta.InsertarMedioPago 
    @descripcion = 'Tarjeta de Crédito';

EXEC Super.InsertarTipoCliente 
    @descripcion = 'Corporativo',
    @genero = 'Masculino';

EXEC Producto.InsertarCategoria 
    @nombre = 'Electrodomésticos';

EXEC Super.InsertarEmpleado 
    @idEmpleado = 1,
    @dni = '12345678',
    @cuil = '20-12345678-9',
    @email = 'empleado1@empresa.com',
    @cargo = 'Gerente',
    @turno = 'Mañana',
    @sucursal = 1; -- Asegúrate de que la sucursal con ID 1 ya exista

EXEC Producto.InsertarProducto 
    @idProducto = 1,
    @categoria = 1, -- Asegúrate de que la categoría con ID 1 ya exista
    @nombre = 'Aspiradora',
    @precio = 199.99;

EXEC Venta.InsertarFactura 
    @idFactura = 'F-0001',
    @fecha = '2024-11-10',
    @hora = '14:30:00',
    @idPago = 'P-12345',
    @medioPago = 1, -- Asegúrate de que el medio de pago con ID 1 ya exista
    @empleado = 1; -- Asegúrate de que el empleado con ID 1 ya exista


EXEC Venta.InsertarVentaDetalle 
    @producto = 1, -- Asegúrate de que el producto con ID 1 ya exista
    @idFactura = 1, -- Asegúrate de que la factura con ID 1 ya exista
    @cantidad = 2;

----------------------stores procedures update------------------------------------------------------------------------
EXEC ModificarSucursal 
    @idSucursal = 1,
    @sucursal = 'Sucursal Norte',
    @ciudad = 'Ciudad B',
    @direccion = 'Av. Secundaria 456',
    @horario = '08:00-17:00',
    @telefono = '987-654-321';

EXEC ModificarMedioPago 
    @idMedioPago = 1,
    @descripcion = 'Transferencia Bancaria';

EXEC ModificarEmpleado 
    @idEmpleado = 1,
    @email = 'nuevoempleado@empresa.com',
    @cargo = 'Supervisor',
    @turno = 'Tarde',
    @sucursal = 1; -- asegurarse de que la sucursal con ID exista

EXEC ModificarProducto 
    @idProducto = 1,
    @categoria = 1, -- asegurarse de que la categoría con ID exista
    @nombre = 'Aspiradora Industrial',
    @precio = 250.75;

EXEC ModificarFactura 
    @id = 1,
    @fecha = '2024-12-01',
    @hora = '15:45:00',
    @idPago = 'P-123456',
    @medioPago = 1, -- asegurarse de que el medio de pago con ID exista
    @empleado = 1;  -- asegurarse de que el empleado con ID  exista

EXEC ModificarTipoCliente 
    @idTipoCliente = 1,
    @descripcion = 'Mayorista',
    @genero = 'Indistinto';

EXEC ModificarCategoria 
    @idCategoria = 1,
    @nombre = 'Electrodomésticos Pequeños';

EXEC ModificarVentaDetalle 
    @idVenta = 1,
    @producto = 3, -- asegurarse de que el producto con ID 1exista
    @cantidad = 10;

-----------------------Stores procedures para eliminar---------------------

EXEC EliminarVentaDetalle @idVenta = 1;
EXEC EliminarFactura @id = 1;
EXEC EliminarProducto @idProducto = 1;
EXEC EliminarEmpleado @idEmpleado = 1;
EXEC EliminarSucursal @idSucursal = 1;
EXEC EliminarMedioPago @idMedioPago = 1;
EXEC EliminarTipoCliente @idTipoCliente = 1;
EXEC EliminarCategoria @idCategoria = 1;


---------------------------------------------------------------------------




