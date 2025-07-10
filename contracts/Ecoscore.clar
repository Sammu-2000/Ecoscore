;; EcoScore Smart Contract - Corrected Version

;; Define the fungible token
(define-fungible-token eco-token u1000000)

;; Admin/owner of the contract
(define-constant admin 'SP000000000000000000002Q6VF78)

;; Error constants
(define-constant err-not-authorized (err u100))
(define-constant err-invalid-action (err u101))
(define-constant err-no-pending-log (err u102))
(define-constant err-list-full (err u103))

;; Actions users can perform
(define-data-var allowed-actions (list 10 (string-ascii 20))  
  (list "plant-tree" "recycle" "bike-to-work" "solar-install" "cleanup-drive"))

;; Pending action logs
(define-map pending-logs  
  { user: principal, id: uint }  
  { action: (string-ascii 20), block: uint })

;; User's total impact log
(define-map impact-log  
  principal  
  { actions: uint, tokens-earned: uint })

;; Counter to keep unique IDs for logs
(define-data-var log-counter uint u0)

;; Helper function to check if an action is allowed
(define-private (is-action-in-list (action (string-ascii 20)) (actions (list 10 (string-ascii 20))))
  (is-some (index-of actions action)))

;; Function: Log eco-friendly action
(define-public (log-action (action (string-ascii 20)))
  (let ((id (+ (var-get log-counter) u1)))
    (if (is-action-in-list action (var-get allowed-actions))
      (begin
        (var-set log-counter id)
        (map-set pending-logs 
          {user: tx-sender, id: id}
          {action: action, block: u0}) ;; Use u0 as a placeholder for block-height
        (print {event: "action-logged", user: tx-sender, id: id, action: action})
        (ok {message: "Action logged", id: id}))
      err-invalid-action)))

;; Function: Approve action log (admin only)
(define-public (approve-action (user principal) (log-id uint) (reward uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-not-authorized)
    (match (map-get? pending-logs {user: user, id: log-id})
      log-data
      (begin
        (map-delete pending-logs {user: user, id: log-id})
        (try! (ft-mint? eco-token reward user))
        ;; Update impact record
        (let ((old-record (default-to
                          {actions: u0, tokens-earned: u0}
                          (map-get? impact-log user))))
          (map-set impact-log user
            {actions: (+ (get actions old-record) u1),
             tokens-earned: (+ (get tokens-earned old-record) reward)})
          (print {event: "action-approved", user: user, tokens: reward})
          (ok "Action approved and rewarded")))
      err-no-pending-log)))

;; Function: Read impact log
(define-read-only (get-impact (user principal))
  (default-to 
    {actions: u0, tokens-earned: u0}
    (map-get? impact-log user)))

;; Function: Get allowed actions
(define-read-only (list-actions)
  (ok (var-get allowed-actions)))

;; Function: Get pending log
(define-read-only (get-pending-log (user principal) (log-id uint))
  (map-get? pending-logs {user: user, id: log-id}))

;; Function: Get token balance
(define-read-only (get-balance (user principal))
  (ft-get-balance eco-token user))

;; Function: Add new allowed action (admin only) - CORRECTED
(define-public (add-allowed-action (new-action (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender admin) err-not-authorized)
    (let ((current-actions (var-get allowed-actions)))
      (if (< (len current-actions) u10)
        (begin
          (var-set allowed-actions (unwrap-panic (as-max-len? (concat current-actions (list new-action)) u10)))
          (ok "Action added successfully"))
        err-list-full))))

;; Function: Get current log counter
(define-read-only (get-log-counter)
  (var-get log-counter))

;; Function: Transfer tokens between users
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (ft-transfer? eco-token amount sender recipient)))