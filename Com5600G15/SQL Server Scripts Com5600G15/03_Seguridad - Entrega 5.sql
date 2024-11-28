--ENTREGA 5: Seguridad. 
--FECHA DE ENTREGA: 15/11/2024
--Materia: Base de datos Aplicadas
--COMISIÓN: 02-5600
--GRUPO: 15
--INTEGRANTES:
--				Medina, Braian Daniel			DNI: 44354115
--				Di Rocco, Sebastian Martin		DNI: 41292371

USE Com5600G15;

-- Crear login si no existe; si existe, eliminarlo y volver a crearlo.
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'supervisor')
BEGIN
    DROP LOGIN supervisor;
END;

CREATE LOGIN supervisor WITH PASSWORD = 'Supervisor123!';
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'cajero')
BEGIN
    DROP LOGIN cajero;
END;

CREATE LOGIN cajero WITH PASSWORD = 'Cajero123!';
GO

-------------------------------------------------------------------------------------------------------------------
use Com5600G15
go


-- Crear usuario 'supervisor'
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'supervisor')
BEGIN
    DROP USER supervisor;
END;

CREATE USER supervisor FOR LOGIN supervisor;
GO

-- Crear usuario 'usuarioBasico'
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'cajero')
BEGIN
    DROP USER cajero;
END;

CREATE USER cajero FOR LOGIN cajero;
GO



---------------------------------------------------------------------------------------------



-- Rol: Administrador
IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'Administrador' AND type = 'R'
)
BEGIN
    DROP ROLE Administrador;
END;

CREATE ROLE Administrador;
GO

-- Rol: usuario
IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'usuario' AND type = 'R'
)
BEGIN
    DROP ROLE usuario;
END;

CREATE ROLE usuario;
GO



CREATE OR ALTER PROCEDURE NotaCredito.GenerarNotaCredito
    @idFactura INT,
    @idProducto Int,
	@cantidad int
AS
BEGIN
    -- Verificar que la factura esté pagada
    IF EXISTS (
        SELECT 1
        FROM NotaCredito.NotaCredito
    )
	begin
	    RAISERROR('Error el cliente ya hizo el reclamo.', 16, 1);
        RETURN;
	end
		if not exists(
					select 1
					from Venta.VentaDetalle
					where idfactura=@idFactura and producto=@idProducto
		)
	begin
	    RAISERROR('Error No existe idFactura o producto', 16, 1);
        RETURN;
	end


		INSERT INTO NotaCredito.NotaCredito (idfactura, idproducto,cantidad,fechaCreacion,estado)
		VALUES (@idFactura, @idProducto,@cantidad,GETDATE() ,1);
END;
go

CREATE OR ALTER PROCEDURE NotaCredito.eliminarNotaCredito
    @idNota INT
AS
BEGIN
    -- Verificar si la nota de crédito existe
    IF EXISTS (
        SELECT 1
        FROM NotaCredito.NotaCredito
        WHERE idNotaCredito = @idNota
    )
    BEGIN
        -- Actualizar el estado de la nota de crédito a 0
        UPDATE NotaCredito.NotaCredito
        SET estado = 0
        WHERE idNotaCredito = @idNota;
    END
    ELSE
    BEGIN
        -- Lanzar un error si no existe la nota de crédito
        RAISERROR('Error: No existe Nota de Crédito.', 16, 1);
    END
END;
GO


-- Asignar permisos al rol Administrador-usuario


grant select on schema::producto to usuario,Administrador;
grant execute on schema::producto to usuario,Administrador;

grant select on schema::venta to usuario,Administrador;
grant execute on schema::venta to usuario,Administrador;

grant select on schema::NotaCredito to usuario,Administrador;
grant execute on schema::NotaCredito to Administrador;

grant select on schema::super to Administrador;
grant execute on schema::Super to Administrador;
go


ALTER ROLE Administrador ADD MEMBER supervisor;
go
ALTER ROLE usuario ADD MEMBER cajero;
go

--------------------------------------------Encriptar datos empleados




create or alter procedure super.encriptarEmpleados
@FraseClave varchar(50)
as
begin
UPDATE Super.Empleado
SET dni = EncryptByPassPhrase(@FraseClave, dni, 1, CONVERT(VARBINARY, idEmpleado)),
    cuil = EncryptByPassPhrase(@FraseClave, cuil, 1, CONVERT(VARBINARY, idEmpleado)),
    email= EncryptByPassPhrase(@FraseClave, email, 1, CONVERT(VARBINARY, idEmpleado));
end



