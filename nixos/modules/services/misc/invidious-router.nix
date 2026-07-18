{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.invidious-router;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options.services.invidious-router = {
    enable = lib.mkEnableOption "the invidious-router service";
    package = lib.mkPackageOption pkgs "invidious-router" { };

    address = lib.mkOption {
      default = "127.0.0.1";

      description = ''
        Address on which invidious-router should listen on.
      '';

      type = lib.types.str;
    };

    nginx = {
      enable = lib.mkEnableOption ''
        Automatic nginx proxy configuration
      '';

      domain = lib.mkOption {
        description = ''
          The domain on which invidious-router should be served.
        '';

        example = "invidious-router.example.com";
        type = lib.types.str;
      };

      extraDomains = lib.mkOption {
        default = [ ];

        description = ''
          Additional domains to serve invidious-router on.
        '';

        type = lib.types.listOf lib.types.str;
      };
    };

    port = lib.mkOption {
      default = 8050;

      description = ''
        Port to bind to.
      '';

      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = {
        api = {
          allowed_regions = [
            "AT"
            "DE"
            "CH"
          ];

          enabled = true;
          filter_regions = true;
          url = "https://api.invidious.io/instances.json";
        };

        app = {
          enable_youtube_fallback = false;
          listen = "127.0.0.1:8050";
          reload_instance_list_interval = "60s";
        };

        healthcheck = {
          allowed_status_codes = [
            200
          ];

          filter_by_response_time = {
            enabled = true;
            qty_of_top_results = 3;
          };

          interval = "10s";
          minimum_ratio = 0.2;
          path = "/";
          remove_no_ratio = true;
          text_not_present = "YouTube is currently trying to block Invidious instances";
          timeout = "1s";
        };
      };

      description = ''
        Configuration for invidious-router.
        Check <https://gitlab.com/gaincoder/invidious-router#configuration>
        for configuration options.
      '';

      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = lib.mkIf cfg.nginx.enable {
      ${cfg.nginx.domain} = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://${cfg.address}:${toString cfg.port}";
          recommendedProxySettings = true;
        };

        serverAliases = cfg.nginx.extraDomains;
      };
    };

    systemd.services.invidious-router = {
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        DynamicUser = "yes";
        ExecStart = "${lib.getExe cfg.package} --configfile ${configFile}";
        Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.sils ];
}
