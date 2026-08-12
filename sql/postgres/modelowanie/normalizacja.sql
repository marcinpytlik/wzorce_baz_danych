-- Wzorzec: normalizacja (3NF) — OLTP
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/modelowanie/normalizacja.md

DROP SCHEMA IF EXISTS wzorzec_norm CASCADE;
CREATE SCHEMA wzorzec_norm;
SET search_path = wzorzec_norm;

CREATE TABLE klient (
    klient_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email       TEXT NOT NULL,
    nazwa       TEXT NOT NULL,
    CONSTRAINT uq_klient_email UNIQUE (email)
);

CREATE TABLE produkt (
    produkt_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku            TEXT NOT NULL,
    nazwa          TEXT NOT NULL,
    cena_biezaca   NUMERIC(12,2) NOT NULL,
    CONSTRAINT uq_produkt_sku UNIQUE (sku),
    CONSTRAINT ck_produkt_cena CHECK (cena_biezaca >= 0)
);

-- Cena na pozycji to snapshot (fakt historyczny), nie kopia do synchronizacji.
CREATE TABLE zamowienie (
    zamowienie_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    klient_id      INT NOT NULL REFERENCES klient (klient_id),
    zlozono_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE pozycja (
    zamowienie_id     INT NOT NULL REFERENCES zamowienie (zamowienie_id),
    produkt_id        INT NOT NULL REFERENCES produkt (produkt_id),
    ilosc             INT NOT NULL,
    cena_w_momencie   NUMERIC(12,2) NOT NULL,
    PRIMARY KEY (zamowienie_id, produkt_id),
    CONSTRAINT ck_pozycja_ilosc CHECK (ilosc > 0),
    CONSTRAINT ck_pozycja_cena CHECK (cena_w_momencie >= 0)
);

-- Odczyt „faktury” składa JOIN; przy ciężkim ekranie → widok zmaterializowany / CQRS.
CREATE VIEW v_faktura AS
SELECT z.zamowienie_id,
       k.nazwa AS klient,
       p.sku,
       p.nazwa AS produkt,
       poz.ilosc,
       poz.cena_w_momencie,
       poz.ilosc * poz.cena_w_momencie AS wartosc
FROM zamowienie z
JOIN klient k ON k.klient_id = z.klient_id
JOIN pozycja poz ON poz.zamowienie_id = z.zamowienie_id
JOIN produkt p ON p.produkt_id = poz.produkt_id;
