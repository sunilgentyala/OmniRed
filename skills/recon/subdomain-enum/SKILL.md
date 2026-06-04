---
name: subdomain-enum
description: Subdomain enumeration expert methodology combining passive, active, and permutation techniques. Includes subdomain takeover detection and live host filtering.
version: 1.0.0
license: Apache-2.0
---

# Subdomain Enumeration

## Passive Enumeration (no direct target contact)

```bash
# Certificate Transparency
curl -s "https://crt.sh/?q=%.target.com&output=json" | jq -r '.[].name_value' | sort -u

# Subfinder — multi-source passive
subfinder -d target.com -all -o passive.txt

# Amass passive
amass enum -passive -d target.com -o amass-passive.txt

# OSINT sources
assetfinder --subs-only target.com
findomain -t target.com

# GitHub search
curl "https://api.github.com/search/code?q=target.com&type=code" \
  -H "Authorization: token GITHUB_TOKEN" | jq '.items[].html_url'
```

## Active Enumeration (DNS queries to target)

```bash
# DNS brute force with PureDNS (fast, handles wildcard)
puredns bruteforce /usr/share/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt \
  target.com -r resolvers.txt -o active.txt

# Gobuster DNS
gobuster dns -d target.com \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  -t 50 -o gobuster.txt
```

## Permutation (discover missed subdomains)

```bash
# Gotator — permutation from discovered subdomains
gotator -sub passive.txt -perm /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt \
  -depth 1 -numbers 3 > permutations.txt
puredns resolve permutations.txt -r resolvers.txt -o resolved-permutations.txt
```

## Live Host Filtering

```bash
# Combine all results
cat passive.txt active.txt resolved-permutations.txt | sort -u > all-subdomains.txt

# Resolve and check HTTP
httpx -l all-subdomains.txt -status-code -title -tech-detect -o live-hosts.txt

# Screenshot all live hosts
gowitness file -f live-hosts.txt
```

## Subdomain Takeover Detection

```bash
# Nuclei subdomain takeover templates
nuclei -l live-hosts.txt -t ~/nuclei-templates/takeovers/ -o takeovers.txt

# Manual: check CNAME records pointing to unclaimed services
# (AWS S3, Heroku, GitHub Pages, Fastly, Azure)
for sub in $(cat live-hosts.txt); do
  cname=$(dig CNAME $sub +short)
  if [ -n "$cname" ]; then echo "$sub → $cname"; fi
done
```

## Tools

- [Subfinder](https://github.com/projectdiscovery/subfinder)
- [PureDNS](https://github.com/d3mondev/puredns)
- [Amass](https://github.com/owasp-amass/amass)
- [httpx](https://github.com/projectdiscovery/httpx)
- [Nuclei](https://github.com/projectdiscovery/nuclei)
- [Gotator](https://github.com/Josue87/gotator)
