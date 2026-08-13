-- Wzorzec: tombstone
-- Silnik: SQL Server 2022
-- Karta:  wzorce/usuwanie/tombstone.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ts') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ts');
GO
DROP TABLE IF EXISTS wzorzec_ts.Tombstone;
GO

CREATE TABLE wzorzec_ts.Tombstone (
    Klucz      NVARCHAR(64) NOT NULL PRIMARY KEY,
    UsunietoAt DATETIME2(3) NOT NULL CONSTRAINT DF_ts_at DEFAULT (SYSUTCDATETIME()),
    WygasaAt   DATETIME2(3) NOT NULL
);
CREATE INDEX IX_ts_wygasa ON wzorzec_ts.Tombstone (WygasaAt);
GO
-- W TX z DELETE źródła: INSERT Tombstone (Klucz, WygasaAt)
--   VALUES (@k, DATEADD(DAY, 7, SYSUTCDATETIME()));
-- Sweep: DELETE FROM Tombstone WHERE WygasaAt < SYSUTCDATETIME();
