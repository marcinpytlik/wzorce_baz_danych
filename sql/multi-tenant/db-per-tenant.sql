-- Wzorzec: db-per-tenant — katalog (same bazy tenantów: CREATE DATABASE / RESTORE szablonu)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/multi-tenant/db-per-tenant.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_dpt') IS NULL EXEC(N'CREATE SCHEMA wzorzec_dpt');
GO

IF OBJECT_ID(N'wzorzec_dpt.KatalogTenant', N'U') IS NOT NULL DROP TABLE wzorzec_dpt.KatalogTenant;
GO

CREATE TABLE wzorzec_dpt.KatalogTenant (
    TenantId        INT NOT NULL CONSTRAINT PK_dpt PRIMARY KEY,
    Kod             NVARCHAR(64) NOT NULL CONSTRAINT UQ_dpt_kod UNIQUE,
    Baza            SYSNAME NOT NULL CONSTRAINT UQ_dpt_baza UNIQUE, -- np. Tenant_Acme
    Instancja       NVARCHAR(256) NOT NULL, -- host\inst, nie connection string z hasłem
    WersjaSchematu  NVARCHAR(32) NOT NULL,
    Aktywny         BIT NOT NULL CONSTRAINT DF_dpt_akt DEFAULT (1)
);
GO

-- Provisioning (osobna rola):
-- RESTORE DATABASE Tenant_Acme FROM DISK = N'...szablon.bak' WITH MOVE ...;
-- INSERT KatalogTenant ...
--
-- Aplikacja czyta katalog, hasła z vault. TLS do instancji.
-- W bazie tenanta nie ma TenantId na każdej tabeli. Restore klienta = RESTORE tej bazy.
-- Osobna instancja to kolejny szczebel operacyjny, nie ten wzorzec.
