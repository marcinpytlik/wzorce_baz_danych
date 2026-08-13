-- Wzorzec: keyset pagination (krotka, SQL Server 2022)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wydajnosc/keyset-pagination.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ks') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ks');
GO
DROP TABLE IF EXISTS wzorzec_ks.Zdarzenie;
GO

CREATE TABLE wzorzec_ks.Zdarzenie (
    ZdarzenieId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Data        DATETIME2(3) NOT NULL,
    Typ         NVARCHAR(32) NOT NULL
);

CREATE INDEX IX_ks_data
    ON wzorzec_ks.Zdarzenie (Data DESC, ZdarzenieId DESC)
    INCLUDE (Typ);
GO

CREATE OR ALTER PROCEDURE wzorzec_ks.NastepnaStrona
    @LastData DATETIME2(3) = NULL,
    @LastId   INT = NULL,
    @N        INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@N) ZdarzenieId, Data, Typ
    FROM wzorzec_ks.Zdarzenie
    WHERE @LastData IS NULL
       OR (Data, ZdarzenieId) < (@LastData, @LastId)
    ORDER BY Data DESC, ZdarzenieId DESC;
END;
GO
