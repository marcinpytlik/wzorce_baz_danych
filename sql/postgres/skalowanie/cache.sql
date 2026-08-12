-- Wzorzec: cache-aside w tabeli + TTL + advisory lock na fill
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/skalowanie/cache.md

DROP SCHEMA IF EXISTS wzorzec_cache CASCADE;
CREATE SCHEMA wzorzec_cache;
SET search_path = wzorzec_cache;

CREATE TABLE cache_pozycja (
    klucz       TEXT PRIMARY KEY,
    payload     JSONB NOT NULL,
    wygasa_at   TIMESTAMPTZ NOT NULL,
    etag        TEXT NOT NULL
);

CREATE INDEX ix_cache_wygasa ON cache_pozycja (wygasa_at);

CREATE FUNCTION cache_get(p_klucz TEXT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE v JSONB;
BEGIN
    SELECT payload INTO v
    FROM cache_pozycja
    WHERE klucz = p_klucz AND wygasa_at > now();
    RETURN v;  -- NULL = miss
END;
$$;

-- Fill: SELECT pg_advisory_xact_lock(hashtext(p_klucz)); potem INSERT ... ON CONFLICT.
CREATE FUNCTION cache_put(p_klucz TEXT, p_payload JSONB, p_ttl INTERVAL, p_etag TEXT)
RETURNS VOID
LANGUAGE sql
AS $$
    INSERT INTO cache_pozycja (klucz, payload, wygasa_at, etag)
    VALUES (p_klucz, p_payload, now() + p_ttl, p_etag)
    ON CONFLICT (klucz) DO UPDATE
    SET payload   = EXCLUDED.payload,
        wygasa_at = EXCLUDED.wygasa_at,
        etag      = EXCLUDED.etag;
$$;
