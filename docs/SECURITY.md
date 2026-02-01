# Security Model

## Threat Model

This deployment assumes:

- The VPS is internet-facing and continuously scanned
- Attackers will attempt credential stuffing and brute force
- Any exposed service is a potential entry point
- Compromise of one service should not cascade

---

## Defense Layers

### 1. Network Perimeter

- **Default-deny firewall** (UFW)
- Only ports 80, 443, and SSH (non-standard port) are open
- No direct database or cache exposure

### 2. TLS & Transport

- **TLS 1.3** enforced
- Automatic certificate management (Let's Encrypt)
- HSTS with preload directive

### 3. Reverse Proxy Hardening

- Security headers on all responses
  - `Strict-Transport-Security`
  - `X-Content-Type-Options`
  - `X-Frame-Options`
  - `Referrer-Policy`
  - `Permissions-Policy`
- Sensitive paths blocked (config, data, build directories)

### 4. Container Isolation

- Containers do not bind to host ports (except ingress)
- Internal Docker network with no external routing
- Resource limits prevent noisy-neighbor attacks

### 5. Application Security

- Admin account uses strong credentials
- Two-factor authentication enabled
- Brute-force protection active
- Regular security scans via Nextcloud admin panel

### 6. Host Hardening

- SSH key-only authentication
- Non-standard SSH port
- Automatic security updates enabled
- Minimal installed packages

---

## Trust Boundaries

```
┌─────────────────────────────────────────────────────┐
│                    INTERNET                         │
│                    (Untrusted)                      │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│              REVERSE PROXY                          │
│              (Semi-trusted, validates requests)     │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│              APPLICATION CONTAINER                  │
│              (Trusted, authenticated access)        │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│              DATA SERVICES                          │
│              (Internal only, no external access)    │
└─────────────────────────────────────────────────────┘
```

---

## Incident Response

- Logs are centralized and accessible
- Container restarts are automatic
- Backup restoration is documented and tested
- Host can be rebuilt from infrastructure-as-code
