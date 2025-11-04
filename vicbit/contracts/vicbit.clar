;; VicBit fungible token implemented with native FT functions
;; - Owner (deployer) can mint
;; - Any holder can transfer and burn

(define-fungible-token vicbit)

(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_ALREADY_INITIALIZED (err u409))
(define-constant DECIMALS u6)                 ;; 6 decimals
(define-constant TOKEN_NAME "VicBit Token")
(define-constant TOKEN_SYMBOL "VICBIT")

;; Owner is set once via `initialize` to the tx-sender of that call
(define-data-var owner (optional principal) none)

;; SIP-010: get-name -> (response (string-ascii 32) uint)
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; SIP-010: get-symbol -> (response (string-ascii 32) uint)
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; SIP-010: get-decimals -> (response uint uint)
(define-read-only (get-decimals)
  (ok DECIMALS)
)

;; SIP-010: get-balance-of -> (response uint uint)
(define-read-only (get-balance-of (who principal))
  (ok (ft-get-balance vicbit who))
)

;; Convenience alias
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance vicbit who))
)

;; SIP-010: get-total-supply -> (response uint uint)
(define-read-only (get-total-supply)
  (ok (ft-get-supply vicbit))
)

;; SIP-010: transfer -> (response bool uint)
(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? vicbit amount tx-sender recipient)
)

;; Initialize owner (one-time)
(define-public (initialize)
  (begin
    (asserts! (is-none (var-get owner)) ERR_ALREADY_INITIALIZED)
    (var-set owner (some tx-sender))
    (ok true)
  )
)

(define-read-only (get-owner)
  (ok (var-get owner))
)

;; Transfer ownership
(define-public (set-owner (new-owner principal))
  (let ((cur (var-get owner)))
    (begin
      (asserts! (is-some cur) ERR_UNAUTHORIZED)
      (asserts! (is-eq tx-sender (unwrap! cur ERR_UNAUTHORIZED)) ERR_UNAUTHORIZED)
      (var-set owner (some new-owner))
      (ok true)
    )
  )
)

;; Owner-only mint
(define-public (mint (amount uint) (recipient principal))
  (let ((cur (var-get owner)))
    (begin
      (asserts! (is-some cur) ERR_UNAUTHORIZED)
      (asserts! (is-eq tx-sender (unwrap! cur ERR_UNAUTHORIZED)) ERR_UNAUTHORIZED)
      (ft-mint? vicbit amount recipient)
    )
  )
)

;; Holder burn
(define-public (burn (amount uint))
  (ft-burn? vicbit amount tx-sender)
)