-- Mechanizm: security definer — API = procedura, zero GRANT na tabelach
-- Silnik: SQL Server 2022
-- Karta:  mechanizmy/security-definer.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'mech_sd') IS NULL EXEC(N'CREATE SCHEMA mech_sd');
GO
DROP TABLE IF EXISTS mech_sd.Zamowienie;
GO
CREATE TABLE mech_sd.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Kwota        DECIMAL(12,2) NOT NULL
);
GO
CREATE OR ALTER PROCEDURE mech_sd.Api_DodajZamowienie
    @Kwota DECIMAL(12,2)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    INSERT mech_sd.Zamowienie (Kwota) VALUES (@Kwota);
END;
GO
-- GRANT EXECUTE ON mech_sd.Api_DodajZamowienie TO app_runtime;
-- Brak GRANT na tabeli. Do precyzyjnego elevation: module signing zamiast OWNER.
