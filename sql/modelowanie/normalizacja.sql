-- Wzorzec: normalizacja (3NF) — OLTP
-- Silnik: SQL Server 2022
-- Karta:  wzorce/modelowanie/normalizacja.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_norm') IS NULL EXEC(N'CREATE SCHEMA wzorzec_norm');
GO

IF OBJECT_ID(N'wzorzec_norm.v_faktura', N'V') IS NOT NULL DROP VIEW wzorzec_norm.v_faktura;
IF OBJECT_ID(N'wzorzec_norm.pozycja', N'U') IS NOT NULL DROP TABLE wzorzec_norm.pozycja;
IF OBJECT_ID(N'wzorzec_norm.zamowienie', N'U') IS NOT NULL DROP TABLE wzorzec_norm.zamowienie;
IF OBJECT_ID(N'wzorzec_norm.produkt', N'U') IS NOT NULL DROP TABLE wzorzec_norm.produkt;
IF OBJECT_ID(N'wzorzec_norm.klient', N'U') IS NOT NULL DROP TABLE wzorzec_norm.klient;
GO

CREATE TABLE wzorzec_norm.klient (
    KlientId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_klient PRIMARY KEY,
    Email      NVARCHAR(320) NOT NULL CONSTRAINT UQ_klient_email UNIQUE,
    Nazwa      NVARCHAR(200) NOT NULL
);

CREATE TABLE wzorzec_norm.produkt (
    ProduktId     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_produkt PRIMARY KEY,
    Sku           NVARCHAR(64) NOT NULL CONSTRAINT UQ_produkt_sku UNIQUE,
    Nazwa         NVARCHAR(200) NOT NULL,
    CenaBiezaca   DECIMAL(12,2) NOT NULL CONSTRAINT CK_produkt_cena CHECK (CenaBiezaca >= 0)
);

CREATE TABLE wzorzec_norm.zamowienie (
    ZamowienieId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_zamowienie PRIMARY KEY,
    KlientId      INT NOT NULL CONSTRAINT FK_zam_klient REFERENCES wzorzec_norm.klient (KlientId),
    ZlozonoAt     DATETIME2(3) NOT NULL CONSTRAINT DF_zam_at DEFAULT (SYSUTCDATETIME())
);

CREATE TABLE wzorzec_norm.pozycja (
    ZamowienieId    INT NOT NULL CONSTRAINT FK_poz_zam REFERENCES wzorzec_norm.zamowienie (ZamowienieId),
    ProduktId       INT NOT NULL CONSTRAINT FK_poz_prod REFERENCES wzorzec_norm.produkt (ProduktId),
    Ilosc           INT NOT NULL CONSTRAINT CK_poz_ilosc CHECK (Ilosc > 0),
    CenaWMomencie   DECIMAL(12,2) NOT NULL CONSTRAINT CK_poz_cena CHECK (CenaWMomencie >= 0),
    CONSTRAINT PK_pozycja PRIMARY KEY (ZamowienieId, ProduktId)
);
GO

CREATE VIEW wzorzec_norm.v_faktura
AS
SELECT z.ZamowienieId,
       k.Nazwa AS Klient,
       p.Sku,
       p.Nazwa AS Produkt,
       poz.Ilosc,
       poz.CenaWMomencie,
       poz.Ilosc * poz.CenaWMomencie AS Wartosc
FROM wzorzec_norm.zamowienie AS z
JOIN wzorzec_norm.klient AS k ON k.KlientId = z.KlientId
JOIN wzorzec_norm.pozycja AS poz ON poz.ZamowienieId = z.ZamowienieId
JOIN wzorzec_norm.produkt AS p ON p.ProduktId = poz.ProduktId;
GO
