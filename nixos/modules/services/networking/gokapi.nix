{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gokapi;
  settingsFormat = pkgs.formats.json { };
  userSettingsFile = settingsFormat.generate "generated-config.json" cfg.settings;
in
{
  options.services.gokapi = {
    enable = lib.mkEnableOption "Lightweight selfhosted Firefox Send alternative without public upload";
    package = lib.mkPackageOption pkgs "gokapi" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables to be set for the gokapi service. Can use systemd specifiers.
        For full list see <https://gokapi.readthedocs.io/en/latest/advanced.html#environment-variables>.
      '';

      type = lib.types.submodule {
        options = {
          GOKAPI_CONFIG_DIR = lib.mkOption {
            default = "%S/gokapi/config";
            description = "Sets the directory for the config file.";
            type = lib.types.str;
          };

          GOKAPI_CONFIG_FILE = lib.mkOption {
            default = "config.json";
            description = "Sets the filename for the config file.";
            type = lib.types.str;
          };

          GOKAPI_DATA_DIR = lib.mkOption {
            default = "%S/gokapi/data";
            description = "Sets the directory for the data.";
            type = lib.types.str;
          };

          GOKAPI_PORT = lib.mkOption {
            default = 53842;
            description = "Sets the port of the service.";
            type = lib.types.port;
          };
        };

        freeformType = lib.types.attrsOf (lib.types.either lib.types.str lib.types.int);
      };
    };

    mutableSettings = lib.mkOption {
      default = true;

      description = ''
        Allow changes to the program config made by the program to persist between restarts.
        If disabled all required values must be set using nix, and all changes to config format over application updates must be resolved by user.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration settings for the generated config json file.
        See <https://gokapi.readthedocs.io/en/latest/advanced.html#config-json> for more information
      '';

      type = lib.types.submodule {
        options = { };
        freeformType = settingsFormat.type;
      };
    };

    settingsFile = lib.mkOption {
      default = null;

      description = ''
        Path to config file to parse and append to settings.
        Largely useful for loading secrets from a file not in the nix store. Can use systemd specifiers.
        See <https://gokapi.readthedocs.io/en/latest/advanced.html#config-json> for more information
      '';

      type = lib.types.nullOr lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {
    systemd.services.gokapi = {
      after = [ "network-online.target" ];
      environment = lib.mapAttrs (_: value: toString value) cfg.environment;

      serviceConfig = {
        CacheDirectory = "gokapi";
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;

        ExecStartPre =
          let
            updateScript = lib.getExe (
              pkgs.writeShellApplication {
                name = "merge-config";
                runtimeInputs = with pkgs; [ jq ];

                text = ''
                  echo "Running merge-config"
                  mutableSettings="$1"
                  statefulSettingsFile="$2"
                  settingsFile="$3"
                  if [[ "$mutableSettings" == true ]]; then
                    if [[ -f "$statefulSettingsFile" ]]; then
                      echo "Updating stateful config file"
                      merged="$(jq -s '.[0] * .[1]' "$statefulSettingsFile" ${userSettingsFile})"
                      echo "$merged" > "$statefulSettingsFile"
                    fi
                  else
                    echo "Overwriting stateful config file"
                    mkdir -p "$(dirname "$statefulSettingsFile")"
                    cat ${userSettingsFile} > "$statefulSettingsFile"
                  fi
                  if [ "$settingsFile" != "null" ]; then
                    echo "Merging settings file into current stateful settings file"
                    merged="$(jq -s '.[0] * .[1]' "$statefulSettingsFile" "$settingsFile")"
                    echo "$merged" > "$statefulSettingsFile"
                  fi
                '';
              }
            );
          in
          lib.strings.concatStringsSep " " [
            updateScript
            (lib.boolToString cfg.mutableSettings)
            "${cfg.environment.GOKAPI_CONFIG_DIR}/${cfg.environment.GOKAPI_CONFIG_FILE}"
            (if (cfg.settingsFile == null) then "null" else cfg.settingsFile)
          ];

        PrivateTmp = true;
        Restart = "on-failure";
        RestartSec = 30;
        StateDirectory = "gokapi";
      };

      unitConfig = {
        Description = "gokapi service";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    delliott
  ];
}
