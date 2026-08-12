-- Wzorzec: closure table
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/hierarchie/closure-table.md

DROP SCHEMA IF EXISTS wzorzec_cl CASCADE;
CREATE SCHEMA wzorzec_cl;
SET search_path = wzorzec_cl;

CREATE TABLE wezel (
    wezel_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa     TEXT NOT NULL
);

CREATE TABLE domkniecie (
    przodek_id   INT NOT NULL REFERENCES wezel (wezel_id) ON DELETE CASCADE,
    potomek_id   INT NOT NULL REFERENCES wezel (wezel_id) ON DELETE CASCADE,
    glebokosc    INT NOT NULL CHECK (glebokosc >= 0),
    PRIMARY KEY (przodek_id, potomek_id)
);

CREATE UNIQUE INDEX uq_jeden_rodzic
    ON domkniecie (potomek_id)
    WHERE glebokosc = 1;

CREATE INDEX ix_cl_potomek ON domkniecie (potomek_id, glebokosc);

CREATE FUNCTION cl_wstaw_korzen(p_nazwa TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE v_id INT;
BEGIN
    INSERT INTO wezel (nazwa) VALUES (p_nazwa) RETURNING wezel_id INTO v_id;
    INSERT INTO domkniecie (przodek_id, potomek_id, glebokosc)
    VALUES (v_id, v_id, 0);
    RETURN v_id;
END;
$$;

CREATE FUNCTION cl_wstaw_dziecko(p_rodzic INT, p_nazwa TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE v_id INT;
BEGIN
    INSERT INTO wezel (nazwa) VALUES (p_nazwa) RETURNING wezel_id INTO v_id;
    INSERT INTO domkniecie (przodek_id, potomek_id, glebokosc)
    SELECT przodek_id, v_id, glebokosc + 1
    FROM domkniecie
    WHERE potomek_id = p_rodzic
    UNION ALL
    SELECT v_id, v_id, 0;
    RETURN v_id;
END;
$$;

-- Poddrzewo: SELECT w.* FROM wezel w
-- JOIN domkniecie d ON d.potomek_id = w.wezel_id
-- WHERE d.przodek_id = :id;
