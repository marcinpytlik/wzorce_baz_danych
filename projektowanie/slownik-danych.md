# Słownik danych

> Przy tabeli musi wisieć to, czego DDL nie widać: **ziarno, NULL, snapshot vs kopia**. Wiki bez `sp_addextendedproperty` ginie.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Nowa tabela, przekazanie modelu, onboarding |
| **Kiedy unikać** | Komentarz `TODO` w kodzie jako jedyna dokumentacja |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/slownik-danych.sql) |

## Minimum przy każdej tabeli

| Pole | Pytanie | Przykład |
|---|---|---|
| Ziarno | Co oznacza **jeden** wiersz? | Linia zamówienia: jeden produkt na jednym zamówieniu |
| Klucz biznesowy | Czym świat odróżnia dwa fakty? | `(ZamowienieId, ProduktId)` / `Numer` |
| Liczność | 1:N / M:N, opcjonalność | Zamówienie ma 1..N pozycji |
| NULL | Co znaczy brak wartości? | `OplaconoAt NULL` = jeszcze nie zapłacone, nie „nie wiadomo” |
| Snapshot vs kopia | Czy `CenaWMomencie` się synchronizuje? | Snapshot; `CenaBiezaca` na produkcie jest inna |
| Retencja | Kiedy wolno skasować? | 6 lat / [retention](../wzorce/usuwanie/retention.md) |
| Właściciel | Kto może ALTER / DELETE? | [data ownership](../wzorce/integracja/data-ownership.md) |

To jest zapis [zasad](zasady.md) pkt 3, 6, 7, 14.

## Gdzie trzymać

1. **Extended properties** w bazie (`MS_Description` na tabeli i kolumnie) — przeżywają backup, widać w SSMS.
2. Karta w tym katalogu albo `projektowanie/case/` dla przykładów.
3. Nie: tylko Confluence bez nazwy obiektu 1:1.

Skrypt pokazuje `sp_addextendedproperty` + odczyt z `sys.extended_properties`.

## Czego nie pisać do słownika

- Plan indeksu (to fizyka, zmienia się częściej).
- Treść wzorca (linkuj kartę: outbox, soft delete).
- Historii ticketów.

## Powiązane

- [Zasady](zasady.md)
- [Checklist przeglądu](checklist-przegladu.md)
- [Nazewnictwo](nazewnictwo.md)
- [Case](case/README.md)
