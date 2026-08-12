-- Wzorzec: CDC — logical publication (konsument: slot / Debezium, poza tym skryptem)
-- Silnik: PostgreSQL 14+  (wymaga wal_level=logical na instancji)
-- Karta:  wzorce/integracja/cdc.md

DROP SCHEMA IF EXISTS wzorzec_cdc CASCADE;
CREATE SCHEMA wzorzec_cdc;
SET search_path = wzorzec_cdc;

CREATE TABLE zamowienie (
    zamowienie_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PK wymagany do UPDATE/DELETE w CDC
    status         TEXT NOT NULL,
    zmieniono_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Publikacja tylko wybranych tabel, nie całej bazy.
-- CREATE PUBLICATION nie wchodzi do bloku DO/funkcji — odpal osobno, raz na instancję:
-- DROP PUBLICATION IF EXISTS wzorzec_cdc_pub;
-- CREATE PUBLICATION wzorzec_cdc_pub FOR TABLE wzorzec_cdc.zamowienie;

-- Slot tworzy konsument (nie zostawiaj go bez czytnika — zatrzyma VACUUM/WAL):
-- SELECT pg_create_logical_replication_slot('wzorzec_cdc_slot', 'pgoutput');
--
-- CDC ≠ outbox: tu dostajesz zmianę wiersza, nie nazwę zdarzenia biznesowego.
