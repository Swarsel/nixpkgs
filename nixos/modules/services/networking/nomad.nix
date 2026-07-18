{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.nomad;
  format = pkgs.formats.json { };
in
{
  ##### interface
  options = {
    services.nomad = {
      enable = mkEnableOption "Nomad, a distributed, highly available, datacenter-aware scheduler";
      package = mkPackageOption pkgs "nomad" { };

      credentials = mkOption {
        default = { };

        description = ''
          Credentials envs used to configure nomad secrets.
        '';

        example = {
          logs_remote_write_password = "/run/keys/nomad_write_password";
        };

        type = types.attrsOf types.str;
      };

      dropPrivileges = mkOption {
        default = true;

        description = ''
          Whether the nomad agent should be run as a non-root nomad user.
        '';

        type = types.bool;
      };

      enableDocker = mkOption {
        default = true;

        description = ''
          Enable Docker support. Needed for Nomad's docker driver.

          Note that the docker group membership is effectively equivalent
          to being root, see <https://github.com/moby/moby/issues/9976>.
        '';

        type = types.bool;
      };

      extraPackages = mkOption {
        default = [ ];

        description = ''
          Extra packages to add to {env}`PATH` for the Nomad agent process.
        '';

        example = literalExpression ''
          with pkgs; [ cni-plugins ]
        '';

        type = types.listOf types.package;
      };

      extraSettingsPaths = mkOption {
        default = [ ];

        description = ''
          Additional settings paths used to configure nomad. These can be files or directories.
        '';

        example = literalExpression ''
          [ "/etc/nomad-mutable.json" "/run/keys/nomad-with-secrets.json" "/etc/nomad/config.d" ]
        '';

        type = types.listOf types.path;
      };

      extraSettingsPlugins = mkOption {
        default = [ ];

        description = ''
          Additional plugins dir used to configure nomad.
        '';

        example = literalExpression ''
          [ "<pluginDir>" pkgs.nomad-driver-nix pkgs.nomad-driver-podman  ]
        '';

        type = types.listOf (types.either types.package types.path);
      };

      settings = mkOption {
        default = { };

        description = ''
          Configuration for Nomad. See the [documentation](https://www.nomadproject.io/docs/configuration)
          for supported values.

          Notes about `data_dir`:

          If `data_dir` is set to a value other than the
          default value of `"/var/lib/nomad"` it is the Nomad
          cluster manager's responsibility to make sure that this directory
          exists and has the appropriate permissions.

          Additionally, if `dropPrivileges` is
          `true` then `data_dir`
          *cannot* be customized. Setting
          `dropPrivileges` to `true` enables
          the `DynamicUser` feature of systemd which directly
          manages and operates on `StateDirectory`.
        '';

        example = literalExpression ''
          {
            # A minimal config example:
            server = {
              enabled = true;
              bootstrap_expect = 1; # for demo; no fault tolerance
            };
            client = {
              enabled = true;
            };
          }
        '';

        type = format.type;
      };
    };
  };

  ##### implementation
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.dropPrivileges -> cfg.settings.data_dir == "/var/lib/nomad";
        message = "settings.data_dir must be equal to \"/var/lib/nomad\" if dropPrivileges is true";
      }
    ];

    environment = {
      etc."nomad.json".source = format.generate "nomad.json" cfg.settings;
      systemPackages = [ cfg.package ];
    };

    services.nomad.settings = {
      # Agrees with `StateDirectory = "nomad"` set below.
      data_dir = mkDefault "/var/lib/nomad";
    };

    systemd.services.nomad = {
      after = [ "network-online.target" ];
      description = "Nomad";

      path =
        cfg.extraPackages
        ++ (with pkgs; [
          # Client mode requires at least the following:
          coreutils
          iproute2
          iptables
        ]);

      restartTriggers = [ config.environment.etc."nomad.json".source ];

      serviceConfig = mkMerge [
        {
          DynamicUser = cfg.dropPrivileges;
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

          ExecStart =
            let
              pluginsDir = pkgs.symlinkJoin {
                name = "nomad-plugins";
                paths = cfg.extraSettingsPlugins;
              };
            in
            "${cfg.package}/bin/nomad agent -config=/etc/nomad.json -plugin-dir=${pluginsDir}/bin"
            + concatMapStrings (path: " -config=${path}") cfg.extraSettingsPaths
            + concatMapStrings (key: " -config=\${CREDENTIALS_DIRECTORY}/${key}") (
              lib.attrNames cfg.credentials
            );

          KillMode = "process";
          KillSignal = "SIGINT";
          LimitNOFILE = 65536;
          LimitNPROC = "infinity";
          LoadCredential = lib.mapAttrsToList (key: value: "${key}:${value}") cfg.credentials;
          OOMScoreAdjust = -1000;
          Restart = "on-failure";
          RestartSec = 2;
          TasksMax = "infinity";
        }
        (mkIf cfg.enableDocker {
          SupplementaryGroups = "docker"; # space-separated string
        })
        (mkIf (cfg.settings.data_dir == "/var/lib/nomad") {
          StateDirectory = "nomad";
        })
      ];

      unitConfig = {
        StartLimitBurst = 3;
        StartLimitIntervalSec = 10;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    # Docker support requires the Docker daemon to be running.
    virtualisation.docker.enable = mkIf cfg.enableDocker true;
  };
}
