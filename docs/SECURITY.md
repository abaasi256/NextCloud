# Security Architecture & Threat Model

## Threat Model (Assumed Risk)

This deployment is designed for a **hostile public internet** environment. We assume:
*   **Perimeter Scans:** Automated bots will scan ports 80/443 continuously.
*   **Credential Stuffing:** Attackers will attempt to use breached credentials.
*   **Container Breakout:** A theoretical risk we mitigate via hardening.

## Defense-in-Depth Layers

### 1. Network Segmentation
We use Docker network isolation to create "air gaps":
*   **Ingress Layer:** Handles TLS termination and request validation.
*   **Data Layer:** `internal: true` flag prevents the Database and Redis from accessing the internet.

### 2. Container Hardening
*   **No New Privileges:** `security_opt: [no-new-privileges:true]` is set on ALL containers. This prevents a compromised process from gaining more privileges (e.g., via `sudo` or setuid binaries) even if the user is root inside the container.
*   **ReadOnly Mounts:** Static assets are mounted `:ro` (Ready Only) where appropriate (e.g., Caddy's view of webroot).

### 3. Ingress Hardening
The bundled Caddy configuration enforces:
*   **HSTS Preload:** Forces browsers to use HTTPS for the domain.
*   **Permissions Policy:** Disables browser API features (Camera, Mic) unless explicitly trusted.
*   **Path Traversal Blocking:** Explicit denial of hidden paths like `/.git`, `/build`, or sensitive Nextcloud data.

### 4. Identity Protection
*   **Account Security:** The setup mandates strong admin passwords during initialization.
*   **Brute Force Protection:** Nextcloud's built-in throttling is effective when configured with Redis (included).

---

## Secrets Management

### Current Implementation: Environment Variables
Secrets (DB passwords, Redis passwords) are injected via a `.env` file at runtime.
*   **Risk Profile:** Acceptable for single-tenant VPS where file permissions (`600` on `.env`) are strictly enforced.
*   **Mitigation:** The `.env` file is excluded from git (`.gitignore`).
*   **Future Path:** For multi-node swarms, migration to Docker Secrets (mounted as files in `/run/secrets`) is the standard upgrade path.
