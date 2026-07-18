{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.recyclarr;
  format = pkgs.formats.yaml { };
  stateDir = "/var/lib/recyclarr";
  configPath = "${stateDir}/config.yml";
  secretsReplacement = utils.genJqSecretsReplacement {
    loadCredential = true;
  } cfg.configuration configPath;
in
{
  options.services.recyclarr = {
    enable = lib.mkEnableOption "recyclarr service";
    package = lib.mkPackageOption pkgs "recyclarr" { };

    command = lib.mkOption {
      default = "sync";
      description = "The recyclarr command to run (e.g., sync).";
      type = lib.types.str;
    };

    configuration = lib.mkOption {
      default = { };

      description = ''
        Recyclarr YAML configuration as a Nix attribute set.

        For detailed configuration options and examples, see the
        [official configuration reference](https://recyclarr.dev/wiki/yaml/config-reference/).

        The configuration is processed using [utils.genJqSecretsReplacement](https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/utils.nix#L232-L331) to handle secret substitution.
        ```
      '';

      example = {
        radarr = {
          radarr-main = {
            api_key = {
              _secret = "/run/credentials/recyclarr.service/radarr-api_key";
            };

            base_url = "http://localhost:7878";
            instance_name = "main";
          };
        };

        sonarr = {
          sonarr-main = {
            api_key = {
              _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
            };

            base_url = "http://localhost:8989";
            instance_name = "main";
          };
        };
      };

      type = format.type;
    };

    group = lib.mkOption {
      default = "recyclarr";
      description = "Group under which recyclarr runs.";
      type = lib.types.str;
    };

    schedule = lib.mkOption {
      default = "daily";
      description = "When to run recyclarr in systemd calendar format.";
      type = lib.types.str;
    };

    user = lib.mkOption {
      default = "recyclarr";
      description = "User account under which recyclarr runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.recyclarr = {
      description = "Recyclarr Service";
      preStart = secretsReplacement.script;

      serviceConfig = {
        CapabilityBoundingSet = "";

        Environment = [
          "RECYCLARR_CONFIG_DIR=${stateDir}"
          "RECYCLARR_DATA_DIR=${stateDir}"
        ];

        ExecStart = "${lib.getExe cfg.package} ${cfg.command} --config ${configPath}";
        Group = cfg.group;
        LoadCredential = secretsReplacement.credentials;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = false;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ stateDir ];
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "recyclarr";
        Type = "oneshot";
        User = cfg.user;
      };
    };

    systemd.timers.recyclarr = {
      description = "Recyclarr Timer";
      partOf = [ "recyclarr.service" ];

      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "5m";
      };

      wantedBy = [ "timers.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "recyclarr") {
      ${cfg.group} = { };
    };

    users.users = lib.mkIf (cfg.user == "recyclarr") {
      recyclarr = {
        description = "recyclarr user";
        group = cfg.group;
        home = stateDir;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = [ lib.maintainers.josephst ];
}
