{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.paisa;
  settingsFormat = pkgs.formats.yaml { };

  args = lib.concatStringsSep " " [
    "--config /var/lib/paisa/paisa.yaml"
  ];

  settings =
    if (cfg.settings != null) then
      removeAttrs
        (
          cfg.settings
          // {
            db_path = cfg.settings.dataDir + cfg.settings.dbFile;
            journal_path = cfg.settings.dataDir + cfg.settings.journalFile;
          }
        )
        [
          "dataDir"
          "journalFile"
          "dbFile"
        ]
    else
      null;

  configFile = (settingsFormat.generate "paisa.yaml" settings).overrideAttrs (_: {
    checkPhase = "";
  });
in
{
  options.services.paisa = with lib.types; {
    enable = lib.mkEnableOption "Paisa personal finance manager";
    package = lib.mkPackageOption pkgs "paisa" { };

    host = lib.mkOption {
      default = "0.0.0.0";
      description = "Host bind IP address.";
      type = str;
    };

    mutableSettings = lib.mkOption {
      default = true;

      description = ''
        Allow changes made on the web interface to persist between service
        restarts.
      '';

      type = bool;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Open ports in the firewall for the Paisa web server.";
      type = bool;
    };

    port = lib.mkOption {
      default = 7500;
      description = "Port to serve Paisa on.";
      type = port;
    };

    settings = lib.mkOption {
      default = null;

      description = ''
        Paisa configuration. Please refer to
        <https://paisa.fyi/reference/config/> for details.

        On start and if `mutableSettings` is `true`, these options are merged
        into the configuration file on start, taking precedence over
        configuration changes made on the web interface.
      '';

      type = nullOr (submodule {
        options = {
          dataDir = lib.mkOption {
            default = "/var/lib/paisa/";
            description = "Path to paisa data directory.";
            type = lib.types.str;
          };

          dbFile = lib.mkOption {
            default = "paisa.sqlite3";
            description = "Filename of the Paisa database.";
            type = lib.types.str;
          };

          journalFile = lib.mkOption {
            default = "main.ledger";
            description = "Filename of the main journal / ledger file.";
            type = lib.types.str;
          };

        };

        freeformType = settingsFormat.type;
      });
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ];
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.paisa = {
      after = [ "network.target" ];
      description = "Paisa: Web Application";

      preStart = lib.optionalString (settings != null) ''
        if [ -e "$STATE_DIRECTORY/paisa.yaml" ] && [ "${toString cfg.mutableSettings}" = "1" ]; then
          # do not write directly to the config file
          ${lib.getExe pkgs.yaml-merge} "$STATE_DIRECTORY/paisa.yaml" "${configFile}" > "$STATE_DIRECTORY/paisa.yaml.tmp"
          mv "$STATE_DIRECTORY/paisa.yaml.tmp" "$STATE_DIRECTORY/paisa.yaml"
        else
          cp --force "${configFile}" "$STATE_DIRECTORY/paisa.yaml"
          chmod 600 "$STATE_DIRECTORY/paisa.yaml"
        fi
      '';

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} serve ${args}";
        Restart = "always";
        RestartSec = 5;
        RuntimeDirectory = "paisa";
        StateDirectory = "paisa";
      };

      unitConfig = {
        StartLimitBurst = 10;
        StartLimitIntervalSec = 5;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    doc = ./paisa.md;
    maintainers = with lib.maintainers; [ skowalak ];
  };
}
