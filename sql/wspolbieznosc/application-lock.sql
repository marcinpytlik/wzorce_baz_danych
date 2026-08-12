-- Wzorzec: sp_getapplock
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wspolbieznosc/application-lock.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_al') IS NULL EXEC(N'CREATE SCHEMA wzorzec_al');
GO

CREATE OR ALTER PROCEDURE wzorzec_al.JedenBackfill
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @rc INT;
    BEGIN TRAN;
    EXEC @rc = sys.sp_getapplock
        @Resource = N'backfill:Zamowienie',
        @LockMode = N'Exclusive',
        @LockOwner = N'Transaction',
        @LockTimeout = 1000;
    IF @rc < 0
    BEGIN
        ROLLBACK;
        THROW 50001, N'Backfill już trwa.', 1;
    END;
    -- praca
    COMMIT; -- zwalnia applock
END;
GO
