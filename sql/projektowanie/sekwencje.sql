-- IDENTITY vs SEQUENCE vs UNIQUEIDENTIFIER
-- Karta: projektowanie/sekwencje.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_seq') IS NULL EXEC(N'CREATE SCHEMA wzorzec_seq');
GO
IF OBJECT_ID(N'wzorzec_seq.SeqDokument', N'SO') IS NOT NULL DROP SEQUENCE wzorzec_seq.SeqDokument;
DROP TABLE IF EXISTS wzorzec_seq.ZGuid;
DROP TABLE IF EXISTS wzorzec_seq.ZSeq;
DROP TABLE IF EXISTS wzorzec_seq.ZIdent;
GO
CREATE TABLE wzorzec_seq.ZIdent (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Tresc NVARCHAR(40) NOT NULL
);
CREATE SEQUENCE wzorzec_seq.SeqDokument AS INT START WITH 1 INCREMENT BY 1;
CREATE TABLE wzorzec_seq.ZSeq (
    Id INT NOT NULL CONSTRAINT DF_seq DEFAULT (NEXT VALUE FOR wzorzec_seq.SeqDokument) PRIMARY KEY,
    Tresc NVARCHAR(40) NOT NULL
);
CREATE TABLE wzorzec_seq.ZGuid (
    Id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_guid DEFAULT (NEWSEQUENTIALID()) PRIMARY KEY,
    Tresc NVARCHAR(40) NOT NULL
);
GO
-- NEWID() na clustered PK — nie. NEWSEQUENTIALID tylko jako DEFAULT kolumny.
-- IDENTITY nie jest numerem faktury (luki po rollback).
