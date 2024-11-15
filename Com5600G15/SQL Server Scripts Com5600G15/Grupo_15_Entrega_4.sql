--ENTREGA 4: Importación de datos. 
--FECHA DE ENTREGA: 08/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

use Com5600G15;
--Activa consultas distribuidas
GO
EXEC sp_configure 'Show Advanced', 1
RECONFIGURE
GO
EXEC sp_configure 'Ad hoc dis', 1
RECONFIGURE
GO


--Muestra la cantidad de registros esperados e importados. Usado para testing
CREATE OR ALTER PROCEDURE Super.MostrarCantidadImportadaYEsperada (
@cantidadEsperada int,
@cantidadImportada int)
AS
BEGIN
	SELECT @cantidadEsperada as CantidadEsperada, @cantidadImportada as CantidadImportada
	--return;
END
GO



-- Importación sucursal (Usa: Informacion_complementaria.xlsx)
CREATE OR ALTER PROCEDURE Super.importarSucursal(
@ruta nvarchar(max))
AS
BEGIN
	DROP TABLE IF EXISTS #SucursalTemp;

	CREATE TABLE #SucursalTemp(
		ciudad nvarchar(max),
		sucursal nvarchar(max),
		direccion nvarchar(max),
		horario nvarchar(max),
		telefono nvarchar(max))


	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		INSERT INTO #SucursalTemp
			SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@ruta+''',
			''SELECT * FROM [Sucursal$]'');'

	EXEC sp_executesql @sql
	
	DECLARE @cantidadEsperada int;
	SELECT @cantidadEsperada = @@ROWCOUNT;

	INSERT INTO Super.Sucursal(ciudad, sucursal, direccion, horario, telefono)
	SELECT ciudad, sucursal, direccion, horario, telefono
	FROM #SucursalTemp AS T
	WHERE T.sucursal NOT IN (SELECT S.sucursal FROM Super.Sucursal AS S);

	--Informe errores/advertencias
	DECLARE @cantidadImportada int;
	SELECT @cantidadImportada = @@ROWCOUNT;
	DECLARE @cantidadRepetida int;
	SELECT @cantidadRepetida = @cantidadEsperada - @cantidadImportada;

	EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperada, @cantidadImportada;
	IF (@cantidadRepetida>0)
		RAISERROR('Se encontraron %d sucursales repetidas y no se importaron',10,1,@cantidadRepetida)
END
GO


-- Importación Medios de Pago (Usa: Informacion_complementaria.xlsx)
CREATE OR ALTER PROCEDURE Venta.ImportarMedioPago(
@ruta nvarchar(max) )
AS
BEGIN
	DROP TABLE IF EXISTS #MedioPagoTemp;
	CREATE TABLE #MedioPagoTemp(
		descripcion nvarchar(max))
	

	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		INSERT INTO #MedioPagoTemp
			SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@ruta+''',
			''SELECT [F2] FROM [medios de pago$]'');'

	EXEC sp_executesql @sql

	DECLARE @cantidadEsperada int;
	SELECT @cantidadEsperada = @@ROWCOUNT;
	

	INSERT INTO Venta.MedioPago(descripcion)
	SELECT descripcion
	FROM #MedioPagoTemp as T
	WHERE T.descripcion NOT IN (SELECT M.descripcion FROM Venta.MedioPago AS M);

	--Informe errores/advertencias
	DECLARE @cantidadImportada int;
	SELECT @cantidadImportada = @@ROWCOUNT;
	DECLARE @cantidadRepetida int;
	SELECT @cantidadRepetida = @cantidadEsperada - @cantidadImportada;

	EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperada, @cantidadImportada;
	IF (@cantidadRepetida>0)
		RAISERROR('Se encontraron %d Medios de Pagos repetidas y no se importaron',10,1,@cantidadRepetida)
END
GO


