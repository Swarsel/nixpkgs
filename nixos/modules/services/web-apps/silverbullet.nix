{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.silverbullet;
  defaultUser = "silverbullet";
  defaultGroup = defaultUser;
  defaultSpaceDir = "/var/lib/silverbullet";
in
{
  options = {
    services.silverbullet = {
      enable = lib.mkEnableOption "Silverbullet, an open-source, self-hosted, offline-capable Personal Knowledge Management (PKM) web application";
      package = lib.mkPackageOption pkgs "silverbullet" { };

      envFile = lib.mkOption {
        default = null;

        description = ''
          File containing extra environment variables. For example:

          ```
          SB_USER=user:password
          SB_AUTH_TOKEN=abcdefg12345
          ```
        '';

        example = "/etc/silverbullet.env";
        type = lib.types.nullOr lib.types.path;
      };

      extraArgs = lib.mkOption {
        default = [ ];
        description = "Extra arguments passed to silverbullet.";
        example = [ "--db /path/to/silverbullet.db" ];
        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = defaultGroup;

        description = ''
          The group to run Silverbullet under.
          By default, a group named `${defaultGroup}` will be created.
        '';

        example = "yourGroup";
        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "127.0.0.1";
        description = "Address or hostname to listen on. Defaults to 127.0.0.1.";
        type = lib.types.str;
      };

      listenPort = lib.mkOption {
        default = 3000;
        description = "Port to listen on.";
        type = lib.types.port;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open port in the firewall.";
        type = lib.types.bool;
      };

      spaceDir = lib.mkOption {
        default = defaultSpaceDir;

        description = ''
          Folder to store Silverbullet's space/workspace.
          By default it is located at `${defaultSpaceDir}`.
        '';

        example = "/home/yourUser/silverbullet";
        type = lib.types.path;
      };

      user = lib.mkOption {
        default = defaultUser;

        description = ''
          The user to run Silverbullet as.
          By default, a user named `${defaultUser}` will be created whose space
          directory is [spaceDir](#opt-services.silverbullet.spaceDir).
        '';

        example = "yourUser";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };

    systemd.services.silverbullet = {
      after = [ "network.target" ];
      description = "Silverbullet service";
      preStart = lib.mkIf (!lib.hasPrefix "/var/lib/" cfg.spaceDir) "mkdir -p '${cfg.spaceDir}'";

      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.envFile != null) "${cfg.envFile}";

        ExecStart =
          "${lib.getExe cfg.package} --port ${toString cfg.listenPort} --hostname '${cfg.listenAddress}' '${cfg.spaceDir}' "
          + lib.concatStringsSep " " cfg.extraArgs;

        Group = "${cfg.group}";
        Restart = "on-failure";

        StateDirectory = lib.mkIf (lib.hasPrefix "/var/lib/" cfg.spaceDir) (
          lib.last (lib.splitString "/" cfg.spaceDir)
        );

        Type = "simple";
        User = "${cfg.user}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${defaultGroup} = lib.mkIf (cfg.group == defaultGroup) { };

    users.users.${defaultUser} = lib.mkIf (cfg.user == defaultUser) {
      description = "Silverbullet daemon user";
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ aorith ];
}
