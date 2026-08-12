-- Wzorzec: Dynamic Data Masking
-- Silnik: SQL Server 2022
-- Karta:  wzorce/bezpieczenstwo/dynamic-data-masking.md

SET NOCOUNT ON;
IF SCHEMA_ID(N'wzorzec_ddm') IS NULL EXEC(N'CREATE SCHEMA wzorzec_ddm');
GO
DROP TABLE IF EXISTS wzorzec_ddm.Osoba;
GO
CREATE TABLE wzorzec_ddm.Osoba (
    OsobaId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Email   NVARCHAR(320) MASKED WITH (FUNCTION = 'email()') NOT NULL,
    Pesel   CHAR(11) MASKED WITH (FUNCTION = 'partial(2,"*******",2)') NOT NULL
);
GO
-- GRANT UNMASK TO app_runtime;
-- Support bez UNMASK widzi a**@****.com / 12*******90.
-- WHERE Pesel = @x nadal działa — to nie ACL.
