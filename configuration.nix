{ config, lib, pkgs, inputs, ... }:

{
  imports = [
  	./hardware-configuration.nix
		inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

	nixpkgs.config.allowUnfree = true;
	nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

	# Modded Minecraft Server Configuration
  services.minecraft-servers = {
    enable = true;
    eula = true; 

    servers.minecrap = {
      enable = true;
      openFirewall = true; # Automatically opens the port (25565)
      
			package = pkgs.fabricServers.fabric-1_21_1;

			# Allocate 6GB of RAM and use optimized Garbage Collection (Aikar's Flags)
      jvmOpts = (builtins.concatStringsSep " " [
        "-Xms6G"
        "-Xmx6G"
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
        "-XX:+AlwaysPreTouch"
      ]);

      serverProperties = {
        server-port = 25565;
        motd = "minecrap (hosted on NixOS!)";
        max-players = 10;
        difficulty = "normal";

				# perf to save the CPU
				view-distance = 8;        
        simulation-distance = 4;  
        network-compression-threshold = 256; 
      };

			symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
						# Libraries
            Fabric-API = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar"; sha512 = "e5f3c3431b96b281300dd118ee523379ff6a774c0e864eab8d159af32e5425c915f8664b1cd576f20275e8baf995e016c5971fea7478c8cb0433a83663f2aea8"; };
						
						# Performance
						Lithium 		= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/XQJtuOTA/lithium-fabric-0.15.3%2Bmc1.21.1.jar"; sha512 = "8c576d519121b0c2521101d2209eccd85d560b097fcb847aa54c51cd0d3f3947676f01c8d99913f514487c8e0972a1cf5f3da0c9ef0ec9bacdf2baeb4eb7d1a7"; };
						FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/sOzRw3CG/ferritecore-7.0.3-fabric.jar"; sha512 = "3ad31620fac4ff44327dc7dedbe162b2d978f3f246dc16255a6e400ce9592a0d326fe36a626f3c1bf30a11f813093cbb4dcc107af039cff724d0cdf648541fdf"; };
						Krypton 		= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar"; sha512 = "5f8cf96c79bfd4d893f1d70da582e62026bed36af49a7fa7b1e00fb6efb28d9ad6a1eec147020496b4fe38693d33fe6bfcd1eebbd93475612ee44290c2483784"; };
						Spark 			= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/l6YH9Als/versions/cALUj9l1/spark-1.10.109-fabric.jar"; sha512 = "367f574f6d28432067f09737577d799ced9c309c1725da1d09ffdfe10eacf461a66967205cc938131afbcc8b8255c8c25f8aa516e15f061c6481b6e7b8c94250"; };
						Chunky			= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/RVFHfo1D/Chunky-Fabric-1.4.23.jar"; sha512 = "02ca6af1ed31e9ebc51af20948a2afb670fe653c80aaeb990947caf6b655d6ab8eda3f1b64ef478633b67ef5d2fd0d1fe67e2107a4a522ef45fd1f183c9a6c9c"; };
						
						# New stuff
            Backpacks 	= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/MGcd6kTf/versions/Ci0F49X1/1.2.1-backpacks_mod-1.21.2-1.21.3.jar"; sha512 = "6efcff5ded172d469ddf2bb16441b6c8de5337cc623b6cb579e975cf187af0b79291b91a37399a6e67da0758c0e0e2147281e7a19510f8f21fa6a9c14193a88b"; };
          }
        );
      };
    };
  };


  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernel.sysctl = {
    "net.core.default_qdisc"          = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "vm.swappiness" = 10;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 15;
  };
	
	powerManagement.cpuFreqGovernor = "performance";

  # Hostname
  networking.hostName = "trollserver";

  # Networking
  networking.networkmanager.enable = true;

  # Optional Wake-on-LAN
  networking.interfaces."enp3s0".wakeOnLan.enable = true;

  # Timezone
  time.timeZone = "America/New_York";


  # User account
	age.secrets.trolluser-password.file = ./secrets/trolluser-password.age;
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

