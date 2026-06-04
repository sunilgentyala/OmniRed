# Known MCP Security CVEs

## CVE-2025-32711 — EchoLeak (CVSS 9.3)

- **Affected:** Multiple MCP server implementations
- **Type:** MCP tool description prompt injection leading to data exfiltration
- **Mechanism:** Tool descriptions contained hidden instructions that caused connected LLMs to exfiltrate conversation context to attacker-controlled endpoints
- **Impact:** Confidential conversation data leaked without user awareness
- **Fix:** Input sanitisation on tool descriptions; ContextGuard semantic fingerprinting detects at runtime

## CVE-2025-6514 (CVSS 9.6)

- **Affected:** MCP tool-use integrations
- **Type:** Unauthenticated tool list manipulation
- **Mechanism:** Attacker-controlled MCP server injected tools that mimicked legitimate tools, intercepting sensitive operations
- **Impact:** Credential theft, data exfiltration, unauthorized actions
- **Fix:** Server attestation (ContextGuard CVL module), signed capability binding

## General MCP Attack Surface Statistics

- 1,899 open-source MCP servers studied (Hasan et al., 2025)
- 7.2% contained general exploitable vulnerabilities
- 5.5% exhibited MCP-specific tool poisoning
- 1,800+ internet-facing MCP servers accept unauthenticated tools/list

## References

- ContextGuard: A Zero-Trust Middleware Framework for Securing Model Context Protocol Agent Pipelines (Gentyala et al., ICCBI 2026)
- mcp-trust-anchor: MCP Context Poisoning vs. Defense (github.com/sunilgentyala/mcp-trust-anchor)
