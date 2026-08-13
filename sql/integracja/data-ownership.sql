-- Wzorzec: data ownership — grant pisania tylko właścicielowi
-- Silnik: SQL Server 2022
-- Karta:  wzorce/integracja/data-ownership.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'billing') IS NULL EXEC(N'CREATE SCHEMA billing');
GO
DROP TABLE IF EXISTS billing.Faktura;
GO
CREATE TABLE billing.Faktura (
    FakturaId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Kwota     DECIMAL(12,2) NOT NULL
);
GO
-- CREATE USER billing_runtime WITHOUT LOGIN;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON billing.Faktura TO billing_runtime;
-- CREATE USER magazyn_runtime WITHOUT LOGIN;
-- GRANT SELECT ON billing.Faktura TO magazyn_runtime; -- odczyt kopii / projekcji, nie UPDATE
-- Magazyn nie dostaje DELETE/UPDATE. Źródło prawdy statusu faktury = billing.
