# Security Policy

## Supported Versions

AURA is currently in active pre-release development. Security updates are applied only to the latest stable minor release. 

| Version | Supported          |
| ------- | ------------------ |
| >= 0.5.x| :white_check_mark: |
| < 0.5.0 | :x:                |

## Security Best Practices

Because AURA is an **offline-first** architecture, many traditional web vulnerabilities (XSS, CSRF) do not apply to the core local application. However, security is still paramount:

1. **Local Data:** AURA uses `sqflite_sqlcipher` for database storage. It is highly recommended to configure it with a secure passphrase if managing sensitive workspace documents.
2. **File Permissions:** AURA runs locally on your machine. Ensure your host OS permissions are configured correctly so unauthorized users cannot access your raw document directories.
3. **No Telemetry:** AURA does not phone home. We consider network requests a security risk for highly confidential offline datasets. Any plugins added must be audited for network usage.

## Reporting a Vulnerability

We take the security of AURA seriously. **Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to the core maintainers (email placeholder). 

### Responsible Disclosure
- Provide a detailed description of the vulnerability.
- Include step-by-step instructions to reproduce it.
- Allow us a reasonable amount of time (at least 14 days) to evaluate and address the issue before publishing details publicly.

You will receive an acknowledgment of your report within 48 hours. If a vulnerability is confirmed, we will coordinate a fix and an advisory.
