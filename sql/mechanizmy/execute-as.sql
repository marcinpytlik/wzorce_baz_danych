-- Mechanizm: EXECUTE AS OWNER (preferuj module signing)
-- Silnik: SQL Server 2022
-- Karta:  mechanizmy/execute-as.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'mech_ea') IS NULL EXEC(N'CREATE SCHEMA mech_ea');
GO
CREATE OR ALTER PROCEDURE mech_ea.Diag
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SUSER_SNAME() AS AsUser, ORIGINAL_LOGIN() AS OriginalLogin;
END;
GO
-- Caller z EXECUTE widzi kontekst OWNER. Łatwo dać za dużo. Patrz module signing.
