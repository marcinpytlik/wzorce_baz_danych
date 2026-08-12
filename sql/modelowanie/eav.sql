-- Wzorzec: EAV + JSON
-- Silnik: SQL Server 2022
-- Karta:  wzorce/modelowanie/eav.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_eav') IS NULL EXEC(N'CREATE SCHEMA wzorzec_eav');
GO

IF OBJECT_ID(N'wzorzec_eav.Wartosc', N'U') IS NOT NULL DROP TABLE wzorzec_eav.Wartosc;
IF OBJECT_ID(N'wzorzec_eav.Atrybut', N'U') IS NOT NULL DROP TABLE wzorzec_eav.Atrybut;
IF OBJECT_ID(N'wzorzec_eav.Encja', N'U') IS NOT NULL DROP TABLE wzorzec_eav.Encja;
IF OBJECT_ID(N'wzorzec_eav.Produkt', N'U') IS NOT NULL DROP TABLE wzorzec_eav.Produkt;
GO

CREATE TABLE wzorzec_eav.Encja (
    EncjaId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_encja PRIMARY KEY,
    Kod     NVARCHAR(64) NOT NULL CONSTRAINT UQ_encja_kod UNIQUE
);

CREATE TABLE wzorzec_eav.Atrybut (
    AtrybutId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_atrybut PRIMARY KEY,
    Kod       NVARCHAR(64) NOT NULL CONSTRAINT UQ_atrybut_kod UNIQUE,
    Typ       NVARCHAR(16) NOT NULL CONSTRAINT CK_atrybut_typ CHECK (Typ IN (N'tekst', N'liczba', N'data', N'bool'))
);

CREATE TABLE wzorzec_eav.Wartosc (
    EncjaId       INT NOT NULL CONSTRAINT FK_w_encja REFERENCES wzorzec_eav.Encja (EncjaId),
    AtrybutId     INT NOT NULL CONSTRAINT FK_w_atr REFERENCES wzorzec_eav.Atrybut (AtrybutId),
    WartoscTekst  NVARCHAR(4000) NULL,
    WartoscLiczba DECIMAL(18,4) NULL,
    WartoscData   DATE NULL,
    WartoscBool   BIT NULL,
    CONSTRAINT PK_wartosc PRIMARY KEY (EncjaId, AtrybutId),
    CONSTRAINT CK_wartosc_jedna CHECK (
        (CASE WHEN WartoscTekst  IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN WartoscLiczba IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN WartoscData   IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN WartoscBool   IS NOT NULL THEN 1 ELSE 0 END) = 1
    )
);

CREATE TABLE wzorzec_eav.Produkt (
    ProduktId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_eav_produkt PRIMARY KEY,
    Sku       NVARCHAR(64) NOT NULL CONSTRAINT UQ_eav_sku UNIQUE,
    Atrybuty  NVARCHAR(MAX) NOT NULL CONSTRAINT DF_eav_json DEFAULT (N'{}'),
    CONSTRAINT CK_eav_json CHECK (ISJSON(Atrybuty) = 1)
);
GO
