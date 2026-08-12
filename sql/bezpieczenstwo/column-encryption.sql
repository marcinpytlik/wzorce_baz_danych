-- Wzorzec: szyfrowanie kolumn — envelope w tabeli (Always Encrypted: CMK/CEK w komentarzu)
-- Silnik: SQL Server 2022
-- Karta:  wzorce/bezpieczenstwo/column-encryption.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_enc') IS NULL EXEC(N'CREATE SCHEMA wzorzec_enc');
GO
DROP TABLE IF EXISTS wzorzec_enc.Sekret;
GO
CREATE TABLE wzorzec_enc.Sekret (
    SekretId     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ciphertext   VARBINARY(MAX) NOT NULL,
    DekWrap      VARBINARY(512) NOT NULL, -- DEK zaszyfrowany KEK z vault
    Algorytm     NVARCHAR(32) NOT NULL CONSTRAINT DF_enc_alg DEFAULT (N'AES-256-GCM'),
    KekId        NVARCHAR(64) NOT NULL
);
GO
-- Always Encrypted (SSMS / dacpac), nie T-SQL ad-hoc bez CMK:
-- CREATE COLUMN MASTER KEY ... KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT' ...
-- CREATE COLUMN ENCRYPTION KEY ...
-- ALTER TABLE ... ALTER COLUMN Pesel ADD ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY=..., ENCRYPTION_TYPE=Randomized, ALGORITHM='AEAD_AES_256_CBC_HMAC_SHA_256');
-- TDE szyfruje pliki — DBA nadal czyta SELECT. To nie ten wzorzec.
