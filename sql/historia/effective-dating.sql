-- Wzorzec: effective dating (valid time, zakaz nakładania)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/historia/effective-dating.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ed') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ed');
GO
DROP TABLE IF EXISTS wzorzec_ed.Cena;
GO

CREATE TABLE wzorzec_ed.Cena (
    CenaId    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProduktId INT NOT NULL,
    Kwota     DECIMAL(12,2) NOT NULL,
    WazneOd   DATE NOT NULL,
    WazneDo   DATE NOT NULL CONSTRAINT DF_ed_do DEFAULT ('9999-12-31'),
    CONSTRAINT CK_ed_okres CHECK (WazneOd < WazneDo)
);
CREATE INDEX IX_ed_prod ON wzorzec_ed.Cena (ProduktId, WazneOd, WazneDo);
GO

CREATE TRIGGER wzorzec_ed.trg_cena_nakladanie
ON wzorzec_ed.Cena
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN wzorzec_ed.Cena AS c
          ON c.ProduktId = i.ProduktId AND c.CenaId <> i.CenaId
         AND c.WazneOd < i.WazneDo AND i.WazneOd < c.WazneDo
    )
        THROW 50001, N'Nakładające się zakresy valid-time.', 1;
END;
GO
-- As-of: WHERE ProduktId=@id AND WazneOd <= @d AND @d < WazneDo
