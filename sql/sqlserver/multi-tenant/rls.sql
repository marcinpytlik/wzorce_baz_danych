-- Wzorzec: RLS (security policy + SESSION_CONTEXT)
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/multi-tenant/rls.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_rls') IS NULL EXEC(N'CREATE SCHEMA wzorzec_rls');
GO

IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = N'TenantFilter' AND schema_id = SCHEMA_ID(N'wzorzec_rls'))
    DROP SECURITY POLICY wzorzec_rls.TenantFilter;
IF OBJECT_ID(N'wzorzec_rls.fn_tenant_predicate', N'IF') IS NOT NULL DROP FUNCTION wzorzec_rls.fn_tenant_predicate;
IF OBJECT_ID(N'wzorzec_rls.Zamowienie', N'U') IS NOT NULL DROP TABLE wzorzec_rls.Zamowienie;
GO

CREATE TABLE wzorzec_rls.Zamowienie (
    TenantId     INT NOT NULL,
    ZamowienieId INT IDENTITY(1,1) NOT NULL,
    Kwota        DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_rls_zam PRIMARY KEY (TenantId, ZamowienieId)
);
GO

CREATE FUNCTION wzorzec_rls.fn_tenant_predicate(@TenantId INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS fn_access
    WHERE @TenantId = CONVERT(INT, SESSION_CONTEXT(N'TenantId'));
GO

CREATE SECURITY POLICY wzorzec_rls.TenantFilter
ADD FILTER PREDICATE wzorzec_rls.fn_tenant_predicate(TenantId) ON wzorzec_rls.Zamowienie,
ADD BLOCK  PREDICATE wzorzec_rls.fn_tenant_predicate(TenantId) ON wzorzec_rls.Zamowienie
WITH (STATE = ON, SCHEMABINDING = ON);
GO

-- Aplikacja (i reset przy zwrocie do puli!):
-- EXEC sys.sp_set_session_context @key = N'TenantId', @value = 42, @read_only = 1;
-- dbo / sysadmin omija polityki — aplikacja nie łączy się jako sa.
