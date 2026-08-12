-- Wzorzec: optimistic concurrency / CAS (rowversion)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wspolbieznosc/optimistic-concurrency.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_opt') IS NULL EXEC(N'CREATE SCHEMA wzorzec_opt');
GO
DROP TABLE IF EXISTS wzorzec_opt.Dokument;
DROP TABLE IF EXISTS wzorzec_opt.Konto;
GO

CREATE TABLE wzorzec_opt.Dokument (
    DokumentId    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Tresc         NVARCHAR(400) NOT NULL,
    WersjaWiersza ROWVERSION NOT NULL
);

CREATE TABLE wzorzec_opt.Konto (
    KontoId INT NOT NULL PRIMARY KEY,
    Saldo   DECIMAL(12,2) NOT NULL CHECK (Saldo >= 0)
);
GO
-- UPDATE Dokument SET Tresc=@t WHERE DokumentId=@id AND WersjaWiersza=@ver;
-- IF @@ROWCOUNT = 0 → konflikt (albo brak wiersza — rozróżnij EXISTS).
-- CAS salda:
-- UPDATE Konto SET Saldo = Saldo - @n WHERE KontoId=@id AND Saldo >= @n;
