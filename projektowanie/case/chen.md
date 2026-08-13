# Case — Chen

Domena: klient składa zamówienia; zamówienie ma pozycje (produkty) i płatności.

```text
     ○ KlientId ★
     ○ Nazwa
     ○ Email ★
┌─────────┴─────────┐
│      KLIENT       │
└─────────┬─────────┘
          │ 1  (częściowe: klient bez zamówień OK)
     ┌────┴────┐
     │ SKŁADA  │
     └────┬────┘
          │ N  (całkowite)
┌─────────┴─────────┐          M     ┌──────────┐     N    ┌─────────┐
│    ZAMÓWIENIE     │────────────────◆  ZAWIERA  ◆─────────│ PRODUKT │
└─────────┬─────────┘                └────┬─────┘          └─────────┘
     ○ ZamowienieId ★                     │              ○ ProduktId ★
     ○ Data                          ○ Ilosc             ○ Sku ★
          │                          ○ CenaWMomencie     ○ Nazwa
          │ 1                                            ○ CenaBiezaca
     ┌────┴────┐                                         ○ UsunietoAt
     │  PŁACI  │                                         (soft delete — fizyka,
     └────┬────┘                                          na Chenie: encja żyje)
          │ N
┌─────────┴─────────┐
│     PŁATNOŚĆ      │
└───────────────────┘
     ○ PlatnoscId ★
     ○ Kwota
     ○ StatusKod  → lookup STATUS_PŁATNOŚCI
```

`POZYCJA` jest encją słabą ziarna związku `ZAWIERA` (klucz częściowy: produkt na zamówieniu / `Lp`).  
`CenaWMomencie` wisi na związku, nie na produkcie.  
`◌ Wartosc` pozycji = `Ilosc × CenaWMomencie` — pochodna, nie elipsa pełna.

Lookup `STATUS_PŁATNOŚCI` to nie encja biznesowa — [lookup](../lookup.md).

Ten sam rysunek w łapkach: [Crow’s Foot](../crows-foot.md).

Dalej: [tabele](tabele.md).
