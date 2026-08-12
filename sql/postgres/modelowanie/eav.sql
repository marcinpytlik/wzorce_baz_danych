-- Wzorzec: EAV + jsonb jako nowocześniejszy wariant
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/modelowanie/eav.md

DROP SCHEMA IF EXISTS wzorzec_eav CASCADE;
CREATE SCHEMA wzorzec_eav;
SET search_path = wzorzec_eav;

CREATE TABLE encja (
    encja_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kod       TEXT NOT NULL UNIQUE
);

CREATE TABLE atrybut (
    atrybut_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kod         TEXT NOT NULL UNIQUE,
    typ         TEXT NOT NULL CHECK (typ IN ('tekst', 'liczba', 'data', 'bool'))
);

-- Osobne kolumny per typ zamiast jednego tekstu na wszystko.
CREATE TABLE wartosc (
    encja_id       INT NOT NULL REFERENCES encja (encja_id),
    atrybut_id     INT NOT NULL REFERENCES atrybut (atrybut_id),
    wartosc_tekst  TEXT,
    wartosc_liczba NUMERIC,
    wartosc_data   DATE,
    wartosc_bool   BOOLEAN,
    PRIMARY KEY (encja_id, atrybut_id),
    CONSTRAINT ck_wartosc_jedna CHECK (
        (wartosc_tekst  IS NOT NULL)::INT
      + (wartosc_liczba IS NOT NULL)::INT
      + (wartosc_data   IS NOT NULL)::INT
      + (wartosc_bool   IS NOT NULL)::INT = 1
    )
);

-- Wariant dokumentowy: otwarte cechy przy stabilnym rdzeniu.
CREATE TABLE produkt (
    produkt_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku         TEXT NOT NULL UNIQUE,
    atrybuty    JSONB NOT NULL DEFAULT '{}'::jsonb,
    CONSTRAINT ck_atrybuty_obiekt CHECK (jsonb_typeof(atrybuty) = 'object')
);

CREATE INDEX ix_produkt_atrybuty ON produkt USING gin (atrybuty);

-- Przykład: filtr po znanych kluczach (GIN) — nadal droższy niż kolumna relacyjna.
-- SELECT * FROM produkt WHERE atrybuty @> '{"kolor": "czerwony"}';
