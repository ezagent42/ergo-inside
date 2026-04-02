# ergo-inside

Configuration for `zchat.inside.h2os.cloud` — the shared ergo IRC server for zchat.

## Architecture

```
IRC clients (:6697, TLS) → Caddy L4 (TLS termination, SNI) → ergo (127.0.0.1:6667)
```

## Authentication

All users must authenticate via SASL PLAIN with an OIDC access token from Logto.
The `ergo_auth_script.py` validates tokens against the Logto userinfo endpoint.

## First-time Setup

```bash
./setup.sh
```

Installs everything from scratch: checks dependencies (ergo, caddy), creates config directories, deploys configs, initializes the ergo database, and registers launchd services.

## Deploy

```bash
./deploy.sh
```

Copies configs from this repo to `~/.config/ergo/` and `~/.config/caddy/`, then restarts both services. Use after editing configs in this repo.

## Backup

```bash
./backup.sh
```

Copies running configs back into this repo. Use after editing configs directly in `~/.config/ergo/` or `~/.config/caddy/`. Review changes with `git diff` before committing.

## Files

| File | Purpose |
|------|---------|
| `ergo.yaml` | Ergo IRC server config (require-sasl + auth-script + SQLite history) |
| `ergo_auth_script.py` | Validates SASL credentials against Logto OIDC userinfo |
| `auth_script_config.json` | Logto userinfo endpoint URL |
| `Caddyfile` | Caddy L4 proxy (TLS termination for :6697) |
| `launchd/` | macOS LaunchAgent plists for ergo and caddy |
| `setup.sh` | First-time setup (install + init + register services) |
| `deploy.sh` | Deploy configs from repo to system |
| `backup.sh` | Backup running configs back to repo |
