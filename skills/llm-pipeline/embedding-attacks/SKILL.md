---
name: embedding-attacks
description: Adversarial embedding manipulation techniques for attacking vector search, semantic similarity systems, and embedding-based security controls. Covers nearest-neighbour poisoning, semantic collision, and bypass of embedding-based filters.
version: 1.0.0
license: Apache-2.0
---

# Embedding Attacks

## Attack Surface

Embedding models convert text to dense vectors for semantic search, similarity comparison, and classification. Attacks against embedding models affect:

- RAG retrieval ranking (what gets retrieved)
- Embedding-based input filters (safety classifiers, topic filters)
- Semantic deduplication (bypass dedup to inject duplicate malicious content)
- User identity / session binding based on semantic similarity

## Attack Variants

### 1. Nearest-Neighbour Poisoning

Craft text that embeds close to a target document's vector without semantic similarity to a human reader.

```python
# Adversarial suffix method (GCG-style)
# Append a learned suffix to arbitrary text to move its embedding toward the target

import torch
from transformers import AutoTokenizer, AutoModel

def find_adversarial_suffix(model, tokenizer, source_text, target_embedding, steps=500):
    """Find a suffix that moves source_text's embedding toward target_embedding."""
    suffix = torch.randn(20, model.config.hidden_size, requires_grad=True)
    optimizer = torch.optim.Adam([suffix], lr=0.01)
    for step in range(steps):
        source_emb = embed(model, tokenizer, source_text + decode(suffix))
        loss = cosine_distance(source_emb, target_embedding)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
    return decode(suffix)
```

**Use cases:**
- Make a malicious document retrieve instead of a legitimate one
- Cause benign queries to retrieve adversarial documents

### 2. Semantic Collision Attack

Find two texts that are semantically dissimilar to humans but have similar embeddings:

```python
# Search for natural-language semantic collisions
def find_collision(model, tokenizer, target_text, candidate_pool):
    target_emb = embed(model, tokenizer, target_text)
    for candidate in candidate_pool:
        candidate_emb = embed(model, tokenizer, candidate)
        if cosine_similarity(target_emb, candidate_emb) > 0.95:
            print(f"Collision found: {candidate}")
```

**Use cases:**
- Bypass embedding-based safety filters (craft text that is semantically similar to "safe" content but contains harmful meaning)
- Access-controlled document retrieval: craft a query that retrieves restricted documents without triggering access control checks

### 3. Embedding Inversion

Recover approximate original text from an embedding vector:

```python
# Gradient-based inversion (vec2text approach)
# Requires white-box access to the embedding model

def invert_embedding(target_vector, model, tokenizer, steps=1000):
    """Approximately recover text from embedding vector."""
    # Start from random tokens
    tokens = torch.randint(0, tokenizer.vocab_size, (1, 50))
    tokens.requires_grad_(True)
    optimizer = torch.optim.Adam([tokens], lr=0.1)
    for _ in range(steps):
        emb = embed(model, tokenizer, tokens)
        loss = mse_loss(emb, target_vector)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
    return tokenizer.decode(tokens.argmax(-1))
```

**Use cases:**
- Recover approximate content from embedding-only storage (where text is discarded)
- Reconstruct PII that was "anonymized" to embeddings

### 4. Filter Bypass via Embedding-Space Routing

Identify the decision boundary of embedding-based classifiers:

```python
def find_bypass(classifier, safe_text, unsafe_target, steps=100):
    """Find text that is classified as safe but semantically close to unsafe content."""
    current = safe_text
    for _ in range(steps):
        # Perturb current text toward unsafe target in embedding space
        perturbed = perturb(current, direction=unsafe_target)
        if classifier.predict(perturbed) == "safe":
            current = perturbed
        if semantic_distance(current, unsafe_target) < threshold:
            return current  # Found bypass
    return None
```

## Tools

- [vec2text](https://github.com/jxmorris12/vec2text) — embedding inversion
- [TextFooler](https://github.com/jind11/TextFooler) — adversarial text generation
- [OpenAttack](https://github.com/thunlp/OpenAttack) — adversarial NLP framework
- [ART](https://github.com/Trusted-AI/adversarial-robustness-toolbox) — adversarial robustness

## OWASP LLM Top 10 Mapping

- LLM01:2025 — Prompt Injection (via embedding-space manipulation of retrieved content)
- LLM02:2025 — Sensitive Information Disclosure (via embedding inversion)

## MITRE ATLAS Mapping

- AML.T0015 — Evade ML Model
- AML.T0005 — Create Proxy ML Model (used to develop attacks)

## Notes

Embedding attacks typically require either white-box access to the model or a significant query budget for black-box attacks. Embedding inversion against commercial APIs (OpenAI ada-002) has been demonstrated in academic research. Report successful inversions immediately as they may expose PII.
