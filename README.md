# Troll Server NixOS Config

This repository contains the declarative NixOS configuration for `trollserver`, the computer that sits beneath my router. 

## Standard Deployment Flow

Every time `configuration.nix` or `flake.nix` is modified, the changes have to be committed before Nix can build them.

1. **Test Build:** `nh os build`
2. **Apply Build:** `nh os switch -u`

*Note: The rebuild command will automatically restart the systemd services if any related configurations or mods were changed.*
