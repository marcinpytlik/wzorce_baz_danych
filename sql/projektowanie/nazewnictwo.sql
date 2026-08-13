-- Nazewnictwo: wzorzec dobrych identyfikatorów (zły przykład w komentarzu)
-- Karta: projektowanie/nazewnictwo.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_nazwy') IS NULL EXEC(N'CREATE SCHEMA wzorzec_nazwy');
GO
DROP TABLE IF EXISTS wzorzec_nazwy.Zamowienie;
DROP TABLE IF EXISTS wzorzec_nazwy.Klient;
GO
CREATE TABLE wzorzec_nazwy.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_nazwy_klient PRIMARY KEY,
    Nazwa    NVARCHAR(200) NOT NULL
);
CREATE TABLE wzorzec_nazwy.Zamowienie (
    ZamowienieId     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_nazwy_zam PRIMARY KEY,
    PlatnikKlientId  INT NOT NULL CONSTRAINT FK_nazwy_platnik
        REFERENCES wzorzec_nazwy.Klient (KlientId) ON DELETE NO ACTION,
    OdbiorcaKlientId INT NOT NULL CONSTRAINT FK_nazwy_odbiorca
        REFERENCES wzorzec_nazwy.Klient (KlientId) ON DELETE NO ACTION
);
GO
-- Źle: tbl_Order, ID, KlientId + KlientId2, sp_get, Zamówienie.
