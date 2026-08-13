-- Wzorzec: Party (TPT + role)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/modelowanie/party.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_party') IS NULL EXEC(N'CREATE SCHEMA wzorzec_party');
GO
DROP TABLE IF EXISTS wzorzec_party.Rola;
DROP TABLE IF EXISTS wzorzec_party.Osoba;
DROP TABLE IF EXISTS wzorzec_party.Firma;
DROP TABLE IF EXISTS wzorzec_party.Party;
GO

CREATE TABLE wzorzec_party.Party (
    PartyId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Typ     NVARCHAR(16) NOT NULL CHECK (Typ IN (N'Osoba', N'Firma'))
);
CREATE TABLE wzorzec_party.Osoba (
    PartyId  INT NOT NULL PRIMARY KEY REFERENCES wzorzec_party.Party (PartyId),
    Imie     NVARCHAR(100) NOT NULL,
    Nazwisko NVARCHAR(100) NOT NULL,
    Pesel    CHAR(11) NULL UNIQUE
);
CREATE TABLE wzorzec_party.Firma (
    PartyId INT NOT NULL PRIMARY KEY REFERENCES wzorzec_party.Party (PartyId),
    Nazwa   NVARCHAR(200) NOT NULL,
    NIP     VARCHAR(13) NULL UNIQUE
);
CREATE TABLE wzorzec_party.Rola (
    PartyId    INT NOT NULL REFERENCES wzorzec_party.Party (PartyId),
    RodzajRoli NVARCHAR(32) NOT NULL,
    WazneOd    DATE NOT NULL,
    WazneDo    DATE NOT NULL,
    CONSTRAINT PK_rola PRIMARY KEY (PartyId, RodzajRoli, WazneOd),
    CONSTRAINT CK_rola_okres CHECK (WazneOd < WazneDo)
);
GO
