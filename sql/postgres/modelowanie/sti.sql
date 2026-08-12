-- Wzorzec: STI vs CTI
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/modelowanie/sti.md

DROP SCHEMA IF EXISTS wzorzec_sti CASCADE;
CREATE SCHEMA wzorzec_sti;
SET search_path = wzorzec_sti;

-- STI: jedna tabela, discriminator, CHECK per typ.
CREATE TABLE pozycja_sti (
    pozycja_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    typ         TEXT NOT NULL CHECK (typ IN ('Notatka', 'Zadanie', 'Wydatek')),
    tytul       TEXT NOT NULL,
    utworzono   TIMESTAMPTZ NOT NULL DEFAULT now(),
    termin      DATE,
    kwota       NUMERIC(12,2),
    CONSTRAINT ck_sti_zadanie CHECK (typ <> 'Zadanie' OR termin IS NOT NULL),
    CONSTRAINT ck_sti_wydatek CHECK (typ <> 'Wydatek' OR kwota IS NOT NULL)
);

CREATE INDEX ix_sti_typ ON pozycja_sti (typ);

-- CTI: wspólny korzeń + 1:1 podtypy (PK dziecka = FK).
CREATE TABLE pozycja (
    pozycja_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    typ         TEXT NOT NULL CHECK (typ IN ('Notatka', 'Zadanie', 'Wydatek')),
    tytul       TEXT NOT NULL,
    utworzono   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE zadanie (
    pozycja_id  INT PRIMARY KEY REFERENCES pozycja (pozycja_id) ON DELETE CASCADE,
    termin      DATE NOT NULL
);

CREATE TABLE wydatek (
    pozycja_id  INT PRIMARY KEY REFERENCES pozycja (pozycja_id) ON DELETE CASCADE,
    kwota       NUMERIC(12,2) NOT NULL CHECK (kwota >= 0)
);

-- Lista mieszana: STI jest tańsza. Pełny odczyt zadania: JOIN CTI.
CREATE VIEW v_zadanie AS
SELECT p.pozycja_id, p.tytul, p.utworzono, z.termin
FROM pozycja p
JOIN zadanie z ON z.pozycja_id = p.pozycja_id;
