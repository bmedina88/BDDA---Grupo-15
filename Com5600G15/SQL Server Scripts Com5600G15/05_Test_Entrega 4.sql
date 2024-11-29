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

--Ruta raiz de la carpeta del proyecto de GIT
DECLARE @rutaIncompleta varchar(max);
DECLARE @rutafinal varchar (max);
DECLARE @rutaFinal2 varchar(max);
SELECT @rutaIncompleta='C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15'
SELECT @rutafinal2=@rutafinal;



--Ignorar Restricción FK 
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
--USAR PARA VOLVER A ACTIVAR RESTRICCIÓN DE FK SI SE EJECUTA INDIVIDUALMENTE:
--EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";



--Test Importar Sucursal 
BEGIN TRANSACTION
DELETE FROM Super.Sucursal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Super.importarSucursal @rutafinal;

ROLLBACK
--Test Importar Sucursal - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Super.Sucursal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'

EXEC Super.importarSucursal @rutafinal;
EXEC Super.importarSucursal @rutafinal;

ROLLBACK




--Test Importar Medio Pago 
BEGIN TRANSACTION
DELETE FROM Venta.MedioPago;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Venta.ImportarMedioPago @rutafinal;

ROLLBACK
select * from Venta.MedioPago
--Test Importar Medio Pago - Registros Repetidos 
BEGIN TRANSACTION
DELETE FROM Venta.MedioPago;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Venta.ImportarMedioPago @rutafinal;
EXEC Venta.ImportarMedioPago @rutafinal;

ROLLBACK




--Test Importar Empleado
BEGIN TRANSACTION
DELETE FROM Super.Empleado;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Super.ImportarEmpleados @rutafinal;

ROLLBACK
--Test Importar Empleado - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Super.Empleado;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Super.ImportarEmpleados @rutafinal;
EXEC Super.ImportarEmpleados @rutafinal;

ROLLBACK




--Test Importar Categoria 
BEGIN TRANSACTION
DELETE FROM Producto.Categoria

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Producto.ImportarCategorias @rutafinal;

ROLLBACK
--Test Importar Categoria - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Categoria

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Producto.ImportarCategorias @rutafinal;
EXEC Producto.ImportarCategorias @rutafinal;

ROLLBACK




--Test Importar Producto Electronico 
BEGIN TRANSACTION
DELETE FROM Producto.Producto

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
EXEC Producto.ImportarProductosElectronicos @rutafinal;

ROLLBACK
--Test Importar Producto Electronico - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Producto

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
EXEC Producto.ImportarProductosElectronicos @rutafinal;
EXEC Producto.ImportarProductosElectronicos @rutafinal;


ROLLBACK




--Test Importar Producto Importado 
BEGIN TRANSACTION
DELETE FROM Producto.Producto

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
EXEC Producto.ImportarProductosImportado @rutafinal;

ROLLBACK
--Test Importar Producto Importado - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Producto

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
EXEC Producto.ImportarProductosImportado @rutafinal;
EXEC Producto.ImportarProductosImportado @rutafinal;

ROLLBACK




--Test Importar Producto Catalogo 
BEGIN TRANSACTION
DELETE FROM Producto.Producto

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\catalogo.csv'
SELECT @rutafinal2 = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Producto.ImportarProductosCatalogo @rutafinal, @rutafinal2;

ROLLBACK
--Test Importar Producto Catalogo - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Producto.Producto

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\catalogo.csv'
SELECT @rutafinal2 = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Producto.ImportarProductosCatalogo @rutafinal, @rutafinal2;
EXEC Producto.ImportarProductosCatalogo @rutafinal, @rutafinal2;

ROLLBACK




--Test Importar Venta 
BEGIN TRANSACTION
DELETE FROM Venta.VentaDetalle;
DELETE FROM Venta.Factura;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Ventas_registradas.csv'
EXEC Venta.ImportarVentas @rutafinal;

ROLLBACK
--Test Importar Venta - Registros Repetidos
BEGIN TRANSACTION
DELETE FROM Venta.VentaDetalle;
DELETE FROM Venta.Factura;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Ventas_registradas.csv'
EXEC Venta.ImportarVentas @rutafinal;
EXEC Venta.ImportarVentas @rutafinal;


ROLLBACK


EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";



--Importar todos los datos
DECLARE @rutaIncompleta varchar(max);
DECLARE @rutafinal varchar (max);
DECLARE @rutaFinal2 varchar(max);
SELECT @rutaIncompleta='C:\Users\beybr\OneDrive\Escritorio\BDDA\BDDA---Grupo-15'
SELECT @rutafinal2=@rutafinal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Super.importarSucursal @rutafinal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Venta.ImportarMedioPago @rutafinal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Super.ImportarEmpleados @rutafinal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Producto.ImportarCategorias @rutafinal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
EXEC Producto.ImportarProductosElectronicos @rutafinal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
EXEC Producto.ImportarProductosImportado @rutafinal;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Productos\catalogo.csv'
SELECT @rutafinal2 = @rutaIncompleta + '\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Producto.ImportarProductosCatalogo @rutafinal, @rutafinal2;

SELECT @rutafinal = @rutaIncompleta + '\TP_integrador_Archivos\Ventas_registradas.csv'
EXEC Venta.ImportarVentas @rutafinal;
