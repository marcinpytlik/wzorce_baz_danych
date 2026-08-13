-- Wzorzec: SCD T1 / T2
-- Silnik: SQL Server 2022
-- Karta:  wzorce/historia/scd.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_scd') IS NULL EXEC(N'CREATE SCHEMA wzorzec_scd');
GO
DROP TABLE IF EXISTS wzorzec_scd.FactSprzedaz;
DROP TABLE IF EXISTS wzorzec_scd.DimKlient;
GO

CREATE TABLE wzorzec_scd.DimKlient (
    KlientSK     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    KlientBK     INT NOT NULL,
    Wojewodztwo  NVARCHAR(64) NOT NULL,
    WazneOd      DATE NOT NULL,
    WazneDo      DATE NOT NULL,
    IsCurrent    BIT NOT NULL,
    CONSTRAINT CK_scd_okres CHECK (WazneOd <= WazneDo)
);

CREATE UNIQUE INDEX UQ_scd_current
    ON wzorzec_scd.DimKlient (KlientBK)
    WHERE IsCurrent = 1;

CREATE TABLE wzorzec_scd.FactSprzedaz (
    FactId   BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    KlientSK INT NOT NULL REFERENCES wzorzec_scd.DimKlient (KlientSK),
    Kwota    DECIMAL(12,2) NOT NULL
);
GO
-- T1: UPDATE DimKlient SET Wojewodztwo=@x WHERE KlientBK=@bk AND IsCurrent=1;
-- T2: UPDATE ... SET WazneDo=@d, IsCurrent=0; INSERT nowy SK, IsCurrent=1;
