-- Mechanizm: CHECK
-- Silnik: SQL Server 2022
-- Karta:  mechanizmy/check-constraint.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'mech_ck') IS NULL EXEC(N'CREATE SCHEMA mech_ck');
GO
DROP TABLE IF EXISTS mech_ck.Pozycja;
GO
CREATE TABLE mech_ck.Pozycja (
    PozycjaId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Typ       NVARCHAR(16) NOT NULL CHECK (Typ IN (N'Notatka', N'Zadanie')),
    Termin    DATE NULL,
    Payload   NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_tph_zadanie CHECK (Typ <> N'Zadanie' OR Termin IS NOT NULL),
    CONSTRAINT CK_json CHECK (ISJSON(Payload) = 1)
);
GO
