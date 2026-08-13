-- Wzorzec: sharding / partycjonowanie RANGE (SQL Server nie ma HASH jak Postgres)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wydajnosc/sharding.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_shard') IS NULL EXEC(N'CREATE SCHEMA wzorzec_shard');
GO

IF OBJECT_ID(N'wzorzec_shard.Zamowienie', N'U') IS NOT NULL DROP TABLE wzorzec_shard.Zamowienie;
IF OBJECT_ID(N'wzorzec_shard.ShardMap', N'U') IS NOT NULL DROP TABLE wzorzec_shard.ShardMap;
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = N'ps_tenant')
    DROP PARTITION SCHEME ps_tenant;
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = N'pf_tenant')
    DROP PARTITION FUNCTION pf_tenant;
GO

CREATE TABLE wzorzec_shard.ShardMap (
    ShardId  INT NOT NULL CONSTRAINT PK_shardmap PRIMARY KEY,
    KluczOd  INT NOT NULL,
    KluczDo  INT NOT NULL,
    CONSTRAINT CK_shard_zakres CHECK (KluczOd < KluczDo)
);

INSERT INTO wzorzec_shard.ShardMap (ShardId, KluczOd, KluczDo) VALUES (0, 0, 1000000), (1, 1000000, 2000000);

CREATE PARTITION FUNCTION pf_tenant (INT)
AS RANGE RIGHT FOR VALUES (1000000);

CREATE PARTITION SCHEME ps_tenant
AS PARTITION pf_tenant ALL TO ([PRIMARY]);

CREATE TABLE wzorzec_shard.Zamowienie (
    TenantId     INT NOT NULL,
    ZamowienieId INT NOT NULL,
    Payload      NVARCHAR(MAX) NOT NULL CONSTRAINT DF_sh_json DEFAULT (N'{}'),
    CONSTRAINT PK_sh_zam PRIMARY KEY (TenantId, ZamowienieId) ON ps_tenant (TenantId)
) ON ps_tenant (TenantId);
GO

-- Prawdziwy sharding = wiele instancji + routing z ShardMap (connection string).
-- Partycje w jednej instancji to pierwszy szczebel: FK i TX jeszcze działają.
