{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.karakeep;

  karakeepEnv = lib.mkMerge [
    { DATA_DIR = "/var/lib/karakeep"; }
    (lib.mkIf cfg.meilisearch.enable {
      MEILI_ADDR = "http://127.0.0.1:${toString config.services.meilisearch.listenPort}";
    })
    (lib.mkIf cfg.browser.enable {
      BROWSER_WEB_URL = "http://127.0.0.1:${toString cfg.browser.port}";
    })
    cfg.extraEnvironment
  ];

  environmentFiles = [
    "/var/lib/karakeep/settings.env"
  ]
  ++ (lib.optional (cfg.environmentFile != null) cfg.environmentFile);
in
{
  options = {
    services.karakeep = {
      enable = lib.mkEnableOption "Enable the Karakeep service";
      package = lib.mkPackageOption pkgs "karakeep" { };

      browser = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Enable the karakeep-browser service that runs a chromium instance in
            the background with debugging ports exposed. This is necessary for
            certain features like screenshots.
          '';

          type = lib.types.bool;
        };

        exe = lib.mkOption {
          default = "${pkgs.chromium}/bin/chromium";
          defaultText = lib.literalExpression "\${pkgs.chromium}/bin/chromium";
          description = "The browser executable (must be Chrome-like).";
          example = lib.literalExpression "\${pkgs.google-chrome}/bin/google-chrome-stable";
          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 9222;
          description = "The port the browser should run on.";
          type = lib.types.port;
        };
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          An optional path to an environment file that will be used in the web and workers
          services. This is useful for loading private keys.
        '';

        example = "/var/lib/karakeep/secrets.env";
        type = lib.types.nullOr lib.types.path;
      };

      extraEnvironment = lib.mkOption {
        default = { };

        description = ''
          Environment variables to pass to Karakaeep. This is how most settings
          can be configured. Changing DATA_DIR is possible but not supported.

          See <https://docs.karakeep.app/configuration/environment-variables>
        '';

        example = lib.literalExpression ''
          {
            PORT = "1234";
            DISABLE_SIGNUPS = "true";
            DISABLE_NEW_RELEASE_CHECK = "true";
          }
        '';

        type = lib.types.attrsOf lib.types.str;
      };

      meilisearch = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Enable Meilisearch and configure Karakeep to use it. Meilisearch is
            required for text search.
          '';

          type = lib.types.bool;
        };

        # TODO: remove when this is either handled by karakeep or becomes default
        #       in services.meilisearch.
        experimental_dumpless_upgrade = lib.mkOption {
          default = true;

          description = ''
            Whether to enable (experimental) dumpless upgrade of the search index.
            Allows upgrading Meilisearch without manually dumping and importing
            the database.
            {option}`services.meilisearch.settings.experimental_dumpless_upgrade`
            overrides this option if set explicitly.

            More information at <https://www.meilisearch.com/docs/learn/update_and_migration/updating#dumpless-upgrade>.
          '';

          type = lib.types.bool;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.meilisearch = {
      enable = cfg.meilisearch.enable;
      settings.experimental_dumpless_upgrade = lib.mkDefault cfg.meilisearch.experimental_dumpless_upgrade;
    };

    systemd.services.karakeep-browser = lib.mkIf cfg.browser.enable {
      after = [ "network.target" ];
      partOf = [ "karakeep.service" ];

      script = ''
        export HOME="$CACHE_DIRECTORY"
        exec ${cfg.browser.exe} \
          --headless --no-sandbox --disable-gpu --disable-dev-shm-usage \
          --remote-debugging-address=127.0.0.1 \
          --remote-debugging-port=${toString cfg.browser.port} \
          --hide-scrollbars \
          --user-data-dir="$STATE_DIRECTORY"
      '';

      serviceConfig = {
        CacheDirectory = "karakeep-browser";
        DevicePolicy = "closed";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "karakeep-browser";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.karakeep-init = {
      after = [ "network.target" ];
      description = "Initialize Karakeep Data";
      partOf = [ "karakeep.service" ];
      path = [ pkgs.openssl ];

      script = ''
        umask 0077

        if [ ! -f "$STATE_DIRECTORY/settings.env" ]; then
          cat <<EOF >"$STATE_DIRECTORY/settings.env"
        # Generated by NixOS Karakeep module
        MEILI_MASTER_KEY=$(openssl rand -base64 36)
        NEXTAUTH_SECRET=$(openssl rand -base64 36)
        EOF
        fi

        export DATA_DIR="$STATE_DIRECTORY"
        exec "${cfg.package}/lib/karakeep/migrate"
      '';

      serviceConfig = {
        Group = "karakeep";
        PrivateTmp = "yes";
        RemainAfterExit = true;
        StateDirectory = "karakeep";
        Type = "oneshot";
        User = "karakeep";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.karakeep-web = {
      after = [
        "network.target"
        "karakeep-init.service"
        "karakeep-workers.service"
      ];

      description = "Karakeep Web";

      environment = {
        NEXT_CACHE_DIR = "%C/karakeep";
      }
      // karakeepEnv;

      partOf = [ "karakeep.service" ];

      serviceConfig = {
        CacheDirectory = "karakeep";
        EnvironmentFile = environmentFiles;
        ExecStart = "${cfg.package}/lib/karakeep/start-web";
        Group = "karakeep";
        PrivateTmp = "yes";
        StateDirectory = "karakeep";
        User = "karakeep";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.karakeep-workers = {
      after = [
        "network.target"
        "karakeep-init.service"
      ];

      description = "Karakeep Workers";
      environment = karakeepEnv;
      partOf = [ "karakeep.service" ];

      path = [
        pkgs.monolith
        pkgs.yt-dlp
      ];

      serviceConfig = {
        EnvironmentFile = environmentFiles;
        ExecStart = "${cfg.package}/lib/karakeep/start-workers";
        Group = "karakeep";
        PrivateTmp = "yes";
        StateDirectory = "karakeep";
        User = "karakeep";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.karakeep = { };

    users.users.karakeep = {
      group = "karakeep";
      isSystemUser = true;
    };
  };

  meta = {
    maintainers = [ lib.maintainers.three ];
  };
}
