# 🐉 Dragon 9: Synchronise Time — Access Paths & Endpoints Reference Guide

This document details all network topology access paths for the **Dragon 9: Synchronise Time** application across **Local Machine**, **Local Area Network (LAN)**, and **Public Cloudflare Tunnel** endpoints.

---

## 🗺️ Network Topology Overview

```
                      ┌────────────────────────────────────────────────────────┐
                      │              PUBLIC WAN ACCESS (Cloudflare)            │
                      │  https://*.trycloudflare.com / https://studio.your.dom │
                      └───────────────────────────┬────────────────────────────┘
                                                  │
                                       (Encrypted Zero-Trust Proxy)
                                                  │
                      ┌───────────────────────────▼────────────────────────────┐
                      │              LAN ACCESS (Local Area Network)           │
                      │               http://10.81.126.24:5000                 │
                      └───────────────────────────┬────────────────────────────┘
                                                  │
                                          (Subnet Routing)
                                                  │
                      ┌───────────────────────────▼────────────────────────────┐
                      │                  LOCAL HOST ACCESS                     │
                      │                http://localhost:5000                   │
                      └────────────────────────────────────────────────────────┘
```

---

## 📍 1. Localhost Access Paths (Loopback)

Designed for local development, operator workstation playback, and local verification.

| Resource / Interface | Access URL | HTTP Method | Auth Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Web Theater & Time Dial** | `http://localhost:5000/` | `GET` | 🔓 Public | Dark Cyberpunk Web Theater & Synchronise Time Switch UI |
| **Engine Health Check** | `http://localhost:5000/health` | `GET` | 🔓 Public | Uptime, system version, and endpoint telemetry (`200 OK`) |
| **Temporal Engine State** | `http://localhost:5000/api/v1/time` | `GET` | 🔓 Public | Live 54m cycle calculations, Apex status, root, and hue |
| **JWT Token Generator** | `http://localhost:5000/api/v1/auth/token` | `POST` / `GET` | 🔓 Public | Generates 64-char-signed 7-day Bearer access keys |
| **Token Verification** | `http://localhost:5000/api/v1/auth/verify` | `POST` | 🔐 Bearer JWT | Verifies token validity and returns decoded payload |
| **HTTP 206 Video Stream** | `http://localhost:5000/api/v1/special/stream` | `GET` | 🔐 Bearer JWT | Byte-range enabled video stream (`H.264/AAC`) |

> [!NOTE]
> To stream via query parameter in HTML5 players, append `?token=<JWT_TOKEN>` to the stream URL:
> `http://localhost:5000/api/v1/special/stream?token=YOUR_JWT_TOKEN`

---

## 📶 2. Local Area Network (LAN) Access Paths

Designed for mobile devices, tablets, secondary control screens, and studio equipment on the same WiFi/Ethernet subnet.

- **Primary Host IP**: `10.81.126.24`
- **Secondary Host IP**: `10.81.126.23`
- **Port**: `5000`

| Resource / Interface | LAN Access URL | HTTP Method | Notes |
| :--- | :--- | :--- | :--- |
| **Mobile Web Theater** | `http://10.81.126.24:5000/` | `GET` | Responsive mobile & tablet layout |
| **LAN Health Endpoint** | `http://10.81.126.24:5000/health` | `GET` | Monitor node health across subnet |
| **LAN Temporal Engine** | `http://10.81.126.24:5000/api/v1/time` | `GET` | Real-time synchronized time broadcast |
| **LAN Video Stream** | `http://10.81.126.24:5000/api/v1/special/stream` | `GET` | Requires `Authorization` header or `?token=` query |

> [!TIP]
> Ensure local firewall allows inbound TCP traffic on port 5000:
> `sudo ufw allow 5000/tcp comment 'Dragon9 Web Theater'`

---

## ☁️ 3. Public Cloudflare Tunnel Access Paths

Enables secure, zero-open-ports WAN access for remote collaborators and global nodes.

### Option A: Instant Zero-Config Quick Tunnel (TryCloudflare)

Launch an ephemeral, SSL-encrypted public URL instantly:

```bash
# Run one-off quick tunnel
cloudflared tunnel --url http://localhost:5000
```

*Example Generated Output:*
```
+--------------------------------------------------------------------------------------------+
|  Your quick Tunnel has been created! Visit it at (it may take some time to be reachable):  |
|  https://dragon9-sync-theater.trycloudflare.com                                            |
+--------------------------------------------------------------------------------------------+
```

| Public Tunnel Resource | Public URL Format |
| :--- | :--- |
| **Public Web Theater** | `https://<tunnel-subdomain>.trycloudflare.com/` |
| **Public Health Check** | `https://<tunnel-subdomain>.trycloudflare.com/health` |
| **Public Token Generator**| `https://<tunnel-subdomain>.trycloudflare.com/api/v1/auth/token` |
| **Public Video Stream** | `https://<tunnel-subdomain>.trycloudflare.com/api/v1/special/stream?token=...` |

---

### Option B: Production Persistent Named Tunnel (`tunnel.yml`)

For permanent custom domains (e.g. `theater.yourdomain.com`):

1. **Authenticate & Create Tunnel**:
   ```bash
   cloudflared tunnel login
   cloudflared tunnel create dragon9-theater
   ```
2. **Configure [`tunnel.yml`](file:///home/tim/tunnel.yml)**:
   ```yaml
   tunnel: dragon9-theater
   credentials-file: /home/tim/.cloudflared/<TUNNEL_UUID>.json

   ingress:
     - hostname: theater.yourdomain.com
       service: http://localhost:5000
       originRequest:
         connectTimeout: 30s
         noTLSVerify: false
         http2Origin: true
         disableChunkedEncoding: false
     - service: http_status:404
   ```
3. **Route DNS & Launch**:
   ```bash
   cloudflared tunnel route dns dragon9-theater theater.yourdomain.com
   cloudflared tunnel --config /home/tim/tunnel.yml run
   ```

---

## ⚡ Quick Verification Commands

```bash
# 1. Verify Localhost API
curl -s http://localhost:5000/health | jq .

# 2. Verify LAN Access
curl -s http://10.81.126.24:5000/health | jq .

# 3. Obtain Token & Test Authenticated Byte-Range Stream
TOKEN=$(curl -s http://localhost:5000/api/v1/auth/token | jq -r .access_token)
curl -sI -H "Range: bytes=0-2048" "http://localhost:5000/api/v1/special/stream?token=${TOKEN}"
```
