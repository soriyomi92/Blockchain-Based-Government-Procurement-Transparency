;; Procurement Officer Verification Contract
;; Manages verification and authentication of government procurement officers

;; Data Variables
(define-data-var contract-owner principal tx-sender)

;; Data Maps
(define-map verified-officers principal
  {
    name: (string-ascii 100),
    department: (string-ascii 100),
    verification-date: uint,
    is-active: bool
  })

(define-map officer-permissions principal (list 10 (string-ascii 50)))

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-OFFICER-NOT-FOUND (err u102))
(define-constant ERR-OFFICER-ALREADY-EXISTS (err u103))
(define-constant ERR-INVALID-OFFICER (err u104))

;; Private Functions
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner)))

;; Public Functions
(define-public (add-officer (officer principal) (name (string-ascii 100)) (department (string-ascii 100)))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? verified-officers officer)) ERR-OFFICER-ALREADY-EXISTS)
    (map-set verified-officers officer {
      name: name,
      department: department,
      verification-date: block-height,
      is-active: true
    })
    (ok true)))

(define-public (deactivate-officer (officer principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? verified-officers officer)) ERR-OFFICER-NOT-FOUND)
    (map-set verified-officers officer
      (merge
        (unwrap! (map-get? verified-officers officer) ERR-OFFICER-NOT-FOUND)
        {is-active: false}))
    (ok true)))

(define-public (set-officer-permissions (officer principal) (permissions (list 10 (string-ascii 50))))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? verified-officers officer)) ERR-OFFICER-NOT-FOUND)
    (map-set officer-permissions officer permissions)
    (ok true)))

;; Read-only Functions
(define-read-only (is-verified-officer (officer principal))
  (match (map-get? verified-officers officer)
    officer-data (get is-active officer-data)
    false))

(define-read-only (get-officer-info (officer principal))
  (map-get? verified-officers officer))

(define-read-only (get-officer-permissions (officer principal))
  (default-to (list) (map-get? officer-permissions officer)))
