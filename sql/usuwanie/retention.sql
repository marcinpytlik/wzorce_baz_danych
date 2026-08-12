-- Wzorzec: retention policy (rejestr + job)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/usuwanie/retention.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ret') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ret');
GO
DROP TABLE IF EXISTS wzorzec_ret.Bieg;
DROP TABLE IF EXISTS wzorzec_ret.Polityka;
GO

CREATE TABLE wzorzec_ret.Polityka (
    Tabela     NVARCHAR(128) NOT NULL PRIMARY KEY,
    Dni        INT NOT NULL CHECK (Dni > 0),
    Akcja      NVARCHAR(32) NOT NULL CHECK (Akcja IN (N'HardDelete', N'Archive', N'Tombstone', N'PartitionSwitch')),
    Wlasciciel NVARCHAR(128) NOT NULL,
    OstatniBiegAt DATETIME2(3) NULL
);

CREATE TABLE wzorzec_ret.Bieg (
    BiegId     BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Tabela     NVARCHAR(128) NOT NULL,
    StartAt    DATETIME2(3) NOT NULL CONSTRAINT DF_ret_s DEFAULT (SYSUTCDATETIME()),
    Wierszy    INT NULL,
    Blad       NVARCHAR(4000) NULL
);
GO
INSERT wzorzec_ret.Polityka (Tabela, Dni, Akcja, Wlasciciel)
VALUES (N'outbox.Outbox', 14, N'HardDelete', N'platforma');
-- Job: SELECT * FROM Polityka; EXEC odpowiadającą procedurę; UPDATE OstatniBiegAt.
