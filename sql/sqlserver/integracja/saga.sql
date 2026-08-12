-- Wzorzec: saga (orkiestracja)
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/integracja/saga.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_saga') IS NULL EXEC(N'CREATE SCHEMA wzorzec_saga');
GO

IF OBJECT_ID(N'wzorzec_saga.SagaKrok', N'U') IS NOT NULL DROP TABLE wzorzec_saga.SagaKrok;
IF OBJECT_ID(N'wzorzec_saga.Saga', N'U') IS NOT NULL DROP TABLE wzorzec_saga.Saga;
GO

CREATE TABLE wzorzec_saga.Saga (
    SagaId         UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_saga PRIMARY KEY,
    Typ            NVARCHAR(64) NOT NULL,
    Stan           NVARCHAR(16) NOT NULL CONSTRAINT CK_saga_stan
        CHECK (Stan IN (N'Nowa', N'WToku', N'Kompensacja', N'Zakonczona', N'Martwa')),
    Wersja         INT NOT NULL CONSTRAINT DF_saga_wer DEFAULT (0),
    Dane           NVARCHAR(MAX) NOT NULL CONSTRAINT DF_saga_dane DEFAULT (N'{}'),
    NastepnyKrokAt DATETIME2(3) NOT NULL CONSTRAINT DF_saga_due DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_saga_json CHECK (ISJSON(Dane) = 1)
);

CREATE INDEX IX_saga_due
    ON wzorzec_saga.Saga (NastepnyKrokAt)
    WHERE Stan IN (N'Nowa', N'WToku', N'Kompensacja');

CREATE TABLE wzorzec_saga.SagaKrok (
    SagaId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_krok_saga REFERENCES wzorzec_saga.Saga (SagaId),
    Nr     INT NOT NULL,
    Nazwa  NVARCHAR(64) NOT NULL,
    Stan   NVARCHAR(24) NOT NULL CONSTRAINT CK_krok_stan CHECK (Stan IN (
               N'DoZrobienia', N'Zrobione', N'DoKompensacji', N'Skompensowane', N'Martwe')),
    CONSTRAINT PK_saga_krok PRIMARY KEY (SagaId, Nr)
);
GO

-- Worker:
-- BEGIN TRAN;
-- SELECT TOP (1) *
-- FROM wzorzec_saga.Saga WITH (UPDLOCK, READPAST, ROWLOCK)
-- WHERE NastepnyKrokAt <= SYSUTCDATETIME()
--   AND Stan IN (N'Nowa', N'WToku', N'Kompensacja');
-- UPDATE Saga SET Wersja = Wersja + 1 WHERE SagaId = @id AND Wersja = @oczekiwana;
-- -- 0 wierszy ⇒ wyścig, odpuść
-- COMMIT;
