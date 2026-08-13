# Case — które wzorce i dlaczego

Model z [tabel](tabele.md) jest 3NF i wystarcza do CRUD. Wzorce dokładamy **tam, gdzie pojawia się konkretny ból**, nie na zapas.

| Ból | Wzorzec | Jak w case |
|---|---|---|
| SKU ma wrócić po „usunięciu” produktu z oferty | [Soft delete](../../wzorce/usuwanie/soft-delete.md) + UNIQUE filtrowany | `Produkt.UsunietoAt`; `UQ Sku WHERE UsunietoAt IS NULL` |
| Złożenie zamówienia **i** zdarzenie dla innych | [Outbox](../../wzorce/integracja/outbox.md) | INSERT `Zamowienie` + `Outbox` w jednej TX |
| Lista zamówień klienta, kolejna strona | [Keyset](../../wzorce/wydajnosc/keyset-pagination.md) | `(Data, ZamowienieId)` nie `OFFSET` |
| Status płatności z etykietą w UI | [Lookup](../lookup.md) | `StatusPlatnosci`, nie EAV i nie sam CHECK na 6 kodach z nazwami |

Czego **nie** ma w tym case (świadomie): sharding, saga, RLS, event sourcing. Nie są potrzebne, żeby sprzedać jeden koszyk w jednej bazie.

Skrypt: [`case-zamowienie.sql`](../../sql/projektowanie/case-zamowienie.sql) — schemat + komentarze TX outbox i keyset.

Powrót: [README case](README.md) · [checklist](../checklist-przegladu.md).
