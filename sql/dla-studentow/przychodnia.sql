-- Szkic: przychodnia
-- dla-studentow/szkice/przychodnia.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'lab_przy') IS NULL EXEC(N'CREATE SCHEMA lab_przy');
GO
DROP TABLE IF EXISTS lab_przy.PozycjaRecepty;
DROP TABLE IF EXISTS lab_przy.WizytaIcd;
DROP TABLE IF EXISTS lab_przy.Wizyta;
DROP TABLE IF EXISTS lab_przy.Telefon;
DROP TABLE IF EXISTS lab_przy.Pacjent;
DROP TABLE IF EXISTS lab_przy.Lekarz;
DROP TABLE IF EXISTS lab_przy.Lek;
DROP TABLE IF EXISTS lab_przy.Icd;
DROP TABLE IF EXISTS lab_przy.StatusWizyty;
GO
CREATE TABLE lab_przy.StatusWizyty (
    StatusKod VARCHAR(16) NOT NULL PRIMARY KEY,
    Nazwa     NVARCHAR(80) NOT NULL
);
INSERT lab_przy.StatusWizyty VALUES
    ('UMOWIONA', N'Umówiona'), ('ODBYTA', N'Odbyta'), ('ANUL', N'Anulowana');
CREATE TABLE lab_przy.Icd (
    IcdKod VARCHAR(16) NOT NULL PRIMARY KEY,
    Nazwa  NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_przy.Lek (
    LekKod VARCHAR(32) NOT NULL PRIMARY KEY,
    Nazwa  NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_przy.Lekarz (
    LekarzId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Npwz     VARCHAR(16) NOT NULL CONSTRAINT UQ_lab_przy_npwz UNIQUE,
    Nazwisko NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_przy.Pacjent (
    PacjentId          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Pesel              CHAR(11) NOT NULL CONSTRAINT UQ_lab_przy_pesel UNIQUE,
    Nazwisko           NVARCHAR(200) NOT NULL,
    ProwadzacyLekarzId INT NULL
        CONSTRAINT FK_lab_przy_pr REFERENCES lab_przy.Lekarz (LekarzId) ON DELETE NO ACTION
);
CREATE TABLE lab_przy.Telefon (
    PacjentId INT NOT NULL
        CONSTRAINT FK_lab_przy_tel REFERENCES lab_przy.Pacjent (PacjentId) ON DELETE CASCADE,
    Numer NVARCHAR(32) NOT NULL,
    CONSTRAINT PK_lab_przy_tel PRIMARY KEY (PacjentId, Numer)
);
CREATE TABLE lab_przy.Wizyta (
    WizytaId  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PacjentId INT NOT NULL
        CONSTRAINT FK_lab_przy_wi_pa REFERENCES lab_przy.Pacjent (PacjentId) ON DELETE NO ACTION,
    LekarzId  INT NOT NULL
        CONSTRAINT FK_lab_przy_wi_le REFERENCES lab_przy.Lekarz (LekarzId) ON DELETE NO ACTION,
    Termin    DATETIME2(0) NOT NULL,
    StatusKod VARCHAR(16) NOT NULL
        CONSTRAINT FK_lab_przy_wi_st REFERENCES lab_przy.StatusWizyty (StatusKod) ON DELETE NO ACTION,
    CONSTRAINT UQ_lab_przy_termin UNIQUE (PacjentId, LekarzId, Termin)
);
CREATE TABLE lab_przy.WizytaIcd (
    WizytaId INT NOT NULL
        CONSTRAINT FK_lab_przy_icd_wi REFERENCES lab_przy.Wizyta (WizytaId) ON DELETE CASCADE,
    IcdKod   VARCHAR(16) NOT NULL
        CONSTRAINT FK_lab_przy_icd REFERENCES lab_przy.Icd (IcdKod) ON DELETE NO ACTION,
    CONSTRAINT PK_lab_przy_icd PRIMARY KEY (WizytaId, IcdKod)
);
CREATE TABLE lab_przy.PozycjaRecepty (
    WizytaId    INT NOT NULL
        CONSTRAINT FK_lab_przy_re_wi REFERENCES lab_przy.Wizyta (WizytaId) ON DELETE CASCADE,
    Lp          INT NOT NULL,
    LekKod      VARCHAR(32) NOT NULL
        CONSTRAINT FK_lab_przy_re_lek REFERENCES lab_przy.Lek (LekKod) ON DELETE NO ACTION,
    Dawka       NVARCHAR(80) NOT NULL,
    Opakowania  INT NOT NULL CHECK (Opakowania > 0),
    CONSTRAINT PK_lab_przy_re PRIMARY KEY (WizytaId, Lp)
);
GO
-- Recepty lekarza w marcu 2026:
-- SELECT w.WizytaId, r.LekKod, r.Dawka
-- FROM lab_przy.PozycjaRecepty AS r
-- JOIN lab_przy.Wizyta AS w ON w.WizytaId = r.WizytaId
-- JOIN lab_przy.Lekarz AS l ON l.LekarzId = w.LekarzId
-- WHERE l.Npwz = '…' AND w.Termin >= '20260301' AND w.Termin < '20260401';
