-- Wzorzec: serializacja kolejką (jeden WToku per klucz)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wspolbieznosc/queue-serialization.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_qs') IS NULL EXEC(N'CREATE SCHEMA wzorzec_qs');
GO
DROP TABLE IF EXISTS wzorzec_qs.Kolejka;
GO

CREATE TABLE wzorzec_qs.Kolejka (
    Id               BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    KluczSerializacji INT NOT NULL,
    Payload          NVARCHAR(MAX) NOT NULL,
    Status           NVARCHAR(16) NOT NULL CHECK (Status IN (N'Nowa', N'WToku', N'Zrobiona')),
    CONSTRAINT CK_qs_json CHECK (ISJSON(Payload) = 1)
);

CREATE UNIQUE INDEX UQ_qs_jeden_wtoku
    ON wzorzec_qs.Kolejka (KluczSerializacji)
    WHERE Status = N'WToku';

CREATE INDEX IX_qs_nowa
    ON wzorzec_qs.Kolejka (KluczSerializacji, Id)
    WHERE Status = N'Nowa';
GO
-- Worker bierze TOP 1 Nowa z READPAST; UPDATE WToku.
-- UNIQUE filtrowany: drugi worker na ten sam klucz dostaje 2601 i odpuszcza.
