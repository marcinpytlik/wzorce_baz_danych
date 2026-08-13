-- Wzorzec: CQRS — write + read, MERGE po wersji
-- Silnik: SQL Server 2022
-- Karta:  wzorce/wydajnosc/cqrs.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_cqrs') IS NULL EXEC(N'CREATE SCHEMA wzorzec_cqrs');
GO

IF OBJECT_ID(N'wzorzec_cqrs.RzutujZamowienie', N'P') IS NOT NULL DROP PROCEDURE wzorzec_cqrs.RzutujZamowienie;
IF OBJECT_ID(N'wzorzec_cqrs.ZamowienieLista', N'U') IS NOT NULL DROP TABLE wzorzec_cqrs.ZamowienieLista;
IF OBJECT_ID(N'wzorzec_cqrs.Pozycja', N'U') IS NOT NULL DROP TABLE wzorzec_cqrs.Pozycja;
IF OBJECT_ID(N'wzorzec_cqrs.Zamowienie', N'U') IS NOT NULL DROP TABLE wzorzec_cqrs.Zamowienie;
GO

CREATE TABLE wzorzec_cqrs.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cqrs_w PRIMARY KEY,
    KlientNazwa  NVARCHAR(200) NOT NULL,
    ZlozonoAt    DATETIME2(3) NOT NULL CONSTRAINT DF_cqrs_at DEFAULT (SYSUTCDATETIME()),
    Wersja       INT NOT NULL CONSTRAINT DF_cqrs_wer DEFAULT (1)
);

CREATE TABLE wzorzec_cqrs.Pozycja (
    ZamowienieId INT NOT NULL CONSTRAINT FK_cqrs_poz REFERENCES wzorzec_cqrs.Zamowienie (ZamowienieId),
    Lp           INT NOT NULL,
    Sku          NVARCHAR(64) NOT NULL,
    Ilosc        INT NOT NULL CONSTRAINT CK_cqrs_ilosc CHECK (Ilosc > 0),
    CONSTRAINT PK_cqrs_poz PRIMARY KEY (ZamowienieId, Lp)
);

CREATE TABLE wzorzec_cqrs.ZamowienieLista (
    ZamowienieId  INT NOT NULL CONSTRAINT PK_cqrs_r PRIMARY KEY,
    KlientNazwa   NVARCHAR(200) NOT NULL,
    ZlozonoAt     DATETIME2(3) NOT NULL,
    PozycjeJson   NVARCHAR(MAX) NOT NULL,
    LiczbaPozycji INT NOT NULL,
    Wersja        INT NOT NULL
);
GO

CREATE PROCEDURE wzorzec_cqrs.RzutujZamowienie
    @ZamowienieId INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src AS (
        SELECT z.ZamowienieId,
               z.KlientNazwa,
               z.ZlozonoAt,
               z.Wersja,
               COUNT(p.Lp) AS LiczbaPozycji,
               (SELECT p2.Sku, p2.Ilosc
                FROM wzorzec_cqrs.Pozycja AS p2
                WHERE p2.ZamowienieId = z.ZamowienieId
                ORDER BY p2.Lp
                FOR JSON PATH) AS PozycjeJson
        FROM wzorzec_cqrs.Zamowienie AS z
        LEFT JOIN wzorzec_cqrs.Pozycja AS p ON p.ZamowienieId = z.ZamowienieId
        WHERE z.ZamowienieId = @ZamowienieId
        GROUP BY z.ZamowienieId, z.KlientNazwa, z.ZlozonoAt, z.Wersja
    )
    MERGE wzorzec_cqrs.ZamowienieLista AS t
    USING src AS s
       ON t.ZamowienieId = s.ZamowienieId
    WHEN MATCHED AND t.Wersja <= s.Wersja THEN
        UPDATE SET KlientNazwa = s.KlientNazwa,
                   ZlozonoAt = s.ZlozonoAt,
                   PozycjeJson = ISNULL(s.PozycjeJson, N'[]'),
                   LiczbaPozycji = s.LiczbaPozycji,
                   Wersja = s.Wersja
    WHEN NOT MATCHED THEN
        INSERT (ZamowienieId, KlientNazwa, ZlozonoAt, PozycjeJson, LiczbaPozycji, Wersja)
        VALUES (s.ZamowienieId, s.KlientNazwa, s.ZlozonoAt, ISNULL(s.PozycjeJson, N'[]'), s.LiczbaPozycji, s.Wersja);
END;
GO
