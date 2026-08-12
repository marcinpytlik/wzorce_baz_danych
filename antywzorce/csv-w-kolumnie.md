# CSV / JSON bez kontraktu w kolumnie

> `Tagi VARCHAR(500) = 'red,blue'` albo `Dane NVARCHAR(MAX)` z dowolnym JSON.

## Objaw

`LIKE '%,admin,%'` do autoryzacji. Albo JSON, w którym raz jest `"id": 1`, raz `"Id": "1"`.

## Dlaczego boli

- Nie ma FK do słownika tagów.
- Nie ma UNIQUE na elemencie.
- SQL Server bez `OPENJSON` / Postgres bez operatorów jsonb robi skan i zgadywanie.

## Zamiast

- Zbiór wartości → tabela `EncjaTag (EncjaId, TagId)` z PK złożonym.
- Dokument z kontraktem → `jsonb` / `JSON` + CHECK (`jsonb_typeof`, `ISJSON`) + znane klucze w dokumentacji wzorca [EAV](../wzorce/modelowanie/eav.md).
- Nigdy CSV do uprawnień i do kluczy.
