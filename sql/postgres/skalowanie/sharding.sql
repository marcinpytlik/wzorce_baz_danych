-- Wzorzec: sharding / partycjonowanie (najpierw partycje w jednej instancji)
-- Silnik: PostgreSQL 14+
-- Karta:  wzorce/skalowanie/sharding.md

DROP SCHEMA IF EXISTS wzorzec_shard CASCADE;
CREATE SCHEMA wzorzec_shard;
SET search_path = wzorzec_shard;

-- Mapa: który zakres klucza → który shard (tu: partycja). Przy prawdziwym
-- shardingu to osobne instancje i connection string w katalogu.
CREATE TABLE shard_map (
    shard_id     INT PRIMARY KEY,
    klucz_od     INT NOT NULL,
    klucz_do     INT NOT NULL,
    CONSTRAINT ck_zakres CHECK (klucz_od < klucz_do)
);

INSERT INTO shard_map VALUES (0, 0, 1000000), (1, 1000000, 2000000);

CREATE TABLE zamowienie (
    tenant_id      INT NOT NULL,
    zamowienie_id  INT NOT NULL,
    payload        JSONB NOT NULL DEFAULT '{}'::jsonb,
    PRIMARY KEY (tenant_id, zamowienie_id)
) PARTITION BY HASH (tenant_id);

CREATE TABLE zamowienie_s0 PARTITION OF zamowienie
    FOR VALUES WITH (MODULUS 2, REMAINDER 0);
CREATE TABLE zamowienie_s1 PARTITION OF zamowienie
    FOR VALUES WITH (MODULUS 2, REMAINDER 1);

-- Unikalność globalna (email) NIE wynika z PK sharda — osobny serwis albo
-- shard po tym kluczu. FK między shardami nie istnieją.
