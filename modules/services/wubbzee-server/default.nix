{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.services.wubbzee-server;

  wubbzeePkg = pkgs.rustPlatform.buildRustPackage {
    pname = "wubbzee-server";
    version = "0.1.0";
    src = inputs.wubbzee-server;
    cargoLock.lockFile = "${inputs.wubbzee-server}/Cargo.lock";
  };
in
{
  options.services.wubbzee-server = {
    enable = lib.mkEnableOption "the wubbzee git-driven static site server";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "wubbzee.com";
      description = "Public hostname the Cloudflare tunnel serves.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Local port wubbzee-server binds to.";
    };

    repoUrl = lib.mkOption {
      type = lib.types.str;
      default = "git@github.com:JGM01/wubbzee-content.git";
      description = "Git remote the server clones and tracks.";
    };

    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Branch the server tracks and resets to.";
    };

    tunnelId = lib.mkOption {
      type = lib.types.str;
      description = ''
        Cloudflare tunnel ID (the UUID printed by `cloudflared tunnel create`,
        NOT the name — cloudflared can't resolve a name without the account cert).
        The matching credentials file must exist at
        /etc/cloudflared/<tunnelId>.json on the server.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.wubbzee = {
      isSystemUser = true;
      group = "wubbzee";
    };
    users.groups.wubbzee = { };

    age.secrets.wubbzee-webhook-secret = {
      file = ../../../secrets/wubbzee-webhook-secret.age;
      owner = "wubbzee";
      group = "wubbzee";
      mode = "0440";
    };
    age.secrets.wubbzee-deploy-key = {
      file = ../../../secrets/wubbzee-deploy-key.age;
      owner = "wubbzee";
      group = "wubbzee";
      mode = "0400";
    };

    services.cloudflared = {
      enable = true;
      tunnels."${cfg.tunnelId}" = {
        credentialsFile = "/etc/cloudflared/${cfg.tunnelId}.json";
        ingress."${cfg.domain}" = "http://127.0.0.1:${toString cfg.port}";
        default = "http_status:404";
      };
    };

    systemd.services.wubbzee-server = {
      description = "wubbzee git-driven static site server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.git ];

      serviceConfig = {
        Type = "simple";
        User = "wubbzee";
        Group = "wubbzee";
        StateDirectory = "wubbzee";
        ExecStart = "${lib.getExe wubbzeePkg}";
        Restart = "on-failure";
        RestartSec = "5s";

        Environment = [
          "WUBBZEE_BIND=127.0.0.1"
          "WUBBZEE_PORT=${toString cfg.port}"
          "WUBBZEE_REPO=${cfg.repoUrl}"
          "WUBBZEE_BRANCH=${cfg.branch}"
          "WUBBZEE_SECRET_FILE=${config.age.secrets.wubbzee-webhook-secret.path}"
          "GIT_SSH_COMMAND=${pkgs.openssh}/bin/ssh -i ${config.age.secrets.wubbzee-deploy-key.path} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/var/lib/wubbzee/known_hosts"
        ];

        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
