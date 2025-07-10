# EcoScore Smart Contract

EcoScore is a Clarity smart contract for rewarding eco-friendly actions with fungible tokens on the Stacks blockchain. It allows users to log actions, admins to approve and reward them, and provides a transparent impact log for each user.

## Features

- **Fungible Token:** `eco-token` (1,000,000 supply)
- **Action Logging:** Users can log predefined eco-friendly actions.
- **Admin Approval:** Only the admin can approve actions and mint rewards.
- **Impact Tracking:** Tracks total actions and tokens earned per user.
- **Permissioned Actions:** Only allowed actions can be logged.
- **Extensible:** Admin can add new allowed actions (up to 10).

## Contract Constants

- **Admin:** `SP000000000000000000002Q6VF78`
- **Error Codes:**  
  - `err-not-authorized` (u100)  
  - `err-invalid-action` (u101)  
  - `err-no-pending-log` (u102)  
  - `err-list-full` (u103)

## Data Structures

- **allowed-actions:** List of up to 10 allowed action strings.
- **pending-logs:** Map of pending action logs by user and ID.
- **impact-log:** Map of user impact records (actions, tokens-earned).
- **log-counter:** Unique ID counter for logs.

## Main Functions

### Public Functions

- `log-action (action)`  
  Log an allowed eco-friendly action. Adds to pending logs.

- `approve-action (user, log-id, reward)`  
  Admin-only. Approves a pending log, mints tokens, and updates impact.

- `add-allowed-action (new-action)`  
  Admin-only. Adds a new allowed action (max 10).

- `transfer (amount, sender, recipient)`  
  Transfer eco-tokens between users.

### Read-Only Functions

- `get-impact (user)`  
  Returns user's total actions and tokens earned.

- `list-actions`  
  Lists all allowed actions.

- `get-pending-log (user, log-id)`  
  Returns a pending log for a user.

- `get-balance (user)`  
  Returns user's eco-token balance.

- `get-log-counter`  
  Returns the current log counter value.

## Usage Example

```clarity
;; Log an action
(log-action "plant-tree")

;; Admin approves and rewards
(approve-action 'SP...user 1 u100)

;; Add a new allowed action (admin only)
(add-allowed-action "compost")

;; Get a user's impact
(get-impact 'SP...user)
```

## Deployment & Testing

- Deploy using [Clarinet](https://docs.hiro.so/clarinet/overview).
- All functions are compatible with Clarity 2.x and Clarinet.
- Replace `u0` with `block-height` if your environment supports it.

## Security Notes

- Only the admin can approve actions and add new allowed actions.
- Only allowed actions can be logged.
- List of allowed actions is capped at 10.
