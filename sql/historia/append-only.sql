-- Wzorzec: append-only (ruchy, bez UPDATE/DELETE dla runtime)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/historia/append-only.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ao') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ao');
GO
DROP TABLE IF EXISTS wzorzec_ao.Ruch;
GO

CREATE TABLE wzorzec_ao.Ruch (
    RuchId      BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    KontoId     INT NOT NULL,
    Kwota       DECIMAL(12,2) NOT NULL,
    Tresc       NVARCHAR(200) NOT NULL,
    Idempotency UNIQUEIDENTIFIER NOT NULL,
    UtworzonoAt DATETIME2(3) NOT NULL CONSTRAINT DF_ao_at DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_ao_idem UNIQUE (Idempotency)
);
CREATE INDEX IX_ao_konto ON wzorzec_ao.Ruch (KontoId, UtworzonoAt);
GO
-- GRANT INSERT, SELECT ON Ruch TO app_runtime; -- bez UPDATE, DELETE
-- Saldo: SELECT SUM(Kwota) FROM Ruch WHERE KontoId=@id;
