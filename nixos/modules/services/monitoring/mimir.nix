{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    escapeShellArgs
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.mimir;

  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.mimir = {
    enable = mkEnableOption "mimir";
    package = mkPackageOption pkgs "mimir" { };

    configFile = mkOption {
      default = null;

      description = ''
        Specify a configuration file that Mimir should use.
      '';

      type = types.nullOr types.path;
    };

    configuration = mkOption {
      default = { };

      description = ''
        Specify the configuration for Mimir in Nix.
      '';

      type = (pkgs.formats.json { }).type;
    };

    extraFlags = mkOption {
      default = [ ];

      description = ''
        Specify a list of additional command line flags,
        which get escaped and are then passed to Mimir.
      '';

      example = [ "--config.expand-env=true" ];
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (
          (cfg.configuration == { } -> cfg.configFile != null)
          && (cfg.configFile != null -> cfg.configuration == { })
        );

        message = ''
          Please specify either
          'services.mimir.configuration' or
          'services.mimir.configFile'.
        '';
      }
    ];

    # for mimirtool
    environment.systemPackages = [ cfg.package ];

    systemd.services.mimir = {
      description = "mimir Service Daemon";

      serviceConfig =
        let
          conf =
            if cfg.configFile == null then
              settingsFormat.generate "config.yaml" cfg.configuration
            else
              cfg.configFile;
        in
        {
          DevicePolicy = "closed";
          DynamicUser = true;
          ExecStart = "${cfg.package}/bin/mimir --config.file=${conf} ${escapeShellArgs cfg.extraFlags}";
          NoNewPrivileges = true;
          ProtectSystem = "full";
          Restart = "always";
          StateDirectory = "mimir";
          WorkingDirectory = "/var/lib/mimir";
        };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
