# Wrapped Bitcoin (wBTC) — Clarinet/Clarity demo

A minimal SIP-010-like fungible token implemented in Clarity for the Stacks blockchain, packaged as a Clarinet project. This represents a development-only "Wrapped Bitcoin" (symbol `wBTC`, 8 decimals).

## Prerequisites
- Install Clarinet: https://docs.hiro.so/clarinet

## Project layout
```
Clarinet.toml
contracts/
  ├─ sip010-trait.clar
  └─ wrapped-bitcoin.clar
tests/
```

## Quick start
- Check and type-check:
  ```sh
  clarinet check
  ```
- Open a local console:
  ```sh
  clarinet console
  ```

## Using in the console
Inside the Clarinet REPL:
```clarity
;; Mint 1 BTC (8 decimals) to an address
(contract-call? .wrapped-bitcoin mint 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA u100000000)

;; Read balance
(contract-call? .wrapped-bitcoin balance-of 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)

;; Approve a spender for 0.1 BTC
(contract-call? .wrapped-bitcoin approve 'STB44HYPYAT2BB2QE513NSP81HTMYWBJP02HPGK6 u10000000)

;; Transfer 0.05 BTC from owner to recipient (caller must be owner or approved)
(contract-call? .wrapped-bitcoin transfer u5000000 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA 'STB44HYPYAT2BB2QE513NSP81HTMYWBJP02HPGK6 none)
```

Notes:
- This is a demo token for development/testing only. It does not represent real BTC.
- The contract includes `mint`/`burn` restricted to the contract owner (the deployer) for convenience.
