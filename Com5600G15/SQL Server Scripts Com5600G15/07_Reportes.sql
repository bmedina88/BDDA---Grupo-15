--ENTREGA: Creación de Reportes
--FECHA DE ENTREGA: 29/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371


USE Com5600G15;
GO

------Reporte Mensual: Total facturado por días de la semana----------
CREATE OR ALTER PROCEDURE Reportes.TotalFacturadoPorDiaDeLaSemana(
@Year INT,
@Month INT)
AS
BEGIN

SELECT 
    DATENAME(WEEKDAY, F.fecha) AS DiaSemana,
    SUM(VD.cantidad * VD.precioUnitario) AS TotalFacturado
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
WHERE YEAR(F.fecha) = @Year AND MONTH(F.fecha) = @Month
GROUP BY DATENAME(WEEKDAY, F.fecha)
ORDER BY 
    CASE DATENAME(WEEKDAY, F.fecha)
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END

FOR XML AUTO, ROOT('ReporteMensual');
END
GO
------Reporte Trimestral: Total facturado por turnos de trabajo por mes-------
CREATE OR ALTER PROCEDURE Reportes.TotalFacturadoPorTurnoDeTrabajoPorMes(
@StartDate DATE,
@EndDate DATE)
AS
BEGIN

SELECT 
    DATENAME(MONTH, F.fecha) AS Mes,
    E.turno AS Turno,
    SUM(VD.cantidad * VD.precioUnitario) AS TotalFacturado
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Super.Empleado E ON F.empleado = E.idEmpleado
WHERE F.fecha BETWEEN @StartDate AND @EndDate
GROUP BY DATENAME(MONTH, F.fecha), E.turno
ORDER BY Mes, Turno

FOR XML AUTO, ROOT('ReporteTrimestral');
END
GO
------Reporte por rango de fechas: Cantidad de productos vendidos en rango de fechas ordenado de mayor a menor---------------
CREATE OR ALTER PROCEDURE Reportes.CantidadProductosVendidosEntreFechas(
@StartDate DATE,
@EndDate DATE)
AS
BEGIN

SELECT 
    P.nombre AS Producto,
    SUM(VD.cantidad) AS CantidadVendida
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Producto.Producto P ON VD.producto = P.idProducto
WHERE F.fecha BETWEEN @StartDate AND @EndDate
GROUP BY P.nombre
ORDER BY CantidadVendida DESC
FOR XML AUTO, ROOT('ReporteProductosVendidos');

SELECT 
    SUM(VD.cantidad) AS TotalCantidadVendida
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
WHERE F.fecha BETWEEN @StartDate AND @EndDate


END
GO
------Reporte por rango de fechas: Cantidad de productos vendidos en rango de fechas POR SUCURSAL ordenado de mayor a menor---------------
CREATE OR ALTER PROCEDURE Reportes.CantidadProductosVendidosEntreFechasPorSucursal(
@StartDate DATE,
@EndDate DATE)
AS
BEGIN

SELECT 
    S.sucursal AS Sucursal,
    P.nombre AS Producto,
    SUM(VD.cantidad) AS CantidadVendida
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Producto.Producto P ON VD.producto = P.idProducto
JOIN Super.Empleado E ON F.empleado = E.idEmpleado
JOIN Super.Sucursal S ON E.sucursal = S.idSucursal
WHERE F.fecha BETWEEN @StartDate AND @EndDate
GROUP BY S.sucursal, P.nombre
ORDER BY S.sucursal, CantidadVendida DESC
FOR XML AUTO, ROOT('ReporteProductosPorSucursal');

SELECT 
     s.sucursal, SUM(VD.cantidad) AS TotalCantidadVendida
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Super.Empleado E ON F.empleado = E.idEmpleado
JOIN Super.Sucursal S ON E.sucursal = S.idSucursal
WHERE F.fecha BETWEEN @StartDate AND @EndDate
GROUP BY S.sucursal, s.sucursal
ORDER BY TotalCantidadVendida DESC


END
GO
------TOP 5: 5 productos menos vendidos en el mes---------------
CREATE OR ALTER PROCEDURE Reportes.ProductosMasVendidosEnMes(
@Year INT,
@Month INT)
AS
BEGIN

SELECT TOP 5 
    P.nombre AS Producto,
    SUM(VD.cantidad) AS CantidadVendida
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Producto.Producto P ON VD.producto = P.idProducto
WHERE YEAR(F.fecha) = @Year AND MONTH(F.fecha) = @Month
GROUP BY P.nombre
ORDER BY CantidadVendida ASC
FOR XML AUTO, ROOT('ReporteTop5MenosVendidos');

END
GO
------TOP 5: 5 productos más vendidos en un mes, por semana---------------
CREATE OR ALTER PROCEDURE Reportes.ProductosMasVendidosEnMesPorSemana(
@Year INT,
@Month INT)
AS
BEGIN

WITH ProductoVentas AS (
    SELECT
        P.nombre AS Producto,
        DATEPART(WEEK, F.fecha) AS Semana,
        SUM(VD.cantidad) AS CantidadVendida
    FROM Venta.Factura F
    JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
    JOIN Producto.Producto P ON VD.producto = P.idProducto
    WHERE YEAR(F.fecha) = @Year AND MONTH(F.fecha) = @Month
    GROUP BY P.nombre, DATEPART(WEEK, F.fecha)
)
SELECT TOP 5 *
FROM ProductoVentas
ORDER BY CantidadVendida DESC
FOR XML AUTO, ROOT('ReporteTop5MasVendidos');

END
GO
------Total acumulado: Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha y sucursal particulares---------------
CREATE OR ALTER PROCEDURE Reportes.TotalAcumuladoPorSucursalEnFecha(
@Fecha DATE,
@SucursalID INT)
AS
BEGIN    

SELECT 
    F.fecha AS Fecha,
    S.sucursal AS Sucursal,
    P.nombre AS Producto,
    VD.cantidad AS CantidadVendida,
    VD.cantidad * P.precio AS TotalPorProducto
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Producto.Producto P ON VD.producto = P.idProducto
JOIN Super.Empleado E ON F.empleado = E.idEmpleado
JOIN Super.Sucursal S ON E.sucursal = S.idSucursal
WHERE S.idSucursal = @SucursalID AND F.fecha = @Fecha 
FOR XML AUTO, ROOT('ReporteTotalAcumulado');


SELECT SUM(VD.cantidad * P.precio) AS TotalVendido
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Producto.Producto P ON VD.producto = P.idProducto
JOIN Super.Empleado E ON F.empleado = E.idEmpleado
JOIN Super.Sucursal S ON E.sucursal = S.idSucursal
WHERE S.idSucursal = @SucursalID AND F.fecha = @Fecha 

END
GO