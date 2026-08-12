-- Wzorzec: Expand–Migrate–Contract (shadow column + backfill batch)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/ewolucja/expand-migrate-contract.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_emc') IS NULL EXEC(N'CREATE SCHEMA wzorzec_emc');
GO
DROP TABLE IF EXISTS wzorzec_emc.BackfillPostep;
DROP TABLE IF EXISTS wzorzec_emc.Klient;
GO

CREATE TABLE wzorzec_emc.Klient (
    KlientId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_emc_klient PRIMARY KEY,
    Nazwa      NVARCHAR(200) NOT NULL,          -- stary kontrakt (v1)
    NazwaNorm  NVARCHAR(200) NULL               -- expand: shadow
);

CREATE TABLE wzorzec_emc.BackfillPostep (
    Tabela     SYSNAME NOT NULL PRIMARY KEY,
    OstatnieId INT NOT NULL,
    Zmieniono  DATETIME2(3) NOT NULL CONSTRAINT DF_emc_bf DEFAULT (SYSUTCDATETIME())
);
GO

-- Migrate: aplikacja w TX pisze obie kolumny.
-- Backfill (idempotentny, keyset):
/*
UPDATE TOP (5000) k
SET NazwaNorm = UPPER(LTRIM(RTRIM(k.Nazwa)))
FROM wzorzec_emc.Klient AS k
WHERE k.KlientId > @ostatnieId
  AND k.NazwaNorm IS NULL;
*/

-- Compatibility view dla v1:
GO
CREATE OR ALTER VIEW wzorzec_emc.v_klient_v1
AS
SELECT KlientId, Nazwa
FROM wzorzec_emc.Klient;
GO

-- Contract (gdy v1 zniknie):
-- ALTER TABLE ... ALTER COLUMN NazwaNorm NVARCHAR(200) NOT NULL;
-- ALTER TABLE ... DROP COLUMN Nazwa;
-- DROP VIEW v_klient_v1;
