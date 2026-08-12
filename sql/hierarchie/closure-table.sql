-- Wzorzec: closure table
-- Silnik: SQL Server 2022
-- Karta:  wzorce/hierarchie/closure-table.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_cl') IS NULL EXEC(N'CREATE SCHEMA wzorzec_cl');
GO

IF OBJECT_ID(N'wzorzec_cl.ClWstawDziecko', N'P') IS NOT NULL DROP PROCEDURE wzorzec_cl.ClWstawDziecko;
IF OBJECT_ID(N'wzorzec_cl.ClWstawKorzen', N'P') IS NOT NULL DROP PROCEDURE wzorzec_cl.ClWstawKorzen;
IF OBJECT_ID(N'wzorzec_cl.Domkniecie', N'U') IS NOT NULL DROP TABLE wzorzec_cl.Domkniecie;
IF OBJECT_ID(N'wzorzec_cl.Wezel', N'U') IS NOT NULL DROP TABLE wzorzec_cl.Wezel;
GO

CREATE TABLE wzorzec_cl.Wezel (
    WezelId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cl_wezel PRIMARY KEY,
    Nazwa   NVARCHAR(200) NOT NULL
);

CREATE TABLE wzorzec_cl.Domkniecie (
    PrzodekId  INT NOT NULL CONSTRAINT FK_cl_prz REFERENCES wzorzec_cl.Wezel (WezelId) ON DELETE NO ACTION,
    PotomekId  INT NOT NULL CONSTRAINT FK_cl_pot REFERENCES wzorzec_cl.Wezel (WezelId) ON DELETE NO ACTION,
    Glebokosc  INT NOT NULL CONSTRAINT CK_cl_g CHECK (Glebokosc >= 0),
    CONSTRAINT PK_cl PRIMARY KEY (PrzodekId, PotomekId)
);

CREATE UNIQUE INDEX UQ_cl_jeden_rodzic
    ON wzorzec_cl.Domkniecie (PotomekId)
    WHERE Glebokosc = 1;

CREATE INDEX IX_cl_potomek ON wzorzec_cl.Domkniecie (PotomekId, Glebokosc);
GO

CREATE PROCEDURE wzorzec_cl.ClWstawKorzen
    @Nazwa NVARCHAR(200),
    @Id    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO wzorzec_cl.Wezel (Nazwa) VALUES (@Nazwa);
    SET @Id = SCOPE_IDENTITY();
    INSERT INTO wzorzec_cl.Domkniecie (PrzodekId, PotomekId, Glebokosc)
    VALUES (@Id, @Id, 0);
END;
GO

CREATE PROCEDURE wzorzec_cl.ClWstawDziecko
    @RodzicId INT,
    @Nazwa    NVARCHAR(200),
    @Id       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO wzorzec_cl.Wezel (Nazwa) VALUES (@Nazwa);
    SET @Id = SCOPE_IDENTITY();

    INSERT INTO wzorzec_cl.Domkniecie (PrzodekId, PotomekId, Glebokosc)
    SELECT PrzodekId, @Id, Glebokosc + 1
    FROM wzorzec_cl.Domkniecie
    WHERE PotomekId = @RodzicId
    UNION ALL
    SELECT @Id, @Id, 0;
END;
GO
