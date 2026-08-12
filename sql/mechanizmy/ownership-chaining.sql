-- Mechanizm: ownership chaining (widok, ten sam owner)
-- Silnik: SQL Server 2022
-- Karta:  mechanizmy/ownership-chaining.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'mech_oc') IS NULL EXEC(N'CREATE SCHEMA mech_oc');
GO
DROP VIEW IF EXISTS mech_oc.v_klient;
DROP TABLE IF EXISTS mech_oc.Klient;
GO
CREATE TABLE mech_oc.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nazwa    NVARCHAR(200) NOT NULL,
    Sekret   NVARCHAR(200) NOT NULL
);
GO
CREATE VIEW mech_oc.v_klient
AS
SELECT KlientId, Nazwa
FROM mech_oc.Klient;
GO
-- GRANT SELECT ON v_klient TO app_reader;
-- Brak GRANT na tabeli: łańcuch działa, bo ten sam owner. Sekret nie wychodzi.
