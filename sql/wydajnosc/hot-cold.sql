-- Wzorzec: hot / cold (dwie tabele, ten sam kształt)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wydajnosc/hot-cold.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_hc') IS NULL EXEC(N'CREATE SCHEMA wzorzec_hc');
IF SCHEMA_ID(N'wzorzec_hc_cold') IS NULL EXEC(N'CREATE SCHEMA wzorzec_hc_cold');
GO
DROP VIEW IF EXISTS wzorzec_hc.v_wszystko;
DROP TABLE IF EXISTS wzorzec_hc.Zdarzenie;
DROP TABLE IF EXISTS wzorzec_hc_cold.Zdarzenie;
GO

CREATE TABLE wzorzec_hc.Zdarzenie (
    ZdarzenieId BIGINT NOT NULL PRIMARY KEY,
    Dzien       DATE NOT NULL,
    Payload     NVARCHAR(200) NOT NULL
);
CREATE TABLE wzorzec_hc_cold.Zdarzenie (
    ZdarzenieId BIGINT NOT NULL PRIMARY KEY,
    Dzien       DATE NOT NULL,
    Payload     NVARCHAR(200) NOT NULL
);
GO
CREATE VIEW wzorzec_hc.v_wszystko
AS
SELECT ZdarzenieId, Dzien, Payload, CAST(N'hot' AS NVARCHAR(8)) AS Warstwa
FROM wzorzec_hc.Zdarzenie
UNION ALL
SELECT ZdarzenieId, Dzien, Payload, N'cold'
FROM wzorzec_hc_cold.Zdarzenie;
GO
-- OLTP: tylko wzorzec_hc.Zdarzenie. Reporting: v_wszystko albo cold + columnstore.
