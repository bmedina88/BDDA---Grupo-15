--Tests Entrega 4
--FECHA DE ENTREGA: 15/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

use Com5600G15;
GO

--Ignorar Restricción FK 
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
--USAR PARA VOLVER A ACTIVAR RESTRICCIÓN DE FK SI SE EJECUTA INDIVIDUALMENTE:
--EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";



--Test Importar Sucursal 
BEGIN TRANSACTION
DELETE FROM Super.Sucursal;

EXEC Super.importarSucursal 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK
--Test Importar Sucursal - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Super.Sucursal;

EXEC Super.importarSucursal 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Super.importarSucursal 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK




--Test Importar Medio Pago 
BEGIN TRANSACTION
DELETE FROM Venta.MedioPago;

EXEC Venta.ImportarMedioPago 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK
select * from Venta.MedioPago
--Test Importar Medio Pago - Registros Repetidos 
BEGIN TRANSACTION
DELETE FROM Venta.MedioPago;

EXEC Venta.ImportarMedioPago 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Venta.ImportarMedioPago 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK




--Test Importar Empleado
BEGIN TRANSACTION
DELETE FROM Super.Empleado;

EXEC Super.ImportarEmpleados 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK
--Test Importar Empleado - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Super.Empleado;

EXEC Super.ImportarEmpleados 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Super.ImportarEmpleados 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK




--Test Importar Categoria 
BEGIN TRANSACTION
DELETE FROM Producto.Categoria

EXEC Producto.ImportarCategorias 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
ROLLBACK
--Test Importar Categoria - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Categoria

EXEC Producto.ImportarCategorias 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Producto.ImportarCategorias 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK




--Test Importar Producto Electronico 
BEGIN TRANSACTION
DELETE FROM Producto.Producto

EXEC Producto.ImportarProductosElectronicos 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';

ROLLBACK
--Test Importar Producto Electronico - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Producto

EXEC Producto.ImportarProductosElectronicos 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';
EXEC Producto.ImportarProductosElectronicos 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';

ROLLBACK




--Test Importar Producto Importado 
BEGIN TRANSACTION
DELETE FROM Producto.Producto

EXEC Producto.ImportarProductosImportado 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Productos_importados.xlsx';

ROLLBACK
--Test Importar Producto Importado - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Producto

EXEC Producto.ImportarProductosImportado 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Productos_importados.xlsx';
EXEC Producto.ImportarProductosImportado 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Productos_importados.xlsx';

ROLLBACK




--Test Importar Producto Catalogo 
BEGIN TRANSACTION
DELETE FROM Producto.Producto

EXEC Producto.ImportarProductosCatalogo 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\catalogo.csv', 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK
--Test Importar Producto Catalogo - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Producto

EXEC Producto.ImportarProductosCatalogo 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\catalogo.csv', 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Producto.ImportarProductosCatalogo 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\catalogo.csv', 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';

ROLLBACK




--Test Importar Venta 
BEGIN TRANSACTION
DELETE FROM Venta.VentaDetalle;
DELETE FROM Venta.Factura;

EXEC Venta.ImportarVentas 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Ventas_registradas.csv';

ROLLBACK
--Test Importar Venta - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Venta.VentaDetalle;
DELETE FROM Venta.Factura;

EXEC Venta.ImportarVentas 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Ventas_registradas.csv';
EXEC Venta.ImportarVentas 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Ventas_registradas.csv';

ROLLBACK


EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";



--Importar todos los datos
GO
EXEC Super.importarSucursal 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO
EXEC Venta.ImportarMedioPago 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO
EXEC Super.ImportarEmpleados 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO
EXEC Producto.ImportarCategorias 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO
EXEC Producto.ImportarProductosElectronicos 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';
GO
EXEC Producto.ImportarProductosImportado 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\Productos_importados.xlsx';
GO
EXEC Producto.ImportarProductosCatalogo 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Productos\catalogo.csv', 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO
EXEC Venta.ImportarVentas 'C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15\TP_integrador_Archivos\Ventas_registradas.csv';
GO