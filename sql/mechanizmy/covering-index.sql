-- Mechanizm: covering index
-- Silnik: SQL Server 2022
-- Karta:  mechanizmy/covering-index.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'mech_cov') IS NULL EXEC(N'CREATE SCHEMA mech_cov');
GO
DROP TABLE IF EXISTS mech_cov.Zdarzenie;
GO
CREATE TABLE mech_cov.Zdarzenie (
    ZdarzenieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Data        DATETIME2(3) NOT NULL,
    Typ         NVARCHAR(32) NOT NULL,
    Status      NVARCHAR(16) NOT NULL
);
CREATE INDEX IX_zdarzenie_data
    ON mech_cov.Zdarzenie (Data DESC, ZdarzenieId DESC)
    INCLUDE (Typ, Status);
GO
