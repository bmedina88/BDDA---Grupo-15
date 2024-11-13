--ENTREGA 4: Importación de datos. 
--FECHA DE ENTREGA: 08/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

use Com5600G15;
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

--PRUEBA DE CONEXION CON EXCEL
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
	IF OBJECT_ID('tempdb..#SucursalTemp') IS NULL
		CREATE TABLE #SucursalTemp(
			ciudad nvarchar(max),
			sucursal nvarchar(max),
			direccion nvarchar(max),
			horario nvarchar(max),
			telefono nvarchar(max))


	

	INSERT INTO #SucursalTemp
		SELECT * FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'SELECT * FROM [Sucursal$]');
	

	INSERT INTO Super.Sucursal(ciudad, sucursal, direccion, horario, telefono)
	SELECT ciudad, sucursal, direccion, horario, telefono
	FROM #SucursalTemp AS T
	WHERE T.sucursal NOT IN (SELECT S.sucursal FROM Super.Sucursal AS S);
	
	DROP TABLE IF EXISTS #SucursalTemp;
END
GO



-- Importación Medios de Pago
CREATE OR ALTER PROCEDURE Venta.ImportarMedioPago(
@ruta nvarchar(max) )
AS
BEGIN
	IF OBJECT_ID('tempdb..#MedioPagoTemp') IS NULL
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
		IF OBJECT_ID('tempdb..#EmpleadoTemp') IS NULL
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


		INSERT INTO #EmpleadoTemp
			SELECT * FROM OPENROWSET(
			'Microsoft.ACE.OLEDB.12.0',
			'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
			'SELECT * FROM [Empleados$]');

		WITH EmpleadoConFk AS
		(SELECT T.legajo, T.dni, T.cuil, T.emailPersonal, T.cargo, T.turno, (SELECT S.idSucursal FROM Super.Sucursal AS S WHERE S.sucursal=T.sucursal) AS idSucursal
		FROM #EmpleadoTemp as T 
		WHERE T.legajo IS NOT NULL)
		INSERT INTO Super.Empleado(idEmpleado, dni, cuil, email, cargo, turno, sucursal)
		SELECT * 
		FROM EmpleadoConFk as F
		WHERE F.legajo NOT IN (SELECT E.idEmpleado FROM Super.Empleado AS E);	
		
		DROP TABLE IF EXISTS #EmpleadoTemp;
END
GO



--Importación de Categorias
CREATE OR ALTER PROCEDURE Producto.ImportarCategorias(
	@RUTA nvarchar(max))
AS
BEGIN
	IF OBJECT_ID('tempdb..#CategoriaTemp') IS NULL
		CREATE TABLE #CategoriaTemp(
			categoria nvarchar(max),
			producto nvarchar(max))

	INSERT INTO #CategoriaTemp
		SELECT * FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'SELECT * FROM [Clasificacion productos$]');	

	INSERT INTO Producto.Categoria (nombre)
	SELECT DISTINCT T.categoria
	FROM #CategoriaTemp AS T
	WHERE T.categoria NOT IN (SELECT C.nombre FROM Producto.Categoria AS C)


	DROP TABLE IF EXISTS #CategoriaTemp;
END
GO


--Importación de Productos Electrónicos 
CREATE OR ALTER PROCEDURE Producto.ImportarProductosElectronicos(
	@RUTA nvarchar(max))
AS
BEGIN
	IF (NOT EXISTS (SELECT * FROM Producto.Categoria WHERE nombre='Electrónicos'))
		INSERT INTO Producto.Categoria (nombre) VALUES ('Electrónicos')
	
	IF OBJECT_ID('tempdb..#ProductoElectronicoTemp') IS NULL
		CREATE TABLE #ProductoElectronicoTemp(
			producto nvarchar(max),
			precio nvarchar(max))

	INSERT INTO #ProductoElectronicoTemp
		SELECT * FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Productos\Electronic accessories.xlsx',
		'SELECT * FROM [Sheet1$]');	

	INSERT INTO Producto.Producto (categoria, nombre, precio)
	SELECT (SELECT C.idCategoria FROM Producto.Categoria AS C WHERE nombre='Electrónicos'), * 
	FROM #ProductoElectronicoTemp AS T
	WHERE T.producto NOT IN (SELECT P.nombre FROM Producto.Producto AS P)

	DROP TABLE IF EXISTS #ProductoElectronicoTemp;
