-- Collation / Unicode
-- Karta: projektowanie/collation.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_col') IS NULL EXEC(N'CREATE SCHEMA wzorzec_col');
GO
DROP TABLE IF EXISTS wzorzec_col.Osoba;
GO
CREATE TABLE wzorzec_col.Osoba (
    OsobaId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nazwisko NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
    Email    NVARCHAR(320) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT UQ_col_email UNIQUE (Email)
);
GO
-- Literał: N'Łódź'. VARCHAR bez N gubi znaki przy złym code page.
-- CI: A@B = a@b w UNIQUE. AI (accent insensitive) zrówna Ł i L — zdecyduj.
-- LIKE N'%ski' i tak nie użyje seek na wiodącym %.
