-- Wzorzec: MATERIALIZED VIEW
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/skalowanie/materialized-view.md

DROP SCHEMA IF EXISTS wzorzec_mv CASCADE;
CREATE SCHEMA wzorzec_mv;
SET search_path = wzorzec_mv;

CREATE TABLE pozycja (
    dzien     DATE NOT NULL,
    sku       TEXT NOT NULL,
    ilosc     INT NOT NULL,
    wartosc   NUMERIC(12,2) NOT NULL
);

CREATE MATERIALIZED VIEW mv_sprzedaz_dzien AS
SELECT dzien,
       sku,
       SUM(ilosc)   AS ilosc,
       SUM(wartosc) AS wartosc
FROM pozycja
GROUP BY dzien, sku
WITH NO DATA;

CREATE UNIQUE INDEX uq_mv_sprzedaz ON mv_sprzedaz_dzien (dzien, sku);

-- Odczyty nieblokujące przy odświeżaniu (wymaga UNIQUE).
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_sprzedaz_dzien;

COMMENT ON MATERIALIZED VIEW mv_sprzedaz_dzien IS
    'Świeżość = ostatni REFRESH, nie ta sama TX co INSERT do pozycja.';
