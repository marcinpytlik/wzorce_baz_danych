-- Wzorzec: CDC (wbudowane) — włączenie wymaga SQL Server Agent i uprawnień db_owner
-- Silnik: SQL Server 2019+
-- Karta:  wzorce/integracja/cdc.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_cdc') IS NULL EXEC(N'CREATE SCHEMA wzorzec_cdc');
GO

IF OBJECT_ID(N'wzorzec_cdc.Zamowienie', N'U') IS NOT NULL DROP TABLE wzorzec_cdc.Zamowienie;
GO

CREATE TABLE wzorzec_cdc.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cdc_zam PRIMARY KEY, -- PK wymagany
    Status       NVARCHAR(32) NOT NULL,
    ZmienionoAt  DATETIME2(3) NOT NULL CONSTRAINT DF_cdc_at DEFAULT (SYSUTCDATETIME())
);
GO

-- Włączenie (nie odpalaj w ciemno na produkcji — retencja logu / cleanup):
-- EXEC sys.sp_cdc_enable_db;
-- EXEC sys.sp_cdc_enable_table
--     @source_schema = N'wzorzec_cdc',
--     @source_name   = N'Zamowienie',
--     @role_name     = N'cdc_czytelnik',
--     @supports_net_changes = 1;
--
-- Konsument trzyma LSN:
-- DECLARE @from BINARY(10) = sys.fn_cdc_get_min_lsn('wzorzec_cdc_Zamowienie');
-- SELECT * FROM cdc.fn_cdc_get_all_changes_wzorzec_cdc_Zamowienie(@from, sys.fn_cdc_get_max_lsn(), N'all');
--
-- Lżejsza alternatywa: CHANGE_TRACKING (tylko które wiersze, nie pełny before/after).
-- CDC ≠ outbox: zmiana kolumny, nie zdarzenie biznesowe.
