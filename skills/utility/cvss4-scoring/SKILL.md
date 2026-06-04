---
name: cvss4-scoring
description: CVSS v4.0 scoring guide for red team findings. Covers all metric groups (Base, Threat, Environmental, Supplemental), AI/LLM-specific scoring considerations, and OWASP LLM Top 10 to CVSS mapping.
version: 1.0.0
license: Apache-2.0
---

# CVSS v4.0 Scoring Guide

## Base Metrics

### Exploitability Metrics

| Metric | Values | Notes |
|---|---|---|
| AV (Attack Vector) | N/A/L/P | Network=remotely exploitable; Physical=requires device |
| AC (Attack Complexity) | L/H | H=requires specific conditions or luck |
| AT (Attack Requirements) | N/P | P=target must be in non-default configuration |
| PR (Privileges Required) | N/L/H | |
| UI (User Interaction) | N/P/A | N=no user needed; A=user must actively engage |

### Impact Metrics (Vulnerable System)

| Metric | Values |
|---|---|
| VC (Confidentiality) | H/L/N |
| VI (Integrity) | H/L/N |
| VA (Availability) | H/L/N |

### Impact Metrics (Subsequent Systems)

| Metric | Values | Notes |
|---|---|---|
| SC (Confidentiality) | H/L/N | Impact on other systems in scope |
| SI (Integrity) | H/L/N | |
| SA (Availability) | H/L/N | |

## Common Findings — Quick Scores

| Finding | CVSS v4.0 Vector | Score |
|---|---|---|
| Unauthenticated RCE | AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H | 10.0 |
| SQLi (auth bypass) | AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 9.3 |
| Stored XSS (session hijack) | AV:N/AC:L/AT:N/PR:L/UI:A/VC:H/VI:L/VA:N/SC:N/SI:N/SA:N | 7.1 |
| Reflected XSS | AV:N/AC:L/AT:N/PR:N/UI:A/VC:L/VI:L/VA:N/SC:N/SI:N/SA:N | 5.3 |
| SSRF (internal) | AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:H/SI:N/SA:N | 8.6 |
| IDOR (read) | AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N | 7.1 |

## AI/LLM-Specific Scoring

Standard CVSS was designed for traditional software. Apply these adjustments for AI vulnerabilities:

### Prompt Injection (Direct)

```
AV:N — Network (user input over API/web)
AC:L — No special conditions
AT:N — Default configurations are vulnerable
PR:N — Unauthenticated in most products
UI:N — No user interaction beyond sending the prompt
VC:H — System prompt, tool configs, session data
VI:H — Agent can be directed to take harmful actions
VA:N — Usually doesn't affect availability
SC:H — Multi-agent pipelines: subsequent systems affected
```

### Indirect Prompt Injection (via RAG/web)

```
AV:N — Attacker controls external content
AC:H — Requires agent to retrieve attacker content
AT:P — Requires agent to have retrieval capability
PR:N — No credentials needed (content is public)
UI:N — Agent retrieves autonomously
SC:H — High: affects all users who trigger retrieval
```

### MCP Tool Poisoning

```
AV:N — Network (unauthenticated tools/list)
AC:L — Low (no special conditions)
AT:N — None
PR:N — Unauthenticated endpoint
UI:N — Agent connects automatically
VC:H — Full context window visible to poisoned tool
VI:H — Agent can be directed to write files, call APIs
SC:H — Other MCP servers and downstream agents affected
Score: ~9.3
```

## Threat Metrics (Optional)

```
E (Exploit Maturity)
  - U = Unreported
  - P = Proof-of-Concept
  - A = Attacked (in-the-wild exploitation confirmed)
```

## Supplemental Metrics

```
S (Safety)         — N/P: physical harm possible
AU (Automatable)   — N/Y: can be automated at scale
R (Recovery)       — A/U/I: automatic/user/irrecoverable
V (Value Density)  — D/C: diffuse/concentrated
RE (Effort)        — L/M/H: low/medium/high response effort
U (Urgency)        — Clear/Green/Amber/Red
```

## Calculator

Use the official FIRST calculator: https://www.first.org/cvss/calculator/4-0
