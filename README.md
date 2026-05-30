# Troll Server NixOS Config

This repository contains the declarative NixOS configuration for `trollserver`, the computer that sits beneath my router. 

## Standard Deployment Flow

Every time `configuration.nix` or `flake.nix` is modified, the changes have to be committed before Nix can build them.

1. **Stage changes:** `git add .`
2. **Commit changes:** `git commit -m "brief description of changes"`
3. **Apply & Restart:** `sudo nixos-rebuild switch --flake .#trollserver`

*Note: The rebuild command will automatically restart the systemd services if any related configurations or mods were changed.*

## Minecraft Console & Logs

The Minecraft server runs headlessly in the background via systemd and is wrapped in a tmux session.

* **Attach to Live Console (Run Commands):**
```bash
sudo tmux -S /run/minecraft/minecrap.sock attach

```

**IMPORTANT:** Do NOT press `Ctrl+C` to exit. To detach without killing the server, press **`Ctrl+B`**, release, then press **`D`**.
* **View Standard Log File (Safe viewing):**
```bash
sudo tail -f /srv/minecraft/minecrap/logs/latest.log

```

* **View Systemd Service Logs (Check for boot errors):**
```bash
sudo journalctl -fu minecraft-server-minecrap

```

## Manual Actions
Not necessary for standard updates (the rebuild command handles it), but to manually kill or start the server:

* **Stop:** `sudo systemctl stop minecraft-server-minecrap`
* **Start:** `sudo systemctl start minecraft-server-minecrap`
* **Restart:** `sudo systemctl restart minecraft-server-minecrap`

## Adding & Updating Mods

First get the mod's `sha512` hash and add it to the `symlinks` section in `configuration.nix`:

**Modrinth Prefetch Tool (Recommended)**
Get the Version ID from the Modrinth download page URL (e.g., `7aM636w8`) and run:

```bash
nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <VERSION_ID>

```

*Copy and paste the output directly into `configuration.nix`.*

## World Management

World info is completely separate from the Nix store.

* **World Directory:** `/srv/minecraft/minecrap/world`

**To wipe the world (e.g., for new terrain generation):**

1. `sudo systemctl stop minecraft-server-minecrap`
2. `sudo rm -rf /srv/minecraft/minecrap/world`
3. `sudo systemctl start minecraft-server-minecrap`

**To pre-generate terrain (Prevents lag):**
Attach to the tmux console and run:

1. `chunky radius 3000`
2. `chunky start`
