{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.icecream.scheduler;
in
{

  ###### interface

  options = {

    services.icecream.scheduler = {
      enable = mkEnableOption "Icecream Scheduler";
      package = mkPackageOption pkgs "icecream" { };

      extraArgs = mkOption {
        default = [ ];
        description = "Additional command line parameters";
        example = [ "-v" ];
        type = types.listOf types.str;
      };

      netName = mkOption {
        default = null;

        description = ''
          Network name for the icecream scheduler.

          Uses the default ICECREAM if null.
        '';

        type = types.nullOr types.str;
      };

      openFirewall = mkOption {
        description = ''
          Whether to automatically open the daemon port in the firewall.
        '';

        type = types.bool;
      };

      openTelnet = mkOption {
        default = false;

        description = ''
          Whether to open the telnet TCP port on 8766.
        '';

        type = types.bool;
      };

      persistentClientConnection = mkOption {
        default = false;

        description = ''
          Whether to prevent clients from connecting to a better scheduler.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 8765;

        description = ''
          Server port to listen for icecream daemon requests.
        '';

        type = types.port;
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkMerge [
      (mkIf cfg.openFirewall [ cfg.port ])
      (mkIf cfg.openTelnet [ 8766 ])
    ];

    systemd.services.icecc-scheduler = {
      after = [ "network.target" ];
      description = "Icecream scheduling server";

      serviceConfig = {
        DynamicUser = true;

        ExecStart = escapeShellArgs (
          [
            "${getBin cfg.package}/bin/icecc-scheduler"
            "-p"
            (toString cfg.port)
          ]
          ++ optionals (cfg.netName != null) [
            "-n"
            (toString cfg.netName)
          ]
          ++ optional cfg.persistentClientConnection "-r"
          ++ cfg.extraArgs
        );
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ emantor ];
}
