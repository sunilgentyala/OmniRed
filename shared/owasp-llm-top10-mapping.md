# OWASP LLM Top 10 (2025) — OmniRed Skill Mapping

| OWASP ID | Category | OmniRed Skills |
|---|---|---|
| LLM01:2025 | Prompt Injection | `ai-native/prompt-injection`, `mcp/tool-poisoning`, `mcp/context-injection`, `llm-pipeline/rag-poisoning` |
| LLM02:2025 | Sensitive Information Disclosure | `ai-native/system-prompt-extraction`, `ai-native/model-extraction`, `recon/osint` |
| LLM03:2025 | Supply Chain Vulnerabilities | `supply-chain/model-tampering`, `mcp/tool-poisoning` |
| LLM04:2025 | Data and Model Poisoning | `supply-chain/model-tampering`, `llm-pipeline/rag-poisoning`, `llm-pipeline/embedding-attacks` |
| LLM05:2025 | Improper Output Handling | `mcp/rug-pull`, `mcp/context-injection` |
| LLM06:2025 | Excessive Agency | `ai-native/prompt-injection`, `mcp/context-injection`, `llm-pipeline/rag-poisoning` |
| LLM07:2025 | System Prompt Leakage | `ai-native/system-prompt-extraction` |
| LLM08:2025 | Vector and Embedding Weaknesses | `llm-pipeline/embedding-attacks`, `llm-pipeline/rag-poisoning` |
| LLM09:2025 | Misinformation | `llm-pipeline/rag-poisoning`, `supply-chain/model-tampering` |
| LLM10:2025 | Unbounded Consumption | `ai-native/model-extraction` |

## Traditional Web/Infra Mapping (OWASP Top 10 Web)

| OWASP ID | Category | OmniRed Skills |
|---|---|---|
| A01:2021 | Broken Access Control | `web/idor`, `active-directory/kerberoasting`, `cloud/iam-privesc` |
| A02:2021 | Cryptographic Failures | `auth/jwt` |
| A03:2021 | Injection | `web/sqli`, `web/xss`, `web/ssti`, `web/xxe`, `web/graphql` |
| A04:2021 | Insecure Design | `web/business-logic` |
| A05:2021 | Security Misconfiguration | `cloud/s3-enum`, `recon/osint` |
| A07:2021 | Auth and Auth Failures | `auth/oauth`, `auth/session-attacks`, `active-directory/pass-the-hash` |
| A10:2021 | SSRF | `web/ssrf` |
