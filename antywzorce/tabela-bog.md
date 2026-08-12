# Tabela-bóg

> Jedna tabela na cały biznes: klient, faktura, magazyn i „flagi na później”.

## Objaw

`dbo.Dane` / `Dokument` z kolumnami `Pole1`…`Pole40`, `TypDokumentu`, trzy daty o niejasnym znaczeniu, `Uwagi` jako szuflada.

## Dlaczego boli

- Każda zmiana procesu to ALTER i nowe NULL.
- Locki i statystyki na jednym obiekcie.
- Nie da się powiedzieć, co jest agregatem i gdzie jest transakcja.

## Zamiast

Rozbij po agregatach ([normalizacja](../wzorce/modelowanie/normalizacja.md)). Wspólna lista UI → [TPH](../wzorce/modelowanie/tph-tpt-tpct.md) albo [CQRS](../wzorce/wydajnosc/cqrs.md), nie jedna tabela zapisu.
