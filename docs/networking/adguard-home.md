# AdGuard Home

## What it does
AdGuard Home is a DNS server and sinkhole (pihole alternative). It intercepts DNS requests and checks the domain against known blocklists. If the domain belongs to an ad network or tracker, AdGuard drops the request, preventing the ad from loading on the device.

## Purpose in this Config
Provides network ad-blocking and telemetry disruption. 
* **Port Configuration:** The web UI runs on port `3001` (Grafana is on 3000), while the actual DNS resolver listens on the port `53` (TCP/UDP).

## Common Commands & Diagnostics

* **`sudo systemctl status adguardhome`**
Checks if the DNS server is running.
* **`sudo journalctl -u adguardhome.service -n 50 --no-pager`**
  If NixOS injects a conflicting port rule (binding to 3000 instead of 3001), or if `systemd-resolved` is using port 53, the error will be logged here.
* **Web UI Access**
  Available at `http://trollserver:3001` (via Tailscale) or `http://192.168.0.163:3001` (via local network).
* **`scutil --dns | grep nameserver` (macOS Client)**
  Run this on a Mac client to verify the operating system has actually adopted AdGuard as its active DNS resolver.
