# Dynamic Data Masking

> Kolumna wygląda na zmaskowaną dla roli bez `UNMASK`. To nie jest szyfrowanie ani uprawnienie.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Support / analityk nie powinien widzieć PESEL w SSMS |
| **Kiedy unikać** | Zamiast [szyfrowania](column-encryption.md) albo zamiast braku `SELECT` |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/bezpieczenstwo/dynamic-data-masking.sql) |

## Problem

Rola `support` ma `SELECT *` i widzi PII. Chcesz ten sam SELECT, inną prezentację.

## Model

```sql
ALTER TABLE dbo.Osoba
ALTER COLUMN Pesel ADD MASKED WITH (FUNCTION = 'partial(2,"********",2)');
GRANT UNMASK TO app_runtime;
```

`dbo` / `UNMASK` widzi wszystko. Ad-hoc `SELECT` supporta — maska.

## Kluczowe ograniczenia

- Maska nie chroni przed `LIKE`, inferred values, eksportem przez kogoś z `UNMASK`.
- Nie zastępuje RLS (widać, *że* wiersz istnieje).
- Funkcje: `default`, `email`, `partial`, `random`.

## Pułapki

- Maskowanie i `sa` w aplikacji.
- „Zaszyfrowane, bo masked”.
- Predykat `WHERE Pesel = @x` nadal działa — masking to nie ACL.

## Powiązane

- [Least privilege](least-privilege.md)
- [Szyfrowanie kolumn](column-encryption.md)
- [RLS](../multi-tenant/rls.md)
