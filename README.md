# OpenClaw Control Center

<img src="docs/assets/overview-hero-en.png" alt="OpenClaw Control Center overview hero screenshot" width="1200" />

Safety-first local control center for OpenClaw.

This repository now uses English as the primary documentation language.

## What it does
- Gives OpenClaw operators one place to inspect health, usage, staff activity, collaboration, tasks, documents, and memory.
- Defaults to a safe posture:
  - `READONLY_MODE=true`
  - `LOCAL_TOKEN_AUTH_REQUIRED=true`
  - mutation routes off
- Runs as a plain Node HTTP app, which makes it easy to place behind an existing reverse proxy.

## Local start
```bash
npm install
cp .env.example .env
npm run build
npm test
npm run smoke:ui
npm run dev:ui
```

Open:
- `http://127.0.0.1:4310/?section=overview`

## Production Docker deployment
The app can run as a single container. You do not need to add Nginx, Caddy, or another web server inside the image.

### Files added for production
- `Dockerfile`
- `compose.production.yml`
- `.env.production.example`

### Deploy
```bash
cp .env.production.example .env.production
docker compose -f compose.production.yml --env-file .env.production up -d --build
```

Set these values in `.env.production` before you start:
- `OPENCLAW_HOME_HOST`
- `CODEX_HOME_HOST`
- `GATEWAY_URL`
- `LOCAL_API_TOKEN` if you want protected routes available while local token auth stays enabled

The production container:
- binds to `0.0.0.0:4310`
- runs `UI_MODE=true`
- runs `MONITOR_CONTINUOUS=true`
- keeps the safe read-only and mutation guard defaults
- exposes `GET /healthz` for health checks

## Reverse proxy for `occ.hubbinash.net`
Since `nginx-proxy-manager` already runs on a different machine, point it at the Docker host directly:

- Domain Names: `occ.hubbinash.net`
- Scheme: `http`
- Forward Hostname / IP: your Docker host
- Forward Port: `4310`

If the proxy must reach the container over a private network, make sure the Docker host firewall allows inbound traffic to port `4310` from the proxy machine.

## Runtime notes
- The app reads OpenClaw and Codex data from mounted directories. The production compose file mounts them read-only into `/data/openclaw` and `/data/codex`.
- If your billing snapshot or workspace layout is non-standard, set `OPENCLAW_SUBSCRIPTION_SNAPSHOT_PATH`, `OPENCLAW_WORKSPACE_ROOT`, or `OPENCLAW_AGENT_ROOT` in `.env.production`.
- The full operator guide remains in [README.en.md](README.en.md).
