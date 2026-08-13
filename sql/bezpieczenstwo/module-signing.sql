-- Wzorzec: module signing (szkic — certyfikat wymaga hasła w prawdziwym środowisku)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/bezpieczenstwo/module-signing.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ms') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ms');
GO

CREATE OR ALTER PROCEDURE wzorzec_ms.DiagWho
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SUSER_SNAME() AS Login, ORIGINAL_LOGIN() AS OriginalLogin;
END;
GO

-- CREATE CERTIFICATE WzorzecMsCert
--     ENCRYPTION BY PASSWORD = N'...'
--     WITH SUBJECT = N'Module signing wzorzec';
-- ADD SIGNATURE TO wzorzec_ms.DiagWho BY CERTIFICATE WzorzecMsCert WITH PASSWORD = N'...';
-- CREATE LOGIN WzorzecMsLogin FROM CERTIFICATE WzorzecMsCert;
-- GRANT VIEW SERVER STATE TO WzorzecMsLogin;
-- GRANT EXECUTE ON wzorzec_ms.DiagWho TO app_runtime;
-- Po ALTER PROC podpis spada — podpisz w migracji.
