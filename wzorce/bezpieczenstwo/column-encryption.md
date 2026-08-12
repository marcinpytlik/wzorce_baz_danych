# Szyfrowanie kolumn (Always Encrypted / envelope)

> Sekret w kolumnie nieczytelny dla DBA bez klucza. Envelope: DEK w wierszu, KEK w vault / CMK.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | PESEL, karta, token — DBA i backup nie mają być w stanie odczytać |
| **Kiedy unikać** | Szyfrujesz kolumny, po których filtrujesz i sortujesz na serwerze (bez randomized/enclave świadomie) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/bezpieczenstwo/column-encryption.sql) |

## Problem

Backup, snapshot, `sa` — każdy z dyskiem ma plaintext PII.

## Model

**Always Encrypted:** CMK (certyfikat / AKV) + CEK w bazie. Klient (driver) szyfruje. SQL widzi ciphertext. SQL Server 2022: enclave (secure enclave) pozwala na ograniczone operacje po stronie serwera.

**Envelope (aplikacja):** `Ciphertext + DEK_zaszyfrowany_KEK`. Baza trzyma bajty, klucz główny poza SQL. Prostsze w appce, trudniejsze w ad-hoc SQL.

Nie mylić z TDE (szyfruje pliki, DBA nadal czyta SELECT).

## Kluczowe ograniczenia

- Deterministic vs randomized: equality vs brak porównań.
- Rotacja CEK/CMK to projekt.
- Connection: `Column Encryption Setting=Enabled`.

## Pułapki

- Always Encrypted + `WHERE Kolumna LIKE` bez enclave.
- Klucz w tej samej bazie co ciphertext (envelope bez vault).
- TDE jako „wystarczy do RODO na kolumnę”.

## Powiązane

- [Dynamic Data Masking](dynamic-data-masking.md)
- [Least privilege](least-privilege.md)
- [Niemutowalny audyt](immutable-audit.md)
