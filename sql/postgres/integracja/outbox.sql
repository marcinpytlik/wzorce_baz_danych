-- Wzorzec: transactional outbox
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/integracja/outbox.md

DROP SCHEMA IF EXISTS wzorzec_outbox CASCADE;
CREATE SCHEMA wzorzec_outbox;
SET search_path = wzorzec_outbox;

CREATE TABLE zamowienie (
    zamowienie_id  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    klient_id      INT NOT NULL,
    zlozono_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE outbox (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agregat_typ      TEXT NOT NULL,
    agregat_id       UUID NOT NULL,
    wersja           INT NOT NULL,
    event_typ        TEXT NOT NULL,
    payload          JSONB NOT NULL,
    utworzono_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    opublikowano_at  TIMESTAMPTZ,
    proby            INT NOT NULL DEFAULT 0,
    CONSTRAINT uq_outbox_wersja UNIQUE (agregat_id, wersja)
);

CREATE INDEX ix_outbox_dren
    ON outbox (utworzono_at)
    WHERE opublikowano_at IS NULL;

-- Aplikacja: BEGIN; INSERT zamowienie; INSERT outbox; COMMIT;

-- Worker (wiele instancji):
-- BEGIN;
-- WITH batch AS (
--   SELECT id FROM outbox
--   WHERE opublikowano_at IS NULL
--   ORDER BY utworzono_at
--   FOR UPDATE SKIP LOCKED
--   LIMIT 50
-- )
-- SELECT o.* FROM outbox o JOIN batch b ON b.id = o.id;
-- -- publish do brokera, potem:
-- UPDATE outbox SET opublikowano_at = now() WHERE id = ANY(...);
-- COMMIT;
