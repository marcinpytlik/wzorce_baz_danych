-- Case: klient–zamówienie–pozycja–płatność (+ outbox, soft delete, keyset)
-- Karty: projektowanie/case/
SET NOCOUNT ON;
IF SCHEMA_ID(N'case_zam') IS NULL EXEC(N'CREATE SCHEMA case_zam');
GO
DROP TABLE IF EXISTS case_zam.Outbox;
DROP TABLE IF EXISTS case_zam.Platnosc;
DROP TABLE IF EXISTS case_zam.Pozycja;
DROP TABLE IF EXISTS case_zam.Zamowienie;
DROP TABLE IF EXISTS case_zam.Produkt;
DROP TABLE IF EXISTS case_zam.Klient;
DROP TABLE IF EXISTS case_zam.StatusPlatnosci;
GO

CREATE TABLE case_zam.StatusPlatnosci (
    StatusKod VARCHAR(16) NOT NULL PRIMARY KEY,
    Nazwa     NVARCHAR(80) NOT NULL
);
INSERT case_zam.StatusPlatnosci VALUES ('NOWA', N'Nowa'), ('POTW', N'Potwierdzona');

CREATE TABLE case_zam.Klient (
    KlientId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cz_klient PRIMARY KEY,
    Nazwa    NVARCHAR(200) NOT NULL,
    Email    NVARCHAR(320) NOT NULL CONSTRAINT UQ_cz_email UNIQUE
);

CREATE TABLE case_zam.Produkt (
    ProduktId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cz_prod PRIMARY KEY,
    Sku         NVARCHAR(64) NOT NULL,
    Nazwa       NVARCHAR(200) NOT NULL,
    CenaBiezaca DECIMAL(19,4) NOT NULL,
    UsunietoAt  DATETIME2(3) NULL
);
CREATE UNIQUE INDEX UQ_cz_sku_zywy ON case_zam.Produkt (Sku) WHERE UsunietoAt IS NULL;

CREATE TABLE case_zam.Zamowienie (
    ZamowienieId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cz_zam PRIMARY KEY,
    KlientId     INT NOT NULL
        CONSTRAINT FK_cz_zam_klient REFERENCES case_zam.Klient (KlientId) ON DELETE NO ACTION,
    Data         DATETIME2(3) NOT NULL CONSTRAINT DF_cz_data DEFAULT (SYSUTCDATETIME())
);
CREATE INDEX IX_cz_zam_klient_data ON case_zam.Zamowienie (KlientId, Data DESC, ZamowienieId DESC);

CREATE TABLE case_zam.Pozycja (
    ZamowienieId    INT NOT NULL
        CONSTRAINT FK_cz_poz_zam REFERENCES case_zam.Zamowienie (ZamowienieId) ON DELETE CASCADE,
    Lp              INT NOT NULL,
    ProduktId       INT NOT NULL
        CONSTRAINT FK_cz_poz_prod REFERENCES case_zam.Produkt (ProduktId) ON DELETE NO ACTION,
    Ilosc           INT NOT NULL CHECK (Ilosc > 0),
    CenaWMomencie   DECIMAL(19,4) NOT NULL,
    Wartosc AS (CONVERT(DECIMAL(19,4), Ilosc * CenaWMomencie)) PERSISTED,
    CONSTRAINT PK_cz_poz PRIMARY KEY (ZamowienieId, Lp),
    CONSTRAINT UQ_cz_poz_prod UNIQUE (ZamowienieId, ProduktId)
);

CREATE TABLE case_zam.Platnosc (
    PlatnoscId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cz_plat PRIMARY KEY,
    ZamowienieId INT NOT NULL
        CONSTRAINT FK_cz_plat_zam REFERENCES case_zam.Zamowienie (ZamowienieId) ON DELETE NO ACTION,
    Kwota        DECIMAL(19,4) NOT NULL,
    StatusKod    VARCHAR(16) NOT NULL
        CONSTRAINT FK_cz_plat_st REFERENCES case_zam.StatusPlatnosci (StatusKod) ON DELETE NO ACTION
);

CREATE TABLE case_zam.Outbox (
    Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_cz_ob PRIMARY KEY DEFAULT (NEWSEQUENTIALID()),
    AgregatId       INT NOT NULL,
    EventTyp        NVARCHAR(64) NOT NULL,
    Payload         NVARCHAR(MAX) NOT NULL,
    UtworzonoAt     DATETIME2(3) NOT NULL CONSTRAINT DF_cz_ob DEFAULT (SYSUTCDATETIME()),
    OpublikowanoAt  DATETIME2(3) NULL,
    CONSTRAINT CK_cz_ob_json CHECK (ISJSON(Payload) = 1)
);
CREATE INDEX IX_cz_ob_dren ON case_zam.Outbox (UtworzonoAt) WHERE OpublikowanoAt IS NULL;
GO

-- TX złożenia: INSERT Zamowienie, Pozycja, Outbox; COMMIT. Nie publish poza TX.
-- Keyset: WHERE KlientId=@k AND (Data, ZamowienieId) < (@d, @id) ORDER BY Data DESC, ZamowienieId DESC.
