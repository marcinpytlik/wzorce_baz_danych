-- Wzorzec: soft delete + indeks filtrowany
-- Silnik: SQL Server 2022
-- Karta:  wzorce/usuwanie/soft-delete.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_soft') IS NULL EXEC(N'CREATE SCHEMA wzorzec_soft');
GO

IF OBJECT_ID(N'wzorzec_soft.v_produkt', N'V') IS NOT NULL DROP VIEW wzorzec_soft.v_produkt;
IF OBJECT_ID(N'wzorzec_soft.Produkt', N'U') IS NOT NULL DROP TABLE wzorzec_soft.Produkt;
GO

CREATE TABLE wzorzec_soft.Produkt (
    ProduktId     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_soft_prod PRIMARY KEY,
    Sku           NVARCHAR(64) NOT NULL,
    Nazwa         NVARCHAR(200) NOT NULL,
    UsunietoAt    DATETIME2(3) NULL,
    UsunietoPrzez NVARCHAR(128) NULL
);

CREATE UNIQUE INDEX UQ_produkt_sku_zywy
    ON wzorzec_soft.Produkt (Sku)
    WHERE UsunietoAt IS NULL;
GO

CREATE VIEW wzorzec_soft.v_produkt
AS
SELECT ProduktId, Sku, Nazwa
FROM wzorzec_soft.Produkt
WHERE UsunietoAt IS NULL;
GO

-- Soft delete: UPDATE ... SET UsunietoAt = SYSUTCDATETIME() WHERE ProduktId = @id AND UsunietoAt IS NULL;
-- Purge (twardy DELETE) = job retencyjny, nie UI.
