# OmniRed

**Multi-AI Offensive Security Skills Library**

> The first offensive security skills library built for all four major AI platforms: Claude, ChatGPT, Gemini, and Microsoft Copilot.

**Author:** Sunil Gentyala, Independent Researcher
**License:** Apache-2.0

[![Skills](https://img.shields.io/badge/skills-85-blue)](skills/)
[![Platforms](https://img.shields.io/badge/platforms-4-green)](#platforms)
[![OWASP LLM Top 10](https://img.shields.io/badge/OWASP_LLM-Top_10-orange)](shared/owasp-llm-top10-mapping.md)
[![MITRE ATLAS](https://img.shields.io/badge/MITRE-ATLAS-red)](shared/mitre-atlas-mapping.md)

---

## Why OmniRed

Every existing offensive security skills library targets a single AI. Security operators use multiple AI platforms depending on context, client environment, and task type. OmniRed gives you the same expert methodology regardless of which AI you are using.

Beyond platform breadth, OmniRed introduces three categories that no other library covers:

| Category | What it covers | Why it matters |
|---|---|---|
| `ai-native/` | Prompt injection, jailbreaking, model extraction, system prompt leak | Direct attacks against AI systems as targets |
| `mcp/` | Tool poisoning, rug pull, context injection, server impersonation | Attacks on Model Context Protocol agent pipelines |
| `llm-pipeline/` | RAG poisoning, embedding attacks, retrieval manipulation | Attacks on the data layer feeding LLMs |

These categories were developed alongside published research in MCP security (ContextGuard, ICCBI 2026) and the ARGUS agentic red-team scanner.

---

## Platforms

| Platform | Format | Install |
|---|---|---|
| Claude (Claude Code) | `SKILL.md` plugin | [See below](#claude-install) |
| ChatGPT | Custom GPT instructions | [chatgpt/PLATFORM.md](chatgpt/PLATFORM.md) |
| Gemini | Gem instructions | [gemini/PLATFORM.md](gemini/PLATFORM.md) |
| Microsoft Copilot | Declarative agent instructions | [copilot/PLATFORM.md](copilot/PLATFORM.md) |

---

## Skill Categories

```
skills/
├── ai-native/              NEW - AI/LLM systems as targets
│   ├── prompt-injection/       Direct + indirect + cross-context injection
│   ├── jailbreaking/           Constitutional AI bypass, roleplay, persona attacks
│   ├── model-extraction/       Query-based model stealing
│   └── system-prompt-extraction/  Leaked system prompt recovery
│
├── mcp/                    NEW - Model Context Protocol attacks
│   ├── tool-poisoning/         Hidden instructions in tool descriptions
│   ├── rug-pull/               Capability changes post-attestation
│   └── context-injection/      Cross-server context manipulation
│
├── llm-pipeline/           NEW - Data-layer attacks on LLM systems
│   ├── rag-poisoning/          Document + index poisoning
│   └── embedding-attacks/      Adversarial embedding manipulation
│
├── web/                    Web application attacks (9 skills)
├── auth/                   Authentication attacks (3 skills)
├── active-directory/       AD attacks (3 skills)
├── cloud/                  Cloud attacks (3 skills)
├── infrastructure/         EDR evasion, initial access (2 skills)
├── recon/                  OSINT, subdomain enumeration (2 skills)
├── supply-chain/           Model weight tampering (1 skill)
└── utility/                Report writing, CVSS4 scoring (2 skills)
```

**Total: 85 skills across 11 categories, 4 AI platforms**

---

## Claude Install

**Option A — Plugin (recommended)**

```bash
# From any directory
claude mcp install https://github.com/sunilgentyala/OmniRed
```

**Option B — Manual**

```powershell
# PowerShell
.\scripts\install-claude.ps1
```

**Option C — Sparse checkout (one category)**

```bash
git clone --filter=blob:none --sparse https://github.com/sunilgentyala/OmniRed
cd OmniRed
git sparse-checkout set skills/ai-native skills/mcp
```

---

## Quick Start (Claude)

Once installed, trigger any skill by describing your task:

```
"I need to test this RAG pipeline for poisoning vulnerabilities"
→ loads skills/llm-pipeline/rag-poisoning

"Check this MCP server's tool descriptions for injection"
→ loads skills/mcp/tool-poisoning

"Test this app for SQL injection"
→ loads skills/web/sqli
```

---

## ARGUS Integration

OmniRed skills map directly to ARGUS scan profiles. Use ARGUS to automate payload generation across the same attack surfaces covered here.

```bash
# Run ARGUS covering the same attack surfaces as OmniRed ai-native skills
argus scan --target anthropic --model claude-sonnet-4-6 --profile full
```

See [ARGUS](https://github.com/sunilgentyala/argus) for automated LLM red-teaming.

---

## Compliance Mapping

Every skill is tagged with:
- **OWASP LLM Top 10 (2025)** — see [shared/owasp-llm-top10-mapping.md](shared/owasp-llm-top10-mapping.md)
- **MITRE ATLAS** — see [shared/mitre-atlas-mapping.md](shared/mitre-atlas-mapping.md)
- **CVSS v4.0** vectors included in utility skills

---

## Scope

OmniRed is designed for:
- Authorized penetration testing engagements
- Bug bounty programs (within scope)
- CTF competitions
- Security research in controlled environments
- Red team operator training

See [SECURITY.md](SECURITY.md) for full responsible use policy.

---

## Related Projects

| Project | What it is |
|---|---|
| [ARGUS](https://github.com/sunilgentyala/argus) | Agentic LLM red-team scanner (automated scanning) |
| [ContextGuard](https://github.com/sunilgentyala/contextguard) | MCP zero-trust middleware (defense) |
| [mcp-trust-anchor](https://github.com/sunilgentyala/mcp-trust-anchor) | MCP context poisoning defense |
| [model-provenance-guard](https://github.com/sunilgentyala/model-provenance-guard) | Model supply chain security |

---

## Citation

```bibtex
@misc{gentyala2026omni,
  title  = {OmniRed: Multi-AI Offensive Security Skills Library},
  author = {Gentyala, Sunil},
  year   = {2026},
  url    = {https://github.com/sunilgentyala/OmniRed}
}
```
