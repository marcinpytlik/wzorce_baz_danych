-- Wzorzec: event sourcing (strumień + snapshot)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/historia/event-sourcing.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_es') IS NULL EXEC(N'CREATE SCHEMA wzorzec_es');
GO
DROP TABLE IF EXISTS wzorzec_es.Snapshot;
DROP TABLE IF EXISTS wzorzec_es.Strumien;
GO

CREATE TABLE wzorzec_es.Strumien (
    AgregatId   UNIQUEIDENTIFIER NOT NULL,
    Wersja      INT NOT NULL,
    Typ         NVARCHAR(128) NOT NULL,
    Payload     NVARCHAR(MAX) NOT NULL,
    UtworzonoAt DATETIME2(3) NOT NULL CONSTRAINT DF_es_at DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_es PRIMARY KEY (AgregatId, Wersja),
    CONSTRAINT CK_es_json CHECK (ISJSON(Payload) = 1),
    CONSTRAINT CK_es_wer CHECK (Wersja >= 1)
);

CREATE TABLE wzorzec_es.Snapshot (
    AgregatId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    Wersja    INT NOT NULL,
    Stan      NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_es_snap CHECK (ISJSON(Stan) = 1)
);
GO
-- Zapis CAS: INSERT Strumien (..., Wersja) VALUES (..., @oczekiwana+1);
-- UNIQUE PK łapie wyścig. Replay od Snapshot.Wersja + 1.
