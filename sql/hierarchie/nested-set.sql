-- Wzorzec: nested set
-- Silnik: SQL Server 2022
-- Karta:  wzorce/hierarchie/nested-set.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ns') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ns');
GO

IF OBJECT_ID(N'wzorzec_ns.NsWstawDziecko', N'P') IS NOT NULL DROP PROCEDURE wzorzec_ns.NsWstawDziecko;
IF OBJECT_ID(N'wzorzec_ns.Wezel', N'U') IS NOT NULL DROP TABLE wzorzec_ns.Wezel;
GO

CREATE TABLE wzorzec_ns.Wezel (
    WezelId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ns PRIMARY KEY,
    RodzicId INT NULL CONSTRAINT FK_ns_rodzic REFERENCES wzorzec_ns.Wezel (WezelId),
    Nazwa    NVARCHAR(200) NOT NULL,
    Lft      INT NOT NULL CONSTRAINT UQ_ns_lft UNIQUE,
    Rgt      INT NOT NULL CONSTRAINT UQ_ns_rgt UNIQUE,
    Poziom   INT NOT NULL CONSTRAINT DF_ns_poz DEFAULT (0),
    CONSTRAINT CK_ns_lft_rgt CHECK (Lft < Rgt)
);

CREATE INDEX IX_ns_zakres ON wzorzec_ns.Wezel (Lft, Rgt);
GO

CREATE PROCEDURE wzorzec_ns.NsWstawDziecko
    @RodzicId INT,
    @Nazwa    NVARCHAR(200),
    @NowyId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Rgt INT, @Poziom INT;

    SELECT @Rgt = Rgt, @Poziom = Poziom
    FROM wzorzec_ns.Wezel WITH (UPDLOCK, HOLDLOCK)
    WHERE WezelId = @RodzicId;

    IF @Rgt IS NULL
        THROW 50001, N'Brak rodzica.', 1;

    UPDATE wzorzec_ns.Wezel SET Rgt = Rgt + 2 WHERE Rgt >= @Rgt;
    UPDATE wzorzec_ns.Wezel SET Lft = Lft + 2 WHERE Lft >= @Rgt;

    INSERT INTO wzorzec_ns.Wezel (RodzicId, Nazwa, Lft, Rgt, Poziom)
    VALUES (@RodzicId, @Nazwa, @Rgt, @Rgt + 1, @Poziom + 1);

    SET @NowyId = SCOPE_IDENTITY();
END;
GO
