-- Wzorzec: blue-green — dwa schematy, cutover przez SYNONYM
-- Silnik: SQL Server 2022
-- Karta:  wzorce/ewolucja/blue-green.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_bg_blue') IS NULL EXEC(N'CREATE SCHEMA wzorzec_bg_blue');
IF SCHEMA_ID(N'wzorzec_bg_green') IS NULL EXEC(N'CREATE SCHEMA wzorzec_bg_green');
IF SCHEMA_ID(N'wzorzec_bg') IS NULL EXEC(N'CREATE SCHEMA wzorzec_bg');
GO
DROP SYNONYM IF EXISTS wzorzec_bg.Zamowienie;
DROP TABLE IF EXISTS wzorzec_bg_blue.Zamowienie;
DROP TABLE IF EXISTS wzorzec_bg_green.Zamowienie;
GO

CREATE TABLE wzorzec_bg_blue.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Kwota        DECIMAL(12,2) NOT NULL
);

CREATE TABLE wzorzec_bg_green.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Kwota        DECIMAL(12,2) NOT NULL,
    Waluta       CHAR(3) NOT NULL CONSTRAINT DF_bg_wal DEFAULT ('PLN')
);

CREATE SYNONYM wzorzec_bg.Zamowienie FOR wzorzec_bg_blue.Zamowienie;
GO

-- Cutover po dograniu ogona:
-- DROP SYNONYM wzorzec_bg.Zamowienie;
-- CREATE SYNONYM wzorzec_bg.Zamowienie FOR wzorzec_bg_green.Zamowienie;
-- Identity: DBCC CHECKIDENT na green przed ruchem zapisu.
