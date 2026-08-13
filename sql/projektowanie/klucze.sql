-- Klucze: surrogate PK + UNIQUE biznesowy + FK
-- Karta: projektowanie/klucze.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_klucze') IS NULL EXEC(N'CREATE SCHEMA wzorzec_klucze');
GO
DROP TABLE IF EXISTS wzorzec_klucze.Zamowienie;
DROP TABLE IF EXISTS wzorzec_klucze.Klient;
GO
CREATE TABLE wzorzec_klucze.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_klucze_klient PRIMARY KEY,
    Email    NVARCHAR(320) NOT NULL CONSTRAINT UQ_klucze_email UNIQUE,
    Nazwa    NVARCHAR(200) NOT NULL
);
CREATE TABLE wzorzec_klucze.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_klucze_zam PRIMARY KEY,
    KlientId     INT NOT NULL
        CONSTRAINT FK_klucze_zam_klient
        REFERENCES wzorzec_klucze.Klient (KlientId) ON DELETE NO ACTION,
    Numer        NVARCHAR(32) NOT NULL,
    CONSTRAINT UQ_klucze_numer UNIQUE (Numer)
);
GO
-- Naturalny Numer nie jest PK (korekta numeru nie przepina FK).
-- IDENTITY może mieć luki — Numer faktury to UNIQUE, nie IDENTITY.
