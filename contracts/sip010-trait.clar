(define-trait sip010-ft-standard
  (
    ;; Transfers tokens from `sender` to `recipient`.
(transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))) (response bool uint))
    ;; Returns the balance for a principal.
(balance-of (who principal) (response uint uint))
    ;; Returns the total supply of tokens.
(total-supply (response uint uint))

    ;; Token metadata
(get-name (response (string-ascii 32) uint))
(get-symbol (response (string-ascii 10) uint))
(get-decimals (response uint uint))
(get-token-uri (response (optional (string-utf8 256)) uint))

    ;; Allowances and approvals
(allowance (owner principal) (spender principal) (response uint uint))
(approve (spender principal) (amount uint) (response bool uint))
  )
)
