{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.whitebophir;
in
{
  options = {
    services.whitebophir = {
      enable = mkEnableOption "whitebophir, an online collaborative whiteboard server (persistent state will be maintained under {file}`/var/lib/whitebophir`)";
      package = mkPackageOption pkgs "whitebophir" { };

      listenAddress = mkOption {
        default = "0.0.0.0";
        description = "Address to listen on (use 0.0.0.0 to allow access from any address).";
        type = types.str;
      };

      port = mkOption {
        default = 5001;
        description = "Port to bind to.";
        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.whitebophir = {
      after = [ "network.target" ];
      description = "Whitebophir Service";

      environment = {
        HOST = toString cfg.listenAddress;
        PORT = toString cfg.port;
        WBO_HISTORY_DIR = "/var/lib/whitebophir";
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/whitebophir";
        Restart = "always";
        StateDirectory = "whitebophir";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
