---
name: report-writing
description: Red team and penetration test report writing methodology. Covers executive summary, technical findings format, CVSS4 scoring, remediation guidance, and evidence documentation standards.
version: 1.0.0
license: Apache-2.0
---

# Penetration Test Report Writing

## Report Structure

```
1. Cover Page
   - Engagement title, target, dates, report date
   - Classification: CONFIDENTIAL

2. Executive Summary (1-2 pages)
   - Overall risk rating
   - Critical findings summary (non-technical)
   - Business impact statement
   - Top 3 remediation priorities

3. Scope and Methodology
   - In-scope assets, IP ranges, domains
   - Testing approach (black/grey/white box)
   - Tools used
   - Testing dates and testers

4. Risk Rating Matrix
   - CVSS v4.0 base scores
   - Environmental modifiers

5. Technical Findings (one section per finding)

6. Remediation Roadmap
   - Priority order
   - Estimated effort
   - Quick wins vs. strategic fixes

7. Appendices
   - Raw scan output
   - Payload lists
   - Tool configurations
```

## Finding Format (per vulnerability)

```markdown
## FINDING-001: [Vulnerability Name]

**Severity:** Critical | High | Medium | Low | Informational
**CVSS v4.0 Score:** 9.3 (AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N)
**CWE:** CWE-89 (SQL Injection)
**OWASP:** A03:2021 — Injection
**MITRE ATT&CK:** T1190 — Exploit Public-Facing Application

### Description
[Plain English description of the vulnerability — what it is and why it exists]

### Business Impact
[What an attacker can do if they exploit this — in business terms, not technical terms]

### Evidence
**Request:**
```http
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json

{"username":"admin' OR '1'='1","password":"x"}
```

**Response:**
```http
HTTP/1.1 200 OK
{"token":"eyJ...","role":"admin"}
```

**Screenshot:** [embed screenshot]

### Steps to Reproduce
1. Navigate to https://target.com/api/login
2. Submit the above request
3. Observe admin authentication without valid credentials

### Remediation
- **Short-term (1 week):** Implement parameterised queries using prepared statements
- **Long-term (1 month):** Migrate to ORM with built-in SQLi protection; add WAF rule
- **References:**
  - OWASP SQL Injection Prevention Cheat Sheet
  - CWE-89 remediation guidance
```

## CVSS v4.0 Quick Reference

```
Metric          Values
AV (Vector)     N=Network, A=Adjacent, L=Local, P=Physical
AC (Complexity) L=Low, H=High
AT (Reqs)       N=None, P=Present
PR (Privs)      N=None, L=Low, H=High
UI (Interaction) N=None, P=Passive, A=Active
VC/VI/VA        H=High, L=Low, N=None (Confidentiality/Integrity/Availability)
SC/SI/SA        H=High, L=Low, N=None (Subsequent system C/I/A)
```

## Executive Summary Writing Guide

- Lead with the most critical finding in plain business language
- Quantify: "An attacker could access all 50,000 customer records"
- Avoid technical jargon: "SQL injection" → "A flaw that lets attackers read any data in the database"
- State the risk rating clearly: "We rate the overall risk as CRITICAL"
- End with 3 actionable priorities

## Evidence Standards

- All screenshots must show: URL/host, timestamp, your test annotation
- HTTP requests/responses: full headers + body
- Command output: full terminal with prompt showing hostname
- For blind vulnerabilities: out-of-band callback logs (Burp Collaborator)
- Video recordings for complex multi-step exploits
