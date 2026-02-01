# Architecture Overview

## High-Level Flow

```
Internet
    │
    ▼
┌─────────────────────────────────────────────┐
│  HTTPS (443)                                │
│  Reverse Proxy                              │
│  • TLS termination                          │
│  • Security headers                         │
│  • Rate limiting                            │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│  Nextcloud Application Container            │
│  • No public ports                          │
│  • Persistent storage volumes               │
│  • Communicates only with internal services │
└─────────────────────────────────────────────┘
          │                     │
          ▼                     ▼
┌──────────────────┐   ┌──────────────────────┐
│  PostgreSQL      │   │  Redis               │
│  • Isolated      │   │  • Internal caching  │
│  • Internal only │   │  • File locking      │
└──────────────────┘   └──────────────────────┘
```

---

## Host System

- **Hardened Ubuntu Linux**
- Default-deny firewall
- Container security enforcement
- Monitoring & observability

---

## Backup Architecture

```
Application Data ─┐
                  ├──► Encrypted Backup ──► External Storage
Database Dump ────┘
```

- Recovery-tested
- Versioned retention

---

## Design Principles

| Principle | Implementation |
|-----------|----------------|
| **Zero-Trust Service Boundaries** | No implicit trust between containers |
| **No Direct Internet Exposure** | Only reverse proxy binds to host ports |
| **Defense-in-Depth** | Multiple independent security layers |
| **Replaceable Application, Durable Data** | Stateless containers, persistent volumes |
