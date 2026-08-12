-- Wzorzec: RLS na shared schema
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/multi-tenant/rls.md

DROP SCHEMA IF EXISTS wzorzec_rls CASCADE;
CREATE SCHEMA wzorzec_rls;
SET search_path = wzorzec_rls;

CREATE TABLE zamowienie (
    tenant_id      INT NOT NULL,
    zamowienie_id  INT GENERATED ALWAYS AS IDENTITY,
    kwota          NUMERIC(12,2) NOT NULL,
    PRIMARY KEY (tenant_id, zamowienie_id)
);

ALTER TABLE zamowienie ENABLE ROW LEVEL SECURITY;
ALTER TABLE zamowienie FORCE ROW LEVEL SECURITY;

CREATE POLICY tenant_izlo ON zamowienie
    USING (tenant_id = current_setting('app.tenant_id')::INT)
    WITH CHECK (tenant_id = current_setting('app.tenant_id')::INT);

-- Aplikacja na starcie requestu (i przy zwrocie połączenia do puli!):
-- SET app.tenant_id = '42';
-- Brak ustawienia ma rzucić, nie zwrócić „pusto”:
-- SET app.tenant_id TO DEFAULT;  -- current_setting bez missing_ok → błąd

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_rls') THEN
        CREATE ROLE app_rls NOLOGIN;
    END IF;
END $$;

GRANT USAGE ON SCHEMA wzorzec_rls TO app_rls;
GRANT SELECT, INSERT, UPDATE, DELETE ON zamowienie TO app_rls;
-- Właściciel tabeli z FORCE RLS też podlega polityce.
-- Superuser omija RLS — aplikacja NIE łączy się jako postgres.
