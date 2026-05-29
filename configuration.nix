{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

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

