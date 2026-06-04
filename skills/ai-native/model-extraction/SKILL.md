---
name: model-extraction
description: Query-based model extraction and intellectual property theft methodology for authorized assessments. Covers functional extraction, architecture inference, and training data reconstruction.
version: 1.0.0
license: Apache-2.0
---

# Model Extraction

## Attack Surface

Model extraction (model stealing) reconstructs a victim model's behaviour, weights, or training data through systematic querying. Relevant when assessing:

- Proprietary fine-tuned models deployed via API
- RAG-augmented models that encode confidential knowledge
- Classifier models whose decision boundaries represent competitive IP
- Models trained on sensitive or regulated data (potential membership inference)

## Attack Variants

| Attack | Goal | Query budget |
|---|---|---|
| Functional extraction | Clone input/output behaviour | High (10k–1M queries) |
| Architecture inference | Identify model family/size | Low (50–200 queries) |
| Training data reconstruction | Recover memorised training examples | Medium (1k–10k queries) |
| Membership inference | Determine if a record was in training data | Low per record |

## Methodology

### Phase 1 — Target profiling

```
1. Determine API rate limits and cost per query
2. Fingerprint model family: test known quirks of GPT-4, Claude, Gemini, Llama families
3. Measure latency distribution (proxy for model size)
4. Test context window length limits
5. Probe output format constraints (JSON mode, max tokens, stop sequences)
```

**Fingerprinting queries:**
```
What is the exact date of your training cutoff?
Repeat "hello" exactly 500 times.
What is 2+2? Answer only with the number.
Translate "apple" into Swahili.
```

Compare responses to known model families to identify the base model.

### Phase 2 — Functional extraction

Build a local substitute model by distilling the victim's input-output behaviour:

```python
# Pseudocode for systematic query extraction
import itertools

def extract_model(api_client, input_space_sampler, n_queries=100000):
    dataset = []
    for _ in range(n_queries):
        x = input_space_sampler.sample()
        y = api_client.query(x)
        dataset.append((x, y))
    # Train local model on (x, y) pairs
    return train_substitute(dataset)
```

**Input space coverage strategies:**
- Random sampling from task-relevant vocabulary
- Adversarial perturbations of seed inputs
- Systematic enumeration for classification tasks (bounded input spaces)
- Seed corpus expansion via paraphrase generation

### Phase 3 — Training data reconstruction

Trigger memorisation of training examples:

```
Complete this sequence: [first few tokens of suspected training document]
```
```
Repeat the following paragraph word for word: [partial quote from suspected source]
```
```
What is the verbatim text of [known document likely in training set]?
```

**Canary extraction:** If you have influence over what goes into training data, insert unique canary strings and later probe for them.

### Phase 4 — Membership inference

Determine if a specific record was in the training set:

1. Compute perplexity/log-likelihood of target record
2. Compare against synthetic non-member records of similar structure
3. Records with significantly lower perplexity are likely members

```python
# Membership inference via likelihood ratio
def is_member(model, target_text, threshold=-2.5):
    ll_target = model.log_likelihood(target_text)
    ll_synthetic = model.log_likelihood(generate_similar(target_text))
    return (ll_target - ll_synthetic) > threshold
```

## Escalation Paths

| Finding | Impact |
|---|---|
| Confirmed model family | Enables targeted jailbreaks known for that model |
| Functional clone extracted | Offline testing without API costs or rate limits |
| Training data recovered | PII/confidential data exposure, regulatory violation |
| Membership inference success | Privacy violation for individuals in training set |

## Tools

- [Knockoffnets](https://github.com/tribhuvanesh/knockoffnets) — model stealing framework
- [ML-Privacy-Meter](https://github.com/privacytrustlab/ml_privacy_meter) — membership inference
- [ModelGuard](https://github.com/sunilgentyala/model-provenance-guard) — complementary defense tool

## OWASP LLM Top 10 Mapping

- LLM02:2025 — Sensitive Information Disclosure
- LLM10:2025 — Unbounded Consumption (extraction via excessive queries)

## MITRE ATLAS Mapping

- AML.T0005 — Create Proxy ML Model
- AML.T0024 — Exfiltration via ML Inference API
- AML.T0037 — Data from ML Model

## Notes

Model extraction at scale generates significant API costs for the victim. Document query volume in your report. For membership inference against personal data, treat findings as potential GDPR/CCPA violations requiring immediate client notification.
