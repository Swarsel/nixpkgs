{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.garage;
  toml = pkgs.formats.toml { };
  configFile = toml.generate "garage.toml" cfg.settings;
in
{
  options.services.garage = {
    enable = mkEnableOption "Garage Object Storage (S3 compatible)";

    package = mkOption {
      description = "Garage package to use, needs to be set explicitly. If you are upgrading from a major version, please read NixOS and Garage release notes for upgrade instructions.";
      type = types.package;
    };

    environmentFile = mkOption {
      default = null;
      description = "File containing environment variables to be passed to the Garage server.";
      type = types.nullOr types.path;
    };

    extraEnvironment = mkOption {
      default = { };
      description = "Extra environment variables to pass to the Garage server.";

      example = {
        RUST_BACKTRACE = "yes";
      };

      type = types.attrsOf types.str;
    };

    logLevel = mkOption {
      default = "info";
      description = "Garage log level, see <https://garagehq.deuxfleurs.fr/documentation/quick-start/#launching-the-garage-server> for examples.";
      example = "debug";

      type = types.enum [
        "error"
        "warn"
        "info"
        "debug"
        "trace"
      ];
    };

    settings = mkOption {
      description = "Garage configuration, see <https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/> for reference.";

      type = types.submodule {
        options = {
          data_dir = mkOption {
            default = "/var/lib/garage/data";

            description = ''
              The directory in which Garage will store the data blocks of objects. This folder can be placed on an HDD.
              Since v0.9.0, Garage supports multiple data directories, refer to <https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/#data_dir> for the exact format.
            '';

            example = [
              {
                capacity = "2T";
                path = "/var/lib/garage/data";
              }
            ];

            type = with types; either path (listOf attrs);
          };

          metadata_dir = mkOption {
            default = "/var/lib/garage/meta";
            description = "The metadata directory, put this on a fast disk (e.g. SSD) if possible.";
            type = types.path;
          };
        };

        freeformType = toml.type;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."garage.toml" = {
      source = configFile;
    };

    # For administration
    environment.systemPackages = [
      (pkgs.writeScriptBin "garage" ''
        # make it so all future variables set are automatically exported as environment variables
        set -a

        # source the set environmentFile (since systemd EnvironmentFile is supposed to be a minor subset of posix sh parsing) (with shell arg escaping to avoid quoting issues)
        [ -f ${lib.escapeShellArg cfg.environmentFile} ] && . ${lib.escapeShellArg cfg.environmentFile}

        # exec the program with quoted args (also with shell arg escaping for the program path to avoid quoting issues there)
        exec ${lib.escapeShellArg (lib.getExe cfg.package)} "$@"
      '')
    ];

    systemd.services.garage = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "Garage Object Storage (S3 compatible)";

      environment = {
        RUST_LOG = lib.mkDefault "garage=${cfg.logLevel}";
      }
      // cfg.extraEnvironment;

      restartTriggers = [
        configFile
      ]
      ++ (lib.optional (cfg.environmentFile != null) cfg.environmentFile);

      serviceConfig =
        let
          paths = lib.flatten (
            with cfg.settings;
            [
              metadata_dir
            ]
            # data_dir can either be a string or a list of attrs
            # if data_dir is a list, the actual path will in in the `path` attribute of each item
            # see https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/#data_dir
            ++ lib.optional (lib.isList data_dir) (map (item: item.path) data_dir)
            ++ lib.optional (lib.isString data_dir) [ data_dir ]
          );
          isDefault = lib.hasPrefix "/var/lib/garage";
          isDefaultStateDirectory = lib.any isDefault paths;
        in
        {
          DynamicUser = lib.mkDefault true;
          EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = "${cfg.package}/bin/garage server";
          # Upstream recommendation https://garagehq.deuxfleurs.fr/documentation/cookbook/systemd/
          LimitNOFILE = 42000;
          NoNewPrivileges = true;
          ProtectHome = true;
          ReadWritePaths = lib.filter (x: !(isDefault x)) (lib.flatten [ paths ]);
          StateDirectory = lib.mkIf isDefaultStateDirectory "garage";
        };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network.target"
        "network-online.target"
      ];
    };
  };

  meta = {
    doc = ./garage.md;

    maintainers = with lib.maintainers; [
      mjm
      cything
    ];
  };
}
