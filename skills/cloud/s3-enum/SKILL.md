---
name: s3-enum
description: AWS S3 and cloud storage enumeration methodology. Covers bucket discovery, access control testing, public data exposure, and cross-cloud (GCS, Azure Blob) equivalents.
version: 1.0.0
license: Apache-2.0
---

# Cloud Storage Enumeration

## AWS S3

### Bucket Discovery

```bash
# Naming conventions to test
target.com
target-backups
target-logs
target-dev
target-staging
target-prod
target-assets
target-uploads
target-data
www.target.com
api.target.com

# Automated
gobuster s3 -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  --wordlist-extra target,company
lazys3 --wordlist targets.txt
```

### Access Testing

```bash
# Check if bucket is public
aws s3 ls s3://target-bucket --no-sign-request

# Download publicly accessible files
aws s3 sync s3://target-bucket . --no-sign-request

# Check ACLs (if you have credentials)
aws s3api get-bucket-acl --bucket target-bucket
aws s3api get-bucket-policy --bucket target-bucket

# List with authenticated credentials
aws s3 ls s3://target-bucket --profile attacker-profile
```

### Misconfigurations to Test

```bash
# Write access (upload test)
echo "test" | aws s3 cp - s3://target-bucket/test.txt --no-sign-request

# Delete access
aws s3 rm s3://target-bucket/test.txt --no-sign-request

# Bucket takeover (if CNAME points to non-existent bucket)
aws s3api create-bucket --bucket deleted-bucket-still-cnamed
```

## GCP Cloud Storage

```bash
# Check public access
gsutil ls gs://target-bucket
gsutil cat gs://target-bucket/sensitive-file.txt

# Check permissions
gsutil iam get gs://target-bucket
```

## Azure Blob Storage

```bash
# Public containers
az storage blob list --container-name target-container \
  --account-name target --auth-mode anonymous

# URL pattern: https://account.blob.core.windows.net/container/blob
```

## Tools

- [S3Scanner](https://github.com/sa7mon/S3Scanner)
- [lazys3](https://github.com/nahamsec/lazys3)
- [bucket-finder](https://github.com/mattweidner/bucket_finder)
- [GrayhatWarfare](https://buckets.grayhatwarfare.com) — public bucket search engine
