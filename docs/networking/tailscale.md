# Tailscale

## What it does
Tailscale is a mesh VPN built on WireGuard. It creates a private network between all authenticated devices, allowing them to communicate point-to-point with e2e encryption, regardless of their physical location.

## Purpose in this Config
1. **Remote Access:** Allows secure SSH (`port 2222`) and web dashboard access without opening router ports to the public internet.
2. **MagicDNS:** Human-readable hostnames (e.g., `trollserver`) instead of IP addresses.
3. **SSL Provisioning:** Generates HTTPS certificates for the internal network, which are handed off to Caddy.
4. **DNS Routing (Split DNS):** It resolves `.ts.net` addresses and forwards all other traffic to AdGuard Home.

## Common Commands & Diagnostics

* **`tailscale status`**
  Lists all connected devices, their Tailscale IPs (100.x.x.x), and current connection status.
* **`sudo tailscale up`**
  Initializes the daemon and provides the authentication URL to add the server to the Tailnet.
* **`tailscale ping <hostname>`**
  Verifies peer-to-peer connectivity with another device on the Tailnet (better than standard ping as it tests the tunnel).
