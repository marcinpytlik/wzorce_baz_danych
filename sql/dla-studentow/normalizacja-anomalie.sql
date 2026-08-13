-- Lekcja 5: arkusz (anomalie) vs 3NF
-- Karta: dla-studentow/05-normalizacja.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'lab_nf') IS NULL EXEC(N'CREATE SCHEMA lab_nf');
GO
DROP TABLE IF EXISTS lab_nf.Pozycja;
DROP TABLE IF EXISTS lab_nf.Telefon;
DROP TABLE IF EXISTS lab_nf.Zamowienie;
DROP TABLE IF EXISTS lab_nf.Produkt;
DROP TABLE IF EXISTS lab_nf.Klient;
DROP TABLE IF EXISTS lab_nf.Arkusz;
GO

-- Przed rozkładem: jeden wiersz = linia arkusza. Klucz „widać”: (ZamowienieNr, Sku).
CREATE TABLE lab_nf.Arkusz (
    ZamowienieNr  INT NOT NULL,
    Data          DATE NOT NULL,
    Email         NVARCHAR(320) NOT NULL,
    NazwaKlienta  NVARCHAR(200) NOT NULL,
    KodPocztowy   VARCHAR(10) NOT NULL,
    Miasto        NVARCHAR(80) NOT NULL,
    Sku           VARCHAR(32) NOT NULL,
    NazwaProduktu NVARCHAR(200) NOT NULL,
    Ilosc         INT NOT NULL,
    CenaJedn      DECIMAL(19,4) NOT NULL,
    Telefony      NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_lab_nf_arkusz PRIMARY KEY (ZamowienieNr, Sku)
);
INSERT lab_nf.Arkusz VALUES
    (100, '2026-03-01', N'a@x', N'Ada',    '80-001', N'Gdańsk',    'ABC', N'Śruba',    2,  1.50, N'500, 501'),
    (100, '2026-03-01', N'a@x', N'Ada',    '80-001', N'Gdańsk',    'DEF', N'Nakrętka', 10, 0.40, N'500, 501'),
    (101, '2026-03-02', N'b@y', N'Bartek', '00-001', N'Warszawa',  'ABC', N'Śruba',    1,  1.50, N'600');
GO
-- Anomalia UPDATE: miasto Ady tylko w jednym wierszu.
-- Anomalia INSERT: klient bez Sku — PK nie puści.
-- Anomalia DELETE: ostatnia pozycja 101 kasuje Bartka.

-- 3NF (Miasto zostaje przy kliencie: KodPocztowy → Miasto nie jest pewne w PL).
CREATE TABLE lab_nf.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_lab_nf_klient PRIMARY KEY,
    Email    NVARCHAR(320) NOT NULL CONSTRAINT UQ_lab_nf_email UNIQUE,
    Nazwa    NVARCHAR(200) NOT NULL,
    KodPocztowy VARCHAR(10) NOT NULL,
    Miasto   NVARCHAR(80) NOT NULL
);
CREATE TABLE lab_nf.Telefon (
    KlientId INT NOT NULL
        CONSTRAINT FK_lab_nf_tel REFERENCES lab_nf.Klient (KlientId) ON DELETE CASCADE,
    Numer NVARCHAR(32) NOT NULL,
    CONSTRAINT PK_lab_nf_tel PRIMARY KEY (KlientId, Numer)
);
CREATE TABLE lab_nf.Produkt (
    Sku   VARCHAR(32) NOT NULL CONSTRAINT PK_lab_nf_prod PRIMARY KEY,
    Nazwa NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_nf.Zamowienie (
    ZamowienieNr INT NOT NULL CONSTRAINT PK_lab_nf_zam PRIMARY KEY,
    Data         DATE NOT NULL,
    KlientId     INT NOT NULL
        CONSTRAINT FK_lab_nf_zam_kl REFERENCES lab_nf.Klient (KlientId) ON DELETE NO ACTION
);
CREATE TABLE lab_nf.Pozycja (
    ZamowienieNr INT NOT NULL
        CONSTRAINT FK_lab_nf_poz_zam REFERENCES lab_nf.Zamowienie (ZamowienieNr) ON DELETE CASCADE,
    Sku          VARCHAR(32) NOT NULL
        CONSTRAINT FK_lab_nf_poz_pr REFERENCES lab_nf.Produkt (Sku) ON DELETE NO ACTION,
    Ilosc        INT NOT NULL CHECK (Ilosc > 0),
    CenaJedn     DECIMAL(19,4) NOT NULL,
    CONSTRAINT PK_lab_nf_poz PRIMARY KEY (ZamowienieNr, Sku)
);
GO
-- CenaJedn = snapshot (fakt linii), nie kopia Produkt — dlatego zostaje na Pozycja.
-- SELECT p.Sku, p.Ilosc FROM lab_nf.Pozycja AS p
-- JOIN lab_nf.Zamowienie AS z ON z.ZamowienieNr = p.ZamowienieNr
-- JOIN lab_nf.Klient AS k ON k.KlientId = z.KlientId
-- WHERE k.Email = N'a@x';
