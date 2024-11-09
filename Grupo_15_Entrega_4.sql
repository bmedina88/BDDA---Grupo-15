--ENTREGA 4: Importación de datos. 
--FECHA DE ENTREGA: 08/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 


------Activar consultas distribuidas
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
    IDFactura VARCHAR(50),
    TipoFactura VARCHAR(50),
    Ciudad VARCHAR(50),
    TipoCliente VARCHAR(50),
    Genero VARCHAR(50),
    Producto NVARCHAR(max),
    PrecioUnitario VARCHAR(50),
    Cantidad VARCHAR(50),
    Fecha VARCHAR(50),
    Hora VARCHAR(50),
    MedioPago VARCHAR(50),
    Empleado VARCHAR(50),
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


INSERT INTO Venta.MedioPago (descripcion)
SELECT DISTINCT MedioPago
FROM #VentasTemp
WHERE MedioPago NOT IN (SELECT descripcion FROM Venta.MedioPago);



INSERT INTO Super.TipoCliente (descripcion, genero)
SELECT DISTINCT vt.TipoCliente, vt.Genero
FROM #VentasTemp AS vt
LEFT JOIN Super.TipoCliente AS tc
    ON vt.TipoCliente = tc.descripcion AND vt.Genero = tc.genero
WHERE tc.descripcion IS NULL;



INSERT INTO Producto.Producto (idProducto, origen, nombre, precio, categoria)
SELECT DISTINCT 
    ROW_NUMBER() OVER (ORDER BY Producto) AS idProducto, 
    1 AS origen,  -- Ajusta el valor de origen según sea necesario
    Producto,
    CAST(PrecioUnitario AS DECIMAL(10,2)),
    (SELECT idCategoria FROM Producto.Categoria WHERE nombre = 'Categoría')  -- Ajusta la categoría según sea necesario
FROM #VentasTemp
WHERE Producto NOT IN (SELECT nombre FROM Producto.Producto);



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



exec venta.importar_ventas 'C:\TP_integrador_Archivos\Ventas_registradas.csv'


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


	CREATE TABLE #SucursalTemp(
		ciudadAnterior nvarchar(max),
		ciudad nvarchar(max),
		direccion nvarchar(max),
		horario nvarchar(max),
		telefono nvarchar(max),)
	

	INSERT INTO #SucursalTemp
		SELECT * FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'SELECT * FROM [Sucursal$]');
	

	INSERT INTO Super.Sucursal(ciudad, ciudadAnterior, direccion,horario, telefono)
	SELECT ciudad,ciudadAnterior, direccion, horario, telefono
	FROM #SucursalTemp;
	

	DROP TABLE IF EXISTS #SucursalTemp;
END

EXEC Super.importarSucursal 'C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx';
select * from Super.Sucursal

----probando--
select 1