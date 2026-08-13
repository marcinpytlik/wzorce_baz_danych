# Zadania projektowe

Trzy domeny tej samej skali co [case zamówienie](../../projektowanie/case/README.md), **bez** outboxa, shardów i RLS. Wybierz jeden na zaliczenie albo zrób wszystkie na laboratorium.

| Zadanie | Główna pułapka | Szkic (po próbie) |
|---|---|---|
| [Rozgrzewka: zamówienie](zamowienie.md) | Snapshot ceny vs cena bieżąca | [case katalogu](../../projektowanie/case/README.md) — Chen i tabele; wzorce pomiń |
| [Wypożyczalnia](wypozyczalnia.md) | Dzieło ≠ egzemplarz; historia wypożyczeń | [szkic](../szkice/wypozyczalnia.md) |
| [Uczelnia](uczelnia.md) | Edycja przedmiotu, nie „student–przedmiot”; ocena przy zapisie | [szkic](../szkice/uczelnia.md) |
| [Przychodnia](przychodnia.md) | Wizyta jako fakt; recepta słaba; ICD = lookup | [szkic](../szkice/przychodnia.md) |

## Co oddajesz

Patrz kontrakt w [README ścieżki](../README.md#zaliczenie-projektu-kontrakt). SQL możesz wzorować na `sql/dla-studentow/*.sql` **po** własnym Chenie — nie odwrotnie.

## Czego nie modelujesz na PBD

EAV „na elastyczność”, `Lek1…Lek5`, CSV autorów, sam `IDENTITY` bez UNIQUE, CASCADE z czytelnika na historię wypożyczeń, outbox.
