--ENTREGA: Test de Reportes
--FECHA DE ENTREGA: 29/11/2024
--Materia: Base de datos Aplicadas
--COMISI�N: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

USE Com5600G15;

-- Ingresando un mes y a�o determinado mostrar el total facturado por d�as de la semana, incluyendo s�bado y domingo.
-- Se usan datos con ventas existentes provenientes de la entrega 4
EXEC Reportes.TotalFacturadoPorDiaDeLaSemana 2019, 03;

-- Mostrar el total facturado por turnos de trabajo por mes en determinado trimestre.
EXEC Reportes.TotalFacturadoPorTurnoDeTrabajoPorMes '2019-03-01', '2019-05-31';

-- Ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
-- Se usan intervalo de fechas con ventas existentes provenientes de la entrega 4
EXEC Reportes.CantidadProductosVendidosEntreFechas '2019-03-01', '2019-05-31';

-- Ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango POR SUCURSAL, ordenado de mayor a menor.
-- Se usan intervalo de fechas con ventas existentes provenientes de la entrega 4
EXEC Reportes.CantidadProductosVendidosEntreFechasPorSucursal '2019-03-01', '2019-05-31';

-- Mostrar los 5 productos menos vendidos en el mes.
EXEC Reportes.ProductosMasVendidosEnMes 2019, 03;

-- Mostrar los 5 productos m�s vendidos en un mes, por semana