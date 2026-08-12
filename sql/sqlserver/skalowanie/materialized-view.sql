-- Wzorzec: indexed view (odpowiednik MV przy DML) + snapshot job gdy indexed view nie przechodzi
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/skalowanie/materialized-view.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_mv') IS NULL EXEC(N'CREATE SCHEMA wzorzec_mv');
GO

IF OBJECT_ID(N'wzorzec_mv.v_sprzedaz_dzien', N'V') IS NOT NULL DROP VIEW wzorzec_mv.v_sprzedaz_dzien;
IF OBJECT_ID(N'wzorzec_mv.Pozycja', N'U') IS NOT NULL DROP TABLE wzorzec_mv.Pozycja;
GO

CREATE TABLE wzorzec_mv.Pozycja (
    Dzien   DATE NOT NULL,
    Sku     NVARCHAR(64) NOT NULL,
    Ilosc   INT NOT NULL,
    Wartosc DECIMAL(12,2) NOT NULL
);
GO

CREATE VIEW wzorzec_mv.v_sprzedaz_dzien
WITH SCHEMABINDING
AS
SELECT Dzien,
       Sku,
       SUM(Ilosc) AS Ilosc,
       SUM(Wartosc) AS Wartosc,
       COUNT_BIG(*) AS Cnt
FROM wzorzec_mv.Pozycja
GROUP BY Dzien, Sku;
GO

CREATE UNIQUE CLUSTERED INDEX IX_mv_sprzedaz
    ON wzorzec_mv.v_sprzedaz_dzien (Dzien, Sku);
GO

-- Odczyt: SELECT * FROM wzorzec_mv.v_sprzedaz_dzien WITH (NOEXPAND);
-- Koszt utrzymania indeksu jest na każdym DML źródła — to nie jest REFRESH z Postgresa.
