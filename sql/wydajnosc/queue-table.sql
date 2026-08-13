-- Wzorzec: queue table (UPDLOCK, READPAST)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wydajnosc/queue-table.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_qt') IS NULL EXEC(N'CREATE SCHEMA wzorzec_qt');
GO
DROP TABLE IF EXISTS wzorzec_qt.Kolejka;
GO

CREATE TABLE wzorzec_qt.Kolejka (
    Id         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Klucz      NVARCHAR(64) NULL,
    Payload    NVARCHAR(MAX) NOT NULL,
    Status     NVARCHAR(16) NOT NULL CHECK (Status IN (N'Nowa', N'WToku', N'Zrobiona', N'Martwa')),
    WidocznyAt DATETIME2(3) NOT NULL CONSTRAINT DF_qt_vis DEFAULT (SYSUTCDATETIME()),
    Proby      INT NOT NULL CONSTRAINT DF_qt_p DEFAULT (0),
    CONSTRAINT CK_qt_json CHECK (ISJSON(Payload) = 1)
);

CREATE INDEX IX_qt_dren
    ON wzorzec_qt.Kolejka (WidocznyAt, Id)
    WHERE Status = N'Nowa';
GO

CREATE OR ALTER PROCEDURE wzorzec_qt.Wez
    @Limit INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH cte AS (
        SELECT TOP (@Limit) *
        FROM wzorzec_qt.Kolejka WITH (UPDLOCK, READPAST, ROWLOCK)
        WHERE Status = N'Nowa' AND WidocznyAt <= SYSUTCDATETIME()
        ORDER BY Id
    )
    UPDATE cte
    SET Status = N'WToku',
        Proby = Proby + 1
    OUTPUT inserted.*;
END;
GO
