--ENTREGA 4: Importación de datos. 
--FECHA DE ENTREGA: 08/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 

use Com5600G15;
------Activar consultas distribuidas
use Com5600G15
GO
EXEC sp_configure 'Show Advanced', 1
RECONFIGURE
GO
EXEC sp_configure 'Ad hoc dis', 1
RECONFIGURE
GO

------importar excel de ventas--------

create or alter procedure venta.importar_ventas(
@direccion nvarchar(max))
as
begin
-- Eliminar la tabla temporal si ya existe
IF OBJECT_ID('tempdb..#VentasTemp') IS NOT NULL
    DROP TABLE #VentasTemp;

-- Crear la tabla temporal con todas las columnas como VARCHAR
CREATE TABLE #VentasTemp (
    IDFactura nVARCHAR(max),
    TipoFactura nVARCHAR(max),
    Ciudad nVARCHAR(max),
    TipoCliente nVARCHAR(max),
    Genero nVARCHAR(max),
    Producto nVARCHAR(max),
    PrecioUnitario nVARCHAR(max),
    Cantidad nVARCHAR(max),
    Fecha nVARCHAR(max),
    Hora nVARCHAR(max),
    MedioPago nVARCHAR(max),
    Empleado nVARCHAR(max),
    IdentificadorPago NVARCHAR(max)
);


-- Importar el archivo CSV
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
BULK INSERT #VentasTemp
FROM ''' + @direccion + '''
WITH (
    FIELDTERMINATOR = '';'',  
    ROWTERMINATOR = ''\n'',  
    FIRSTROW = 2,            
    CODEPAGE = ''65001''
);';

EXEC sp_executesql @sql;


INSERT INTO Super.TipoCliente (descripcion, genero)
SELECT DISTINCT vt.TipoCliente, vt.Genero
FROM #VentasTemp AS vt
LEFT JOIN Super.TipoCliente AS tc
    ON vt.TipoCliente = tc.descripcion AND vt.Genero = tc.genero
WHERE tc.descripcion IS NULL;

INSERT INTO Venta.Venta (
    idFactura,
    tipoFactura,
    fecha,
    hora,
    idPago,
    tipoCliente,
    producto,
    origen,
    medioPago,
    empleado
)
SELECT 
    IDFactura,
    TipoFactura,
    TRY_CAST(Fecha AS DATE),
    TRY_CAST(Hora AS TIME),
    IdentificadorPago,
    (SELECT TOP 1 idTipoCliente FROM Super.TipoCliente WHERE descripcion = TipoCliente AND genero = Genero),
    (SELECT TOP 1 idProducto FROM Producto.Producto WHERE nombre = Producto),
    1,  -- Define un valor para origen si es constante o ajusta según corresponda
    (SELECT TOP 1 idMedioPago FROM Venta.MedioPago WHERE descripcion = MedioPago),
    try_cast(Empleado as int)
FROM #VentasTemp;

drop table #VentasTemp
end
go





---------------------


SELECT * FROM OPENROWSET(
	'Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
	'SELECT * FROM [medios de pago$]'
)



-- Importación sucursal
CREATE OR ALTER PROCEDURE Super.importarSucursal(
@ruta nvarchar(max))
AS
BEGIN	
	IF OBJECT_ID('tempdb..#SucursalTemp') IS NOT NULL
		CREATE TABLE #SucursalTemp(
			ciudadAnterior nvarchar(max),
			ciudad nvarchar(max),
			direccion nvarchar(max),
			horario nvarchar(max),
			telefono nvarchar(max))


	

	INSERT INTO #SucursalTemp
		SELECT * FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'SELECT * FROM [Sucursal$]');
	

	INSERT INTO Super.Sucursal(ciudad, ciudadAnterior, direccion,horario, telefono)
	SELECT ciudad,ciudadAnterior, direccion, horario, telefono
	FROM #SucursalTemp AS T
	WHERE T.ciudad NOT IN (SELECT S.ciudad FROM Super.Sucursal AS S);
	
	DROP TABLE IF EXISTS #SucursalTemp;
END
GO


-- Importación Medios de Pago
CREATE OR ALTER PROCEDURE Venta.ImportarMedioPago(
@ruta nvarchar(max) )
AS
BEGIN
	IF OBJECT_ID('tempdb..#MedioPagoTemp') IS NOT NULL
		CREATE TABLE #MedioPagoTemp(
			descripcion nvarchar(max))
	

	INSERT INTO #MedioPagoTemp
		SELECT * FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'SELECT [F2] FROM [medios de pago$]');
	

	INSERT INTO Venta.MedioPago(descripcion)
	SELECT descripcion
	FROM #MedioPagoTemp as T
	WHERE T.descripcion NOT IN (SELECT M.descripcion FROM Venta.MedioPago AS M);

	DROP TABLE IF EXISTS #MedioPagoTemp;
END
GO


--Importación Empleados
CREATE OR ALTER PROCEDURE Super.ImportarEmpleados(
	@RUTA nvarchar(max) )
AS
BEGIN
		IF OBJECT_ID('tempdb..#EmpleadoTemp') IS NOT NULL
		CREATE TABLE #EmpleadoTemp(
			legajo nvarchar(max),
			nombre nvarchar(max),
			apellido nvarchar(max),
			dni nvarchar(max),
			direccion nvarchar(max),
			emailPersonal nvarchar(max),
			emailEmpresa nvarchar(max),
			cuil nvarchar(max),
			cargo nvarchar(max),
			sucursal nvarchar(max),
			turno nvarchar(max))


END
GO

