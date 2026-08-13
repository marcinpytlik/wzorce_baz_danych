# Case — tabele (3NF)

Mapowanie [Chena](chen.md) → SQL Server 2022. Pełny DDL: [`case-zamowienie.sql`](../../sql/projektowanie/case-zamowienie.sql).

| Chen | Tabela | Uwagi |
|---|---|---|
| KLIENT | `Klient` | PK `KlientId` IDENTITY; UNIQUE `Email` |
| ZAMÓWIENIE | `Zamowienie` | FK `KlientId NOT NULL` `ON DELETE NO ACTION` |
| PRODUKT | `Produkt` | UNIQUE `Sku`; [soft delete](../../wzorce/usuwanie/soft-delete.md) — UNIQUE filtrowany |
| ZAWIERA + słaba pozycja | `Pozycja` | PK `(ZamowienieId, Lp)`; `ON DELETE CASCADE`; `Wartosc AS Ilosc*CenaWMomencie` |
| PŁATNOŚĆ | `Platnosc` | FK zamówienie NO ACTION |
| STATUS_PŁATNOŚCI | `StatusPlatnosci` | PK kod naturalny |
| (integracja) | `Outbox` | nie ma na Chenie — warstwa fizyczna/integracja |

Crow’s Foot (skrót):

```text
Klient           ||————o<  Zamowienie  ||————o<  Pozycja
Produkt          ||————o<  Pozycja
Zamowienie       ||————o<  Platnosc
StatusPlatnosci  ||————o<  Platnosc
```

Ziarno `Pozycja`: jedna linia jednego zamówienia na jeden produkt (`UQ (ZamowienieId, ProduktId)`).  
`CenaWMomencie` = snapshot. `CenaBiezaca` na produkcie = fakt bieżący.

Dalej: [wzorce na tym modelu](wzorce.md).
