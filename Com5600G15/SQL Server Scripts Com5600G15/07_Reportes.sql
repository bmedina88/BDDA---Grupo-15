--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

--Reportes

USE Com5600G15;

------Reporte Mensual: Total facturado por días de la semana----------
BEGIN

DECLARE @Year INT = 2024; -- Cambiar según corresponda
DECLARE @Month INT = 11;  -- Cambiar según corresponda

SELECT 
    DATENAME(WEEKDAY, F.fecha) AS DiaSemana,
    SUM(VD.cantidad * P.precio) AS TotalFacturado
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Producto.Producto P ON VD.producto = P.idProducto
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
-----------Consulta Ajustada: Reporte Trimestral-------
BEGIN

DECLARE @StartDate DATE = '2024-01-01'; -- Cambiar al inicio del trimestre
DECLARE @EndDate DATE = '2024-03-31';   -- Cambiar al final del trimestre

SELECT 
    DATENAME(MONTH, F.fecha) AS Mes,
    E.turno AS Turno,
    SUM(VD.cantidad * P.precio) AS TotalFacturado
FROM Venta.Factura F
JOIN Venta.VentaDetalle VD ON F.id = VD.idfactura
JOIN Producto.Producto P ON VD.producto = P.idProducto
JOIN Super.Empleado E ON F.empleado = E.idEmpleado
WHERE F.fecha BETWEEN @StartDate AND @EndDate
GROUP BY DATENAME(MONTH, F.fecha), E.turno
ORDER BY Mes, Turno
FOR XML AUTO, ROOT('ReporteTrimestral');

END
GO
----------------Reporte por rango de fechas: Cantidad de productos vendidos ordenado de mayor a menor---------------
BEGIN

DECLARE @StartDate DATE = '2024-01-01'; 
DECLARE @EndDate DATE = '2024-12-31';  

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

END
GO
--------------- Reporte por rango de fechas: Cantidad de productos vendidos por sucursal-----------------
BEGIN

DECLARE @StartDate DATE = '2024-01-01'; 
DECLARE @EndDate DATE = '2024-12-31';  

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


END
GO
--------Mostrar los 5 productos menos vendidos en el mes.-------------------
BEGIN
DECLARE @Year INT = 2024; 
DECLARE @Month INT = 11; 

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
------------Mostrar los 5 productos más vendidos en un mes, por semana---
BEGIN
DECLARE @Year INT = 2024; 
DECLARE @Month INT = 11; 

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
-----------Total acumulado de ventas para una fecha y sucursal particulares----------
BEGIN

DECLARE @Fecha DATE = '2024-11-10'; 
DECLARE @SucursalID INT = 1;        

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
WHERE F.fecha = @Fecha AND S.idSucursal = @SucursalID
FOR XML AUTO, ROOT('ReporteTotalAcumulado');

END
GO