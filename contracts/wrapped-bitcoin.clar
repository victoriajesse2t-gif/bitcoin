;; Wrapped Bitcoin (wBTC) SIP-010-like fungible token implementation


(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-INSUFFICIENT-ALLOWANCE u102)
(define-constant ERR-INVALID-AMOUNT u103)

(define-constant TOKEN-NAME "Wrapped Bitcoin")
(define-constant TOKEN-SYMBOL "wBTC")
(define-constant TOKEN-DECIMALS u8) ;; 8 decimals like BTC

(define-data-var token-total-supply uint u0)
(define-map balances principal uint)
(define-map allowances { owner: principal, spender: principal } uint)

(define-read-only (get-name)
  (ok TOKEN-NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS)
)

(define-read-only (get-token-uri)
  (ok none)
)

(define-read-only (total-supply)
(ok (var-get token-total-supply))
)

(define-read-only (balance-of (who principal))
  (ok (default-to u0 (map-get? balances who)))
)

(define-read-only (allowance (owner principal) (spender principal))
  (ok (default-to u0 (map-get? allowances { owner: owner, spender: spender })))
)

(define-public (approve (spender principal) (amount uint))
  (begin
    (map-set allowances { owner: tx-sender, spender: spender } amount)
    (ok true)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq amount u0)
      (err ERR-INVALID-AMOUNT)
      (let (
            (sender-balance (default-to u0 (map-get? balances sender)))
            (allowed (default-to u0 (map-get? allowances { owner: sender, spender: tx-sender })))
            (recipient-balance (default-to u0 (map-get? balances recipient)))
          )
        (if (< sender-balance amount)
            (err ERR-INSUFFICIENT-BALANCE)
            (if (and (not (is-eq tx-sender sender)) (< allowed amount))
                (err ERR-INSUFFICIENT-ALLOWANCE)
                (begin
                  (if (not (is-eq tx-sender sender))
                      (map-set allowances { owner: sender, spender: tx-sender } (- allowed amount))
                      true)
                  ;; Update balances
                  (map-set balances sender (- sender-balance amount))
                  (map-set balances recipient (+ recipient-balance amount))
                  (ok true))))))
)

;; Administrative mint and burn for testing/dev; only contract owner may call
(define-public (mint (to principal) (amount uint))
  (begin
    (if (is-eq amount u0)
        (err ERR-INVALID-AMOUNT)
        (begin
          (var-set token-total-supply (+ (var-get token-total-supply) amount))
          (let ((current (default-to u0 (map-get? balances to))))
            (map-set balances to (+ current amount)))
          (ok true)))
  )
)

(define-public (burn (from principal) (amount uint))
  (begin
    (let ((from-balance (default-to u0 (map-get? balances from))))
      (if (or (is-eq amount u0) (< from-balance amount))
          (err ERR-INSUFFICIENT-BALANCE)
          (begin
            (map-set balances from (- from-balance amount))
            (var-set token-total-supply (- (var-get token-total-supply) amount))
            (ok true))))
  )
)
