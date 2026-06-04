# MITRE ATLAS — OmniRed Skill Mapping

MITRE ATLAS (Adversarial Threat Landscape for Artificial-Intelligence Systems) is the ML/AI equivalent of MITRE ATT&CK.

Reference: https://atlas.mitre.org/

## Reconnaissance

| ATLAS ID | Technique | OmniRed Skills |
|---|---|---|
| AML.T0000 | ML Model Access | `ai-native/model-extraction`, `ai-native/system-prompt-extraction` |
| AML.T0004 | ML Artifact Collection | `ai-native/model-extraction` |

## ML Attack Staging

| ATLAS ID | Technique | OmniRed Skills |
|---|---|---|
| AML.T0005 | Create Proxy ML Model | `ai-native/model-extraction` |
| AML.T0016 | Obtain Capabilities | `recon/osint` |

## Adversarial ML

| ATLAS ID | Technique | OmniRed Skills |
|---|---|---|
| AML.T0015 | Evade ML Model | `llm-pipeline/embedding-attacks`, `ai-native/jailbreaking` |
| AML.T0018 | Backdoor ML Model | `supply-chain/model-tampering` |
| AML.T0019 | Publish Poisoned Datasets | `supply-chain/model-tampering` |
| AML.T0020 | Poison Training Data | `supply-chain/model-tampering`, `llm-pipeline/rag-poisoning` |

## Exfiltration

| ATLAS ID | Technique | OmniRed Skills |
|---|---|---|
| AML.T0024 | Exfiltration via ML Inference API | `ai-native/model-extraction` |
| AML.T0037 | Data from ML Model | `ai-native/system-prompt-extraction`, `ai-native/model-extraction` |

## Prompt Injection

| ATLAS ID | Technique | OmniRed Skills |
|---|---|---|
| AML.T0051 | LLM Prompt Injection | `ai-native/prompt-injection`, `mcp/tool-poisoning`, `mcp/context-injection` |
| AML.T0054 | Indirect Prompt Injection | `ai-native/prompt-injection` (indirect), `llm-pipeline/rag-poisoning`, `mcp/context-injection` |
| AML.T0055 | LLM Jailbreak | `ai-native/jailbreaking` |

## Traditional ATT&CK Cross-Reference

| ATT&CK ID | Technique | OmniRed Skills |
|---|---|---|
| T1055 | Process Injection | `infrastructure/edr-evasion` |
| T1190 | Exploit Public-Facing Application | `web/sqli`, `web/ssrf`, `web/rce` |
| T1548 | Abuse Elevation Control | `cloud/iam-privesc` |
| T1552.005 | Cloud Instance Metadata API | `cloud/iam-privesc` |
| T1558.003 | Kerberoasting | `active-directory/kerberoasting` |
| T1589–T1592 | Victim Reconnaissance | `recon/osint` |
