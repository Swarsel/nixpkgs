{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = cfgTaler.merchant;
  cfgTaler = config.services.taler;

  talerComponent = "merchant";

  # https://docs.taler.net/taler-merchant-manual.html#launching-the-backend
  servicesDB = [
    "httpd"
    "webhook"
    "wirewatch"
    "depositcheck"
    "exchangekeyupdate"
  ];

  configFile = config.environment.etc."taler/taler.conf".source;
in
{
  imports = [
    (import ./common.nix { inherit talerComponent servicesDB; })
  ];

  options.services.taler.merchant = {
    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration options for the taler merchant config file.

        For a list of all possible options, please see the man page [`taler-merchant.conf(5)`](https://docs.taler.net/manpages/taler-merchant.conf.5.html)
      '';

      type = lib.types.submodule {
        inherit (options.services.taler.settings.type.nestedTypes) freeformType;

        options = {
          merchant = {
            DB = lib.mkOption {
              default = "postgres";
              description = "Plugin to use for the database.";
              type = lib.types.enum [ "postgres" ];
            };

            LEGAL_PRESERVATION = lib.mkOption {
              default = "10 years";
              description = "How long to keep data in the database for tax audits after the transaction has completed.";
              type = lib.types.str;
            };

            PORT = lib.mkOption {
              default = 8083;
              description = "Port on which the HTTP server listens.";
              type = lib.types.port;
            };

            SERVE = lib.mkOption {
              default = "tcp";

              description = ''
                Whether the HTTP server should listen on a UNIX domain socket ("unix") or on a TCP socket ("tcp").
              '';

              type = lib.types.enum [
                "tcp"
                "unix"
              ];
            };
          };

          merchantdb-postgres = {
            CONFIG = lib.mkOption {
              default = "postgres:///taler-merchant-httpd";
              description = "Database connection URI.";
              type = lib.types.nonEmptyStr;
            };

            SQL_DIR = lib.mkOption {
              default = "${cfg.package}/share/taler/sql/merchant/";
              description = "The location for the SQL files to setup the database tables.";
              internal = true;
              type = lib.types.str;
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."taler-${talerComponent}-dbinit".script = ''
      ${lib.getExe' cfg.package "taler-merchant-dbinit"} -c ${configFile}
    '';

    systemd.services.taler-merchant-depositcheck = {
      # taler-merchant-depositcheck needs its executable is in the PATH
      # NOTE: couldn't use `lib.getExe` to only get that single executable
      path = [ cfg.package ];
    };
  };
}