--Importación Empleados (Usa: Informacion_complementaria.xlsx)
CREATE OR ALTER PROCEDURE Super.ImportarEmpleados(
	@RUTA nvarchar(max) )
AS
BEGIN
	DROP TABLE IF EXISTS #EmpleadoTemp;
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


	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		INSERT INTO #EmpleadoTemp
			SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@ruta+''',
			''SELECT * FROM [Empleados$]'');'

	EXEC sp_executesql @sql;

	DECLARE @cantidadEsperada int;
	SELECT @cantidadEsperada = count(*)
	FROM #EmpleadoTemp
	WHERE legajo IS NOT NULL;

	WITH EmpleadoConFk AS
		(SELECT T.legajo, T.dni, T.cuil, T.emailPersonal, T.cargo, T.turno, (SELECT S.idSucursal FROM Super.Sucursal AS S WHERE S.sucursal=T.sucursal) AS idSucursal
		FROM #EmpleadoTemp as T 
		WHERE T.legajo IS NOT NULL)
	INSERT INTO Super.Empleado(idEmpleado, dni, cuil, email, cargo, turno, sucursal)
		SELECT * 
		FROM EmpleadoConFk as F
		WHERE F.legajo NOT IN (SELECT E.idEmpleado FROM Super.Empleado AS E);

	--Informe errores/advertencias
	DECLARE @cantidadImportada int;
	SELECT @cantidadImportada = @@ROWCOUNT;
	DECLARE @cantidadRepetida int;
	SELECT @cantidadRepetida = @cantidadEsperada - @cantidadImportada;

	EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperada, @cantidadImportada;
	IF (@cantidadRepetida>0)
		RAISERROR('Se encontraron %d Empleados repetidas y no se importaron',10,1,@cantidadRepetida)
END
GO


--Importación de Categorias (Usa: Informacion_complementaria.xlsx)
CREATE OR ALTER PROCEDURE Producto.ImportarCategorias(
	@RUTA nvarchar(max))
AS
BEGIN
	DROP TABLE IF EXISTS #CategoriaTemp;
	CREATE TABLE #CategoriaTemp(
		categoria nvarchar(max),
		producto nvarchar(max))


	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		INSERT INTO #CategoriaTemp
			SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@ruta+''',
			''SELECT * FROM [Clasificacion productos$]'');'

	EXEC sp_executesql @sql

	
	DECLARE @cantidadEsperada int;
	SELECT @cantidadEsperada = COUNT(*)
	FROM (SELECT DISTINCT categoria FROM #CategoriaTemp) AS subConsulta;


	INSERT INTO Producto.Categoria (nombre)
	SELECT DISTINCT T.categoria
	FROM #CategoriaTemp AS T
	WHERE T.categoria NOT IN (SELECT C.nombre FROM Producto.Categoria AS C)

	--Informe errores/advertencias
	DECLARE @cantidadImportada int;
	SELECT @cantidadImportada = @@ROWCOUNT;
	DECLARE @cantidadRepetida int;
	SELECT @cantidadRepetida = @cantidadEsperada - @cantidadImportada;

	EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperada, @cantidadImportada;
	IF (@cantidadRepetida>0)
		RAISERROR('Se encontraron %d Categorias repetidas y no se importaron',10,1,@cantidadRepetida)
END
GO


--Importación de Productos Electrónicos (Usa: Electronic accessories.xlsx)
CREATE OR ALTER PROCEDURE Producto.ImportarProductosElectronicos(
	@RUTA nvarchar(max))
AS
BEGIN
	DROP TABLE IF EXISTS #ProductoElectronicoTemp;
	CREATE TABLE #ProductoElectronicoTemp(
		producto nvarchar(max),
		precio nvarchar(max))

	IF (NOT EXISTS (SELECT * FROM Producto.Categoria WHERE nombre='Electrónicos'))
		INSERT INTO Producto.Categoria (nombre) VALUES ('Electrónicos')


	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		INSERT INTO #ProductoElectronicoTemp
			SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@ruta+''',
			''SELECT * FROM [Sheet1$]'');'

	EXEC sp_executesql @sql

	DECLARE @cantidadEsperada int;
	SELECT @cantidadEsperada = @@ROWCOUNT;


	INSERT INTO Producto.Producto (categoria, nombre, precio)
	SELECT (SELECT C.idCategoria FROM Producto.Categoria AS C WHERE nombre='Electrónicos'), * 
	FROM #ProductoElectronicoTemp AS T
	WHERE T.producto NOT IN (SELECT P.nombre FROM Producto.Producto AS P)
	

	--Informe errores/advertencias
	DECLARE @cantidadImportada int;
	SELECT @cantidadImportada = @@ROWCOUNT;
	DECLARE @cantidadRepetida int;
	SELECT @cantidadRepetida = @cantidadEsperada - @cantidadImportada;

	EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperada, @cantidadImportada;
	IF (@cantidadRepetida>0)
		RAISERROR('Se encontraron %d Productos Electronicos repetidos y no se importaron',10,1,@cantidadRepetida)
END
GO


--Importación Productos Importados (Usa: Productos_importados.xlsx)
CREATE OR ALTER PROCEDURE Producto.ImportarProductosImportado(
	@RUTA nvarchar(max))
AS
BEGIN
	DROP TABLE IF EXISTS #ProductoImportadoTemp;
	CREATE TABLE #ProductoImportadoTemp(
		id nvarchar(max),
		nombre nvarchar(max),
		proveedor nvarchar(max),
		categoria nvarchar(max),
		cantidadPorUnidad nvarchar(max),
		precioPorUnidad nvarchar(max))


	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		INSERT INTO #ProductoImportadoTemp
			SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@ruta+''',
			''SELECT * FROM [Listado de Productos$]'');'

	EXEC sp_executesql @sql

	DECLARE @cantidadEsperada int;
	SELECT @cantidadEsperada = @@ROWCOUNT;


	--Creación de categorias no registradas 

	INSERT INTO Producto.Categoria (nombre)
	SELECT DISTINCT T.categoria
	FROM #ProductoImportadoTemp AS T
	WHERE T.categoria NOT IN (SELECT C.nombre FROM Producto.Categoria AS C);

	--

	WITH ProductoImportadoConFk AS 
	( 
		SELECT (SELECT C.idCategoria FROM Producto.Categoria AS C WHERE T.categoria=C.nombre) AS idCategoria, T.nombre, T.precioPorUnidad
		FROM #ProductoImportadoTemp AS T
	)
	INSERT INTO Producto.Producto (categoria, nombre, precio)
	SELECT *
	FROM ProductoImportadoConFk AS C
	WHERE NOT EXISTS(SELECT * FROM Producto.Producto AS P WHERE P.nombre=C.nombre AND P.categoria=C.idCategoria) 

	--Informe errores/advertencias
	DECLARE @cantidadImportada int;
	SELECT @cantidadImportada = @@ROWCOUNT;
	DECLARE @cantidadRepetida int;
	SELECT @cantidadRepetida = @cantidadEsperada - @cantidadImportada;

	EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperada, @cantidadImportada;
	IF (@cantidadRepetida>0)
		RAISERROR('Se encontraron %d Productos Importados repetidos y no se importaron',10,1,@cantidadRepetida)
