# Shared database (między serwisami)

> Kilka serwisów pisze do jednej bazy i uważa to za „integrację”. To nie jest [shared schema](../wzorce/multi-tenant/shared-schema.md) multi-tenant.

## Objaw

Billing i Magazyn mają connection string do `Prod`. FK między ich tabelami. Deploy A łamie migrację B. „Szybki JOIN”.

## Dlaczego boli

Brak [data ownership](../wzorce/integracja/data-ownership.md). Cykle życia sklejone. Transakcja rozciąga się na dwa bounded contexty bez sagi — albo odwrotnie: 2PC.

## Zamiast

- Jeden pisarz na tabelę ([ownership](../wzorce/integracja/data-ownership.md))
- Osobna baza, gdy granica ma być twarda ([database per service](../wzorce/integracja/database-per-service.md))
- Odczyt cudzych danych: [outbox](../wzorce/integracja/outbox.md) + [read model](../wzorce/wydajnosc/cqrs.md), nie `UPDATE dbo.Cudze`

Multi-tenant shared schema (wielu klientów, jeden produkt) to **inny** wzorzec i jest OK.

## Powiązane

- [Data ownership](../wzorce/integracja/data-ownership.md)
- [Dual write](dual-write.md)
- [ACL](../wzorce/integracja/anti-corruption-layer.md)
