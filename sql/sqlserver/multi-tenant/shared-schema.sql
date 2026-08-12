-- Wzorzec: shared schema — TenantId w PK i FK
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/multi-tenant/shared-schema.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_shared') IS NULL EXEC(N'CREATE SCHEMA wzorzec_shared');
GO

IF OBJECT_ID(N'wzorzec_shared.Zamowienie', N'U') IS NOT NULL DROP TABLE wzorzec_shared.Zamowienie;
IF OBJECT_ID(N'wzorzec_shared.Klient', N'U') IS NOT NULL DROP TABLE wzorzec_shared.Klient;
IF OBJECT_ID(N'wzorzec_shared.Tenant', N'U') IS NOT NULL DROP TABLE wzorzec_shared.Tenant;
GO

CREATE TABLE wzorzec_shared.Tenant (
    TenantId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tenant PRIMARY KEY,
    Kod      NVARCHAR(64) NOT NULL CONSTRAINT UQ_tenant_kod UNIQUE
);

CREATE TABLE wzorzec_shared.Klient (
    TenantId INT NOT NULL,
    KlientId INT IDENTITY(1,1) NOT NULL,
    Email    NVARCHAR(320) NOT NULL,
    CONSTRAINT PK_klient PRIMARY KEY (TenantId, KlientId),
    CONSTRAINT FK_klient_tenant FOREIGN KEY (TenantId)
        REFERENCES wzorzec_shared.Tenant (TenantId),
    CONSTRAINT UQ_klient_email UNIQUE (TenantId, Email)
);

CREATE TABLE wzorzec_shared.Zamowienie (
    TenantId     INT NOT NULL,
    ZamowienieId INT IDENTITY(1,1) NOT NULL,
    KlientId     INT NOT NULL,
    CONSTRAINT PK_zam PRIMARY KEY (TenantId, ZamowienieId),
    CONSTRAINT FK_zam_klient FOREIGN KEY (TenantId, KlientId)
        REFERENCES wzorzec_shared.Klient (TenantId, KlientId)
);
GO
