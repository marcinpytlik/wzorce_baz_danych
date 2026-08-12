-- Wzorzec: least privilege — role (loginy tworzysz poza przykładem)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/bezpieczenstwo/least-privilege.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_lp') IS NULL EXEC(N'CREATE SCHEMA wzorzec_lp');
GO
DROP TABLE IF EXISTS wzorzec_lp.Zamowienie;
GO
CREATE TABLE wzorzec_lp.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Kwota        DECIMAL(12,2) NOT NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_runtime')
    CREATE ROLE app_runtime;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'migrator')
    CREATE ROLE migrator;

GRANT SELECT, INSERT, UPDATE, DELETE ON wzorzec_lp.Zamowienie TO app_runtime;
GRANT CONTROL ON SCHEMA::wzorzec_lp TO migrator;
-- Runtime: bez ALTER, bez VIEW SERVER STATE, bez db_owner.
-- Migrator nie w connection pool aplikacji.
