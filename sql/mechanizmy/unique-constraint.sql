-- Mechanizm: UNIQUE jako strażnik wyścigu
-- Silnik: SQL Server 2022
-- Karta:  mechanizmy/unique-constraint.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'mech_uq') IS NULL EXEC(N'CREATE SCHEMA mech_uq');
GO
DROP TABLE IF EXISTS mech_uq.Faktura;
GO
CREATE TABLE mech_uq.Faktura (
    FakturaId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TenantId  INT NOT NULL,
    Numer     NVARCHAR(32) NOT NULL,
    CONSTRAINT UQ_faktura UNIQUE (TenantId, Numer)
);
GO
-- Drugi INSERT tej samej pary: error 2627. Aplikacja mapuje na „już jest”.
