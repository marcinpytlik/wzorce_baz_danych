-- Wzorzec: partition switching purge (sliding window — szkic)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/usuwanie/partition-switching-purge.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_psp') IS NULL EXEC(N'CREATE SCHEMA wzorzec_psp');
GO
DROP TABLE IF EXISTS wzorzec_psp.Zdarzenie;
DROP TABLE IF EXISTS wzorzec_psp.Zdarzenie_staging;
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = N'ps_psp') DROP PARTITION SCHEME ps_psp;
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = N'pf_psp') DROP PARTITION FUNCTION pf_psp;
GO

CREATE PARTITION FUNCTION pf_psp (DATE)
AS RANGE RIGHT FOR VALUES ('2026-01-01', '2026-02-01', '2026-03-01');
CREATE PARTITION SCHEME ps_psp AS PARTITION pf_psp ALL TO ([PRIMARY]);

CREATE TABLE wzorzec_psp.Zdarzenie (
    Dzien      DATE NOT NULL,
    ZdarzenieId INT IDENTITY(1,1) NOT NULL,
    Payload    NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_psp PRIMARY KEY (Dzien, ZdarzenieId)
) ON ps_psp (Dzien);

CREATE TABLE wzorzec_psp.Zdarzenie_staging (
    Dzien      DATE NOT NULL,
    ZdarzenieId INT NOT NULL,
    Payload    NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_psp_st PRIMARY KEY (Dzien, ZdarzenieId),
    CONSTRAINT CK_psp_st CHECK (Dzien >= '2026-01-01' AND Dzien < '2026-02-01')
) ON [PRIMARY];
GO
-- Purge stycznia:
-- ALTER TABLE wzorzec_psp.Zdarzenie SWITCH PARTITION 2 TO wzorzec_psp.Zdarzenie_staging;
-- TRUNCATE TABLE wzorzec_psp.Zdarzenie_staging;
-- ALTER PARTITION FUNCTION pf_psp() MERGE RANGE ('2026-01-01');
-- ALTER PARTITION SCHEME ps_psp NEXT USED [PRIMARY];
-- ALTER PARTITION FUNCTION pf_psp() SPLIT RANGE ('2026-04-01');
