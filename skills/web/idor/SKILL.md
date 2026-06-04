---
name: idor
description: Insecure Direct Object Reference (IDOR) methodology. Covers horizontal and vertical privilege escalation, GUID bypass, mass assignment, and multi-step IDOR chains.
version: 1.0.0
license: Apache-2.0
---

# Insecure Direct Object Reference (IDOR)

## Discovery

Map all object identifiers in API responses and URL parameters: numeric IDs, GUIDs, hashes, filenames. For each identifier:

1. Is it predictable? (sequential integers → enumerate)
2. Does changing it return another user's data? (horizontal IDOR)
3. Does changing it return admin/privileged data? (vertical IDOR)

## Testing Methodology

### Horizontal IDOR (access peer resources)

```
GET /api/users/1001/profile    → your profile
GET /api/users/1002/profile    → another user's profile (IDOR if successful)

GET /api/orders/55512          → your order
GET /api/orders/55511          → another user's order (IDOR)
```

### Vertical IDOR (access higher-privilege resources)

```
GET /api/admin/users           → with user-level token (403 expected)
GET /api/invoices/INV-2024-001 → with user-level token (403 expected, return 200 = IDOR)
```

### GUID bypass techniques

Obtain a valid GUID for another user via:
- API response leakage (user objects containing other users' IDs)
- Email/notification references
- Public profile pages
- Shared resource references

### Indirect IDOR

```
POST /api/messages
Body: {"recipient_id": 9999, "message": "test"}
→ Does the server validate that recipient_id belongs to an accessible user?
```

### Mass assignment IDOR

```
PUT /api/users/1001
Body: {"name": "Test", "role": "admin"}
→ Does the server accept and apply the "role" field?
```

## Chaining IDORs

Combine multiple low-severity IDORs for critical impact:
1. IDOR #1 — leak email via profile endpoint
2. IDOR #2 — use leaked email to trigger password reset
3. Result: account takeover from information disclosure

## Tools

- Burp Suite Intruder — enumerate IDs
- [Autorize](https://github.com/Quitten/Autorize) — Burp extension for IDOR automation
- Manual API exploration with multiple test accounts

## OWASP Mapping

- A01:2021 — Broken Access Control
