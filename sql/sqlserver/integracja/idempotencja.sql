-- Wzorzec: klucz idempotency
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/integracja/idempotencja.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_idem') IS NULL EXEC(N'CREATE SCHEMA wzorzec_idem');
GO

IF OBJECT_ID(N'wzorzec_idem.Idempotencja', N'U') IS NOT NULL DROP TABLE wzorzec_idem.Idempotencja;
GO

CREATE TABLE wzorzec_idem.Idempotencja (
    Zakres       NVARCHAR(128) NOT NULL,  -- tenant + endpoint
    Klucz        NVARCHAR(128) NOT NULL,  -- Idempotency-Key
    RequestHash  NVARCHAR(64)  NOT NULL,
    Stan         NVARCHAR(16)  NOT NULL CONSTRAINT CK_idem_stan
        CHECK (Stan IN (N'WToku', N'Zrobione', N'Blad')),
    Odpowiedz    NVARCHAR(MAX) NULL,
    UtworzonoAt  DATETIME2(3) NOT NULL CONSTRAINT DF_idem_at DEFAULT (SYSUTCDATETIME()),
    WygasaAt     DATETIME2(3) NOT NULL,
    CONSTRAINT PK_idem PRIMARY KEY (Zakres, Klucz)
);

CREATE INDEX IX_idem_wygasa ON wzorzec_idem.Idempotencja (WygasaAt);
GO

-- INSERT WToku; 2627/2601 → SELECT stanu: Zrobione = replay, WToku = 409, inny hash = 409.
-- Potem efekty biznesowe i UPDATE Zrobione + snapshot odpowiedzi.
