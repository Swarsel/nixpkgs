{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    getExe
    maintainers
    mkEnableOption
    mkOption
    mkPackageOption
    ;
  inherit (lib.types)
    str
    path
    bool
    float
    int
    package
    ;
  cfg = config.services.ersatztv;
  defaultEnv = {
    ETV_BASE_URL = "/";
    ETV_UI_PORT = 8409;
  };

in
{
  options = {
    services.ersatztv = {
      enable = mkEnableOption "ErsatzTV";
      package = mkPackageOption pkgs "ersatztv" { };

      baseUrl = mkOption {
        default = "/";

        description = ''
          Base URL to support reverse proxies that use paths (e.g. `/ersatztv`)
        '';

        type = str;
      };

      environment = mkOption {
        default = defaultEnv;
        description = "Environment variables to set for the ErsatzTV service.";

        example = {
          ETV_STREAMING_PORT = 8001;
          ETV_UI_PORT = 8000;
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            float
            bool
            path
            package
          ]);
      };

      group = mkOption {
        default = "ersatztv";
        description = "Group under which ErsatzTV runs.";
        type = str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open the default ports in the firewall for the server.
        '';

        type = bool;
      };

      user = mkOption {
        default = "ersatztv";
        description = "User account under which ErsatzTV runs.";
        type = str;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.environment.ETV_UI_PORT
      ];
    };

    services.ersatztv.environment = lib.mapAttrs (_: lib.mkDefault) defaultEnv;

    systemd = {
      services.ersatztv = {
        after = [ "network-online.target" ];
        description = "ErsatzTV";

        # Set environment variables for the service, using known values for ETV_CONFIG_FOLDER and ETV_TRANSCODE_FOLDER, and allowing overrides from cfg.environment
        environment = {
          ETV_CONFIG_FOLDER = "/var/lib/ersatztv/config";
          ETV_TRANSCODE_FOLDER = "/var/lib/ersatztv/transcode";
        }
        // (lib.mapAttrs (_: s: if lib.isBool s then lib.boolToString s else toString s) cfg.environment);

        serviceConfig = {
          DynamicUser = true;
          ExecStart = getExe cfg.package;
          Group = cfg.group;
          Restart = "on-failure";
          StateDirectory = "ersatztv";
          Type = "simple";
          UMask = "0077";
          User = cfg.user;
          WorkingDirectory = "/var/lib/ersatztv";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };
    };

    users.groups = mkIf (cfg.group == "ersatztv") { ersatztv = { }; };

    users.users = mkIf (cfg.user == "ersatztv") {
      ersatztv = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

  };

  meta.maintainers = with maintainers; [ allout58 ];
}
