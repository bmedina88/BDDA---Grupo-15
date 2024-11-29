--Test Entrega 5
--FECHA DE ENTREGA: 15/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371



use Com5600G15;



-- Cambiar al login 'supervisor'
EXECUTE AS LOGIN = 'supervisor';
-- Ejecuta comandos en el contexto de 'supervisor'
SELECT CURRENT_USER AS 'Login Actual';


select * from Venta.Factura
select * from Producto.Producto
select * from Venta.VentaDetalle

EXEC NotaCredito.GenerarNotaCredito
    @idFactura = 1,       
    @idProducto = 1,     
    @cantidad = 1

select * from NotaCredito.NotaCredito

exec NotaCredito.eliminarNotaCredito
@idNota=1

select * from Super.Empleado
exec super.encriptarEmpleados 'ClaveSeguraParaEmpleados'
select * from Super.Empleado

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
-- Revertir al login original
REVERT;
------------------------------------------------
-- Cambiar al login 'usuarioBasico'
EXECUTE AS LOGIN = 'cajero';
-- Ejecuta comandos en el contexto de 'usuarioBasico'
SELECT CURRENT_USER AS 'Login Actual';

select * from Venta.Factura
select * from Producto.Producto
select * from Venta.VentaDetalle

EXEC NotaCredito.GenerarNotaCredito
    @idFactura = 1,       
    @idProducto = 1,     
    @cantidad = 1

select * from NotaCredito.NotaCredito

exec NotaCredito.eliminarNotaCredito
@idNota=1

select * from Super.Empleado
exec super.encriptarEmpleados 'ClaveSeguraParaEmpleados'
select * from Super.Empleado