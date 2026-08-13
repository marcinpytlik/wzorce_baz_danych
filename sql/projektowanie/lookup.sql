-- Lookup: kod naturalny, nie EAV
-- Karta: projektowanie/lookup.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_lu') IS NULL EXEC(N'CREATE SCHEMA wzorzec_lu');
GO
DROP TABLE IF EXISTS wzorzec_lu.Platnosc;
DROP TABLE IF EXISTS wzorzec_lu.StatusPlatnosci;
GO
CREATE TABLE wzorzec_lu.StatusPlatnosci (
    StatusKod VARCHAR(16) NOT NULL PRIMARY KEY,
    Nazwa     NVARCHAR(80) NOT NULL,
    Kolejnosc INT NOT NULL,
    Aktywny   BIT NOT NULL CONSTRAINT DF_lu_akt DEFAULT (1)
);
INSERT wzorzec_lu.StatusPlatnosci (StatusKod, Nazwa, Kolejnosc) VALUES
    ('NOWA',     N'Nowa',     1),
    ('POTW',     N'Potwierdzona', 2),
    ('ODRZUCON', N'Odrzucona', 3);
CREATE TABLE wzorzec_lu.Platnosc (
    PlatnoscId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StatusKod  VARCHAR(16) NOT NULL
        CONSTRAINT FK_lu_plat_st
        REFERENCES wzorzec_lu.StatusPlatnosci (StatusKod) ON DELETE NO ACTION
);
GO
-- Kasowanie statusu z wiszącymi płatnościami: błąd (NO ACTION). Dezaktywuj Aktywny=0.