END
GO


--Importación Productos Catalogo (Usa: catalogo.csv, Informacion_complementaria,xlsx)
CREATE OR ALTER PROCEDURE Producto.ImportarProductosCatalogo(
	@RUTACATALAGO nvarchar(max),
	@RUTACATEGORIAS nvarchar(max))
AS
BEGIN
	DROP TABLE IF EXISTS #CategoriaTemp;
	--Precarga de Categorias y su detalle para su posterior busqueda
	CREATE TABLE #CategoriaTemp(
		categoria nvarchar(max),
		producto nvarchar(max));


	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		INSERT INTO #CategoriaTemp
			SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;Database='+@RUTACATEGORIAS+''',
			''SELECT * FROM [Clasificacion productos$]'');';

	EXEC sp_executesql @sql;


	--Importación catalago
	DROP TABLE IF EXISTS #CatalogoTemp;
	CREATE TABLE #CatalogoTemp(
		id nvarchar(max),
		categoria nvarchar(max),
		nombre nvarchar(max),
		precio nvarchar(max),
		precio_referencia nvarchar(max),
		unidad_referencia nvarchar(max),
		fecha nvarchar(max));

	
	DECLARE @sql2 nvarchar(max);
	SELECT @sql2 = '
		BULK INSERT #CatalogoTemp
		FROM '''+@RUTACATALAGO+'''
		WITH 
		(	
			FORMAT = ''CSV'',
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''0x0a'',
			CODEPAGE = ''65001''
		);'
	EXEC sp_executesql @sql2;

	DECLARE @cantidadEsperada int;
	SELECT @cantidadEsperada = @@ROWCOUNT;

	WITH CategoriaConFk AS
	(
		SELECT CTC.*, CC.idCategoria
		FROM Producto.Categoria AS CC 
		RIGHT JOIN #CategoriaTemp AS CTC ON CC.nombre=CTC.categoria
	), 
	CatalogoConFk AS
	(
		SELECT  (SELECT CCFK.idCategoria
				FROM CategoriaConFk AS CCFK
				WHERE CCFK.producto=T.categoria) AS idCategoria,  T.nombre, T.precio
		FROM #CatalogoTemp AS T
	)
	INSERT INTO Producto.Producto (categoria, nombre, precio)
	SELECT *
	FROM CatalogoConFk AS CACFK
	WHERE NOT EXISTS(SELECT * FROM Producto.Producto AS P WHERE P.categoria=CACFK.idCategoria AND P.nombre=CACFK.nombre)


	--Informe errores/advertencias
	DECLARE @cantidadImportada int;
	SELECT @cantidadImportada = @@ROWCOUNT;
	DECLARE @cantidadRepetida int;
	SELECT @cantidadRepetida = @cantidadEsperada - @cantidadImportada;

	EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperada, @cantidadImportada;
	IF (@cantidadRepetida>0)
		RAISERROR('Se encontraron %d Productos del Catalogo repetidos y no se importaron',10,1,@cantidadRepetida)
