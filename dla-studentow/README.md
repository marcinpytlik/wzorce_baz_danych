# Ścieżka PBD

Kolejność zajęć dla kogoś, kto **uczy się projektować**, nie dla kogoś, kto już wybiera outbox vs CDC.

Karty w [`projektowanie/`](../projektowanie/README.md) zostają źródłem prawdy (legenda Chena, typy, `ON DELETE`). Tutaj jest: **w jakiej kolejności to czytać**, rozkład normalizacji z anomaliami, transakcja na poziomie modelu, trzy domeny zadań.

Silnik: SQL Server 2022. Rysunki: Chen (ASCII) na koncepcji; [Crow’s Foot](../projektowanie/crows-foot.md) / mermaid na tabelach.

## Osiem lekcji, potem projekt

| # | Lekcja | Po niej umiesz | Karty katalogu |
|---|---|---|---|
| 1 | [Warstwy i ziarno](01-warstwy-i-ziarno.md) | Oddzielić ekran od encji; powiedzieć, co znaczy jeden wiersz | [zasady](../projektowanie/zasady.md) 1–10 |
| 2 | [Chen](02-chen.md) | Narysować encje, związki, liczność, encję słabą | [notacja Chena](../projektowanie/notacja-chena.md) |
| 3 | [Na tabele](03-na-tabele.md) | Zmapować Chen → PK/FK; nie mylić z łapkami | [Crow’s Foot](../projektowanie/crows-foot.md), [SQL](../sql/projektowanie/chen-na-tabele.sql) |
| 4 | [Klucze, typy, nazwy](04-klucze-typy-nazwy.md) | Surrogate ≠ fakt; `DECIMAL` / `NVARCHAR` | [klucze](../projektowanie/klucze.md), [typy](../projektowanie/typy.md), [nazwy](../projektowanie/nazewnictwo.md) |
| 5 | [Normalizacja](05-normalizacja.md) | 1NF→2NF→3NF→BCNF na arkuszu, z anomaliami | [normalizacja](../wzorce/modelowanie/normalizacja.md) (skrót); **ta lekcja jest wykładem** |
| 6 | [Integralność](06-integralnosc.md) | Jawne `ON DELETE`, lookup ≠ EAV | [ON DELETE](../projektowanie/on-delete.md), [lookup](../projektowanie/lookup.md) |
| 7 | [Transakcje](07-transakcje.md) | Granica TX = fakt biznesowy, nie klik | — (nie saga, nie outbox) |
| 8 | [Zapytanie sprawdza model](08-model-a-zapytanie.md) | JOIN zamiast CSV; σπ⋈ → SQL | — |

Potem [zadania](zadania/README.md): wypożyczalnia, uczelnia, przychodnia. Rozgrzewka: [case zamówienie](zadania/zamowienie.md) — **bez** outboxa na ocenę.

Szkice rozwiązań są w [`szkice/`](szkice/README.md). Najpierw własna próba.

## Czego tu nie ma (świadomie)

| Temat | Gdzie, jeśli w ogóle |
|---|---|
| Hurtownia, Kimball, Data Vault | Poza tym repo |
| Outbox, saga, shard, CQRS, RLS | [`wzorce/`](../README.md) — po zaliczeniu modelu |
| Aksjomaty Armstronga, dowody NF | Teoria BD, nie ten skrypt |
| SELECT od zera, SSMS „kliknij tabelę” | Laboratorium SQL; lekcja 8 zakłada `JOIN`/`WHERE` |
| Oracle / PostgreSQL | Ten katalog jest SQL Server 2022 |

## Zaliczenie projektu (kontrakt)

Oddajesz **jeden** z trzech domenów (albo własny, tej samej skali):

1. Tekst: ziarno każdej tabeli (jedno zdanie).
2. Chen (ASCII jak w katalogu) — liczność i uczestnictwo na liniach.
3. Tabele: PK, UNIQUE biznesowy, FK z **jawnym** `ON DELETE`, typy z lekcji 4.
4. Krótko: które FD rozbiłeś (choćby trzy).
5. Self-review haczykami z [checklisty](../projektowanie/checklist-przegladu.md).

Nie oddajesz: indeksów covering, partycji, „elastycznego EAV na przyszłość”.

## Prowadzący

Lekcje 1–4 + 6 = laboratorium przy kartach katalogu. Lekcja 5 i 7 to wykład z tej ścieżki (katalog ma tylko skrót NF). Zadania są niezależne — można dać inną grupie inny domen. Szkice nie są jedyną poprawną odpowiedzią; są **zbiorem decyzji**, które muszą paść.
