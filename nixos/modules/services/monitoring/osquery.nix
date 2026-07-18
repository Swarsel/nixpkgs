{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.osquery;
  dirname =
    path:
    with lib.strings;
    with lib.lists;
    concatStringsSep "/" (init (splitString "/" (normalizePath path)));

  # conf is the osquery configuration file used when the --config_plugin=filesystem.
  # filesystem is the osquery default value for the config_plugin flag.
  conf = pkgs.writeText "osquery.conf" (builtins.toJSON cfg.settings);

  # flagfile is the file containing osquery command line flags to be
  # provided to the application using the special --flagfile option.
  flagfile = pkgs.writeText "osquery.flags" (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "--${name}=${value}")
        # Use the conf derivation if not otherwise specified.
        ({ config_path = conf; } // cfg.flags)
    )
  );
  osquery = cfg.package;
  osqueryi = pkgs.runCommand "osqueryi" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${osquery}/bin/osqueryi $out/bin/osqueryi \
      --add-flags "--flagfile ${flagfile} --disable-database"
  '';

in
{
  options.services.osquery = {
    enable = lib.mkEnableOption "osqueryd daemon";
    package = lib.mkPackageOption pkgs "osquery" { };

    flags = lib.mkOption {
      default = { };

      description = ''
        Attribute set of flag names and values to be written to the osqueryd flagfile.
        For more information, refer to <https://osquery.readthedocs.io/en/stable/installation/cli-flags>.
      '';

      example = {
        config_refresh = "10";
      };

      type =
        with lib.types;
        submodule {
          options = {
            database_path = lib.mkOption {
              default = "/var/lib/osquery/osquery.db";

              description = ''
                Path used for the database file.

                ::: {.note}
                If left as the default value, this directory will be automatically created before the
                service starts, otherwise you are responsible for ensuring the directory exists with
                the appropriate ownership and permissions.
              '';

              readOnly = true;
              type = path;
            };

            logger_path = lib.mkOption {
              default = "/var/log/osquery";

              description = ''
                Base directory used for logging.

                ::: {.note}
                If left as the default value, this directory will be automatically created before the
                service starts, otherwise you are responsible for ensuring the directory exists with
                the appropriate ownership and permissions.
              '';

              readOnly = true;
              type = path;
            };

            pidfile = lib.mkOption {
              default = "/run/osquery/osqueryd.pid";
              description = "Path used for pid file.";
              readOnly = true;
              type = path;
            };
          };

          freeformType = attrsOf str;
        };
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration to be written to the osqueryd JSON configuration file.
        To understand the configuration format, refer to <https://osquery.readthedocs.io/en/stable/deployment/configuration/#configuration-components>.
      '';

      example = {
        options.utc = false;
      };

      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ osqueryi ];

    systemd.services.osqueryd = {
      after = [
        "network.target"
        "syslog.service"
      ];

      description = "The osquery daemon";

      serviceConfig = {
        ExecStart = "${osquery}/bin/osqueryd --flagfile ${flagfile}";
        LogsDirectory = lib.mkIf (cfg.flags.logger_path == "/var/log/osquery") [ "osquery" ];
        PIDFile = cfg.flags.pidfile;
        Restart = "always";
        StateDirectory = lib.mkIf (cfg.flags.database_path == "/var/lib/osquery/osquery.db") [ "osquery" ];
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-osquery".${dirname cfg.flags.pidfile}.d = {
      group = "root";
      mode = "0755";
      user = "root";
    };
  };
}
