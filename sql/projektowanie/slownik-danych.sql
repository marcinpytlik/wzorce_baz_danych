-- Słownik danych: extended properties
-- Karta: projektowanie/slownik-danych.md
SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_sd') IS NULL EXEC(N'CREATE SCHEMA wzorzec_sd');
GO
DROP TABLE IF EXISTS wzorzec_sd.Pozycja;
GO
CREATE TABLE wzorzec_sd.Pozycja (
    ZamowienieId  INT NOT NULL,
    Lp            INT NOT NULL,
    CenaWMomencie DECIMAL(19,4) NOT NULL,
    CONSTRAINT PK_sd_poz PRIMARY KEY (ZamowienieId, Lp)
);
GO
EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Ziarno: jedna linia jednego zamówienia. CenaWMomencie = snapshot, nie kopia ceny produktu.',
    @level0type = N'SCHEMA', @level0name = N'wzorzec_sd',
    @level1type = N'TABLE',  @level1name = N'Pozycja';
EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Snapshot ceny z chwili złożenia. Nie synchronizować z Produkt.CenaBiezaca.',
    @level0type = N'SCHEMA', @level0name = N'wzorzec_sd',
    @level1type = N'TABLE',  @level1name = N'Pozycja',
    @level2type = N'COLUMN', @level2name = N'CenaWMomencie';
GO
-- SELECT objname, name, value FROM fn_listextendedproperty('MS_Description', 'SCHEMA', 'wzorzec_sd', 'TABLE', 'Pozycja', NULL, NULL);
