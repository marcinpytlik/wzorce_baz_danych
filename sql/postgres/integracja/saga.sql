-- Wzorzec: saga (orkiestracja) — stan + kroki + wersja
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/integracja/saga.md

DROP SCHEMA IF EXISTS wzorzec_saga CASCADE;
CREATE SCHEMA wzorzec_saga;
SET search_path = wzorzec_saga;

CREATE TABLE saga (
    saga_id          UUID PRIMARY KEY,
    typ              TEXT NOT NULL,
    stan             TEXT NOT NULL CHECK (stan IN ('Nowa', 'WToku', 'Kompensacja', 'Zakonczona', 'Martwa')),
    wersja           INT NOT NULL DEFAULT 0,
    dane             JSONB NOT NULL DEFAULT '{}'::jsonb,
    nastepny_krok_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ix_saga_due ON saga (nastepny_krok_at)
    WHERE stan IN ('Nowa', 'WToku', 'Kompensacja');

CREATE TABLE saga_krok (
    saga_id      UUID NOT NULL REFERENCES saga (saga_id),
    nr           INT NOT NULL,
    nazwa        TEXT NOT NULL,
    stan         TEXT NOT NULL CHECK (stan IN (
                     'DoZrobienia', 'Zrobione', 'DoKompensacji', 'Skompensowane', 'Martwe')),
    PRIMARY KEY (saga_id, nr)
);

-- Worker: SELECT ... FROM saga WHERE nastepny_krok_at <= now() FOR UPDATE SKIP LOCKED;
-- Po kroku: UPDATE saga SET wersja = wersja + 1 WHERE saga_id = :id AND wersja = :oczekiwana;
-- 0 wierszy ⇒ ktoś inny wziął krok (idempotencja + optymistyczna współbieżność).
