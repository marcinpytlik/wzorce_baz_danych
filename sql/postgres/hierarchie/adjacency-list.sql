-- Wzorzec: adjacency list + CTE
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/hierarchie/adjacency-list.md

DROP SCHEMA IF EXISTS wzorzec_adj CASCADE;
CREATE SCHEMA wzorzec_adj;
SET search_path = wzorzec_adj;

CREATE TABLE wezel (
    wezel_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rodzic_id  INT REFERENCES wezel (wezel_id),
    nazwa      TEXT NOT NULL,
    CONSTRAINT ck_nie_sam_rodzic CHECK (wezel_id IS DISTINCT FROM rodzic_id)
);

CREATE INDEX ix_wezel_rodzic ON wezel (rodzic_id);

-- Dzieci: SELECT * FROM wezel WHERE rodzic_id = :id;

-- Poddrzewo (uwaga na cykle — LIMIT głębokości).
CREATE VIEW v_poddrzewo_przyklad AS
WITH RECURSIVE t AS (
    SELECT wezel_id, rodzic_id, nazwa, 0 AS glebokosc, ARRAY[wezel_id] AS sciezka
    FROM wezel
    WHERE rodzic_id IS NULL
    UNION ALL
    SELECT d.wezel_id, d.rodzic_id, d.nazwa, t.glebokosc + 1, t.sciezka || d.wezel_id
    FROM wezel d
    JOIN t ON d.rodzic_id = t.wezel_id
    WHERE d.wezel_id <> ALL (t.sciezka)   -- ochrona przed cyklem
      AND t.glebokosc < 32
)
SELECT * FROM t;
