-- Wzorzec: klucz idempotency
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/integracja/idempotencja.md

DROP SCHEMA IF EXISTS wzorzec_idem CASCADE;
CREATE SCHEMA wzorzec_idem;
SET search_path = wzorzec_idem;

CREATE TABLE idempotencja (
    zakres         TEXT NOT NULL,          -- tenant + endpoint
    klucz          TEXT NOT NULL,          -- Idempotency-Key z klienta
    request_hash   TEXT NOT NULL,
    stan           TEXT NOT NULL CHECK (stan IN ('WToku', 'Zrobione', 'Blad')),
    odpowiedz      JSONB,
    utworzono_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    wygasa_at      TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (zakres, klucz)
);

CREATE INDEX ix_idem_wygasa ON idempotencja (wygasa_at);

-- 1) INSERT WToku. unique_violation → replay albo 409 (inny hash / WToku).
-- 2) Efekty biznesowe.
-- 3) UPDATE Zrobione + snapshot odpowiedzi.
