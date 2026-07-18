{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.vector;
in
{
  options.services.vector = {
    enable = lib.mkEnableOption "Vector, a high-performance observability data pipeline";
    package = lib.mkPackageOption pkgs "vector" { };

    gracefulShutdownLimitSecs = lib.mkOption {
      default = 60;

      description = ''
        Set the duration in seconds to wait for graceful shutdown after SIGINT or SIGTERM are received.
        After the duration has passed, Vector will force shutdown.
      '';

      type = lib.types.ints.positive;
    };

    journaldAccess = lib.mkOption {
      default = false;

      description = ''
        Enable Vector to access journald.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Specify the configuration for Vector in Nix.
      '';

      type = (pkgs.formats.json { }).type;
    };

    validateConfig = lib.mkOption {
      default = true;

      description = ''
        Enable the checking of the vector config during build time. This should be disabled when interpolating environment variables.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    # for cli usage
    environment.systemPackages = [ cfg.package ];

    systemd.services.vector = {
      after = [ "network-online.target" ];
      description = "Vector event and log aggregator";
      requires = [ "network-online.target" ];

      serviceConfig =
        let
          format = pkgs.formats.toml { };
          conf = format.generate "vector.toml" cfg.settings;
          validatedConfig =
            file:
            pkgs.runCommand "validate-vector-conf"
              {
                nativeBuildInputs = [ cfg.package ];
              }
              ''
                vector validate --no-environment "${file}"
                ln -s "${file}" "$out"
              '';
        in
        {
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          DynamicUser = true;
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

          ExecStart = "${lib.getExe cfg.package} --config ${
            if cfg.validateConfig then (validatedConfig conf) else conf
          }  --graceful-shutdown-limit-secs ${toString cfg.gracefulShutdownLimitSecs}";

          Restart = "always";
          StateDirectory = "vector";
          # This group is required for accessing journald.
          SupplementaryGroups = lib.mkIf cfg.journaldAccess "systemd-journal";
        };

      unitConfig = {
        StartLimitBurst = 5;
        StartLimitIntervalSec = 10;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
