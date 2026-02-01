# Security Architecture & Threat Model

## Threat Model (Assumed Risk)

This deployment is designed for a **hostile public internet** environment. We assume:
*   **Perimeter Scans:** Automated bots will scan ports 80/443 continuously.
*   **Credential Stuffing:** Attackers will attempt to use breached credentials.
*   **Zero-Day Vulnerabilities:** The application or container runtime may have undiscovered vulnerabilities.

## Defense-in-Depth Layers

### 1. Network Segmentation
We use Docker network isolation to create "air gaps" logic:
*   **Ingress Layer:** Handles TLS termination and request validation.
*   **Application Layer:** Processes PHP logic.
*   **Data Layer:** Completely isolated. `internal: true` flag prevents the Database and Redis from accessing the internet, mitigating reverse-shell/C2 risks.

### 2. Ingress Hardening
The bundled Caddy configuration enforces:
*   **HSTS Preload:** Forces browsers to use HTTPS.
*   **Permissions Policy:** Disables browser API features (Camera, Mic, etc.) irrelevant to file storage.
*   **Path Traversal Blocking:** Explicit denial of hidden paths like `/.git`, `/build`, or sensitive Nextcloud data directories.

### 3. Identity Protection
*   **Account Security:** The setup mandates strong admin passwords during initialization.
*   **MFA:** Nextcloud supports TOTP/WebAuthn (to be configured in-app).
*   **Brute Force Protection:** IP rate limiting at the ingress/app level (Nextcloud's built-in brute force protection).

---

## Secrets Management

### Current Implementation: Environment Variables
Secrets (DB passwords, Redis passwords) are injected via a `.env` file at runtime.
*   **Risk Profile:** Acceptable for single-tenant VPS where file permissions (`600` on `.env`) are strictly enforced.
*   **Mitigation:** The `.env` file is excluded from git (`.gitignore`).
*   **Future Path:** For multi-node swarms, migration to Docker Secrets (mounted as files in `/run/secrets`) is the standard upgrade path.

---

## Operational Security (OpSec)

*   **Minimality:** Usage of Alpine Linux images reduces the CVE surface area.
*   **Immutability:** Containers are treated as ephemeral; configuration is read-only where possible.
*   **Observability:** Logs are accessible via `docker compose logs` but should be forwarded to a SIEM/CrowdSec instance in high-security environments.
