-- Wzorzec: audit trail (append-only dla runtime)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/historia/audit-trail.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_audit') IS NULL EXEC(N'CREATE SCHEMA wzorzec_audit');
GO
DROP TABLE IF EXISTS wzorzec_audit.Audit;
DROP TABLE IF EXISTS wzorzec_audit.Dokument;
GO

CREATE TABLE wzorzec_audit.Dokument (
    DokumentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Tresc      NVARCHAR(400) NOT NULL
);

CREATE TABLE wzorzec_audit.Audit (
    AuditId    BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Kiedy      DATETIME2(3) NOT NULL CONSTRAINT DF_aud_kiedy DEFAULT (SYSUTCDATETIME()),
    Kto        SYSNAME NOT NULL CONSTRAINT DF_aud_kto DEFAULT (SUSER_SNAME()),
    Encja      NVARCHAR(64) NOT NULL,
    EncjaId    INT NOT NULL,
    Operacja   CHAR(1) NOT NULL CHECK (Operacja IN ('I','U','D')),
    Payload    NVARCHAR(MAX) NULL,
    CONSTRAINT CK_aud_json CHECK (Payload IS NULL OR ISJSON(Payload) = 1)
);
GO

CREATE TRIGGER wzorzec_audit.trg_dokument_audit
ON wzorzec_audit.Dokument
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT wzorzec_audit.Audit (Encja, EncjaId, Operacja, Payload)
    SELECT N'Dokument', i.DokumentId, 'I', (SELECT i.Tresc FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted AS i
    WHERE NOT EXISTS (SELECT 1 FROM deleted AS d WHERE d.DokumentId = i.DokumentId);

    INSERT wzorzec_audit.Audit (Encja, EncjaId, Operacja, Payload)
    SELECT N'Dokument', i.DokumentId, 'U', (SELECT i.Tresc FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM inserted AS i
    JOIN deleted AS d ON d.DokumentId = i.DokumentId;

    INSERT wzorzec_audit.Audit (Encja, EncjaId, Operacja, Payload)
    SELECT N'Dokument', d.DokumentId, 'D', (SELECT d.Tresc FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM deleted AS d
    WHERE NOT EXISTS (SELECT 1 FROM inserted AS i WHERE i.DokumentId = d.DokumentId);
END;
GO
-- Runtime: GRANT INSERT, SELECT ON Audit; bez UPDATE/DELETE.
