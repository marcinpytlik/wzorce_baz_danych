-- Wzorzec: CQRS — write 3NF + read denormalizowany, spięte wersją
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/skalowanie/cqrs.md

DROP SCHEMA IF EXISTS wzorzec_cqrs CASCADE;
CREATE SCHEMA wzorzec_cqrs;
SET search_path = wzorzec_cqrs;

-- WRITE
CREATE TABLE zamowienie (
    zamowienie_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    klient_nazwa   TEXT NOT NULL,
    zlozono_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    wersja         INT NOT NULL DEFAULT 1
);

CREATE TABLE pozycja (
    zamowienie_id  INT NOT NULL REFERENCES zamowienie (zamowienie_id),
    lp             INT NOT NULL,
    sku            TEXT NOT NULL,
    ilosc          INT NOT NULL CHECK (ilosc > 0),
    PRIMARY KEY (zamowienie_id, lp)
);

-- READ (osobny schemat / baza w produkcji). Brak FK do write.
CREATE TABLE zamowienie_lista (
    zamowienie_id  INT PRIMARY KEY,
    klient_nazwa   TEXT NOT NULL,
    zlozono_at     TIMESTAMPTZ NOT NULL,
    pozycje_json   JSONB NOT NULL,
    liczba_pozycji INT NOT NULL,
    wersja         INT NOT NULL
);

-- Projekcja idempotentna: upsert tylko gdy wersja >= znanej.
CREATE FUNCTION rzutuj_zamowienie(p_id INT)
RETURNS VOID
LANGUAGE sql
AS $$
    INSERT INTO zamowienie_lista (zamowienie_id, klient_nazwa, zlozono_at, pozycje_json, liczba_pozycji, wersja)
    SELECT z.zamowienie_id,
           z.klient_nazwa,
           z.zlozono_at,
           COALESCE(jsonb_agg(jsonb_build_object('sku', p.sku, 'ilosc', p.ilosc) ORDER BY p.lp), '[]'::jsonb),
           COUNT(p.lp)::INT,
           z.wersja
    FROM zamowienie z
    LEFT JOIN pozycja p ON p.zamowienie_id = z.zamowienie_id
    WHERE z.zamowienie_id = p_id
    GROUP BY z.zamowienie_id
    ON CONFLICT (zamowienie_id) DO UPDATE
    SET klient_nazwa   = EXCLUDED.klient_nazwa,
        zlozono_at     = EXCLUDED.zlozono_at,
        pozycje_json   = EXCLUDED.pozycje_json,
        liczba_pozycji = EXCLUDED.liczba_pozycji,
        wersja         = EXCLUDED.wersja
    WHERE zamowienie_lista.wersja <= EXCLUDED.wersja;
$$;
