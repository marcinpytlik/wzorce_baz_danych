-- Wzorzec: materialized path (ltree)
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/hierarchie/materialized-path.md

CREATE EXTENSION IF NOT EXISTS ltree;

DROP SCHEMA IF EXISTS wzorzec_mp CASCADE;
CREATE SCHEMA wzorzec_mp;
SET search_path = wzorzec_mp;

CREATE TABLE wezel (
    wezel_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rodzic_id  INT REFERENCES wezel (wezel_id),
    nazwa      TEXT NOT NULL,
    sciezka    LTREE NOT NULL UNIQUE
);

CREATE INDEX ix_mp_gist ON wezel USING gist (sciezka);

CREATE FUNCTION mp_wstaw(p_rodzic INT, p_nazwa TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
    v_path LTREE;
BEGIN
    INSERT INTO wezel (rodzic_id, nazwa, sciezka)
    VALUES (p_rodzic, p_nazwa, 'tmp'::ltree)
    RETURNING wezel_id INTO v_id;

    IF p_rodzic IS NULL THEN
        v_path := v_id::TEXT::ltree;
    ELSE
        SELECT sciezka || v_id::TEXT::ltree INTO v_path
        FROM wezel WHERE wezel_id = p_rodzic;
    END IF;

    UPDATE wezel SET sciezka = v_path WHERE wezel_id = v_id;
    RETURN v_id;
END;
$$;

-- Poddrzewo: SELECT * FROM wezel WHERE sciezka <@ '1.4';
-- Breadcrumb: SELECT * FROM wezel WHERE sciezka @> (SELECT sciezka FROM wezel WHERE wezel_id = :id);
