-- Wzorzec: temporal — SYSTEM_VERSIONING + valid-time (bez nakładania, trigger)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/historia/temporal.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_temporal') IS NULL EXEC(N'CREATE SCHEMA wzorzec_temporal');
IF SCHEMA_ID(N'wzorzec_temporal_hist') IS NULL EXEC(N'CREATE SCHEMA wzorzec_temporal_hist');
GO

IF OBJECT_ID(N'wzorzec_temporal.Produkt', N'U') IS NOT NULL
BEGIN
    IF OBJECTPROPERTY(OBJECT_ID(N'wzorzec_temporal.Produkt'), N'TableTemporalType') = 2
        ALTER TABLE wzorzec_temporal.Produkt SET (SYSTEM_VERSIONING = OFF);
    DROP TABLE IF EXISTS wzorzec_temporal.Produkt;
    DROP TABLE IF EXISTS wzorzec_temporal_hist.Produkt;
END;
DROP TABLE IF EXISTS wzorzec_temporal.CenaObowiazujaca;
GO

CREATE TABLE wzorzec_temporal.Produkt (
    ProduktId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tmp_prod PRIMARY KEY,
    Sku       NVARCHAR(64) NOT NULL CONSTRAINT UQ_tmp_sku UNIQUE,
    Cena      DECIMAL(12,2) NOT NULL,
    ValidFrom DATETIME2(3) GENERATED ALWAYS AS ROW START NOT NULL,
    ValidTo   DATETIME2(3) GENERATED ALWAYS AS ROW END   NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = wzorzec_temporal_hist.Produkt));

-- As-of:
-- SELECT * FROM wzorzec_temporal.Produkt FOR SYSTEM_TIME AS OF @ts WHERE ProduktId = 1;

CREATE TABLE wzorzec_temporal.CenaObowiazujaca (
    CenaId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cena_ob PRIMARY KEY,
    ProduktId INT NOT NULL,
    Cena      DECIMAL(12,2) NOT NULL,
    WazneOd   DATETIME2(3) NOT NULL,
    WazneDo   DATETIME2(3) NOT NULL,
    CONSTRAINT CK_cena_okres CHECK (WazneOd < WazneDo)
);
GO

CREATE TRIGGER wzorzec_temporal.trg_cena_brak_nakladania
ON wzorzec_temporal.CenaObowiazujaca
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN wzorzec_temporal.CenaObowiazujaca AS c
          ON c.ProduktId = i.ProduktId
         AND c.CenaId <> i.CenaId
         AND c.WazneOd < i.WazneDo
         AND i.WazneOd < c.WazneDo
    )
    BEGIN
        THROW 50001, N'Nakładające się okresy valid-time dla produktu.', 1;
    END;
END;
GO
