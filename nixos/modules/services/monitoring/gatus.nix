{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gatus;

  settingsFormat = pkgs.formats.yaml { };

  inherit (lib)
    getExe
    literalExpression
    maintainers
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    ;

  inherit (lib.types)
    bool
    int
    nullOr
    path
    submodule
    ;
in
{
  options.services.gatus = {
    enable = mkEnableOption "Gatus";
    package = mkPackageOption pkgs "gatus" { };

    configFile = mkOption {
      default = settingsFormat.generate "gatus.yaml" cfg.settings;
      defaultText = literalExpression ''(pkgs.formats.yaml { }).generate "gatus.yaml" config.services.gatus.settings'';

      description = ''
        Path to the Gatus configuration file.
        Overrides any configuration made using the `settings` option.
      '';

      type = path;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        File to load as environment file.
        Environmental variables from this file can be interpolated in the configuration file using `''${VARIABLE}`.
        This is useful to avoid putting secrets into the nix store.
      '';

      type = nullOr path;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Whether to open the firewall for the Gatus web interface.
      '';

      type = bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for Gatus.
        Supported options can be found at the [docs](https://gatus.io/docs).
      '';

      example = literalExpression ''
        {
          web.port = 8080;
          endpoints = [{
            name = "website";
            url = "https://twin.sh/health";
            interval = "5m";
            conditions = [
              "[STATUS] == 200"
              "[BODY].status == UP"
              "[RESPONSE_TIME] < 300"
            ];
          }];
        }
      '';

      type = submodule {
        options = {
          web.port = mkOption {
            default = 8080;

            description = ''
              The TCP port to serve the Gatus service at.
            '';

            type = int;
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ cfg.settings.web.port ];

    systemd.services.gatus = {
      after = [ "network-online.target" ];
      description = "Automated developer-oriented status page";

      environment = {
        GATUS_CONFIG_PATH = cfg.configFile;
      };

      requires = [ "network-online.target" ];

      serviceConfig = {
        # see https://github.com/prometheus-community/pro-bing#linux
        AmbientCapabilities = "CAP_NET_RAW";
        CapabilityBoundingSet = "CAP_NET_RAW";
        DynamicUser = true;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = getExe cfg.package;
        Group = "gatus";
        NoNewPrivileges = true;
        Restart = "on-failure";
        StateDirectory = "gatus";
        SyslogIdentifier = "gatus";
        Type = "simple";
        User = "gatus";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ pizzapim ];
}
