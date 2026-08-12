# Skrypty SQL

Każdy wzorzec ma parę skryptów: **PostgreSQL** i **SQL Server**.
Są to przykłady edukacyjne (schemat + typowe operacje), nie gotowy system produkcyjny.

```
sql/
  postgres/     # psql, PostgreSQL 14+
  sqlserver/    # SSMS / sqlcmd, SQL Server 2019+
```

Nazwa pliku = nazwa wzorca (`outbox.sql`, `rls.sql`, …).
Katalogi wewnątrz odpowiadają kategoriom z `wzorce/`.

## Jak odpalać

**Postgres** (lokalna baza `wzorcownia`):

```bash
psql -d wzorcownia -v ON_ERROR_STOP=1 -f sql/postgres/integracja/outbox.sql
```

**SQL Server**:

```bash
sqlcmd -S localhost -d wzorcownia -I -i sql/sqlserver/integracja/outbox.sql
```

Skrypty są idempotentne tam, gdzie da się to zrobić tanio (`DROP TABLE IF EXISTS` / `IF OBJECT_ID ... DROP`).
Nie łączą się z repozytorium produkcyjnym — konkretne wdrożenia (np. outbox/inbox w osobnym systemie) linkujemy z dokumentacji wzorca, a kod zostaje tam, gdzie jest.
