

-- Crear login si no existe; si existe, eliminarlo y volver a crearlo.
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'supervisor')
BEGIN
    DROP LOGIN supervisor;
END;

CREATE LOGIN supervisor WITH PASSWORD = 'Supervisor123!';
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuarioBasico')
BEGIN
    DROP LOGIN usuarioBasico;
END;

CREATE LOGIN usuarioBasico WITH PASSWORD = 'Usuario123!';
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
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuarioBasico')
BEGIN
    DROP USER usuarioBasico;
END;

CREATE USER usuarioBasico FOR LOGIN usuarioBasico;
GO



---------------------------------------------------------------------------------------------


IF OBJECT_ID(N'Venta.NotaCredito', N'U') IS NOT NULL
BEGIN
    DROP TABLE Venta.NotaCredito;
END;
CREATE TABLE Venta.NotaCredito (
    idNotaCredito INT IDENTITY(1,1) PRIMARY KEY,
    idFactura INT NOT NULL REFERENCES Venta.Factura(id),
    idProducto INT NULL REFERENCES Producto.Producto(idProducto),
    valorCredito DECIMAL(10, 2) NOT NULL,
    fechaCreacion DATETIME DEFAULT GETDATE()
);



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


-- Asignar permisos al rol Administrador
GRANT INSERT, UPDATE, SELECT ON Venta.NotaCredito TO Administrador;
go
GRANT SELECT ON Venta.Factura TO Administrador;
go
GRANT SELECT ON super.Empleado TO Administrador;
go
-- Asignar permisos al rol usuario
GRANT SELECT ON Venta.Factura TO usuario;
go




CREATE OR ALTER PROCEDURE GenerarNotaCredito
    @idFactura INT,
    @idProducto INT ,
    @valorCredito DECIMAL(10, 2)
AS
BEGIN
    -- Verificar que la factura esté pagada
    IF NOT EXISTS (
        SELECT 1
        FROM Venta.Factura
        WHERE id = @idFactura
    )
    BEGIN
        PRINT 'Error: La factura no está pagada.';
        RETURN;
    END;


    -- Insertar la nota de crédito
    INSERT INTO Venta.NotaCredito (idFactura, idProducto, valorCredito)
    VALUES (@idFactura, @idProducto, @valorCredito);



END;
go
GRANT EXECUTE ON OBJECT::dbo.GenerarNotaCredito TO Administrador;
go

ALTER ROLE Administrador ADD MEMBER supervisor;
go
ALTER ROLE usuario ADD MEMBER usuarioBasico;
go

--------------------------------------------Encriptar datos empleados



DECLARE @FraseClave NVARCHAR(128);
SET @FraseClave = 'ClaveSeguraParaEmpleados';

UPDATE Super.Empleado
SET dni = EncryptByPassPhrase(@FraseClave, dni, 1, CONVERT(VARBINARY, idEmpleado)),
    cuil = EncryptByPassPhrase(@FraseClave, cuil, 1, CONVERT(VARBINARY, idEmpleado)),
    email= EncryptByPassPhrase(@FraseClave, email, 1, CONVERT(VARBINARY, idEmpleado));
GO

select * from Super.Empleado


------------------------------------Back UP

BACKUP DATABASE [Com5600G15] 
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\Com5600G15.bak'
WITH NOFORMAT, NOINIT,  NAME = N'Com5600G15-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
