-- Typy: typowe dziedziny OLTP
-- Karta: projektowanie/typy.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_typy') IS NULL EXEC(N'CREATE SCHEMA wzorzec_typy');
GO
DROP TABLE IF EXISTS wzorzec_typy.Przyklad;
GO
CREATE TABLE wzorzec_typy.Przyklad (
    PrzykladId   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Sku          VARCHAR(32) NOT NULL,
    Nazwa        NVARCHAR(200) NOT NULL,
    Cena         DECIMAL(19,4) NOT NULL,
    Aktywny      BIT NOT NULL CONSTRAINT DF_typy_akt DEFAULT (1),
    Dzien        DATE NOT NULL,
    ZarejestrowanoUtc DATETIME2(3) NOT NULL CONSTRAINT DF_typy_utc DEFAULT (SYSUTCDATETIME()),
    WersjaWiersza ROWVERSION NOT NULL,
    CONSTRAINT CK_typy_cena CHECK (Cena >= 0)
);
GO
-- Nie: FLOAT na Cena, DATETIME na Dzien, VARCHAR na Nazwa, TIMESTAMP jako data.
