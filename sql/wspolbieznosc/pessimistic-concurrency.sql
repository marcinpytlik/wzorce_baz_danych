-- Wzorzec: pessimistic concurrency (UPDLOCK, HOLDLOCK)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wspolbieznosc/pessimistic-concurrency.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_pes') IS NULL EXEC(N'CREATE SCHEMA wzorzec_pes');
GO
DROP TABLE IF EXISTS wzorzec_pes.Konto;
GO
CREATE TABLE wzorzec_pes.Konto (
    KontoId INT NOT NULL PRIMARY KEY,
    Saldo   DECIMAL(12,2) NOT NULL
);
GO
/*
SET LOCK_TIMEOUT 1000;
BEGIN TRAN;
SELECT Saldo
FROM wzorzec_pes.Konto WITH (UPDLOCK, HOLDLOCK, ROWLOCK)
WHERE KontoId = @id;
UPDATE wzorzec_pes.Konto SET Saldo = Saldo - @n WHERE KontoId = @id;
COMMIT;
*/
