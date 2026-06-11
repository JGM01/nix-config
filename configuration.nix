{ config, lib, pkgs, inputs, self, ... }:

{
  imports = [
  	./hardware-configuration.nix
		./modules/diagnostics
		inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

	nixpkgs.config.allowUnfree = true;
	nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

	# Minecraft Server Config
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.minecrap = {
      enable = true;
      openFirewall = true;

      package = pkgs.fabricServers.fabric-1_21_1;

			# Aikar's Flags
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
        "-XX:ErrorFile=/var/log/minecraft/minecrap/hs_err_pid%p.log"
        "-Xlog:gc*,safepoint:file=/var/log/minecraft/minecrap/gc.log:time,uptime,level,tags:filecount=10,filesize=25M"
      ]);

      serverProperties = {
        server-port = 25565;
        motd = "minecrap (hosted on NixOS!)";
        max-players = 11;
        difficulty = "normal";

				# perf to save the CPU
				view-distance = 8;
        simulation-distance = 4;
        network-compression-threshold = 256;

				white-list = true;
  			enforce-whitelist = true;
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
						ModMenu							= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/mOgUt4GM/versions/v6Xx3fbU/modmenu-11.0.4.jar"; sha512 = "45ea8f7e0749bc0eb98900f94486e323f153b199617fa43977b46472e4196ee5a6739f41a1e7f68e270f84a367df5f7f53c2a1f46145ad7d349ede4297895396"; };
						OwoLib							= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/ccKDOlHs/versions/JB1fLQnc/owo-lib-0.12.15.4%2B1.21.jar"; sha512 = "b9c79035c912ef043722f2a1f0bc0166e0ca047ea5237a86f23198dea487289e0a0f92a96e46bd683ffc39e4190b95450d13456b14f6280587635b51c9393a1b"; };
						Collective 					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/6xEh8Qbr/collective-1.21.1-8.22.jar"; sha512 = "e598ce7f8bd822fa8a5ffa21c45fa1a14716191b6791ab8cdb96a66b4647483c1b6e2c4e38ba13a2ff5e97a93d851cb9000985a0f2dc7034391811fbbdcfe9a9"; };
						BackpackLib					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9jxwkYQL/versions/ZLVrtF0Q/sophisticatedcore-1.21.1-1.2.9.21.168.jar"; sha512 = "330489fa3434702a01aa1a98d46eca5d155cb4c2dd25b30c70f6afb29a8d027381cf395d5965b3c46df899bb96675536604302d9db6273f624ba959f4009ce25"; };
						FzzyConfig					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/hYykXjDp/versions/kOmySYD4/fzzy_config-0.7.6%2B1.21.jar"; sha512 = "84f4176e371e65c838e7b78a7defdf18cad1fe5ad47dabe2a3fc5a940d900296d8af7a0320fb0c15040e38bf9be98d046f38a93d392a6ecaed71926de5158ddf"; };
						MultiMod            = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/k68glP2e/versions/taR5fMv3/automodpack-mc1.21.1-fabric-4.0.5.jar"; sha512 = "6bc599601975083b1287894b5c783466b05acd15a2c6276b7258749e1db6e07fe95f40653fc88366e9354faed0552ad89923df270d6f61643c5a239805acc77c"; };
						SuperMartijnLib     = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/rOUBggPv/versions/blDCgrqh/supermartijn642corelib-1.1.21-fabric-mc1.21.jar"; sha512 = "845981e2819e80b94492a3606ee75400205026771309afca26186a43e64e170fd8ffc4526bb3dea5d31e1aff0e8fea017eabd1a94cd3b5faa0b668f05a754775"; };
						SuperMartijnConfig  = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/LN9BxssP/versions/euSlaAtA/supermartijn642configlib-1.1.8-fabric-mc1.21.jar"; sha512 = "479838148fc1979409474b460de73162b7730c36b201eb903e299c144a056fed4f6dfb4498e0ded1e93a168379ff7efe0623279aa33a82b1b222c68468c477d6"; };

						# Performance
						Lithium 		= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/XQJtuOTA/lithium-fabric-0.15.3%2Bmc1.21.1.jar"; sha512 = "8c576d519121b0c2521101d2209eccd85d560b097fcb847aa54c51cd0d3f3947676f01c8d99913f514487c8e0972a1cf5f3da0c9ef0ec9bacdf2baeb4eb7d1a7"; };
						FerriteCore = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uXXizFIs/versions/sOzRw3CG/ferritecore-7.0.3-fabric.jar"; sha512 = "3ad31620fac4ff44327dc7dedbe162b2d978f3f246dc16255a6e400ce9592a0d326fe36a626f3c1bf30a11f813093cbb4dcc107af039cff724d0cdf648541fdf"; };
						Krypton 		= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar"; sha512 = "5f8cf96c79bfd4d893f1d70da582e62026bed36af49a7fa7b1e00fb6efb28d9ad6a1eec147020496b4fe38693d33fe6bfcd1eebbd93475612ee44290c2483784"; };
						Chunky			= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/RVFHfo1D/Chunky-Fabric-1.4.23.jar"; sha512 = "02ca6af1ed31e9ebc51af20948a2afb670fe653c80aaeb990947caf6b655d6ab8eda3f1b64ef478633b67ef5d2fd0d1fe67e2107a4a522ef45fd1f183c9a6c9c"; };
						DH					= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/uCdwusMi/versions/oYXIfeus/DistantHorizons-3.0.3-b-1.21.1-fabric-neoforge.jar"; sha512 = "8b39994ee6c5d71b8afacc80c2d13dd92fad10281374392c0049d1b6aebc823d7e137125268dee7383d3ff753eacf708fbe87d773cf0087d7b6057a05cf18ad3"; };

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
						TreeHarvester		= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/abooMhox/versions/OtzwmSlR/treeharvester-1.21.1-9.1.jar"; sha512 = "ef05666db209bcc339a89c83106c329a51d32310188f913375d8ebb3ff98251f99ae21baa6def18e1125d64e5d454f6cd5c5dbe7f8ddc00312dfa1b89a866c4d"; };
						Backpacks 			= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/ouNrBQtq/versions/nHhuPdda/sophisticatedbackpacks-1.21.1-3.23.4.3.106.jar"; sha512 = "04c0c22489a16d782b644ec7ad6aa5bf4353614148a9fb1e152e9ec6c72be14d36b1c0793c25b720f2baf85aa299fc6585b4ee1991de25ac426166dc72fb0def"; };
						BetterClimbing	= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/ZucWZEBV/versions/6nQWk1fq/better_climbing-fabric-3.jar"; sha512 = "c6bec1500149bb59dd1a5eefda549323313747d9388da38e5347c63d4320f30aff239969a19ea2d437489ebeb1cc4ae293b55261132ac90ec57ee6c123603fb7"; };
						ImmersivePaint	= pkgs.fetchurl { url = "https://cdn.modrinth.com/data/6txNkua3/versions/sScHMgAp/immersive_paintings-fabric-1.21.1-0.7.7.jar"; sha512 = "99ee65b34b4e7a6e78fe7dc2cb3cf2f3ec3128b82f8e36644a4afe0edfbda6374b62686abc5ccfc95d040483021bbe221edc467fbcbd4bddb6075b97a68910ef"; };
						Trinkets        = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/5aaWibi9/versions/JagCscwi/trinkets-3.10.0.jar"; sha512 = "3ea846c945a0559696501ff65b373c8ee8fd9b394604e9910b4ed710c3e07cadc674a615a2c3b385951a42253a418201975df951b3100053ed39afadc70221c9"; };
						TomStorage      = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/XZNI4Cpy/versions/GwLz79tK/toms_storage_fabric-1.21-2.3.0.jar"; sha512 = "e7bc2828cbf7cda7fa178c81d9f6935985c72fe44b3ccc33e383101c53f4964eb54c0a6e1b3a6a0e13466a30eb043bccd3021ede141b962ed211ddd2948daa2f"; };
						JEI             = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/TvqzuFwN/jei-1.21.1-fabric-19.27.0.340.jar"; sha512 = "04d4067931010578b55aee55b1e38f7ea2ea3ce8d258ae5d9ece7facfcfcb41349a457ca8bd2ca502577616b84b1c14dbd00b2985ffc6cde5c3d1ec2dd214a04"; };
						IronChest       = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/7mHyGgvW/versions/rHtTi59k/IronChests-2.0.4.jar"; sha512 = "69a92cad45ba947f9f29f79aa3132fc287b86a3d46e501ad4505fe2aeac7e15fc517be32a162169e472345c58d7490a9bfb72fc20fda2ed94ff8c4a8526815da"; };
						ChunkLoader     = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/t1VgucWo/versions/gC8IvJwh/chunkloaders-1.2.9-fabric-mc1.21.1.jar"; sha512 = "76dd56e5223e2e5072f5fd143bf95feb9e5e5cc73fed5d99c8ad2a9a77e2a12d0b34efdae94bc792209989c07212cc189d8ed905fe985ff4a711813a212e2a9a"; };
						StorageDrawers  = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/guitPqEi/versions/78LmfH8Z/StorageDrawers-fabric-1.21.1-13.11.4.jar"; sha512 = "1ec2f81b50708b610d0e7024d067ac630c0f9497307e68e1dc22ee41c6d196f2db3249cad6ab243f3192e73b6a569fb2936a96b9bf61a94ea67a643a5f5b6283"; };
						}
        );
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  services.caddy = {
    enable = true;

    virtualHosts."localhost" = {
      extraConfig = ''
        respond "Caddy is up and running on NixOS!" 200
      '';
    };
  };

	services.prometheus = {
		enable = true;

		exporters.node = {
			enable = true;
			enabledCollectors = [ "systemd" "processes" ];
			port = 9100;
		};

		scrapeConfigs = [
			{
				job_name = "node";
				static_configs = [{
					targets = [ "localhost:9100" ];
				}];
			}
		];
	};

	services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "0.0.0.0";
      http_port = 3000;
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
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  # Networking
  networking.networkmanager.enable = true;

  # Wake-on-LAN
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
		tmux
    tree
    ghostty.terminfo
  ];

  # OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
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
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        80     # Caddy (HTTP)
        443    # Caddy (HTTPS)
        25565  # Minecraft
        3000   # Grafana
      ];

      allowedUDPPorts = [];
      trustedInterfaces = [ "tailscale0" ];
    };

	system.autoUpgrade = {
		enable = true;
		flake = "${self}";
		flags = [
			"--update-input" "nixpkgs"
			"--commit-lock-file"
		];
		dates = "Mon 04:00";
		allowReboot = true;
	};


  # NixOS release compatibility
  system.stateVersion = "25.11";
}
