-- Wzorzec: cache-aside + TTL + sp_getapplock na fill
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/skalowanie/cache.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_cache') IS NULL EXEC(N'CREATE SCHEMA wzorzec_cache');
GO

IF OBJECT_ID(N'wzorzec_cache.CachePut', N'P') IS NOT NULL DROP PROCEDURE wzorzec_cache.CachePut;
IF OBJECT_ID(N'wzorzec_cache.CacheGet', N'P') IS NOT NULL DROP PROCEDURE wzorzec_cache.CacheGet;
IF OBJECT_ID(N'wzorzec_cache.Pozycja', N'U') IS NOT NULL DROP TABLE wzorzec_cache.Pozycja;
GO

CREATE TABLE wzorzec_cache.Pozycja (
    Klucz     NVARCHAR(200) NOT NULL CONSTRAINT PK_cache PRIMARY KEY,
    Payload   NVARCHAR(MAX) NOT NULL,
    WygasaAt  DATETIME2(3) NOT NULL,
    Etag      NVARCHAR(64) NOT NULL,
    CONSTRAINT CK_cache_json CHECK (ISJSON(Payload) = 1)
);

CREATE INDEX IX_cache_wygasa ON wzorzec_cache.Pozycja (WygasaAt);
GO

CREATE PROCEDURE wzorzec_cache.CacheGet
    @Klucz NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Payload
    FROM wzorzec_cache.Pozycja
    WHERE Klucz = @Klucz AND WygasaAt > SYSUTCDATETIME();
END;
GO

CREATE PROCEDURE wzorzec_cache.CachePut
    @Klucz   NVARCHAR(200),
    @Payload NVARCHAR(MAX),
    @TtlSec  INT,
    @Etag    NVARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    MERGE wzorzec_cache.Pozycja AS t
    USING (SELECT @Klucz AS Klucz) AS s
       ON t.Klucz = s.Klucz
    WHEN MATCHED THEN
        UPDATE SET Payload = @Payload,
                   WygasaAt = DATEADD(SECOND, @TtlSec, SYSUTCDATETIME()),
                   Etag = @Etag
    WHEN NOT MATCHED THEN
        INSERT (Klucz, Payload, WygasaAt, Etag)
        VALUES (@Klucz, @Payload, DATEADD(SECOND, @TtlSec, SYSUTCDATETIME()), @Etag);
END;
GO

-- Stampede: EXEC sp_getapplock @Resource = @Klucz, @LockMode = 'Exclusive'; potem fill.
