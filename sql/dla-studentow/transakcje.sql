-- Lekcja 7: granica transakcji = jeden fakt biznesowy
-- Karta: dla-studentow/07-transakcje.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'lab_tx') IS NULL EXEC(N'CREATE SCHEMA lab_tx');
GO
DROP TABLE IF EXISTS lab_tx.Pozycja;
DROP TABLE IF EXISTS lab_tx.Zamowienie;
DROP TABLE IF EXISTS lab_tx.Produkt;
GO
CREATE TABLE lab_tx.Produkt (
    Sku         VARCHAR(32) NOT NULL PRIMARY KEY,
    Nazwa       NVARCHAR(200) NOT NULL,
    StanMagazyn INT NOT NULL CHECK (StanMagazyn >= 0)
);
CREATE TABLE lab_tx.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Email        NVARCHAR(320) NOT NULL
);
CREATE TABLE lab_tx.Pozycja (
    ZamowienieId INT NOT NULL
        CONSTRAINT FK_lab_tx_poz REFERENCES lab_tx.Zamowienie (ZamowienieId) ON DELETE CASCADE,
    Sku VARCHAR(32) NOT NULL
        CONSTRAINT FK_lab_tx_sku REFERENCES lab_tx.Produkt (Sku) ON DELETE NO ACTION,
    Ilosc INT NOT NULL CHECK (Ilosc > 0),
    CONSTRAINT PK_lab_tx_poz PRIMARY KEY (ZamowienieId, Sku)
);
INSERT lab_tx.Produkt VALUES ('ABC', N'Śruba', 10);
GO
-- Złożenie: INSERT Zamowienie + Pozycja + zmniejszenie StanMagazyn w JEDNEJ TX.
-- Mail do klienta: poza TX (nie ten przedmiot; na produkcji: outbox, po zaliczeniu).
/*
BEGIN TRAN;
INSERT lab_tx.Zamowienie (Email) VALUES (N'a@x');
DECLARE @id INT = SCOPE_IDENTITY();
INSERT lab_tx.Pozycja (ZamowienieId, Sku, Ilosc) VALUES (@id, 'ABC', 2);
UPDATE lab_tx.Produkt SET StanMagazyn = StanMagazyn - 2 WHERE Sku = 'ABC' AND StanMagazyn >= 2;
IF @@ROWCOUNT <> 1 ROLLBACK TRAN;
ELSE COMMIT TRAN;
*/
-- Lost update: dwa UPDATE StanMagazyn bez warunku i bez TX — nie modeluj tego „flagą w UI”.
