-- Wzorzec: transactional outbox
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/integracja/outbox.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_outbox') IS NULL EXEC(N'CREATE SCHEMA wzorzec_outbox');
GO

IF OBJECT_ID(N'wzorzec_outbox.Outbox', N'U') IS NOT NULL DROP TABLE wzorzec_outbox.Outbox;
IF OBJECT_ID(N'wzorzec_outbox.Zamowienie', N'U') IS NOT NULL DROP TABLE wzorzec_outbox.Zamowienie;
GO

CREATE TABLE wzorzec_outbox.Zamowienie (
    ZamowienieId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ob_zam PRIMARY KEY
        CONSTRAINT DF_ob_zam DEFAULT (NEWSEQUENTIALID()),
    KlientId     INT NOT NULL,
    ZlozonoAt    DATETIME2(3) NOT NULL CONSTRAINT DF_ob_at DEFAULT (SYSUTCDATETIME())
);

CREATE TABLE wzorzec_outbox.Outbox (
    Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_outbox PRIMARY KEY
        CONSTRAINT DF_ob_id DEFAULT (NEWSEQUENTIALID()),
    AgregatTyp      NVARCHAR(64) NOT NULL,
    AgregatId       UNIQUEIDENTIFIER NOT NULL,
    Wersja          INT NOT NULL,
    EventTyp        NVARCHAR(128) NOT NULL,
    Payload         NVARCHAR(MAX) NOT NULL,
    UtworzonoAt     DATETIME2(3) NOT NULL CONSTRAINT DF_ob_utw DEFAULT (SYSUTCDATETIME()),
    OpublikowanoAt  DATETIME2(3) NULL,
    Proby           INT NOT NULL CONSTRAINT DF_ob_proby DEFAULT (0),
    CONSTRAINT UQ_outbox_wersja UNIQUE (AgregatId, Wersja),
    CONSTRAINT CK_outbox_json CHECK (ISJSON(Payload) = 1)
);

CREATE INDEX IX_outbox_dren
    ON wzorzec_outbox.Outbox (UtworzonoAt)
    WHERE OpublikowanoAt IS NULL;
GO

-- Aplikacja: BEGIN TRAN; INSERT Zamowienie; INSERT Outbox; COMMIT;
--
-- Worker (wiele instancji):
-- BEGIN TRAN;
-- SELECT TOP (50) *
-- FROM wzorzec_outbox.Outbox WITH (UPDLOCK, READPAST, ROWLOCK)
-- WHERE OpublikowanoAt IS NULL
-- ORDER BY UtworzonoAt;
-- -- publish, potem UPDATE OpublikowanoAt; COMMIT;
-- Nie ustawiaj OpublikowanoAt przed ACK brokera.
