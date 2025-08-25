;; Sports League Registry Contract
;; Manages teams, players, and league-wide settings

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PLAYER-NOT-FOUND (err u101))
(define-constant ERR-TEAM-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INVALID-INPUT (err u104))

;; Data Variables
(define-data-var league-name (string-ascii 50) "Professional Sports League")
(define-data-var current-season uint u2024)
(define-data-var salary-cap-limit uint u100000000) ;; $100M default cap
(define-data-var luxury-tax-threshold uint u120000000) ;; $120M luxury tax threshold
(define-data-var next-player-id uint u1)
(define-data-var next-team-id uint u1)

;; Data Maps
(define-map teams
  { team-id: uint }
  {
    name: (string-ascii 50),
    city: (string-ascii 30),
    owner: principal,
    founded: uint,
    active: bool
  }
)

(define-map players
  { player-id: uint }
  {
    name: (string-ascii 50),
    position: (string-ascii 20),
    age: uint,
    current-team: (optional uint),
    contract-status: (string-ascii 20),
    injury-status: bool,
    created-at: uint
  }
)

(define-map team-rosters
  { team-id: uint, player-id: uint }
  {
    jersey-number: uint,
    added-at: uint,
    role: (string-ascii 20)
  }
)

(define-map league-officials
  { official: principal }
  {
    role: (string-ascii 30),
    permissions: uint,
    active: bool
  }
)

;; Public Functions

;; Register a new team
(define-public (register-team (name (string-ascii 50)) (city (string-ascii 30)) (owner principal))
  (let ((team-id (var-get next-team-id)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len city) u0) ERR-INVALID-INPUT)

    (map-set teams
      { team-id: team-id }
      {
        name: name,
        city: city,
        owner: owner,
        founded: (var-get current-season),
        active: true
      }
    )

    (var-set next-team-id (+ team-id u1))
    (ok team-id)
  )
)

;; Register a new player
(define-public (register-player (name (string-ascii 50)) (position (string-ascii 20)) (age uint))
  (let ((player-id (var-get next-player-id)))
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len position) u0) ERR-INVALID-INPUT)
    (asserts! (and (>= age u18) (<= age u50)) ERR-INVALID-INPUT)

    (map-set players
      { player-id: player-id }
      {
        name: name,
        position: position,
        age: age,
        current-team: none,
        contract-status: "free-agent",
        injury-status: false,
        created-at: block-height
      }
    )

    (var-set next-player-id (+ player-id u1))
    (ok player-id)
  )
)

;; Add player to team roster
(define-public (add-to-roster (team-id uint) (player-id uint) (jersey-number uint))
  (let (
    (team (unwrap! (map-get? teams { team-id: team-id }) ERR-TEAM-NOT-FOUND))
    (player (unwrap! (map-get? players { player-id: player-id }) ERR-PLAYER-NOT-FOUND))
  )
    (asserts! (or (is-eq tx-sender CONTRACT-OWNER) (is-eq tx-sender (get owner team))) ERR-NOT-AUTHORIZED)
    (asserts! (and (> jersey-number u0) (<= jersey-number u99)) ERR-INVALID-INPUT)

    ;; Update player's current team
    (map-set players
      { player-id: player-id }
      (merge player { current-team: (some team-id), contract-status: "signed" })
    )

    ;; Add to roster
    (map-set team-rosters
      { team-id: team-id, player-id: player-id }
      {
        jersey-number: jersey-number,
        added-at: block-height,
        role: "player"
      }
    )

    (ok true)
  )
)

;; Update league settings
(define-public (update-salary-cap (new-cap uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> new-cap u0) ERR-INVALID-INPUT)
    (var-set salary-cap-limit new-cap)
    (ok true)
  )
)

;; Add league official
(define-public (add-league-official (official principal) (role (string-ascii 30)) (permissions uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set league-officials
      { official: official }
      {
        role: role,
        permissions: permissions,
        active: true
      }
    )
    (ok true)
  )
)

;; Read-only Functions

(define-read-only (get-team (team-id uint))
  (map-get? teams { team-id: team-id })
)

(define-read-only (get-player (player-id uint))
  (map-get? players { player-id: player-id })
)

(define-read-only (get-roster-entry (team-id uint) (player-id uint))
  (map-get? team-rosters { team-id: team-id, player-id: player-id })
)

(define-read-only (get-salary-cap)
  (var-get salary-cap-limit)
)

(define-read-only (get-luxury-tax-threshold)
  (var-get luxury-tax-threshold)
)

(define-read-only (get-current-season)
  (var-get current-season)
)

(define-read-only (is-league-official (official principal))
  (match (map-get? league-officials { official: official })
    entry (get active entry)
    false
  )
)
