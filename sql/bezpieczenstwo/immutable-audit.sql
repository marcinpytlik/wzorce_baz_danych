-- Wzorzec: niemutowalny audyt — ledger SQL Server 2022
-- Silnik: SQL Server 2022
-- Karta:  wzorce/bezpieczenstwo/immutable-audit.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_led') IS NULL EXEC(N'CREATE SCHEMA wzorzec_led');
GO
DROP TABLE IF EXISTS wzorzec_led.AuditLedger;
GO

CREATE TABLE wzorzec_led.AuditLedger (
    Id      BIGINT IDENTITY(1,1) NOT NULL,
    Kiedy   DATETIME2(3) NOT NULL CONSTRAINT DF_led_k DEFAULT (SYSUTCDATETIME()),
    Kto     SYSNAME NOT NULL CONSTRAINT DF_led_kto DEFAULT (SUSER_SNAME()),
    Payload NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_led PRIMARY KEY (Id),
    CONSTRAINT CK_led_json CHECK (ISJSON(Payload) = 1)
) WITH (LEDGER = ON);
GO
-- EXEC sys.sp_generate_database_ledger_digest;  -- wynik TRZYMAJ POZA bazą
-- EXEC sys.sp_verify_database_ledger @json_diagnostics = ...
-- Runtime: tylko INSERT.
