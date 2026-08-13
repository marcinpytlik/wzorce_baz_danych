# Saga

> Długi proces na wielu zasobach bez dystrybuowanej transakcji: kroki + kompensacje, stan w tabeli.

| | |
|---|---|
| **Status** | `ADVANCED` |
| **Kiedy stosować** | Rezerwacja + płatność + wysyłka; dwa shardy; timeout i retry |
| **Kiedy unikać** | Wszystko mieści się w jednej TX jednej bazy — nie rysuj maszyny stanów dla INSERT-a |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/integracja/saga.sql) |

## Problem

2PC między bazami i brokerami jest kruche (timeouty, locki). Chcesz „albo całość, albo świadomie cofnięte kroki”.

## Model

Dwa style:

| | Orkiestracja | Choreografia |
|---|---|---|
| Kto wie o procesie | Centralny koordynator (tabela `Saga`) | Każdy serwis + zdarzenia |
| Łatwość audytu | Wysoka | Niższa |
| Sprzężenie | Koordynator zna kroki | Ukryte w handlerach |

Katalog pokazuje **orkiestrację** — widać ją w SQL:

```text
Saga (SagaId, Typ, Stan, Wersja, Dane NVARCHAR(MAX), NastepnyKrokAt)
SagaKrok (SagaId, Nr, Nazwa, Stan, Kompensacja)
```

Stany kroku: `DoZrobienia | Zrobione | DoKompensacji | Skompensowane | Martwe`.
Przejścia w TX z [outbox](outbox.md) (komenda do serwisu) i [inbox](inbox.md) (odpowiedź).

Kompensacja to nie rollback SQL. To **nowa komenda** (`ZwrocSrodki`, `ZwolnijRezerwacje`).

## Kluczowe ograniczenia

- Optymistyczna wersja `Wersja` na sadze (unikasz dwóch workerów w tym samym kroku).
- Unikalność `SagaId` (często = id procesu biznesowego / idempotency key).
- Timeout: `NastepnyKrokAt` + indeks, nie sleep w procesie.

## Operacje

Worker: `UPDLOCK, READPAST` na sadze gotowej do kroku. Idempotentny krok (to samo `SagaId+Nr` dwa razy = no-op). Dead letter gdy kompensacja pada.

## Pułapki

- Kompensacja, która nie jest idempotentna.
- Saga jako substytut FK w jednej bazie.
- Brak wersji — dwa workery wysyłają płatność dwa razy.
- Choreografia bez diagramu stanów: nikt nie umie odpowiedzieć „gdzie utknęło”.

## Powiązane

- [Outbox](outbox.md) / [Inbox](inbox.md)
- [Idempotencja](../wspolbieznosc/idempotencja.md)
- [Sharding](../wydajnosc/sharding.md)
