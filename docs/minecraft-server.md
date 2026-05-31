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

To wipe the world (e.g., for new terrain generation):

1. `sudo systemctl stop minecraft-server-minecrap`
2. `sudo rm -rf /srv/minecraft/minecrap/world`
3. `sudo systemctl start minecraft-server-minecrap`

To pre-generate terrain (Prevents lag):
1. `sudo tmux -S /run/minecraft/minecrap.sock attach`
2. `chunky radius 3000`
3. `chunky start`
