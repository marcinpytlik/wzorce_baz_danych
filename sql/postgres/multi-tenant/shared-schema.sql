-- Wzorzec: shared schema — TenantId w PK i FK
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/multi-tenant/shared-schema.md

DROP SCHEMA IF EXISTS wzorzec_shared CASCADE;
CREATE SCHEMA wzorzec_shared;
SET search_path = wzorzec_shared;

CREATE TABLE tenant (
    tenant_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kod        TEXT NOT NULL UNIQUE
);

CREATE TABLE klient (
    tenant_id  INT NOT NULL REFERENCES tenant (tenant_id),
    klient_id  INT GENERATED ALWAYS AS IDENTITY,
    email      TEXT NOT NULL,
    PRIMARY KEY (tenant_id, klient_id),
    UNIQUE (tenant_id, email)
);

CREATE TABLE zamowienie (
    tenant_id      INT NOT NULL,
    zamowienie_id  INT GENERATED ALWAYS AS IDENTITY,
    klient_id      INT NOT NULL,
    PRIMARY KEY (tenant_id, zamowienie_id),
    FOREIGN KEY (tenant_id, klient_id)
        REFERENCES klient (tenant_id, klient_id)
);

-- FK złożone: nie podpinasz klienta tenanta A pod zamówienie tenanta B.
