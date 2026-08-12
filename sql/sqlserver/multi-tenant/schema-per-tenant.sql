-- Wzorzec: schema-per-tenant
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/multi-tenant/schema-per-tenant.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_spt_shared') IS NULL EXEC(N'CREATE SCHEMA wzorzec_spt_shared');
IF SCHEMA_ID(N't_acme') IS NULL EXEC(N'CREATE SCHEMA t_acme');
GO

IF OBJECT_ID(N't_acme.Zamowienie', N'U') IS NOT NULL DROP TABLE t_acme.Zamowienie;
IF OBJECT_ID(N'wzorzec_spt_shared.Tenant', N'U') IS NOT NULL DROP TABLE wzorzec_spt_shared.Tenant;
GO

CREATE TABLE wzorzec_spt_shared.Tenant (
    TenantId INT NOT NULL CONSTRAINT PK_spt_tenant PRIMARY KEY,
    Kod      NVARCHAR(64) NOT NULL CONSTRAINT UQ_spt_kod UNIQUE,
    Schemat  NVARCHAR(128) NOT NULL CONSTRAINT UQ_spt_sch UNIQUE
);

INSERT INTO wzorzec_spt_shared.Tenant (TenantId, Kod, Schemat)
VALUES (1, N'acme', N't_acme');

CREATE TABLE t_acme.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_acme_zam PRIMARY KEY,
    Kwota        DECIMAL(12,2) NOT NULL
);
GO

-- Login tenanta: DEFAULT_SCHEMA = t_acme, GRANT tylko na ten schemat.
-- Offboarding: DROP TABLE ... ; DROP SCHEMA t_acme; (po backupie)
-- Migracje: pętla po rejestrze — nie jedna migracja EF na dbo.
