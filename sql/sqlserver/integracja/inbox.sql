-- Wzorzec: inbox (deduplikacja konsumenta)
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/integracja/inbox.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_inbox') IS NULL EXEC(N'CREATE SCHEMA wzorzec_inbox');
GO

IF OBJECT_ID(N'wzorzec_inbox.Faktura', N'U') IS NOT NULL DROP TABLE wzorzec_inbox.Faktura;
IF OBJECT_ID(N'wzorzec_inbox.Inbox', N'U') IS NOT NULL DROP TABLE wzorzec_inbox.Inbox;
GO

CREATE TABLE wzorzec_inbox.Inbox (
    MessageId      UNIQUEIDENTIFIER NOT NULL,
    Konsument      NVARCHAR(64) NOT NULL,
    OdebranoAt     DATETIME2(3) NOT NULL CONSTRAINT DF_in_od DEFAULT (SYSUTCDATETIME()),
    PrzetworzonoAt DATETIME2(3) NULL,
    CONSTRAINT PK_inbox PRIMARY KEY (MessageId, Konsument)
);

CREATE TABLE wzorzec_inbox.Faktura (
    FakturaId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_fakt PRIMARY KEY
        CONSTRAINT DF_fakt DEFAULT (NEWSEQUENTIALID()),
    ZamowienieId  UNIQUEIDENTIFIER NOT NULL CONSTRAINT UQ_fakt_zam UNIQUE,
    Kwota         DECIMAL(12,2) NOT NULL
);
GO

-- BEGIN TRAN;
-- BEGIN TRY
--   INSERT Inbox (MessageId, Konsument) VALUES (@id, N'fakturownia');
-- END TRY
-- BEGIN CATCH
--   IF ERROR_NUMBER() IN (2627, 2601) BEGIN ROLLBACK; /* duplikat — ACK */ RETURN; END
--   THROW;
-- END CATCH
-- INSERT Faktura (...);
-- UPDATE Inbox SET PrzetworzonoAt = SYSUTCDATETIME()
--  WHERE MessageId = @id AND Konsument = N'fakturownia';
-- COMMIT; -- potem ACK brokera
