# 📦 Production-Grade Self-Hosted Cloud Platform

## Overview

This project implements a **secure, maintainable self-hosted cloud platform** on a single VPS. 

Built on **Nextcloud** and **Docker**, it replaces "hobbyist" defaults with **DevSecOps best practices**: strict network segmentation, resource governance, and defense-in-depth architecture.

---

## 🏗 Architecture

| Component | Technology | Role |
|-----------|------------|------|
| **Ingress** | Caddy | TLS Termination, HTTP/3, Security Headers |
| **App Runtime** | Nextcloud (FPM) | Stateless PHP runtime with externalized persistence |
| **Database** | PostgreSQL 16+ | High-concurrency relational storage |
| **Cache** | Redis | Session management & Transactional Locking |
| **Orchestrator** | Docker Compose | Declarative service lifecycle & topology |

### Key Features
*   **Declarative Service Topology** defined in `docker-compose.yml`.
*   **Least-Privilege Network Segmentation:** Database and Redis operate on an `internal` network with no internet access.
*   **Resource Governance:** CPU and Memory limits (cgroups) prevent "noisy neighbor" scenarios.
*   **Ingress Hardening:** Modern TLS defaults via Caddy (TLS 1.3, HSTS, strict headers).
*   **Privilege Escalation Prevention:** All containers run with `security_opt: [no-new-privileges:true]`.

---

## ⚖️ Design Trade-offs

*   **PostgreSQL vs MariaDB:** We chose **PostgreSQL** for its superior handling of concurrent writes and reliability (WAL), despite slightly higher memory overhead than MariaDB.
*   **Caddy vs external Nginx:** This repo bundles **Caddy** for a self-contained "Reference Architecture." In a multi-app VPS, this acts as the **Application Gateway**, sitting behind your edge proxy.
*   **Secrets via .env:** For simplicity on a single node, we use environment variables. A Swarm/K8s migration would move this to Docker Secrets.

---

## 💥 Failure Scenarios & Recovery

| Scenario | Impact | Mitigation |
|----------|--------|------------|
| **Container Crash** | Minimal | `restart: unless-stopped` auto-recovery. |
| **Database Corruption** | High | Daily `pg_dump` via `scripts/backup.sh`. |
| **Host Compromise** | Critical | Containers have no privilege escalation (`no-new-privileges`). |
| **Resource Exhaustion** | Managed | Hard limits prevent Nextcloud from crashing the system. |

> **Note:** The backup script assumes the project resides in `/opt/nextcloud` or is executed from the project root.

---

## 🚀 Getting Started

### 1. Prerequisites
*   Docker Engine & Docker Compose
*   A domain name pointing to your VPS
*   `restic` (optional, for offsite backups)

### 2. Configuration
Copy the template and set strong credentials:
```bash
cp .env.example .env
chmod 600 .env  # Restrict permissions
# Edit .env with your secrets
```

### 3. Deployment
```bash
docker compose up -d
```
The architecture will initialize, create the isolated networks, and provision the database schema automatically.

---

## 🔐 Security Checks
*   [x] **No exposed ports** for DB or Redis.
*   [x] **Modern TLS defaults** provided by Caddy (TLS 1.3 preferred).
*   [x] **No-New-Privileges** flag enabled on all containers.

---

## 🧾 License
MIT
