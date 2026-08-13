-- Mechanizm: filtered index
-- Silnik: SQL Server 2022
-- Karta:  mechanizmy/filtered-index.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'mech_fi') IS NULL EXEC(N'CREATE SCHEMA mech_fi');
GO
DROP TABLE IF EXISTS mech_fi.Produkt;
GO
CREATE TABLE mech_fi.Produkt (
    ProduktId  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Sku        NVARCHAR(64) NOT NULL,
    UsunietoAt DATETIME2(3) NULL
);
CREATE UNIQUE INDEX UQ_sku_zywy
    ON mech_fi.Produkt (Sku)
    WHERE UsunietoAt IS NULL;
GO
