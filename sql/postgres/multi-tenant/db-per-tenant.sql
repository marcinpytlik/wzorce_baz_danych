-- Wzorzec: db-per-tenant — katalog połączeń (same bazy tenantów powstają poza tym skryptem)
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/multi-tenant/db-per-tenant.md

DROP SCHEMA IF EXISTS wzorzec_dpt CASCADE;
CREATE SCHEMA wzorzec_dpt;
SET search_path = wzorzec_dpt;

CREATE TABLE katalog_tenant (
    tenant_id     INT PRIMARY KEY,
    kod           TEXT NOT NULL UNIQUE,
    baza          TEXT NOT NULL UNIQUE,          -- np. tenant_acme
    host          TEXT NOT NULL,
    port          INT NOT NULL DEFAULT 5432,
    wersja_schematu TEXT NOT NULL,
    aktywny       BOOLEAN NOT NULL DEFAULT TRUE
);

-- Provisioning (osobna rola, nie app):
-- CREATE DATABASE tenant_acme TEMPLATE template_app;
-- INSERT INTO katalog_tenant ...
--
-- Aplikacja: SELECT host, port, baza FROM katalog_tenant WHERE kod = :kod AND aktywny;
-- Hasła / TLS nie trzymamy w tej tabeli w plaintext — vault / rotation.
--
-- W bazie tenanta NIE ma TenantId na każdej tabeli. Restore = RESTORE tej jednej bazy.
