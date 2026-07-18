{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.owncast;
in
{

  options.services.owncast = {

    enable = lib.mkEnableOption "owncast, a video live streaming solution";

    dataDir = lib.mkOption {
      default = "/var/lib/owncast";

      description = ''
        The directory where owncast stores its data files. If left as the default value this directory will automatically be created before the owncast server starts, otherwise the sysadmin is responsible for ensuring the directory exists with appropriate ownership and permissions.
      '';

      type = lib.types.str;
    };

    group = lib.mkOption {
      default = "owncast";
      description = "Group under which owncast runs.";
      type = lib.types.str;
    };

    listen = lib.mkOption {
      default = "127.0.0.1";
      description = "The IP address to bind the owncast web server to.";
      example = "0.0.0.0";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open the appropriate ports in the firewall for owncast.
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 8080;

      description = ''
        TCP port where owncast web-gui listens.
      '';

      type = lib.types.port;
    };

    rtmp-port = lib.mkOption {
      default = 1935;

      description = ''
        TCP port where owncast rtmp service listens.
      '';

      type = lib.types.port;
    };

    user = lib.mkOption {
      default = "owncast";
      description = "User account under which owncast runs.";
      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.rtmp-port ] ++ lib.optional (cfg.listen != "127.0.0.1") cfg.port;
    };

    systemd.services.owncast = {
      description = "A self-hosted live video and web chat server";

      serviceConfig = lib.mkMerge [
        {
          ExecStart = "${pkgs.owncast}/bin/owncast -webserverport ${toString cfg.port} -rtmpport ${toString cfg.rtmp-port} -webserverip ${cfg.listen}";
          Group = cfg.group;
          Restart = "on-failure";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        }
        (lib.mkIf (cfg.dataDir == "/var/lib/owncast") {
          StateDirectory = "owncast";
        })
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "owncast") { owncast = { }; };

    users.users = lib.mkIf (cfg.user == "owncast") {
      owncast = {
        description = "owncast system user";
        group = cfg.group;
        isSystemUser = true;
      };
    };

  };

  meta = {
    maintainers = with lib.maintainers; [ MayNiklas ];
  };
}