END
GO


--Importación Productos Importados
CREATE OR ALTER PROCEDURE Producto.ImportarProductosImportado(
	@RUTA nvarchar(max))
AS
BEGIN
	IF OBJECT_ID('tempdb..#ProductoImportadoTemp') IS NULL
		CREATE TABLE #ProductoImportadoTemp(
			id nvarchar(max),
			nombre nvarchar(max),
			proveedor nvarchar(max),
			categoria nvarchar(max),
			cantidadPorUnidad nvarchar(max),
			precioPorUnidad nvarchar(max))

	INSERT INTO #ProductoImportadoTemp
		SELECT * FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Productos\Productos_importados.xlsx',
		'SELECT * FROM [Listado de Productos$]');	

	--Creación de categorias no registradas 

	INSERT INTO Producto.Categoria (nombre)
	SELECT DISTINCT T.categoria
	FROM #ProductoImportadoTemp AS T
	WHERE T.categoria NOT IN (SELECT C.nombre FROM Producto.Categoria AS C);

	---SS

	WITH ProductoImportadoConFk AS 
	( 
		SELECT (SELECT C.idCategoria FROM Producto.Categoria AS C WHERE T.categoria=C.nombre) AS idCategoria, T.nombre, T.precioPorUnidad
		FROM #ProductoImportadoTemp AS T
	)
	INSERT INTO Producto.Producto (categoria, nombre, precio)
	SELECT *
	FROM ProductoImportadoConFk AS C
	WHERE NOT EXISTS(SELECT * FROM Producto.Producto AS P WHERE P.nombre=C.nombre AND P.categoria=C.idCategoria) 
	

	DROP TABLE IF EXISTS #ProductoImportadoTemp;
END
GO


create or alter procedure producto.insertarCatalogo(
@Ruta nvarchar(max))
as
begin
		IF OBJECT_ID('tempdb..#catalogoTemp') IS NOT NULL
			DROP TABLE #catalogoTemp;

		CREATE TABLE #catalogoTemp(
			id nvarchar(max),
			categoria nvarchar(max),
			nombre nvarchar(max),
			precio nvarchar(max),
			precio_referencia nvarchar(max),
			referencia_unidad nvarchar(max),
			fecha nvarchar(max)
			)


DECLARE @sql NVARCHAR(MAX);
SET @sql = N'
BULK INSERT #catalogoTemp
FROM ''' + @Ruta + '''
WITH (
    FIELDTERMINATOR = '','',  -- Delimitador de campos
    ROWTERMINATOR = ''\n'',  -- Delimitador de filas
    FIRSTROW = 2,            -- Ignorar encabezados
    CODEPAGE = ''65001''     -- Codificaci?n UTF-8
);';

EXEC sp_executesql @sql;


		-- Insertar categorias si no existen
		INSERT INTO Producto.Categoria (nombre)
		SELECT DISTINCT categoria
		FROM #catalogoTemp
		WHERE categoria NOT IN (
			SELECT nombre FROM Producto.Categoria
		);


-- Insertar productos en la tabla Producto.Producto si no existen
		INSERT INTO Producto.Producto (idProducto, categoria, nombre, precio)
		SELECT 
			TRY_CAST(temp.id AS INT) AS idProducto, -- Usar el id del archivo como idProducto
			(SELECT TOP 1 idCategoria FROM Producto.Categoria WHERE nombre = temp.categoria), 
			temp.nombre,
			TRY_CAST(temp.precio AS DECIMAL(10, 2)) -- Conversión del precio a DECIMAL
		FROM #catalogoTemp AS temp
		WHERE NOT EXISTS (
			SELECT 1 
			FROM Producto.Producto AS prod
			WHERE prod.idProducto = TRY_CAST(temp.id AS INT) -- Validar si el idProducto ya existe
			   OR prod.nombre = temp.nombre
		);


drop table #catalogoTemp
end


EXEC Producto.ImportarCategorias'S'
EXEC Producto.ImportarProductosImportado 'S'
SELECT * FROM Producto.Categoria
SeLECT * FROM Producto.producto


