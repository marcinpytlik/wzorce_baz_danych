-- Wzorzec: adjacency list + CTE
-- Silnik: SQL Server 2022
-- Karta:  wzorce/hierarchie/adjacency-list.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_adj') IS NULL EXEC(N'CREATE SCHEMA wzorzec_adj');
GO

IF OBJECT_ID(N'wzorzec_adj.Wezel', N'U') IS NOT NULL DROP TABLE wzorzec_adj.Wezel;
GO

CREATE TABLE wzorzec_adj.Wezel (
    WezelId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_adj PRIMARY KEY,
    RodzicId INT NULL CONSTRAINT FK_adj_rodzic REFERENCES wzorzec_adj.Wezel (WezelId),
    Nazwa    NVARCHAR(200) NOT NULL,
    CONSTRAINT CK_adj_nie_sam CHECK (WezelId <> RodzicId)
);

CREATE INDEX IX_adj_rodzic ON wzorzec_adj.Wezel (RodzicId);
GO

-- Poddrzewo od korzeni; OPTION (MAXRECURSION 32) chroni przed cyklem/głębokością.
/*
WITH t AS (
    SELECT WezelId, RodzicId, Nazwa, 0 AS Glebokosc
    FROM wzorzec_adj.Wezel
    WHERE RodzicId IS NULL
    UNION ALL
    SELECT d.WezelId, d.RodzicId, d.Nazwa, t.Glebokosc + 1
    FROM wzorzec_adj.Wezel AS d
    JOIN t ON d.RodzicId = t.WezelId
)
SELECT * FROM t
OPTION (MAXRECURSION 32);
*/
