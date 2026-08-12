-- Wzorzec: inbox (deduplikacja konsumenta)
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/integracja/inbox.md

DROP SCHEMA IF EXISTS wzorzec_inbox CASCADE;
CREATE SCHEMA wzorzec_inbox;
SET search_path = wzorzec_inbox;

CREATE TABLE inbox (
    message_id      UUID NOT NULL,
    konsument       TEXT NOT NULL,
    odebrano_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    przetworzono_at TIMESTAMPTZ,
    PRIMARY KEY (message_id, konsument)
);

CREATE TABLE faktura (
    faktura_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zamowienie_id  UUID NOT NULL UNIQUE,
    kwota          NUMERIC(12,2) NOT NULL
);

-- Handler w jednej TX:
-- INSERT INTO inbox (message_id, konsument) VALUES (:id, 'fakturownia');
--   -- unique_violation ⇒ duplikat, ACK i wyjście
-- INSERT INTO faktura (zamowienie_id, kwota) VALUES (...);
-- UPDATE inbox SET przetworzono_at = now()
--  WHERE message_id = :id AND konsument = 'fakturownia';
-- COMMIT; ACK do brokera.
