-- Wzorzec: schema-per-tenant
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/multi-tenant/schema-per-tenant.md

DROP SCHEMA IF EXISTS wzorzec_spt_shared CASCADE;
DROP SCHEMA IF EXISTS t_acme CASCADE;
CREATE SCHEMA wzorzec_spt_shared;
CREATE SCHEMA t_acme;

CREATE TABLE wzorzec_spt_shared.tenant (
    tenant_id  INT PRIMARY KEY,
    kod        TEXT NOT NULL UNIQUE,
    schemat    TEXT NOT NULL UNIQUE
);

INSERT INTO wzorzec_spt_shared.tenant VALUES (1, 'acme', 't_acme');

-- Szablon DDL per tenant (w produkcji: migrator w pętli po rejestrze).
CREATE TABLE t_acme.zamowienie (
    zamowienie_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kwota          NUMERIC(12,2) NOT NULL
);

-- Połączenie tenanta: SET search_path = t_acme, wzorzec_spt_shared;
-- Offboarding: DROP SCHEMA t_acme CASCADE; (po backupie)
