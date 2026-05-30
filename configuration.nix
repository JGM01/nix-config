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
            FabricAPI 					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/Lwt6YYHL/fabric-api-0.116.12%2B1.21.1.jar"; sha512 = "e2da98d9885b2d1c2d15b77bfdafa5df6c294cc96844ded739c8fd61a358fc69c4c391e3296534ea67806cb8ec8d250c0343c0b237c567d9740c586e6d67333a"; };
						ClothAPI 						= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9s6osm5g/versions/HpMb5wGb/cloth-config-15.0.140-fabric.jar"; sha512 = "1b3f5db4fc1d481704053db9837d530919374bf7518d7cede607360f0348c04fc6347a3a72ccfef355559e1f4aef0b650cd58e5ee79c73b12ff0fc2746797a00"; };
						Architectury				= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/Wto0RchG/architectury-13.0.8-fabric.jar"; sha512 = "7a24a0481732c5504b07347d64a2843c10c29e748018af8e5f5844e5ea2f4517433886231025d823f90eb0b0271d1fa9849c27e7b0c81476c73753f79f19302a"; };
						GeckoLib						= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8BmcQJ2H/versions/3GjkJptS/geckolib-fabric-1.21.1-4.8.4.jar"; sha512 = "fe2592bce89898c5dadba718cc3b58f4201c0a19fe3561cdab6a410155f43073ea57b9c1a83229589c8816c8e89a42336c4f0ae09c77640d3dfbadc07afb5f9e"; };
						ForgeConfigAPIPort	= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/ohNO6lps/versions/N5qzq0XV/ForgeConfigAPIPort-v21.1.6-1.21.1-Fabric.jar"; sha512 = "cd9296e78ba969f7aed6e3692aa25eb61c102c79c55ca5f9592576bacaa26feab5d5d48fa30cf07ca852e0f1d42afc4d4558feff69a67b225183d2bc15898cf9"; };
						Balm								= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/p7lNrqW8/balm-fabric-1.21.1-21.0.58.jar"; sha512 = "c2cad8ba9eaa9d3f8142f11be1bdb5a3c3fc90c59f417c8be904ee6b32e7c57db299e9db0747ab83d7902372cabce5fd3046194e935a589978ca9aa5bc450218"; };
						Silk								= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/aTaCgKLW/versions/7WFi2tUG/silk-all-1.11.0.jar"; sha512 = "dd67903f354b0e2925a1eb3da6bd3ff0c839b4c4539dc12bff91de4dd57192f078a5cdc92e162a1a9fc1e441208735cac76356a59354386ecfc43fd367a16002"; };
						Kotlin							= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/2i87JpYj/fabric-language-kotlin-1.13.11%2Bkotlin.2.3.21.jar"; sha512 = "fa5ed2613f7216999cc0c5ddc71906f082a32b52507d7160acbdcf0eb8de12993ba302e5afde6681d025008ecc66c7533fc0c21deb672ef681b2194fb9be4245"; };
						Athena 							= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/b1ZV3DIJ/versions/JfyYsWKP/athena-fabric-1.21.1-4.0.6.jar"; sha512 = "6fec9964e4ce654f3b0c7fd849e34ce28aaeed15557dc253bbef59c577add7b96fe2fb454ece6183aec8356bcfd8d9c7327f48ced154f48b75c78043dea7eb10"; };


						# Performance
						Lithium 		= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/XQJtuOTA/lithium-fabric-0.15.3%2Bmc1.21.1.jar"; sha512 = "8c576d519121b0c2521101d2209eccd85d560b097fcb847aa54c51cd0d3f3947676f01c8d99913f514487c8e0972a1cf5f3da0c9ef0ec9bacdf2baeb4eb7d1a7"; };
						FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/sOzRw3CG/ferritecore-7.0.3-fabric.jar"; sha512 = "3ad31620fac4ff44327dc7dedbe162b2d978f3f246dc16255a6e400ce9592a0d326fe36a626f3c1bf30a11f813093cbb4dcc107af039cff724d0cdf648541fdf"; };
						Krypton 		= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar"; sha512 = "5f8cf96c79bfd4d893f1d70da582e62026bed36af49a7fa7b1e00fb6efb28d9ad6a1eec147020496b4fe38693d33fe6bfcd1eebbd93475612ee44290c2483784"; };
						Spark 			= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/l6YH9Als/versions/cALUj9l1/spark-1.10.109-fabric.jar"; sha512 = "367f574f6d28432067f09737577d799ced9c309c1725da1d09ffdfe10eacf461a66967205cc938131afbcc8b8255c8c25f8aa516e15f061c6481b6e7b8c94250"; };
						Chunky			= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/RVFHfo1D/Chunky-Fabric-1.4.23.jar"; sha512 = "02ca6af1ed31e9ebc51af20948a2afb670fe653c80aaeb990947caf6b655d6ab8eda3f1b64ef478633b67ef5d2fd0d1fe67e2107a4a522ef45fd1f183c9a6c9c"; };
						
						# New stuff
						Aether					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/YhmgMVyu/versions/NSqdh1i9/aether-1.21.1-1.5.11-fabric.jar"; sha512 = "de78675eb2719965cb1378113cc443c43039ff706ed70824355267f40286ab3abfb3065778ab711a43615c818362dad5e4dca672c3568d90b14b1a86a9037e04"; };
						Graves					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/HnD1GX6e/versions/T3grMjgj/youre-in-grave-danger-fabric-2.4.18.jar"; sha512 = "a095eaf4d132e374a9d6eb3e9ed01184f6e6880fd12b9a94000c40f16cd2099c7d1ba6b67c306a93d8f04837c4c76473b189d797545a1f1d5b3d4f9112d9e93d"; };
						Oritech					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/4sYI62kA/versions/dEYQ7Q5W/oritech-fabric-1.21.1-1.2.6.jar"; sha512 = "a90a2c722d707f6ff9e2fa711b03f11a0ebaeaf6823282d822b21bb2bd0e1d3b162adbdc624b8c410180bb642403e7149ba797e2c5c4cada75eb099ce657f26b"; };
						Waystones				= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/LOpKHB2A/versions/h6AyNItT/waystones-fabric-1.21.1-21.1.34.jar"; sha512 = "9b61458f15211555b84ce6e671e2fb50a10a9097283cb4c948342f1a73a6a4ec6f98162169e6c848414f4ffa57d335355eaf49f8f23327a9792bf5eed6e50a3c"; };
						Terralith				= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/MuJMtPGQ/Terralith_1.21.x_v2.5.8.jar"; sha512 = "f862ed5435ce4c11a97d2ea5c40eee9f817c908f3223b5fd3e3fff0562a55111d7429dc73a2f1ca0b1af7b1ff6fa0470ed6efebb5de13336c40bb70fb357dd60"; };
						VillagerBucket 	= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/IAvnm8Mq/versions/9bCE5hfU/villagerinabucket-fabric-1.21.1-1.1.1.jar"; sha512 = "ba3bdc088958629712acfb4042d2116ce9cf063cb0968e27e731f122043b9d3bce1a00cbcbd8d41305371f091d99950516bffd6f4d760e20c6aa83c2475710c4"; };
						VeinMiner				= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/OhduvhIc/versions/1NZqjOaM/veinminer-fabric-2.4.2.jar"; sha512 = "44143f84a1e109ff0b4f29c8a739e452f2390e9b51f5a6bf6bc48acd3bc970b5db61c44c6c3115c85ddaa7efe88a00f73fa1aa4a18ebc411359938989be0c476"; };
						VoiceChat				= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/RMvAyxuK/voicechat-fabric-1.21.1-2.6.18.jar"; sha512 = "6f758aa709bd997afbc1e5c511ceb28f562e297151fca11eca0a93b16d84224c555858b395a20310ac0c2772aaf92285797e25a2cca714a3b9033d2e061fff99"; };
						Lootr						= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/EltpO5cN/versions/SojdASBz/lootr-fabric-1.21.1-1.11.37.120.jar"; sha512 = "4b4e18b69a5d4b023c876b93b88973b07c1de0cee5e474ce049314e50b1eeba36a679ec3d8a5a618ca5a2bdb12cdfca4f6c2144468ace24687484e4883038f58"; };
						Comforts				= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/SaCpeal4/versions/LUPOTXbk/comforts-fabric-9.0.5%2B1.21.1.jar"; sha512 = "617711d65c0ac1ddb8069ed46051c7da5fd7f4a19adbefc1c6d417621d32a4a4929dd60bd76f204045537a151d29f5e518aa7d18d604012ef1f9b62de707530d"; };

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
		killall
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

