-- Wzorzec: soft delete + częściowy UNIQUE
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/modelowanie/soft-delete.md

DROP SCHEMA IF EXISTS wzorzec_soft CASCADE;
CREATE SCHEMA wzorzec_soft;
SET search_path = wzorzec_soft;

CREATE TABLE produkt (
    produkt_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku           TEXT NOT NULL,
    nazwa         TEXT NOT NULL,
    usunieto_at   TIMESTAMPTZ,
    usunieto_przez TEXT
);

-- Ten sam SKU wolno wstawić ponownie dopiero gdy stary wiersz jest martwy.
CREATE UNIQUE INDEX uq_produkt_sku_zywy
    ON produkt (sku)
    WHERE usunieto_at IS NULL;

CREATE VIEW v_produkt AS
SELECT produkt_id, sku, nazwa
FROM produkt
WHERE usunieto_at IS NULL;

CREATE FUNCTION usun_produkt(p_id INT, p_kto TEXT)
RETURNS VOID
LANGUAGE sql
AS $$
    UPDATE produkt
    SET usunieto_at = now(),
        usunieto_przez = p_kto
    WHERE produkt_id = p_id
      AND usunieto_at IS NULL;
$$;

-- Purge (twardy DELETE) to osobny job retencyjny, nie ścieżka UI.
