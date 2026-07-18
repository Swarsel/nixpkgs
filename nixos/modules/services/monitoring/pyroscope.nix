{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.pyroscope;
  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.pyroscope = {
    enable = lib.mkEnableOption "Pyroscope";
    package = lib.mkPackageOption pkgs "pyroscope" { };

    configFile = lib.mkOption {
      default = null;
      description = "Specify a path to a configuration file that Pyroscope should use.";
      type = lib.types.nullOr lib.types.path;
    };

    extraFlags = lib.mkOption {
      default = [ ];
      description = "Additional arguments to pass to pyroscope";
      type = lib.types.listOf lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether or not to open the firewall for this service";
      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Specify the configuration for Pyroscope in Nix.

        See <https://grafana.com/docs/pyroscope/latest/configure-server/reference-configuration-parameters/> for available options.
      '';

      type = lib.types.submodule {
        options = {
          server = {
            http_listen_address = lib.mkOption {
              default = "127.0.0.1";
              description = "The server listen address";
              type = lib.types.str;
            };

            http_listen_port = lib.mkOption {
              default = 4040;
              description = "The port that Pyroscope should run on";
              type = lib.types.port;
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = ((cfg.settings == { }) != (cfg.configFile == null));

        message = ''
          Please specify a configuration for Pyroscope with either
          'services.pyroscope.settings' or
          'services.pyroscope.configFile'.
        '';
      }
    ];

    # Pyroscope and it's CLI
    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.settings.server.http_listen_port
    ];

    systemd.services.pyroscope = {
      after = [ "network.target" ];
      description = "Grafana Pyroscope Service Daemon";

      serviceConfig =
        let
          conf =
            if cfg.configFile == null then
              settingsFormat.generate "config.yaml" cfg.settings
            else
              cfg.configFile;
        in
        {
          DevicePolicy = "closed";
          DynamicUser = true;

          ExecStart = utils.escapeSystemdExecArgs (
            [
              "${lib.getExe cfg.package}"
              "--config.file=${conf}"
            ]
            ++ cfg.extraFlags
          );

          ProtectSystem = "full";
          Restart = "on-failure";
          StateDirectory = "pyroscope";
          WorkingDirectory = "/var/lib/pyroscope";
        };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = [ lib.maintainers.kashw2 ];

}
