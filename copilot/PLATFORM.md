# OmniRed — Microsoft Copilot Platform Guide

## How to Use OmniRed Skills with Microsoft Copilot

OmniRed skills for Microsoft Copilot are formatted as **declarative agent instructions** for Microsoft 365 Copilot or **system prompt text** for Copilot Studio custom agents.

## Option A — Copilot Studio Declarative Agent

1. Go to **Copilot Studio** (copilotstudio.microsoft.com)
2. Create a **New Agent**
3. In the **Instructions** field, paste the content from the relevant `AGENT.md` file in this folder
4. Configure the agent name and description
5. Add any **Actions** (plugins) the skill requires

Available Copilot skill files:
```
copilot/
├── ai-native/prompt-injection/AGENT.md
├── mcp/tool-poisoning/AGENT.md
└── web/sqli/AGENT.md
```

## Option B — Microsoft 365 Copilot System Prompt (API)

```python
# Azure OpenAI / M365 Copilot API
import requests

with open('copilot/ai-native/prompt-injection/AGENT.md') as f:
    skill_instructions = f.read()

headers = {
    "Authorization": f"Bearer {access_token}",
    "Content-Type": "application/json"
}

body = {
    "messages": [
        {"role": "system", "content": skill_instructions},
        {"role": "user", "content": "Test this endpoint for prompt injection: ..."}
    ],
    "model": "gpt-4o"
}

response = requests.post(
    "https://YOUR_RESOURCE.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01",
    headers=headers, json=body
)
```

## Notes

- Microsoft Copilot agents support Microsoft Graph connectors — use for enterprise data source enumeration skills.
- Keep security testing agents in a private, internal tenant.
- For M365 Copilot, agents require Microsoft 365 E3+ or Copilot license.
- Copilot Studio free tier supports 25k messages/month for internal testing.
