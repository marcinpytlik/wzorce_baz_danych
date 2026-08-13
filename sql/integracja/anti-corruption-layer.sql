-- Wzorzec: anti-corruption layer (staging + mapa)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/integracja/anti-corruption-layer.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'zewn') IS NULL EXEC(N'CREATE SCHEMA zewn');
IF SCHEMA_ID(N'map') IS NULL EXEC(N'CREATE SCHEMA map');
IF SCHEMA_ID(N'wzorzec_acl') IS NULL EXEC(N'CREATE SCHEMA wzorzec_acl');
GO
DROP TABLE IF EXISTS map.KlientMap;
DROP TABLE IF EXISTS wzorzec_acl.Klient;
DROP TABLE IF EXISTS zewn.KlientRaw;
GO

CREATE TABLE zewn.KlientRaw (
    ZewnKod NVARCHAR(32) NOT NULL PRIMARY KEY,
    Nazwa   NVARCHAR(200) NOT NULL,
    Hash    VARBINARY(32) NOT NULL
);

CREATE TABLE wzorzec_acl.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nazwa    NVARCHAR(200) NOT NULL
);

CREATE TABLE map.KlientMap (
    ZewnKod  NVARCHAR(32) NOT NULL PRIMARY KEY
        REFERENCES zewn.KlientRaw (ZewnKod),
    KlientId INT NOT NULL UNIQUE
        REFERENCES wzorzec_acl.Klient (KlientId)
);
GO
-- Import: upsert raw → INSERT Klient gdy brak mapy → INSERT map.
-- dbo nie ma FK do zewn.
