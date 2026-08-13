-- ON DELETE: NO ACTION vs CASCADE vs SET NULL (świadomie)
-- Karta: projektowanie/on-delete.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_od') IS NULL EXEC(N'CREATE SCHEMA wzorzec_od');
GO
DROP TABLE IF EXISTS wzorzec_od.Pozycja;
DROP TABLE IF EXISTS wzorzec_od.Zamowienie;
DROP TABLE IF EXISTS wzorzec_od.Notatka;
DROP TABLE IF EXISTS wzorzec_od.Klient;
GO
CREATE TABLE wzorzec_od.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL PRIMARY KEY
);
CREATE TABLE wzorzec_od.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    KlientId     INT NOT NULL
        CONSTRAINT FK_od_zam_klient
        REFERENCES wzorzec_od.Klient (KlientId) ON DELETE NO ACTION
);
CREATE TABLE wzorzec_od.Pozycja (
    ZamowienieId INT NOT NULL
        CONSTRAINT FK_od_poz_zam
        REFERENCES wzorzec_od.Zamowienie (ZamowienieId) ON DELETE CASCADE,
    Lp INT NOT NULL,
    CONSTRAINT PK_od_poz PRIMARY KEY (ZamowienieId, Lp)
);
CREATE TABLE wzorzec_od.Notatka (
    NotatkaId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    KlientId  INT NULL
        CONSTRAINT FK_od_not_klient
        REFERENCES wzorzec_od.Klient (KlientId) ON DELETE SET NULL
);
GO
-- SET NULL tylko gdy związek jest opcjonalny i dziecko żyje bez rodzica (notatka).
-- Zamówienie bez klienta — NO ACTION, nie CASCADE.
