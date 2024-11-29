--ENTREGA: Test de Reportes
--FECHA DE ENTREGA: 29/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

USE Com5600G15;

-- Ingresando un mes y año determinado mostrar el total facturado por días de la semana, incluyendo sábado y domingo.
-- Se usan datos con ventas existentes provenientes de la entrega 4
EXEC Reportes.TotalFacturadoPorDiaDeLaSemana 2019, 03;

-- Mostrar el total facturado por turnos de trabajo por mes en determinado trimestre.-- Se usan comienzo y final de trmestre con ventas existentes provenientes de la entrega 4
EXEC Reportes.TotalFacturadoPorTurnoDeTrabajoPorMes '2019-03-01', '2019-05-31';

-- Ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
-- Se usan intervalo de fechas con ventas existentes provenientes de la entrega 4
EXEC Reportes.CantidadProductosVendidosEntreFechas '2019-03-01', '2019-05-31';

-- Ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango POR SUCURSAL, ordenado de mayor a menor.
-- Se usan intervalo de fechas con ventas existentes provenientes de la entrega 4
EXEC Reportes.CantidadProductosVendidosEntreFechasPorSucursal '2019-03-01', '2019-05-31';

-- Mostrar los 5 productos menos vendidos en el mes.-- Se usan datos con ventas existentes provenientes de la entrega 4
EXEC Reportes.ProductosMasVendidosEnMes 2019, 03;

-- Mostrar los 5 productos más vendidos en un mes, por semana-- Se usan datos con ventas existentes provenientes de la entrega 4EXEC Reportes.ProductosMasVendidosEnMesPorSemana 2019, 03;-- Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha y sucursal particulares-- Se usa una fecha con ventas e id de sucursal existentes provenientes de la entrega 4SELECT * FROM Super.SucursalEXEC Reportes.TotalAcumuladoPorSucursalEnFecha '2019-03-01', 1