# OmniRed — Gemini Platform Guide

## How to Use OmniRed Skills with Gemini

OmniRed skills for Gemini are formatted as **Gem instructions** — text you configure when creating a custom Gem in Google Gemini.

## Creating a Security Testing Gem

1. Go to **gemini.google.com**
2. Click **Explore Gems** → **New Gem**
3. In the **Instructions** field, paste the content from the relevant `GEM.md` file in this folder
4. Set a name (e.g., "Red Team: Prompt Injection") and description
5. Save the Gem

## Available Gemini Skill Files

```
gemini/
├── ai-native/prompt-injection/GEM.md
├── mcp/tool-poisoning/GEM.md
├── llm-pipeline/rag-poisoning/GEM.md
└── web/sqli/GEM.md
```

## Option B — API System Instruction

Via the Gemini API, pass skill content as a system instruction:

```python
import google.generativeai as genai

with open('gemini/ai-native/prompt-injection/GEM.md') as f:
    skill_instructions = f.read()

genai.configure(api_key="YOUR_API_KEY")
model = genai.GenerativeModel(
    model_name="gemini-2.0-flash",
    system_instruction=skill_instructions
)

response = model.generate_content("Test this endpoint for prompt injection...")
```

## Notes

- Gemini Gems support grounding with Google Search — enable it for recon skills.
- Keep offensive Gems private.
- Gemini 2.0 Flash and Pro support long context windows suitable for large skill files.
