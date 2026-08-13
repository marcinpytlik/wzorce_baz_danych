-- Wzorzec: STI vs CTI
-- Silnik: SQL Server 2022
-- Karta:  wzorce/modelowanie/tph-tpt-tpct.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_sti') IS NULL EXEC(N'CREATE SCHEMA wzorzec_sti');
GO

IF OBJECT_ID(N'wzorzec_sti.v_zadanie', N'V') IS NOT NULL DROP VIEW wzorzec_sti.v_zadanie;
IF OBJECT_ID(N'wzorzec_sti.Wydatek', N'U') IS NOT NULL DROP TABLE wzorzec_sti.Wydatek;
IF OBJECT_ID(N'wzorzec_sti.Zadanie', N'U') IS NOT NULL DROP TABLE wzorzec_sti.Zadanie;
IF OBJECT_ID(N'wzorzec_sti.Pozycja', N'U') IS NOT NULL DROP TABLE wzorzec_sti.Pozycja;
IF OBJECT_ID(N'wzorzec_sti.PozycjaSti', N'U') IS NOT NULL DROP TABLE wzorzec_sti.PozycjaSti;
GO

CREATE TABLE wzorzec_sti.PozycjaSti (
    PozycjaId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_sti PRIMARY KEY,
    Typ       NVARCHAR(16) NOT NULL CONSTRAINT CK_sti_typ CHECK (Typ IN (N'Notatka', N'Zadanie', N'Wydatek')),
    Tytul     NVARCHAR(200) NOT NULL,
    Utworzono DATETIME2(3) NOT NULL CONSTRAINT DF_sti_at DEFAULT (SYSUTCDATETIME()),
    Termin    DATE NULL,
    Kwota     DECIMAL(12,2) NULL,
    CONSTRAINT CK_sti_zadanie CHECK (Typ <> N'Zadanie' OR Termin IS NOT NULL),
    CONSTRAINT CK_sti_wydatek CHECK (Typ <> N'Wydatek' OR Kwota IS NOT NULL)
);

CREATE INDEX IX_sti_typ ON wzorzec_sti.PozycjaSti (Typ);

CREATE TABLE wzorzec_sti.Pozycja (
    PozycjaId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cti PRIMARY KEY,
    Typ       NVARCHAR(16) NOT NULL CONSTRAINT CK_cti_typ CHECK (Typ IN (N'Notatka', N'Zadanie', N'Wydatek')),
    Tytul     NVARCHAR(200) NOT NULL,
    Utworzono DATETIME2(3) NOT NULL CONSTRAINT DF_cti_at DEFAULT (SYSUTCDATETIME())
);

CREATE TABLE wzorzec_sti.Zadanie (
    PozycjaId INT NOT NULL CONSTRAINT PK_zadanie PRIMARY KEY
        CONSTRAINT FK_zadanie_poz REFERENCES wzorzec_sti.Pozycja (PozycjaId) ON DELETE CASCADE,
    Termin    DATE NOT NULL
);

CREATE TABLE wzorzec_sti.Wydatek (
    PozycjaId INT NOT NULL CONSTRAINT PK_wydatek PRIMARY KEY
        CONSTRAINT FK_wydatek_poz REFERENCES wzorzec_sti.Pozycja (PozycjaId) ON DELETE CASCADE,
    Kwota     DECIMAL(12,2) NOT NULL CONSTRAINT CK_wydatek_kwota CHECK (Kwota >= 0)
);
GO

CREATE VIEW wzorzec_sti.v_zadanie
AS
SELECT p.PozycjaId, p.Tytul, p.Utworzono, z.Termin
FROM wzorzec_sti.Pozycja AS p
JOIN wzorzec_sti.Zadanie AS z ON z.PozycjaId = p.PozycjaId;
GO
