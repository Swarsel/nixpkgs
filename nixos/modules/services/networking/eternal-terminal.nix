{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.eternal-terminal;

in

{

  ###### interface

  options = {

    services.eternal-terminal = {

      enable = lib.mkEnableOption "Eternal Terminal server";

      logSize = lib.mkOption {
        default = 20971520;

        description = ''
          The maximum log size.
        '';

        type = lib.types.int;
      };

      port = lib.mkOption {
        default = 2022;

        description = ''
          The port the server should listen on. Will use the server's default (2022) if not specified.

          Make sure to open this port in the firewall if necessary.
        '';

        type = lib.types.port;
      };

      silent = lib.mkOption {
        default = false;

        description = ''
          If enabled, disables all logging.
        '';

        type = lib.types.bool;
      };

      verbosity = lib.mkOption {
        default = 0;

        description = ''
          The verbosity level (0-9).
        '';

        type = lib.types.enum (lib.range 0 9);
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    # We need to ensure the et package is fully installed because
    # the (remote) et client runs the `etterminal` binary when it
    # connects.
    environment.systemPackages = [ pkgs.eternal-terminal ];

    systemd.services = {
      eternal-terminal = {
        after = [ "network.target" ];
        description = "Eternal Terminal server.";

        serviceConfig = {
          ExecStart = "${pkgs.eternal-terminal}/bin/etserver --daemon --cfgfile=${pkgs.writeText "et.cfg" ''
            ; et.cfg : Config file for Eternal Terminal
            ;

            [Networking]
            port = ${toString cfg.port}

            [Debug]
            verbose = ${toString cfg.verbosity}
            silent = ${if cfg.silent then "1" else "0"}
            logsize = ${toString cfg.logSize}
          ''}";

          KillMode = "process";
          Restart = "on-failure";
          Type = "forking";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
  };

  meta = {
    maintainers = [ ];
  };
}
