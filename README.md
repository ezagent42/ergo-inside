# ergo-inside

Configuration for `zchat.inside.h2os.cloud` — the shared ergo IRC server for zchat.

## Architecture

```
IRC clients (:6697, TLS) → Caddy L4 (TLS termination, SNI) → ergo (127.0.0.1:6667)
```

## Authentication

All users must authenticate via SASL PLAIN with an OIDC access token from Logto.
The `ergo_auth_script.py` validates tokens against the Logto userinfo endpoint.

## Deploy

```bash
./deploy.sh
```

This copies configs to `~/.config/ergo/` and `~/.config/caddy/`, then restarts both services.

## Files

| File | Purpose |
|------|---------|
| `ergo.yaml` | Ergo IRC server config (require-sasl + auth-script enabled) |
| `ergo_auth_script.py` | Validates SASL credentials against Logto userinfo |
| `auth_script_config.json` | Logto userinfo endpoint URL |
| `Caddyfile` | Caddy L4 proxy (TLS termination for :6697) |
| `launchd/` | macOS LaunchAgent plists for ergo and caddy |
| `deploy.sh` | Deploy script |
