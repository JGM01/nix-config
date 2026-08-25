{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.services.wubbzee-server;

  wubbzeePkg = pkgs.rustPlatform.buildRustPackage {
    pname = "wubbzee-server";
    version = "0.1.0";
    src = inputs.wubbzee-server;
    cargoLock.lockFile = "${inputs.wubbzee-server}/Cargo.lock";
  };

  # GitHub's published SSH host keys (api.github.com/meta). Shipped read-only
  # so ssh never needs to write a known_hosts file at runtime.
  githubKnownHosts = pkgs.writeText "github-known-hosts" ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
  '';

  # Wrapper so GIT_SSH_COMMAND is a single token (systemd Environment= splits
  # on spaces and would otherwise drop the -i/-o flags).
  gitSsh = pkgs.writeShellScript "wubbzee-git-ssh" ''
    exec ${pkgs.openssh}/bin/ssh \
      -i ${config.age.secrets.wubbzee-deploy-key.path} \
      -o IdentitiesOnly=yes \
      -o StrictHostKeyChecking=yes \
      -o UserKnownHostsFile=${githubKnownHosts} \
      "$@"
  '';
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
      path = [ pkgs.git pkgs.graphviz ];

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
          "GIT_SSH_COMMAND=${gitSsh}"
        ];

        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
