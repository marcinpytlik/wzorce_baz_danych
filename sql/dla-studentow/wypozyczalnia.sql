-- Szkic: wypożyczalnia
-- dla-studentow/szkice/wypozyczalnia.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'lab_wyp') IS NULL EXEC(N'CREATE SCHEMA lab_wyp');
GO
DROP TABLE IF EXISTS lab_wyp.Wypozyczenie;
DROP TABLE IF EXISTS lab_wyp.Telefon;
DROP TABLE IF EXISTS lab_wyp.Egzemplarz;
DROP TABLE IF EXISTS lab_wyp.AutorDzielo;
DROP TABLE IF EXISTS lab_wyp.Czytelnik;
DROP TABLE IF EXISTS lab_wyp.Dzielo;
DROP TABLE IF EXISTS lab_wyp.Autor;
DROP TABLE IF EXISTS lab_wyp.StatusEgzemplarza;
GO
CREATE TABLE lab_wyp.StatusEgzemplarza (
    StatusKod VARCHAR(16) NOT NULL PRIMARY KEY,
    Nazwa     NVARCHAR(80) NOT NULL
);
INSERT lab_wyp.StatusEgzemplarza VALUES
    ('NA_POLCE', N'Na półce'),
    ('WYPOZYCZONY', N'Wypożyczony'),
    ('W_NAPRAWIE', N'W naprawie');
-- WYPOZYCZONY jest snapshotem UI; integralność: UNIQUE otwartego wypożyczenia.
CREATE TABLE lab_wyp.Autor (
    AutorId  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nazwisko NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_wyp.Dzielo (
    DzieloId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Isbn     VARCHAR(17) NULL CONSTRAINT UQ_lab_wyp_isbn UNIQUE,
    Tytul    NVARCHAR(300) NOT NULL,
    Rok      SMALLINT NULL
);
CREATE TABLE lab_wyp.AutorDzielo (
    AutorId  INT NOT NULL
        CONSTRAINT FK_lab_wyp_ad_au REFERENCES lab_wyp.Autor (AutorId) ON DELETE NO ACTION,
    DzieloId INT NOT NULL
        CONSTRAINT FK_lab_wyp_ad_dz REFERENCES lab_wyp.Dzielo (DzieloId) ON DELETE NO ACTION,
    CONSTRAINT PK_lab_wyp_ad PRIMARY KEY (AutorId, DzieloId)
);
CREATE TABLE lab_wyp.Czytelnik (
    CzytelnikId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Email       NVARCHAR(320) NOT NULL CONSTRAINT UQ_lab_wyp_em UNIQUE,
    Nazwisko    NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_wyp.Telefon (
    CzytelnikId INT NOT NULL
        CONSTRAINT FK_lab_wyp_tel REFERENCES lab_wyp.Czytelnik (CzytelnikId) ON DELETE CASCADE,
    Numer NVARCHAR(32) NOT NULL,
    CONSTRAINT PK_lab_wyp_tel PRIMARY KEY (CzytelnikId, Numer)
);
CREATE TABLE lab_wyp.Egzemplarz (
    EgzemplarzId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DzieloId     INT NOT NULL
        CONSTRAINT FK_lab_wyp_eg_dz REFERENCES lab_wyp.Dzielo (DzieloId) ON DELETE NO ACTION,
    KodKreskowy  VARCHAR(64) NOT NULL CONSTRAINT UQ_lab_wyp_kk UNIQUE,
    StatusKod    VARCHAR(16) NOT NULL
        CONSTRAINT FK_lab_wyp_eg_st REFERENCES lab_wyp.StatusEgzemplarza (StatusKod) ON DELETE NO ACTION
);
CREATE TABLE lab_wyp.Wypozyczenie (
    WypozyczenieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EgzemplarzId   INT NOT NULL
        CONSTRAINT FK_lab_wyp_wy_eg REFERENCES lab_wyp.Egzemplarz (EgzemplarzId) ON DELETE NO ACTION,
    CzytelnikId    INT NOT NULL
        CONSTRAINT FK_lab_wyp_wy_cz REFERENCES lab_wyp.Czytelnik (CzytelnikId) ON DELETE NO ACTION,
    Od             DATE NOT NULL,
    DoPlan         DATE NOT NULL,
    ZwrotAt        DATE NULL,
    CONSTRAINT CK_lab_wyp_termin CHECK (DoPlan >= Od)
);
CREATE UNIQUE INDEX UQ_lab_wyp_otwarte
    ON lab_wyp.Wypozyczenie (EgzemplarzId) WHERE ZwrotAt IS NULL;
GO
-- Wolne egzemplarze dzieła:
-- SELECT e.KodKreskowy FROM lab_wyp.Egzemplarz AS e
-- JOIN lab_wyp.Dzielo AS d ON d.DzieloId = e.DzieloId
-- WHERE d.Isbn = '978-83-…'
--   AND e.StatusKod = 'NA_POLCE'
--   AND NOT EXISTS (SELECT 1 FROM lab_wyp.Wypozyczenie AS w
--                   WHERE w.EgzemplarzId = e.EgzemplarzId AND w.ZwrotAt IS NULL);
-- Limit 5 otwartych: procedura / TRIGGER, nie sam model.
