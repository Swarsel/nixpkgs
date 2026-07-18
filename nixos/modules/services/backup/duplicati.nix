{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.duplicati;

  parametersFile =
    if cfg.parametersFile != null then
      cfg.parametersFile
    else
      pkgs.writeText "duplicati-parameters" cfg.parameters;
in
{
  options = {
    services.duplicati = {
      enable = lib.mkEnableOption "Duplicati";
      package = lib.mkPackageOption pkgs "duplicati" { };

      dataDir = lib.mkOption {
        default = "/var/lib/duplicati";

        description = ''
          The directory where Duplicati stores its data files.

          ::: {.note}
          If left as the default value this directory will automatically be created
          before the Duplicati server starts, otherwise you are responsible for ensuring
          the directory exists with appropriate ownership and permissions.
          :::
        '';

        type = lib.types.str;
      };

      interface = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          Listening interface for the web UI
          Set it to "any" to listen on all available interfaces
        '';

        type = lib.types.str;
      };

      parameters = lib.mkOption {
        default = "";

        description = ''
          This option can be used to store some or all of the options given to the
          commandline client.
          Each line in this option should be of the format --option=value.
          The options in this file take precedence over the options provided
          through command line arguments.
          [Duplicati docs: parameters-file](https://duplicati.readthedocs.io/en/latest/06-advanced-options/#parameters-file)
        '';

        example = ''
          --webservice-allowedhostnames=*
        '';

        type = lib.types.lines;
      };

      parametersFile = lib.mkOption {
        default = null;

        description = ''
          This file can be used to store some or all of the options given to the
          commandline client.
          Each line in the file option should be of the format --option=value.
          The options in this file take precedence over the options provided
          through command line arguments.
          [Duplicati docs: parameters-file](https://duplicati.readthedocs.io/en/latest/06-advanced-options/#parameters-file)
        '';

        type = lib.types.nullOr lib.types.path;
      };

      port = lib.mkOption {
        default = 8200;

        description = ''
          Port serving the web interface
        '';

        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "duplicati";

        description = ''
          Duplicati runs as it's own user. It will only be able to backup world-readable files.
          Run as root with special care.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.parametersFile != null && cfg.parameters != "");
        message = "cannot set both services.duplicati.parameters and services.duplicati.parametersFile at the same time";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.services.duplicati = {
      after = [ "network.target" ];
      description = "Duplicati backup";

      serviceConfig = lib.mkMerge [
        {
          ExecStart = "${cfg.package}/bin/duplicati-server --webservice-interface=${cfg.interface} --webservice-port=${toString cfg.port} --server-datafolder=${cfg.dataDir} --parameters-file=${parametersFile}";
          Group = "duplicati";
          Restart = "on-failure";
          User = cfg.user;
        }
        (lib.mkIf (cfg.dataDir == "/var/lib/duplicati") {
          StateDirectory = "duplicati";
        })
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.duplicati.gid = config.ids.gids.duplicati;

    users.users = lib.optionalAttrs (cfg.user == "duplicati") {
      duplicati = {
        group = "duplicati";
        home = cfg.dataDir;
        uid = config.ids.uids.duplicati;
      };
    };

  };
}
