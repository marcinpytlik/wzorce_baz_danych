# Polimorficzny FK

> `RodzicTyp IN ('Zamowienie','Zgloszenie')` + `RodzicId` bez prawdziwego klucza obcego.

## Objaw

Nie da się `REFERENCES`. Osierocone id po DELETE. Trigger „sprawdź czy istnieje” napisany trzy razy i źle.

## Dlaczego boli

Silnik nie pilnuje integralności. CASCADE nie istnieje. Zapytania to `CASE RodzicTyp`.

## Zamiast

- Osobna tabela powiązań per typ (`ZalacznikZamowienia`, `ZalacznikZgloszenia`).
- Wspólny rodzic w [CTI](../wzorce/modelowanie/sti.md): `Zalacznik (Id)` + dziecko 1:1.
- Gdy naprawdę wiele-do-wielu do wielu typów: tabela asocjacji z **prawdziwym** FK, nie para (typ, id).
