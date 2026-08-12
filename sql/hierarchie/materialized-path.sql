-- Wzorzec: materialized path (hierarchyid)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/hierarchie/materialized-path.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_mp') IS NULL EXEC(N'CREATE SCHEMA wzorzec_mp');
GO

IF OBJECT_ID(N'wzorzec_mp.MpWstaw', N'P') IS NOT NULL DROP PROCEDURE wzorzec_mp.MpWstaw;
IF OBJECT_ID(N'wzorzec_mp.Wezel', N'U') IS NOT NULL DROP TABLE wzorzec_mp.Wezel;
GO

CREATE TABLE wzorzec_mp.Wezel (
    WezelId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_mp PRIMARY KEY,
    RodzicId INT NULL CONSTRAINT FK_mp_rodzic REFERENCES wzorzec_mp.Wezel (WezelId),
    Nazwa    NVARCHAR(200) NOT NULL,
    Sciezka  HIERARCHYID NOT NULL CONSTRAINT UQ_mp_sciezka UNIQUE
);

CREATE INDEX IX_mp_sciezka ON wzorzec_mp.Wezel (Sciezka);
GO

CREATE PROCEDURE wzorzec_mp.MpWstaw
    @RodzicId INT,
    @Nazwa    NVARCHAR(200),
    @Id       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RodzicPath HIERARCHYID, @Nowa HIERARCHYID, @Ostatnie HIERARCHYID;

    IF @RodzicId IS NULL
        SET @RodzicPath = HIERARCHYID::GetRoot();
    ELSE
        SELECT @RodzicPath = Sciezka FROM wzorzec_mp.Wezel WHERE WezelId = @RodzicId;

    SELECT @Ostatnie = MAX(Sciezka)
    FROM wzorzec_mp.Wezel
    WHERE Sciezka.GetAncestor(1) = @RodzicPath;

    SET @Nowa = @RodzicPath.GetDescendant(@Ostatnie, NULL);

    INSERT INTO wzorzec_mp.Wezel (RodzicId, Nazwa, Sciezka)
    VALUES (@RodzicId, @Nazwa, @Nowa);

    SET @Id = SCOPE_IDENTITY();
END;
GO

-- Poddrzewo: SELECT * FROM wzorzec_mp.Wezel WHERE Sciezka.IsDescendantOf(@rodzic) = 1;
