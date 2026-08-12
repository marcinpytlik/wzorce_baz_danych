-- Wzorzec: temporal — historia triggerem + valid-time zakresem
-- Silnik: PostgreSQL 14+  (brak wbudowanego SYSTEM_VERSIONING jak w SQL Server)
-- Karta:  wzorce/modelowanie/temporal.md

CREATE EXTENSION IF NOT EXISTS btree_gist;

DROP SCHEMA IF EXISTS wzorzec_temporal CASCADE;
CREATE SCHEMA wzorzec_temporal;
SET search_path = wzorzec_temporal;

-- System time: current + historia append-only.
CREATE TABLE produkt (
    produkt_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku         TEXT NOT NULL UNIQUE,
    cena        NUMERIC(12,2) NOT NULL,
    zmieniono   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE produkt_historia (
    produkt_id  INT NOT NULL,
    sku         TEXT NOT NULL,
    cena        NUMERIC(12,2) NOT NULL,
    wazne_od    TIMESTAMPTZ NOT NULL,
    wazne_do    TIMESTAMPTZ NOT NULL,
    operacja    TEXT NOT NULL CHECK (operacja IN ('U', 'D'))
);

CREATE INDEX ix_produkt_hist ON produkt_historia (produkt_id, wazne_od);

CREATE FUNCTION trg_produkt_historia()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO produkt_historia (produkt_id, sku, cena, wazne_od, wazne_do, operacja)
        VALUES (OLD.produkt_id, OLD.sku, OLD.cena, OLD.zmieniono, now(), 'U');
        NEW.zmieniono := now();
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO produkt_historia (produkt_id, sku, cena, wazne_od, wazne_do, operacja)
        VALUES (OLD.produkt_id, OLD.sku, OLD.cena, OLD.zmieniono, now(), 'D');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER produkt_historia_au
BEFORE UPDATE OR DELETE ON produkt
FOR EACH ROW EXECUTE FUNCTION trg_produkt_historia();

-- Valid time: cena obowiązująca w świecie, bez nakładania się.
CREATE TABLE cena_obowiazujaca (
    produkt_id  INT NOT NULL,
    cena        NUMERIC(12,2) NOT NULL,
    okres       TSTZRANGE NOT NULL,
    EXCLUDE USING gist (produkt_id WITH =, okres WITH &&)
);

-- As-of (system time, przybliżenie): current jeśli nie zmieniany po @ts, inaczej historia.
-- SELECT * FROM produkt_historia
-- WHERE produkt_id = 1 AND wazne_od <= @ts AND wazne_do > @ts;
