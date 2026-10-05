# Technical Audit & Master App Consolidation Report
**Generated:** 2026-08-29T22:41:16.228Z
**Role:** Principal Systems Architect & Lead Full-Stack Engineer

---

## 1. System Audit Summary

### Key Findings & Strengths
- **Modern Frontend Stack:** React 19, Tailwind CSS v4, and Vite allow deterministic client builds with low bundle footprint.
- **Server-Side API Isolation:** Gemini SDK and third-party credentials encapsulated server-side, preventing client token leaks.
- **Unified Express Runtime:** Eliminates fragmented background node processes.

### Identified Redundancies & Risks
- **Scattered Package & Config Silos:** Disparate `package.json` and `tsconfig.json` files cause version skew.
- **Direct 0.0.0.0 Port Surface:** Services exposed without reverse proxy rate limiting.
- **ISP CGNAT & Dynamic IP Bottleneck:** Standard ISP routing breaks external webhooks unless bypassed with Cloudflare Tunnels.

---

## 2. Master App Unification Roadmap

| Feature / Capability | Original App | Target Unified Path | Refactor Effort | Status |
|---|---|---|---|---|
| AI Intelligence & LLM Service Engine | Standalone AI Playground | `packages/server/src/services/ai` (/api/v1/ai/*) | Low | completed |
| Centralized User Auth & Session Gateway | Legacy Auth Microservice | `packages/server/src/middleware/auth` (/api/v1/auth/*) | Medium | in-progress |
| Interactive Analytics & Dashboard Hub | Metrics App & Telemetry Viewer | `packages/client/src/modules/analytics` (/dashboard/analytics) | Low | completed |
| System Health & Port Monitor | DevOps Tooling Script | `packages/server/src/services/system` (/api/v1/system/health) | Low | completed |
| Shared UI Design System & Component Library | Scattered UI Elements across 3 apps | `packages/ui/src/components` (/src/components/common/*) | Medium | in-progress |
| Durable Local Database & Cache Engine | Independent SQLite & File Stores | `packages/server/src/db` (/data/master.db) | High | pending |

---

## 3. Local Server Deployment Blueprint

### Caddy Reverse Proxy Configuration (`/etc/caddy/Caddyfile`)
```caddy
# /etc/caddy/Caddyfile - Production Reverse Proxy
yourdomain.com, app.local {
    # Automatic Let's Encrypt / ZeroSSL TLS Certificate
    tls admin@yourdomain.com

    # Security Headers
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "strict-origin-when-cross-origin"
        Permissions-Policy "camera=(), microphone=(), geolocation=()"
    }

    # API Gateway Reverse Proxy
    handle /api/* {
        reverse_proxy 127.0.0.1:3000 {
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-Proto {scheme}
        }
    }

    # WebSocket Upgrade
    handle /ws* {
        reverse_proxy 127.0.0.1:3000
    }

    # Master SPA Frontend
    handle {
        reverse_proxy 127.0.0.1:3000
    }

    # Gzip & Zstandard Compression
    encode zstd gzip
    
    # Access Logging
    log {
        output file /var/log/caddy/access.log {
            roll_size 10MB
            roll_keep 10
        }
    }
}
```

### Systemd Service Daemon (`/etc/systemd/system/master-app.service`)
```ini
# /etc/systemd/system/master-app.service
[Unit]
Description=Master Unified Node.js Application
After=network.target

[Service]
Type=simple
User=nodeapp
WorkingDirectory=/opt/master-app
ExecStart=/usr/bin/node dist/server.cjs
Restart=always
RestartSec=5
Environment=NODE_ENV=production
Environment=PORT=3000
EnvironmentFile=/opt/master-app/.env

# Security Sandbox Directives
ProtectSystem=full
ProtectHome=true
NoNewPrivileges=true
PrivateTmp=true

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=master-app

[Install]
WantedBy=multi-user.target
```

### ISP CGNAT Bypass (Cloudflare Tunnel)
```yaml
# ~/.cloudflared/config.yml
tunnel: your-tunnel-id-here
credentials-file: /etc/cloudflared/cert.json

ingress:
  # Route public domain securely to local Caddy reverse proxy
  - hostname: app.yourdomain.com
    service: https://127.0.0.1:443
    originRequest:
      noTLSVerify: true
  
  # Catch-all rule (required)
  - service: http_status:404
```

---

## 4. Local Environment Security Hardening Checklist

| Control ID | Category | Risk Level | Title | Verification Command |
|---|---|---|---|---|
| `fw-1` | firewall | **Critical** | UFW Default Drop Inbound Policy | `sudo ufw status verbose | grep "Default:"` |
| `fw-2` | firewall | **High** | Rate-Limited SSH Port Rule | `sudo ufw status verbose | grep "22/tcp"` |
| `fw-3` | firewall | **Critical** | Public Ingress Restricted Strictly to Ports 80 & 443 | `sudo ufw status numbered | grep -E "80/tcp|443/tcp"` |
| `fw-4` | firewall | **Critical** | Node.js (3000) & DB (5432) Loopback Isolation | `sudo ss -tulpn | grep -E ":3000|:5432"` |
| `fw-5` | firewall | **Medium** | Stateful Connection Tracking & Invalid Packet Drop | `sudo iptables -L INPUT -v -n | grep -i "state"` |
| `ssh-1` | ssh | **Critical** | Disable SSH Password Authentication | `sshd -T | grep -i "passwordauthentication"` |
| `ssh-2` | ssh | **Critical** | Disable Direct Root SSH Login (`PermitRootLogin no`) | `sshd -T | grep -i "permitrootlogin"` |
| `ssh-3` | ssh | **High** | Enforce Modern Ed25519 Cryptographic Public Keys | `cat ~/.ssh/authorized_keys | awk '{print $1, $NF}'` |
| `ssh-4` | ssh | **Medium** | SSH Inactivity Timeout & Keepalive Limits | `sshd -T | grep -E "clientaliveinterval|clientalivecountmax"` |
| `ssh-5` | ssh | **High** | Disable Empty Passwords & GUI X11 Forwarding | `sshd -T | grep -E "permitemptypasswords|x11forwarding"` |
| `sec-1` | secrets | **Critical** | Strict File Permissions on `.env` Files (`chmod 600`) | `stat -c "%a %U:%G %n" /opt/master-app/.env` |
| `sec-2` | secrets | **Critical** | Prevent `.env` Leaks via `.gitignore` & Pre-commit Hooks | `git check-ignore -v .env .env.local .env.production 2>/dev/null || echo "Needs gitignore entry"` |
| `sec-3` | secrets | **Critical** | Client vs Server Variable Separation (`GEMINI_API_KEY` vs `VITE_*`) | `grep -rn --include="*.ts*" -E "VITE_.*(KEY|SECRET|PASS|TOKEN)" src/ || echo "✔ Client bundle is clean"` |
| `sec-4` | secrets | **High** | Systemd EnvironmentFile & Process Sandbox Directives | `systemctl cat master-app.service | grep -E "EnvironmentFile|PrivateTmp|ProtectSystem"` |
| `sec-5` | secrets | **Medium** | Automated Local Secret Scanning with GitLeaks | `gitleaks version || echo "GitLeaks not installed"` |
| `sys-1` | system | **Critical** | Dedicated Non-Privileged Service User (`nodeapp`) | `ps aux | grep "dist/server.cjs" | grep -v "root"` |
| `sys-2` | system | **High** | Unattended Automatic OS Security Updates | `systemctl is-active unattended-upgrades` |

---

## 5. Action Plan & Phased Roadmap
### Phase 1: Discovery, Audit & Monorepo Scaffold: Establish Unified Project Root & Dependency Lockfile
- **Description:** Unify package.json configurations into a consolidated project workspace, eliminating version drift and redundant build tools.
- **Estimated Effort:** 4 Hours (Risk: Low)
- **Deliverables:**
  - Standardized package.json with unified React 19, Tailwind v4, Express 4/5, and tsx
  - Clean tsconfig.json with module resolution and strict path aliases (@/*)
  - Baseline .env.example with secret isolation schema
- **Commands:**
```bash
npm install
npm run lint
```

### Phase 2: Master Backend Gateway & Security Hardening: Build Single-Entry Express API Gateway with Service Modules
- **Description:** Implement server.ts combining Vite middleware in dev, static serving in prod, and modular route dispatchers under /api/v1.
- **Estimated Effort:** 8 Hours (Risk: Medium)
- **Deliverables:**
  - Multi-service API router (/api/v1/ai, /api/v1/health, /api/v1/system, /api/v1/data)
  - Centralized CORS, rate limiting, and request logging middleware
  - Secure server-side Gemini SDK initialization with fallback graceful handling
- **Commands:**
```bash
npm run build
node dist/server.cjs
```

### Phase 3: Frontend Module Consolidation & Design System: Merge Disparate UI Screens into Unified Master Dashboard
- **Description:** Port individual app views into clean modular tabs/views sharing a cohesive Tailwind design system, global theme, and state engine.
- **Estimated Effort:** 12 Hours (Risk: Medium)
- **Deliverables:**
  - Master App Shell with responsive sidebar navigation and tab switching
  - Consolidated common component library (buttons, badges, metric cards, modals)
  - Unified client state store with persistent local synchronization
- **Commands:**
```bash
npm run dev
```

### Phase 4: Local Server & ISP Deployment Production Setup: Configure Reverse Proxy, Cloudflare Tunnel & Systemd Daemons
- **Description:** Deploy Caddy/Nginx reverse proxy, establish automatic TLS certificates, configure systemd watchdog services, and bypass ISP CGNAT.
- **Estimated Effort:** 6 Hours (Risk: High)
- **Deliverables:**
  - Production Caddyfile / Nginx configuration with TLS and security headers
  - Systemd service unit (master-app.service) with automatic crash restart
  - Cloudflare Tunnel config (cloudflared) for secure remote access without port forwarding
  - UFW firewall rules restricting all internal ports to 127.0.0.1
- **Commands:**
```bash
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo systemctl enable --now master-app.service
sudo caddy start --config ./Caddyfile
```

