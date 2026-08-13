-- Wzorzec: read replicas — routing w katalogu (AG / log shipping poza skryptem)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wydajnosc/read-replicas.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_rr') IS NULL EXEC(N'CREATE SCHEMA wzorzec_rr');
GO
DROP TABLE IF EXISTS wzorzec_rr.KatalogPolaczen;
GO
CREATE TABLE wzorzec_rr.KatalogPolaczen (
    Rola      NVARCHAR(16) NOT NULL PRIMARY KEY CHECK (Rola IN (N'Primary', N'ReadOnly')),
    Instancja NVARCHAR(256) NOT NULL,
    Baza      SYSNAME NOT NULL,
    Intent    NVARCHAR(32) NOT NULL -- ReadWrite / ReadOnly
);
INSERT wzorzec_rr.KatalogPolaczen VALUES
    (N'Primary',  N'tcp:ag-listener,1433', N'App', N'ReadWrite'),
    (N'ReadOnly', N'tcp:ag-listener,1433', N'App', N'ReadOnly');
GO
-- Connection: ApplicationIntent=ReadOnly na secondary.
-- Po INSERT na primary nie czytaj secondary w tym samym requestcie.
