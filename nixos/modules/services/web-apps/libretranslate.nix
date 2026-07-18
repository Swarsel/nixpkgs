{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.libretranslate;
  ltmanageKeysCli = pkgs.writeShellScriptBin "ltmanage-keys" ''
    set -a
    export HOME="/var/lib/libretranslate"
    sudo=exec
    if [[ "$USER" != ${cfg.user} ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${cfg.user} --preserve-env'
    fi
    $sudo ${cfg.package}/bin/ltmanage keys --api-keys-db-path ${cfg.dataDir}/db/api_keys.db "$@"
  '';

in
{
  options = {
    services.libretranslate = {
      enable = lib.mkEnableOption "LibreTranslate service";
      package = lib.mkPackageOption pkgs "libretranslate" { };

      configureNginx = lib.mkOption {
        default = false;
        description = "Configure nginx as a reverse proxy for LibreTranslate.";
        type = lib.types.bool;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/libretranslate";
        description = "The data directory.";
        example = "/srv/data/libretranslate";
        type = lib.types.path;
      };

      disableWebUI = lib.mkOption {
        default = false;
        description = "Whether to disable the Web UI.";
        example = true;
        type = lib.types.bool;
      };

      domain = lib.mkOption {
        default = "";

        description = ''
          The domain serving your LibreTranslate instance.
          Required for configure nginx as a reverse proxy.
        '';

        example = "libretranslate.example.com";
        type = lib.types.str;
      };

      enableApiKeys = lib.mkOption {
        default = false;
        description = "Whether to enable the API keys database.";
        example = true;
        type = lib.types.bool;
      };

      extraArgs = lib.mkOption {
        default = { };
        description = "Extra arguments passed to the LibreTranslate.";

        example = {
          debug = true;
          disable-files-translation = true;
          url-prefix = "translate";
        };

        type =
          with lib.types;
          attrsOf (
            nullOr (oneOf [
              bool
              str
              int
              (listOf (oneOf [
                bool
                str
                int
              ]))
            ])
          );
      };

      group = lib.mkOption {
        default = "libretranslate";
        description = "Group account under which libretranslate runs.";
        type = lib.types.str;
      };

      host = lib.mkOption {
        default = "127.0.0.1";
        description = "The address the application should listen on.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 5000;
        description = "The the application should listen on.";
        type = lib.types.port;
      };

      threads = lib.mkOption {
        default = null;
        description = "Set number of threads.";
        example = 8;
        type = lib.types.nullOr lib.types.ints.positive;
      };

      updateModels = lib.mkOption {
        default = false;
        description = "Update language models at startup";
        example = true;
        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "libretranslate";
        description = "User account under which libretranslate runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkIf cfg.enableApiKeys [ ltmanageKeysCli ];

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = true;

      virtualHosts."${cfg.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };

        locations."= /favicon.ico" = {
          alias = "${cfg.package.static-compressed}/share/libretranslate/static/favicon.ico";
        };

        locations."^~ /static/" = {
          alias = "${cfg.package.static-compressed}/share/libretranslate/static/";
        };

        root = "/var/empty";
      };
    };

    systemd.services.libretranslate = {
      after = [ "network.target" ];
      description = "LibreTranslate service";

      environment = {
        HOME = cfg.dataDir;
        PYTHONUNBUFFERED = "1"; # ensure stdout is logged to journal
      };

      serviceConfig = lib.mkMerge [
        {
          CapabilityBoundingSet = "";

          ExecStart = ''
            ${cfg.package}/bin/libretranslate ${
              lib.cli.toCommandLineShellGNU { } (
                cfg.extraArgs
                // {
                  inherit (cfg) host port threads;
                  api-keys = cfg.enableApiKeys;
                  disable-web-ui = cfg.disableWebUI;
                  update-models = cfg.updateModels;
                }
              )
            }
          '';

          Group = cfg.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = false;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "all";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @setuid" ];
          Type = "simple";
          UMask = "0027";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        }
        (lib.mkIf (cfg.dataDir == "/var/lib/libretranslate") {
          StateDirectory = "libretranslate";
          StateDirectoryMode = "0750";
        })
        (lib.mkIf (cfg.dataDir != "/var/lib/libretranslate") {
          ReadWritePaths = cfg.dataDir;
        })
      ];

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = lib.mkIf (cfg.dataDir != "/var/lib/libretranslate") [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "z '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "libretranslate") {
      libretranslate = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "libretranslate") {
      libretranslate = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
