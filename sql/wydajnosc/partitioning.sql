-- Wzorzec: partycjonowanie RANGE po dacie
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wydajnosc/partitioning.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_part') IS NULL EXEC(N'CREATE SCHEMA wzorzec_part');
GO
DROP TABLE IF EXISTS wzorzec_part.Zdarzenie;
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = N'ps_zdarzenie') DROP PARTITION SCHEME ps_zdarzenie;
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = N'pf_zdarzenie') DROP PARTITION FUNCTION pf_zdarzenie;
GO

CREATE PARTITION FUNCTION pf_zdarzenie (DATE)
AS RANGE RIGHT FOR VALUES ('2026-01-01', '2026-04-01', '2026-07-01');
CREATE PARTITION SCHEME ps_zdarzenie AS PARTITION pf_zdarzenie ALL TO ([PRIMARY]);

CREATE TABLE wzorzec_part.Zdarzenie (
    Dzien       DATE NOT NULL,
    ZdarzenieId INT IDENTITY(1,1) NOT NULL,
    Typ         NVARCHAR(32) NOT NULL,
    CONSTRAINT PK_part_zdar PRIMARY KEY (Dzien, ZdarzenieId)
) ON ps_zdarzenie (Dzien);
GO
-- $PARTITION.pf_zdarzenie(Dzien) — numer partycji.
-- Purge: wzorce/usuwanie/partition-switching-purge.md
