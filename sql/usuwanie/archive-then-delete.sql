-- Wzorzec: archive then delete
-- Silnik: SQL Server 2022
-- Karta:  wzorce/usuwanie/archive-then-delete.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_arch') IS NULL EXEC(N'CREATE SCHEMA wzorzec_arch');
IF SCHEMA_ID(N'wzorzec_arch_cold') IS NULL EXEC(N'CREATE SCHEMA wzorzec_arch_cold');
GO
DROP TABLE IF EXISTS wzorzec_arch.Zamowienie;
DROP TABLE IF EXISTS wzorzec_arch_cold.Zamowienie;
GO

CREATE TABLE wzorzec_arch.Zamowienie (
    ZamowienieId INT NOT NULL PRIMARY KEY,
    ZlozonoAt    DATETIME2(3) NOT NULL,
    Payload      NVARCHAR(MAX) NOT NULL
);
CREATE TABLE wzorzec_arch_cold.Zamowienie (
    ZamowienieId INT NOT NULL PRIMARY KEY,
    ZlozonoAt    DATETIME2(3) NOT NULL,
    Payload      NVARCHAR(MAX) NOT NULL,
    ZarchiwizowanoAt DATETIME2(3) NOT NULL CONSTRAINT DF_arch_at DEFAULT (SYSUTCDATETIME())
);
GO

CREATE OR ALTER PROCEDURE wzorzec_arch.Archiwizuj
    @Prog DATETIME2(3),
    @Batch INT = 5000
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRAN;
    DELETE TOP (@Batch) h
    OUTPUT deleted.ZamowienieId, deleted.ZlozonoAt, deleted.Payload, SYSUTCDATETIME()
    INTO wzorzec_arch_cold.Zamowienie (ZamowienieId, ZlozonoAt, Payload, ZarchiwizowanoAt)
    FROM wzorzec_arch.Zamowienie AS h
    WHERE h.ZlozonoAt < @Prog;
    COMMIT;
END;
GO
