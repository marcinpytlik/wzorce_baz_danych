# Rozgrzewka: zamówienie

To **nie** nowy domen. To ten sam [case](../../projektowanie/case/README.md) okrojony do PBD.

Zrób samodzielnie, potem porównaj:

1. [Chen](../../projektowanie/case/chen.md)
2. [Tabele](../../projektowanie/case/tabele.md)

**Na ocenę z tej rozgrzewki nie oddajesz:** soft delete, outbox, keyset — to [wzorce na modelu](../../projektowanie/case/wzorce.md), po zaliczeniu 3NF.

SQL katalogu (`case-zamowienie.sql`) ma te wzorce w DDL. Na PBD wolno mieć `Produkt` bez `UsunietoAt` i bez tabeli `Outbox`.

Dalej na zaliczenie: jeden z trzech domenów w tym folderze.
