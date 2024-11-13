---- testing
go
use Com5600G15
go
------entrega 3

-----stores procedures insersion--------
EXEC Super.InsertarSucursal 
    @sucursal = 'Sucursal Central',
    @ciudad = 'Ciudad A',
    @direccion = 'Av. Principal 123',
    @horario = '08:00-18:00',
    @telefono = '123-456-789';

EXEC Venta.InsertarMedioPago 
    @descripcion = 'Tarjeta de Cr�dito';

EXEC Super.InsertarTipoCliente 
    @descripcion = 'Corporativo',
    @genero = 'Masculino';

EXEC Producto.InsertarCategoria 
    @nombre = 'Electrodom�sticos';

EXEC Super.InsertarEmpleado 
    @idEmpleado = 1,
    @dni = '12345678',
    @cuil = '20-12345678-9',
    @email = 'empleado1@empresa.com',
    @cargo = 'Gerente',
    @turno = 'Ma�ana',
    @sucursal = 1; -- Aseg�rate de que la sucursal con ID 1 ya exista

EXEC Producto.InsertarProducto 
    @idProducto = 1,
    @categoria = 1, -- Aseg�rate de que la categor�a con ID 1 ya exista
    @nombre = 'Aspiradora',
    @precio = 199.99;

EXEC Venta.InsertarFactura 
    @idFactura = 'F-0001',
    @fecha = '2024-11-10',
    @hora = '14:30:00',
    @idPago = 'P-12345',
    @medioPago = 1, -- Aseg�rate de que el medio de pago con ID 1 ya exista
    @empleado = 1; -- Aseg�rate de que el empleado con ID 1 ya exista


EXEC Venta.InsertarVentaDetalle 
    @producto = 1, -- Aseg�rate de que el producto con ID 1 ya exista
    @idFactura = 1, -- Aseg�rate de que la factura con ID 1 ya exista
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
    @categoria = 1, -- asegurarse de que la categor�a con ID exista
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
    @nombre = 'Electrodom�sticos Peque�os';

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


-- Cambiar al login 'supervisor'
EXECUTE AS LOGIN = 'supervisor';
-- Ejecuta comandos en el contexto de 'supervisor'
SELECT CURRENT_USER AS 'Login Actual';

-- Revertir al login original
REVERT;

-- Cambiar al login 'usuarioBasico'
EXECUTE AS LOGIN = 'usuarioBasico';
-- Ejecuta comandos en el contexto de 'usuarioBasico'
SELECT CURRENT_USER AS 'Login Actual';

select * from Venta.Factura
select * from Producto.Producto

EXEC GenerarNotaCredito
    @idFactura = 1,        -- ID de la factura creada
    @idProducto = 1,       -- ID del producto creado
    @valorCredito = 100.00-- Valor de la nota de cr�dito

----------------------PERMISOS----------------------------------
SELECT 
    perms.state_desc AS State,           
    permission_name AS [Permission],      
    obj.name AS [on Object],             
    dp.name AS [to User Name]            
FROM sys.database_permissions AS perms  
JOIN sys.database_principals AS dp      
    ON perms.grantee_principal_id = dp.principal_id
JOIN sys.objects AS obj                 
    ON perms.major_id = obj.object_id
     
---------------------------------------------------------------------


