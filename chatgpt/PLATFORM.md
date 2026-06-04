# OmniRed — ChatGPT Platform Guide

## How to Use OmniRed Skills with ChatGPT

OmniRed skills for ChatGPT are formatted as **Custom GPT instructions** — text you paste into the "Instructions" field when creating a Custom GPT in ChatGPT.

## Option A — Dedicated Custom GPTs (Recommended)

Create a separate Custom GPT for each skill category:

1. Go to **ChatGPT** → **Explore GPTs** → **Create**
2. Click **Configure**
3. In the **Instructions** field, paste the content from the relevant `INSTRUCTIONS.md` file in this folder
4. Set **Name** and **Description** to match the skill
5. Under **Capabilities**, enable **Code Interpreter** for skills that require code execution

Available ChatGPT skill files:
```
chatgpt/
├── ai-native/prompt-injection/INSTRUCTIONS.md
├── ai-native/jailbreaking/INSTRUCTIONS.md
├── mcp/tool-poisoning/INSTRUCTIONS.md
├── llm-pipeline/rag-poisoning/INSTRUCTIONS.md
└── web/sqli/INSTRUCTIONS.md
```

## Option B — System Prompt Injection (API Access)

If you have API access, prepend the skill instruction to your system prompt:

```python
import openai

with open('chatgpt/ai-native/prompt-injection/INSTRUCTIONS.md') as f:
    skill_instructions = f.read()

client = openai.OpenAI(api_key="...")
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": skill_instructions},
        {"role": "user", "content": "Test this endpoint for prompt injection: ..."}
    ]
)
```

## Notes

- ChatGPT Custom GPTs have a character limit on instructions (~32k tokens). Use sparse checkout for large skill sets.
- Enable **Web Browsing** for recon skills.
- Enable **Code Interpreter** for exploit development and payload generation skills.
- Custom GPTs are private by default — keep offensive skill GPTs unpublished.
