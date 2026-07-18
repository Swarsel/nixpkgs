{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.home-assistant-matter-hub;
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "home-assistant-matter-hub.json" cfg.settings;
in
{
  options.services.home-assistant-matter-hub = {
    enable = lib.mkEnableOption "home-assistant-matter-hub, a Matter bridge for Home Assistant";
    package = lib.mkPackageOption pkgs "home-assistant-matter-hub" { };

    accessTokenFile = lib.mkOption {
      description = ''
        Path to a file containing a Home Assistant long-lived access token.
        The file is loaded as a systemd credential and read into
        `HAMH_HOME_ASSISTANT_ACCESS_TOKEN` at service start.
      '';

      example = "/run/secrets/home-assistant-matter-hub-token";
      type = lib.types.externalPath;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open the Matter commissioning ports (UDP/TCP 5540) in the
        firewall.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration written to a JSON file and passed to
        `home-assistant-matter-hub start --config`. Keys use camelCase, matching
        the long-form CLI flags. See
        <https://riddix.github.io/home-assistant-matter-hub/getting-started/installation#23-configuration-options>
        for the full list of options.
      '';

      example = lib.literalExpression ''
        {
          homeAssistantUrl = config.services.home-assistant.config.homeassistant.internal_url;
        }
      '';

      type = lib.types.submodule {
        options = {
          homeAssistantUrl = lib.mkOption {
            description = "HTTP URL of the Home Assistant instance to bridge.";
            example = lib.literalExpression "config.services.home-assistant.config.homeassistant.internal_url";
            type = lib.types.str;
          };

          httpPort = lib.mkOption {
            default = 8482;
            description = "Port the web interface listens on.";
            type = lib.types.port;
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5540 ];
      allowedUDPPorts = [ 5540 ];
    };

    systemd.services.home-assistant-matter-hub = {
      after = [ "network.target" ];
      description = "Home Assistant Matter Hub";
      documentation = [ "https://riddix.github.io/home-assistant-matter-hub/" ];

      script = ''
        export HAMH_HOME_ASSISTANT_ACCESS_TOKEN=$(systemd-creds cat HAMH_HOME_ASSISTANT_ACCESS_TOKEN)
        exec ${lib.getExe cfg.package} start --config=${configFile} --storage-location="$1"
      '';

      scriptArgs = "%S/home-assistant-matter-hub";

      serviceConfig = {
        DynamicUser = true;
        LoadCredential = [ "HAMH_HOME_ASSISTANT_ACCESS_TOKEN:${cfg.accessTokenFile}" ];
        StateDirectory = "home-assistant-matter-hub";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    kranzes
    marie
  ];
}
