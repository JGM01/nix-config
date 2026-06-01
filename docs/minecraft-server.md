# Minecraft Server

The Minecraft server runs headlessly in the background via systemd and is wrapped in a tmux session.

Attach to Live Console (Run Commands):
```bash
sudo tmux -S /run/minecraft/minecrap.sock attach

```

**IMPORTANT:** Do NOT press `Ctrl+C` to exit. To detach without killing the server, press **`Ctrl+B`**, release, then press **`D`**.

View Standard Log File (Safe viewing):
```bash
sudo tail -f /srv/minecraft/minecrap/logs/latest.log

```

View Systemd Service Logs (Check for boot errors):
```bash
sudo journalctl -fu minecraft-server-minecrap

```

## Incident RCA

Crash evidence is collected locally. To create a focused bundle manually:

```bash
sudo trollserver-incident-bundle
```

Bundles are written to `/var/lib/trollserver-incidents/` as compressed `.tar.zst` files. The system keeps the latest 5 bundles.

List bundle contents:

```bash
sudo sh -c 'tar --zstd -tf /var/lib/trollserver-incidents/*.tar.zst | head -80'
```

Minecraft JVM crash logs and rotating GC logs are written to:

```bash
/var/log/minecraft/minecrap/
```

When `minecraft-server-minecrap` fails, systemd automatically runs the same bundle collector through the `trollserver-incident-bundle@...` failure hook.

Useful first checks after a crash:

```bash
sudo ls -lh /var/lib/trollserver-incidents/
sudo journalctl -b -u minecraft-server-minecrap --no-pager
sudo journalctl -b -p warning..alert --no-pager
sudo smartctl --scan-open
sudo smartctl -a /dev/sda
```

## Manual Actions
Not necessary for standard updates (the rebuild command handles it), but to manually kill or start the server:

* **Stop:** `sudo systemctl stop minecraft-server-minecrap`
* **Start:** `sudo systemctl start minecraft-server-minecrap`
* **Restart:** `sudo systemctl restart minecraft-server-minecrap`

## Adding & Updating Mods

Get the Version ID from the Modrinth download page URL (e.g., `7aM636w8`) and run:

```bash
nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <VERSION_ID>

```

Copy and paste the output directly into `configuration.nix`.

## World Management

World data is in `/srv/minecraft/minecrap/world`.

Create a one-off local archive for copying:

```bash
sudo systemctl stop minecraft-server-minecrap
sudo tar -C /srv/minecraft/minecrap -czf /tmp/minecrap-world-$(date +%Y%m%d-%H%M%S).tar.gz world
sudo chown trolluser:users /tmp/minecrap-world-*.tar.gz
sudo systemctl start minecraft-server-minecrap
```

Then pull it:

```bash
scp trolluser@trollserver.local:/tmp/minecrap-world-*.tar.gz ~/Downloads/
```

After confirming the file, remove the temporary server copy:

```bash
rm /tmp/minecrap-world-*.tar.gz
```

To wipe the world (e.g., for new terrain generation):

1. `sudo systemctl stop minecraft-server-minecrap`
2. `sudo rm -rf /srv/minecraft/minecrap/world`
3. `sudo systemctl start minecraft-server-minecrap`

To pre-generate terrain (Prevents lag):
1. `sudo tmux -S /run/minecraft/minecrap.sock attach`
2. `chunky radius 3000`
3. `chunky start`
