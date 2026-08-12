# Module signing

> Procedura podpisana certyfikatem dostaje uprawnienia certyfikatu, nie callera i nie wiecznego `EXECUTE AS OWNER`.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Runtime ma wołać wybrany kod z wyższym uprawnieniem (np. odczyt metadanych, kill sesji joba) |
| **Kiedy unikać** | `EXECUTE AS OWNER` na wszystkich procedurach „bo działa” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/bezpieczenstwo/module-signing.sql) |

## Problem

Aplikacja nie może mieć `VIEW SERVER STATE`, ale jedna procedura diagnostyczna musi. Dajesz `sa` albo `EXECUTE AS OWNER` i zapominasz.

## Model

1. Certyfikat w bazie.
2. Login z certyfikatu + minimalne granty (np. `VIEW SERVER STATE`).
3. `ADD SIGNATURE` na procedurze.
4. Caller ma tylko `EXECUTE` na procedurze.

Ownership chaining i `EXECUTE AS` to [mechanizmy](../../mechanizmy/README.md) — często za szerokie. Podpis jest precyzyjny i przeżywa zmianę callera.

## Kluczowe ograniczenia

- Certyfikat z hasłem, backup klucza.
- Po `ALTER` procedury podpis spada — podpisz znowu (job migracji).
- Login z certyfikatu bez `CONNECT` (nie do logowania).

## Pułapki

- Podpis i `EXECUTE AS OWNER` naraz „dla pewności”.
- Certyfikat w kodzie źródłowym w plaintext.
- Grant na certyfikat-login szerszy niż procedura potrzebuje.

## Powiązane

- [Least privilege](least-privilege.md)
- [EXECUTE AS](../../mechanizmy/execute-as.md)
- [Ownership chaining](../../mechanizmy/ownership-chaining.md)
- [Security definer](../../mechanizmy/security-definer.md)
