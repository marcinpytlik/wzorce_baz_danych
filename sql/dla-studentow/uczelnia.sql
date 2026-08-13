-- Szkic: uczelnia
-- dla-studentow/szkice/uczelnia.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'lab_ucz') IS NULL EXEC(N'CREATE SCHEMA lab_ucz');
GO
DROP TABLE IF EXISTS lab_ucz.Zapis;
DROP TABLE IF EXISTS lab_ucz.Edycja;
DROP TABLE IF EXISTS lab_ucz.Student;
DROP TABLE IF EXISTS lab_ucz.Przedmiot;
DROP TABLE IF EXISTS lab_ucz.Wykladowca;
DROP TABLE IF EXISTS lab_ucz.StatusZapisu;
GO
CREATE TABLE lab_ucz.StatusZapisu (
    StatusKod VARCHAR(16) NOT NULL PRIMARY KEY,
    Nazwa     NVARCHAR(80) NOT NULL
);
INSERT lab_ucz.StatusZapisu VALUES
    ('AKTYWNY', N'Aktywny'), ('REZYGN', N'Rezygnacja'), ('ZALICZONY', N'Zaliczony');
CREATE TABLE lab_ucz.Wykladowca (
    WykladowcaId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nazwisko     NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_ucz.Przedmiot (
    PrzedmiotKod VARCHAR(16) NOT NULL PRIMARY KEY,
    Nazwa        NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_ucz.Student (
    StudentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NrAlbumu  VARCHAR(16) NOT NULL CONSTRAINT UQ_lab_ucz_alb UNIQUE,
    Email     NVARCHAR(320) NOT NULL CONSTRAINT UQ_lab_ucz_em UNIQUE,
    Nazwisko  NVARCHAR(200) NOT NULL
);
CREATE TABLE lab_ucz.Edycja (
    EdycjaId     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PrzedmiotKod VARCHAR(16) NOT NULL
        CONSTRAINT FK_lab_ucz_ed_pr REFERENCES lab_ucz.Przedmiot (PrzedmiotKod) ON DELETE NO ACTION,
    Semestr      VARCHAR(8) NOT NULL,
    Grupa        VARCHAR(8) NOT NULL,
    WykladowcaId INT NOT NULL
        CONSTRAINT FK_lab_ucz_ed_wy REFERENCES lab_ucz.Wykladowca (WykladowcaId) ON DELETE NO ACTION,
    CONSTRAINT UQ_lab_ucz_ed UNIQUE (PrzedmiotKod, Semestr, Grupa)
);
CREATE TABLE lab_ucz.Zapis (
    EdycjaId  INT NOT NULL
        CONSTRAINT FK_lab_ucz_za_ed REFERENCES lab_ucz.Edycja (EdycjaId) ON DELETE NO ACTION,
    StudentId INT NOT NULL
        CONSTRAINT FK_lab_ucz_za_st REFERENCES lab_ucz.Student (StudentId) ON DELETE NO ACTION,
    StatusKod VARCHAR(16) NOT NULL
        CONSTRAINT FK_lab_ucz_za_stt REFERENCES lab_ucz.StatusZapisu (StatusKod) ON DELETE NO ACTION,
    Ocena     DECIMAL(2,1) NULL,
    CONSTRAINT PK_lab_ucz_za PRIMARY KEY (EdycjaId, StudentId),
    CONSTRAINT CK_lab_ucz_ocena CHECK (
        Ocena IS NULL OR Ocena IN (2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0))
);
GO
-- Studenci edycji PBD/2026L/A bez oceny:
-- SELECT s.NrAlbumu FROM lab_ucz.Zapis AS z
-- JOIN lab_ucz.Edycja AS e ON e.EdycjaId = z.EdycjaId
-- JOIN lab_ucz.Student AS s ON s.StudentId = z.StudentId
-- WHERE e.PrzedmiotKod = 'PBD' AND e.Semestr = '2026L' AND e.Grupa = 'A'
--   AND z.Ocena IS NULL;
