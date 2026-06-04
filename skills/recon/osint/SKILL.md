---
name: osint
description: Open Source Intelligence expert methodology for pre-engagement reconnaissance. Covers target profiling, email harvesting, subdomain enumeration, technology fingerprinting, employee reconnaissance, and dark web monitoring.
version: 1.0.0
license: Apache-2.0
---

# OSINT Reconnaissance

## Methodology

### Phase 1 — Scope definition and initial collection

```
Target: domain, IP ranges, org name, LinkedIn company page, stock ticker
Deliverables: attack surface map, employee list, technology stack, exposed assets
```

### Phase 2 — Domain and infrastructure enumeration

```bash
# DNS enumeration
dig +any target.com
nslookup -type=ANY target.com
fierce --domain target.com
dnsx -d target.com -a -aaaa -cname -mx -ns -txt

# ASN and IP range discovery
whois -h whois.radb.net -- '-i origin AS12345'
bgp.he.net — manual lookup
amass intel -org "Target Corp"

# Certificate transparency (fast subdomain discovery)
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq '.[].name_value' | sort -u
```

### Phase 3 — Subdomain enumeration

```bash
# Passive (no direct target contact)
amass enum -passive -d target.com
subfinder -d target.com -all
assetfinder target.com
findomain -t target.com

# Active (sends DNS queries)
gobuster dns -d target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt
puredns bruteforce /usr/share/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt target.com

# Combine and resolve
cat passive.txt active.txt | sort -u | httpx -status-code -title -tech-detect
```

### Phase 4 — Email harvesting

```bash
theHarvester -d target.com -l 500 -b google,bing,yahoo,linkedin,twitter
hunter.io API — pattern discovery + verification
phonebook.cz — email/subdomain/URL search
emailrep.io — reputation scoring

# LinkedIn scraping (respect ToS — use during authorized engagements)
linkedin2username.py -c "Target Corp"   # generate username formats
```

### Phase 5 — Technology fingerprinting

```bash
# Web technology
whatweb target.com
wappalyzer CLI — browser-based fingerprinting
builtwith.com — technology profile

# Cloud provider and CDN
clouddetect.py target.com
nmap -sV -p 80,443,8080,8443 target.com

# WAF detection
wafw00f https://target.com
nmap --script http-waf-detect target.com
```

### Phase 6 — Employee and social reconnaissance

```
LinkedIn: employees, roles, technology mentions in profiles
GitHub: employee repos — leaked credentials, internal tool names, API endpoints
Twitter/X: security event mentions, tool names, incident indicators
Glassdoor: job postings reveal technology stack
Indeed job listings: mention specific products, frameworks, versions
```

### Phase 7 — Exposed credentials and secrets

```bash
# GitHub dorking
"target.com" password site:github.com
"target.com" api_key site:github.com
"@target.com" site:pastebin.com

# Automated credential search
trufflehog git https://github.com/target-org/
gitrob --github-access-token <token> target-org
gitleaks detect --source=.

# Breach databases
haveibeenpwned.com API
dehashed.com
intelx.io
```

### Phase 8 — Google Dorking

```
site:target.com filetype:pdf
site:target.com ext:xlsx OR ext:docx
site:target.com inurl:admin OR inurl:login
site:target.com "internal use only"
"@target.com" site:linkedin.com
cache:target.com/admin
```

## Tools

- [Amass](https://github.com/owasp-amass/amass) — comprehensive enumeration
- [Subfinder](https://github.com/projectdiscovery/subfinder) — passive subdomain
- [theHarvester](https://github.com/laramies/theHarvester) — email/host harvesting
- [Shodan](https://shodan.io) — internet-facing asset discovery
- [Censys](https://censys.io) — certificate and host search
- [OSINT Framework](https://osintframework.com) — tool directory

## MITRE ATT&CK Mapping

- T1590 — Gather Victim Network Information
- T1591 — Gather Victim Organization Information
- T1592 — Gather Victim Host Information
- T1589 — Gather Victim Identity Information
