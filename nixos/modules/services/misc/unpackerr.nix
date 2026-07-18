{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.unpackerr;
  configFormat = pkgs.formats.toml { };
  configFile = configFormat.generate "unpackerr.conf" cfg.settings;
  inherit (lib)
    mkEnableOption
    mkOption
    mkPackageOption
    mkIf
    getExe
    types
    ;
in
{
  options = {
    services.unpackerr = {
      enable = mkEnableOption "Unpackerr";
      package = mkPackageOption pkgs "unpackerr" { };

      group = mkOption {
        default = "unpackerr";
        description = "Group under which Unpackerr runs.";
        type = types.str;
      };

      settings = mkOption {
        default = { };

        description = ''
          Unpackerr TOML configuration as a Nix attribute set.
          Refer to [Unpackerr docs](https://unpackerr.zip/docs/install/configuration) for details.
          For setting secrets refer to this [section](https://unpackerr.zip/docs/install/configuration/#secrets-and-passwords).
        '';

        example = {
          radarr = [
            {
              api_key = "0123456789abcdef0123456789abcdef";
              url = "http://127.0.0.1:8989";
            }
          ];

          sonarr = [
            {
              api_key = "0123456789abcdef0123456789abcdef";
              url = "http://127.0.0.1:7878";
            }
          ];
        };

        type = configFormat.type;
      };

      user = mkOption {
        default = "unpackerr";
        description = "User account under which Unpackerr runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    # Upstream service: https://github.com/Unpackerr/unpackerr/blob/main/init/systemd/unpackerr.service
    systemd = {
      services.unpackerr = {
        after = [ "network.target" ];
        description = "Unpackerr - archive extraction daemon";

        serviceConfig = {
          ExecStart = utils.escapeSystemdExecArgs [
            (getExe cfg.package)
            "--config=${configFile}"
          ];

          Group = cfg.group;
          Restart = "always";
          RestartSec = 10;
          Type = "exec";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network.target" ];
      };
    };

    users.groups = mkIf (cfg.group == "unpackerr") {
      unpackerr = { };
    };

    users.users = mkIf (cfg.user == "unpackerr") {
      unpackerr = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ Wekuz ];
}