END
GO


--Importación Ventas (Usa: Ventas_registradas.csv)
CREATE OR ALTER PROCEDURE Venta.ImportarVentas(
	@RUTA NVARCHAR(MAX))
AS
BEGIN
	DROP TABLE IF EXISTS #VentaTemp
	CREATE TABLE #VentaTemp(
	idFactura nvarchar(max),
	tipoFactura nvarchar(max),
	ciudadSucursal nvarchar(max),
	tipoCliente nvarchar(max),
	genero nvarchar(max),
	producto nvarchar(max),
	precioUnitario nvarchar(max),
	cantidad nvarchar(max),
	fecha nvarchar(max),
	hora nvarchar(max),
	medioPago nvarchar(max),
	empleado nvarchar(max),
	idPago nvarchar(max))

	DECLARE @sql nvarchar(max);
	SELECT @sql = '
		BULK INSERT #VentaTemp
		FROM '''+@RUTA+'''
		WITH 
		(	
			FORMAT = ''CSV'',
			FIRSTROW = 2,
			FIELDTERMINATOR = '';'',
			ROWTERMINATOR = ''0x0a'',
			CODEPAGE = ''65001''
		);'
	EXEC sp_executesql @sql;

	--DECLARE @cantidadEsperadaVentaDetalle int;
	--SELECT @cantidadEsperadaVentaDetalle = @@ROWCOUNT;

	DECLARE @cantidadEsperadaFactura int;
	SELECT @cantidadEsperadaFactura = COUNT(*)
	FROM (SELECT DISTINCT idFactura FROM #VentaTemp) AS subconsulta;


--Update para acentos
	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Ã¡', 'á')
	WHERE producto LIKE '%Ã¡%';

	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Ã©', 'é')
	WHERE producto LIKE '%Ã©%';

	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Ã­', 'í')
	WHERE producto LIKE '%Ã­%';

	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Ã³', 'ó')
	WHERE producto LIKE '%Ã³%';

	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Ãº', 'ú')
	WHERE producto LIKE '%Ãº%';

	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Ã±', 'ñ')
	WHERE producto LIKE '%Ã±%';

	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Âº', 'º')
	WHERE producto LIKE '%Âº%';

	UPDATE #VentaTemp
	SET producto = REPLACE(producto, 'Â', 'ª')
	WHERE producto LIKE '%Âª%';

--Import clientes default
INSERT INTO Super.TipoCliente (descripcion, genero)
SELECT VT.tipoCliente, VT.genero
FROM #VentaTemp AS VT
WHERE NOT EXISTS (SELECT * FROM Super.TipoCliente AS TC WHERE TC.descripcion=VT.tipoCliente AND TC.genero=VT.genero)
GROUP BY VT.tipoCliente, VT.genero



--Import Factura
INSERT INTO Venta.Factura(idfactura,tipoFactura, idpago, fecha, hora, empleado, medioPago, cliente)
SELECT T.idFactura, T.tipoFactura, T.idPago, T.fecha, T.hora, T.empleado, (SELECT M.idMedioPago FROM Venta.MedioPago AS M WHERE M.descripcion=T.medioPago),
		(SELECT TC.idTipoCliente FROM Super.TipoCliente AS TC WHERE TC.descripcion=T.tipoCliente AND TC.genero=T.genero)
FROM #VentaTemp AS T
WHERE NOT EXISTS (SELECT * FROM Venta.Factura AS F WHERE F.idfactura=T.idFactura)
GROUP BY T.idFactura,T.tipoFactura, idPago, fecha, hora, empleado, medioPago, tipoCliente, genero

DECLARE @cantidadImportadaFactura int;
SELECT @cantidadImportadaFactura = @@ROWCOUNT;

--Import VentaDetalle
INSERT INTO Venta.VentaDetalle(cantidad, idfactura, producto)
SELECT T.cantidad, (SELECT F.id FROM Venta.Factura AS F WHERE F.idfactura=T.idFactura),
		(SELECT TOP(1) P.idProducto FROM Producto.Producto AS P WHERE P.nombre = T.producto AND P.precio = T.precioUnitario)
FROM #VentaTemp AS T

--NOTA: PENSAR UN UPDATE AL INGRESAR PRODUCTO REPETIDO 

--Informe errores/advertencias
--DECLARE @cantidadImportadaVentaDetalle int;
--SELECT @cantidadImportadaVentaDetalle = @@ROWCOUNT;
--DECLARE @cantidadRepetidaVentaDetalle int;
--SELECT @cantidadRepetidaVentaDetalle = @cantidadEsperadaVentaDetalle - @cantidadImportadaVentaDetalle;
DECLARE @cantidadRepetidaFactura int;
SELECT @cantidadRepetidaFactura = @cantidadEsperadaFactura - @cantidadImportadaFactura;

EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperadaFactura, @cantidadImportadaFactura;
IF (@cantidadRepetidaFactura>0)
	RAISERROR('Se encontraron %d Facturas repetidas y no se importaron',10,1,@cantidadRepetidaFactura)

--EXEC Super.MostrarCantidadImportadaYEsperada @cantidadEsperadaVentaDetalle, @cantidadImportadaVentaDetalle;
--IF (@cantidadRepetidaVentaDetalle>0)
--	RAISERROR('Se encontraron %d DetalleVentas repetidas y no se importaron',10,1,@cantidadRepetidaVentaDetalle)
END
GO


