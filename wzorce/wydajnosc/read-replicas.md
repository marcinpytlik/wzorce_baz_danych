# Read replicas

> Skala odczytu: kopia (AG secondary, log shipping) do zapytań, które znoszą opóźnienie. To nie sharding zapisu.

| | |
|---|---|
| **Status** | `ADVANCED` |
| **Kiedy stosować** | Raporty / read model biją primary, stale sekundy są OK |
| **Kiedy unikać** | Read-your-writes bez sticky sesji; zapis na replikę |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wydajnosc/read-replicas.sql) |

## Problem

Primary dusi się SELECT-ami. Dokładasz CPU i nadal jeden log zapisów.

## Model

Primary: zapis + odczyty, które muszą być current. Secondary: reporting, [CQRS](cqrs.md) ciężki. Connection string / `ApplicationIntent=ReadOnly` (AG). Aplikacja nie udaje, że secondary to primary.

## Kluczowe ograniczenia

- Jawne SLO stale (sekundy).
- Brak jobów DML na secondary (poza tym, co AG pozwala).
- Failover: connection retry, nie założenie że nazwa się nie zmieni.

## Pułapki

- SELECT po INSERT w tym samym requestcie na replikę — pusty odczyt.
- Replika jako „backup”, bez monitoringu opóźnienia.
- Sharding „bo repliki nie wystarczą”, gdy problemem był tylko reporting.

## Powiązane

- [CQRS](cqrs.md)
- [Sharding](sharding.md)
- [Blue-green](../ewolucja/blue-green.md)
