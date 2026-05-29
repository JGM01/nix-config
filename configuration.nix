{ config, lib, pkgs, ... }:

{
  imports = [
  	./hardware-configuration.nix
		inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

	nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

	# Modded Minecraft Server Configuration
  services.minecraft-servers = {
    enable = true;
    eula = true; 

    servers.minecrap = {
      enable = true;
      openFirewall = true; # Automatically opens the port (25565)
      
			package = pkgs.fabricServers.fabric-1_21_1

      serverProperties = {
        server-port = 25565;
        motd = "minecrap (hosted on NixOS!)";
        max-players = 10;
        difficulty = "normal";
      };

			symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar";
              sha512 = "e5f3c3431b96b281300dd118ee523379ff6a774c0e864eab8d159af32e5425c915f8664b1cd576f20275e8baf995e016c5971fea7478c8cb0433a83663f2aea8";
            };
            Backpacks = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/MGcd6kTf/versions/Ci0F49X1/1.2.1-backpacks_mod-1.21.2-1.21.3.jar";
              sha512 = "6efcff5ded172d469ddf2bb16441b6c8de5337cc623b6cb579e975cf187af0b79291b91a37399a6e67da0758c0e0e2147281e7a19510f8f21fa6a9c14193a88b";
            };
          }
        );
      };
    };
  };


  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  # + fix Nix build sandbox on hardened kernel
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  security.unprivilegedUsernsClone = true;
  
  # Hostname
  networking.hostName = "trollserver";

  # Networking
  networking.networkmanager.enable = true;

  # Optional Wake-on-LAN
  networking.interfaces."enp3s0".wakeOnLan.enable = true;

  # Timezone
  time.timeZone = "America/New_York";

  age.secrets.trolluser-password.file = ./secrets/trolluser-password.age;
  # User account
  users.users.trolluser = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    packages = with pkgs; [
      tree
    ];

    hashedPasswordFile = config.age.secrets.trolluser-password.path;

    openssh.authorizedKeys.keyFiles = [
      ./sshpubkey.pub
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    btop
    curl
    tree
  ];

  # OpenSSH
  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # mDNS / local discovery
  services.avahi = {
    enable = true;

    nssmdns4 = true;

    openFirewall = true;

    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings = {
    auto-optimise-store = true;

    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };


  # Firewall
  networking.firewall.enable = true;

  # NixOS release compatibility
  system.stateVersion = "25.11";
}

