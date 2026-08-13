-- Computed = atrybut pochodny z Chena
-- Karta: projektowanie/kolumna-obliczana.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_comp') IS NULL EXEC(N'CREATE SCHEMA wzorzec_comp');
GO
DROP TABLE IF EXISTS wzorzec_comp.Pozycja;
GO
CREATE TABLE wzorzec_comp.Pozycja (
    ZamowienieId  INT NOT NULL,
    Lp            INT NOT NULL,
    Ilosc         INT NOT NULL CHECK (Ilosc > 0),
    CenaWMomencie DECIMAL(19,4) NOT NULL,
    Wartosc AS (CONVERT(DECIMAL(19,4), Ilosc * CenaWMomencie)) PERSISTED,
    CONSTRAINT PK_comp PRIMARY KEY (ZamowienieId, Lp)
);
GO
-- Suma zamówienia ≠ computed na Zamowienie (to agregat wielu wierszy → indexed view / SELECT).
