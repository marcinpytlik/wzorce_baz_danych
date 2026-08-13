-- Mapowanie diagramu Chena → tabele (SQL Server 2022)
-- Karta:  projektowanie/notacja-chena.md
--
-- Encje: KLIENT, ZAMÓWIENIE, PRODUKT, POZYCJA (słaba), TELEFON (atrybut wielowartościowy).
-- Związki: SKŁADA (1:N), ZAWIERA (M:N z atrybutami = identyfikujący dla pozycji).

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_chen') IS NULL EXEC(N'CREATE SCHEMA wzorzec_chen');
GO

DROP TABLE IF EXISTS wzorzec_chen.Pozycja;
DROP TABLE IF EXISTS wzorzec_chen.Telefon;
DROP TABLE IF EXISTS wzorzec_chen.Zamowienie;
DROP TABLE IF EXISTS wzorzec_chen.Produkt;
DROP TABLE IF EXISTS wzorzec_chen.Klient;
GO

-- Encja mocna KLIENT. KlientId ★
CREATE TABLE wzorzec_chen.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_chen_klient PRIMARY KEY,
    Nazwa    NVARCHAR(200) NOT NULL,
    Email    NVARCHAR(320) NOT NULL
        CONSTRAINT UQ_chen_klient_email UNIQUE
);

-- Atrybut wielowartościowy ◎ Telefon → osobna tabela, nie CSV.
CREATE TABLE wzorzec_chen.Telefon (
    KlientId INT NOT NULL
        CONSTRAINT FK_chen_tel_klient
        REFERENCES wzorzec_chen.Klient (KlientId) ON DELETE CASCADE,
    Numer    NVARCHAR(32) NOT NULL,
    CONSTRAINT PK_chen_telefon PRIMARY KEY (KlientId, Numer)
);

-- Encja mocna ZAMÓWIENIE.
-- Związek SKŁADA 1:N, uczestnictwo zamówienia całkowite → KlientId NOT NULL.
CREATE TABLE wzorzec_chen.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_chen_zam PRIMARY KEY,
    KlientId     INT NOT NULL
        CONSTRAINT FK_chen_zam_klient
        REFERENCES wzorzec_chen.Klient (KlientId),
    Data         DATETIME2(3) NOT NULL
        CONSTRAINT DF_chen_zam_data DEFAULT (SYSUTCDATETIME())
);

CREATE TABLE wzorzec_chen.Produkt (
    ProduktId    INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_chen_prod PRIMARY KEY,
    Sku          NVARCHAR(64) NOT NULL
        CONSTRAINT UQ_chen_sku UNIQUE,
    Nazwa        NVARCHAR(200) NOT NULL,
    CenaBiezaca  DECIMAL(12,2) NOT NULL
        CONSTRAINT CK_chen_cena CHECK (CenaBiezaca >= 0)
);

-- Encja słaba POZYCJA + atrybuty związku ZAWIERA (Ilosc, CenaWMomencie).
-- Klucz: (ZamowienieId, Lp) — Lp to klucz częściowy.
CREATE TABLE wzorzec_chen.Pozycja (
    ZamowienieId    INT NOT NULL
        CONSTRAINT FK_chen_poz_zam
        REFERENCES wzorzec_chen.Zamowienie (ZamowienieId) ON DELETE CASCADE,
    Lp              INT NOT NULL,
    ProduktId       INT NOT NULL
        CONSTRAINT FK_chen_poz_prod
        REFERENCES wzorzec_chen.Produkt (ProduktId),
    Ilosc           INT NOT NULL
        CONSTRAINT CK_chen_ilosc CHECK (Ilosc > 0),
    CenaWMomencie   DECIMAL(12,2) NOT NULL
        CONSTRAINT CK_chen_cena_poz CHECK (CenaWMomencie >= 0),
    CONSTRAINT PK_chen_pozycja PRIMARY KEY (ZamowienieId, Lp),
    CONSTRAINT UQ_chen_poz_prod UNIQUE (ZamowienieId, ProduktId)
);
GO

-- Pochodny ◌ Wartosc = Ilosc * CenaWMomencie: nie trzymamy; liczymy przy odczycie.
-- SELECT Ilosc * CenaWMomencie AS Wartosc FROM wzorzec_chen.Pozycja;
