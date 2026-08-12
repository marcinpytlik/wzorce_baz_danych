-- Wzorzec: hard delete + kolejność FK + outbox w komentarzu
-- Silnik: SQL Server 2022
-- Karta:  wzorce/usuwanie/hard-delete.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_hd') IS NULL EXEC(N'CREATE SCHEMA wzorzec_hd');
GO
DROP TABLE IF EXISTS wzorzec_hd.Pozycja;
DROP TABLE IF EXISTS wzorzec_hd.Zamowienie;
GO

CREATE TABLE wzorzec_hd.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY
);
CREATE TABLE wzorzec_hd.Pozycja (
    ZamowienieId INT NOT NULL REFERENCES wzorzec_hd.Zamowienie (ZamowienieId) ON DELETE CASCADE,
    Lp           INT NOT NULL,
    CONSTRAINT PK_hd_poz PRIMARY KEY (ZamowienieId, Lp)
);
GO
-- BEGIN TRAN;
-- INSERT Outbox (... 'Usunieto' ...);
-- DELETE FROM wzorzec_hd.Zamowienie WHERE ZamowienieId = @id; -- CASCADE pozycje
-- COMMIT;
-- Duży DELETE: batche albo partition switch, nie jeden skan.
