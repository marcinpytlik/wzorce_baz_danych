-- Wzorzec: nested set
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/hierarchie/nested-set.md

DROP SCHEMA IF EXISTS wzorzec_ns CASCADE;
CREATE SCHEMA wzorzec_ns;
SET search_path = wzorzec_ns;

CREATE TABLE wezel (
    wezel_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rodzic_id  INT REFERENCES wezel (wezel_id),  -- adjacency obok, do zapisu
    nazwa      TEXT NOT NULL,
    lft        INT NOT NULL,
    rgt        INT NOT NULL,
    poziom     INT NOT NULL DEFAULT 0,
    CONSTRAINT ck_lft_rgt CHECK (lft < rgt),
    CONSTRAINT uq_lft UNIQUE (lft),
    CONSTRAINT uq_rgt UNIQUE (rgt)
);

CREATE INDEX ix_ns_zakres ON wezel (lft, rgt);

-- Poddrzewo węzła :id
-- SELECT d.*
-- FROM wezel r
-- JOIN wezel d ON d.lft BETWEEN r.lft AND r.rgt
-- WHERE r.wezel_id = :id;

-- Przodkowie
-- SELECT a.*
-- FROM wezel d
-- JOIN wezel a ON a.lft < d.lft AND a.rgt > d.rgt
-- WHERE d.wezel_id = :id
-- ORDER BY a.lft;

-- INSERT liścia wymaga przesunięcia zakresów w TX (tu szkic):
CREATE FUNCTION ns_wstaw_dziecko(p_rodzic INT, p_nazwa TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_rgt INT;
    v_id  INT;
BEGIN
    SELECT rgt INTO v_rgt FROM wezel WHERE wezel_id = p_rodzic FOR UPDATE;
    IF v_rgt IS NULL THEN
        RAISE EXCEPTION 'brak rodzica %', p_rodzic;
    END IF;
    UPDATE wezel SET rgt = rgt + 2 WHERE rgt >= v_rgt;
    UPDATE wezel SET lft = lft + 2 WHERE lft >= v_rgt;
    INSERT INTO wezel (rodzic_id, nazwa, lft, rgt, poziom)
    SELECT p_rodzic, p_nazwa, v_rgt, v_rgt + 1, poziom + 1
    FROM wezel WHERE wezel_id = p_rodzic
    RETURNING wezel_id INTO v_id;
    RETURN v_id;
END;
$$;
