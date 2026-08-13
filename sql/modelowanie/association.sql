-- Wzorzec: association table (N:N + atrybut związku)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/modelowanie/association.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_assoc') IS NULL EXEC(N'CREATE SCHEMA wzorzec_assoc');
GO
DROP TABLE IF EXISTS wzorzec_assoc.Pozycja;
DROP TABLE IF EXISTS wzorzec_assoc.Produkt;
DROP TABLE IF EXISTS wzorzec_assoc.Zamowienie;
GO

CREATE TABLE wzorzec_assoc.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY
);
CREATE TABLE wzorzec_assoc.Produkt (
    ProduktId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Sku       NVARCHAR(64) NOT NULL UNIQUE
);
CREATE TABLE wzorzec_assoc.Pozycja (
    ZamowienieId INT NOT NULL REFERENCES wzorzec_assoc.Zamowienie (ZamowienieId) ON DELETE CASCADE,
    ProduktId    INT NOT NULL REFERENCES wzorzec_assoc.Produkt (ProduktId),
    Ilosc        INT NOT NULL CHECK (Ilosc > 0),
    CONSTRAINT PK_pozycja PRIMARY KEY (ZamowienieId, ProduktId)
);
GO
