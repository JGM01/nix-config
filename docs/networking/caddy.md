# Caddy

## What it does
Caddy is a reverse proxy (nginx alternative). It has automatic HTTPS and it manages certificate provisioning and renewals.

## Purpose in this Config
Instead of accessing dashboards via IPs and port numbers (`http://100.125.100.96:3000`), Caddy intercepts requests to the Tailnet domain (`https://trollserver.<tailnet-domain>.ts.net`) and routes them to the internal port. It is configured to bypass standard verification and instead pull certificates directly from the local Tailscale daemon socket (`services.tailscale.permitCertUid = config.services.caddy.user`).

## Common Commands & Diagnostics

* **`sudo systemctl status caddy`**
  Checks if the reverse proxy is running.
* **`sudo journalctl -u caddy -n 50 --no-pager`**
  If a dashboard isn't loading or a browser has an SSL error, this log will show if Caddy failed to fetch the certificate from Tailscale or if the upstream port (e.g., 3001) is unreachable.
* **`curl -v https://trollserver.<tailnet-domain>.ts.net`**
  Useful for testing the proxy response directly from the command line to isolate browser caching issues.
