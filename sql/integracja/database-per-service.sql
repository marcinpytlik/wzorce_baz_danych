-- Wzorzec: database per service — katalog (same bazy powstają poza skryptem)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/integracja/database-per-service.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_dps') IS NULL EXEC(N'CREATE SCHEMA wzorzec_dps');
GO
DROP TABLE IF EXISTS wzorzec_dps.KatalogSerwis;
GO
CREATE TABLE wzorzec_dps.KatalogSerwis (
    Serwis         NVARCHAR(64) NOT NULL PRIMARY KEY,
    Baza           SYSNAME NOT NULL UNIQUE,
    Instancja      NVARCHAR(256) NOT NULL,
    WersjaSchematu NVARCHAR(32) NOT NULL
);
INSERT wzorzec_dps.KatalogSerwis VALUES
    (N'billing',  N'Billing',  N'localhost', N'1.0'),
    (N'magazyn',  N'Magazyn',  N'localhost', N'1.0');
GO
-- Brak FK między bazami. Integracja: outbox/inbox, nie linked server w requestcie.
