--ENTREGA 4: Importación de datos. 
--FECHA DE ENTREGA: 08/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

use Com5600G15;
--Activar consultas distribuidas
GO
EXEC sp_configure 'Show Advanced', 1
RECONFIGURE
GO
EXEC sp_configure 'Ad hoc dis', 1
RECONFIGURE
GO



--PRUEBA DE CONEXION CON EXCEL
SELECT * FROM OPENROWSET(
	'Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
	'SELECT * FROM [medios de pago$]'
)
GO



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
	DROP TABLE IF EXISTS #CategoriaTemp;
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


--Importación Productos Catalogo
CREATE OR ALTER PROCEDURE Producto.ImportarProductosCatalogo(
	@RUTACATALAGO nvarchar(max),
	@RUTACATEGORIAS nvarchar(max))
AS
BEGIN
	DROP TABLE IF EXISTS #CategoriaTemp;
	--Precarga de Categorias y su detalle para su posterior busqueda
	IF OBJECT_ID('tempdb..#CategoriaTemp') IS NULL
		CREATE TABLE #CategoriaTemp(
			categoria nvarchar(max),
			producto nvarchar(max))

	INSERT INTO #CategoriaTemp (categoria, producto)
		SELECT *
		FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Informacion_complementaria.xlsx',
		'SELECT * FROM [Clasificacion productos$]');


	--Importación catalago
	DROP TABLE IF EXISTS #CatalogoTemp;
	IF OBJECT_ID('tempdb..#CatalogoTemp') IS NULL
		CREATE TABLE #CatalogoTemp(
			id nvarchar(max),
			categoria nvarchar(max),
			nombre nvarchar(max),
			precio nvarchar(max),
			precio_referencia nvarchar(max),
			unidad_referencia nvarchar(max),
			fecha nvarchar(max))

	BULK INSERT #CatalogoTemp
	FROM 'C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Productos\catalogo.csv'
	WITH 
	(	
		FORMAT = 'CSV',
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0a',
		CODEPAGE = '65001'
	);


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




		DROP TABLE IF EXISTS #CategoriaTemp;
		DROP TABLE IF EXISTS #CatalogoTemp;
END
GO


--Importación Ventas
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


	BULK INSERT #VentaTemp
	FROM 'C:\Users\beybr\OneDrive\Escritorio\TP_integrador_Archivos\Ventas_registradas.csv'
	WITH 
	(	
		FORMAT = 'CSV',
		FIRSTROW = 2,
		FIELDTERMINATOR = ';',
		ROWTERMINATOR = '0x0a',
		CODEPAGE = '65001'
	);

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

--Import VentaDetalle
INSERT INTO Venta.VentaDetalle(cantidad, idfactura, producto)
SELECT T.cantidad, (SELECT F.id FROM Venta.Factura AS F WHERE F.idfactura=T.idFactura),
		(SELECT P.idProducto FROM Producto.Producto AS P WHERE P.nombre = T.producto AND P.precio = T.precioUnitario)
FROM #VentaTemp AS T

--NOTA: PENSAR UN UPDATE AL INGRESAR PRODUCTO REPETIDO 

END
GO





