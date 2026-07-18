{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gancio;
  settingsFormat = pkgs.formats.json { };
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    literalExpression
    mkIf
    optional
    mapAttrsToList
    concatStringsSep
    concatMapStringsSep
    getExe
    mkMerge
    ;
in
{
  options.services.gancio = {
    enable = mkEnableOption "Gancio, a shared agenda for local communities";
    package = mkPackageOption pkgs "gancio" { };

    nginx = mkOption {
      default = { };
      description = "Extra configuration for the nginx virtual host of gancio.";

      example = {
        enableACME = false;
        forceSSL = false;
      };

      type = types.submodule (
        lib.recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) {
          options.enableACME.default = true;
          # enable encryption by default,
          # as sensitive login credentials should not be transmitted in clear text.
          options.forceSSL.default = true;
        }
      );
    };

    plugins = mkOption {
      default = [ ];

      description = ''
        Paths of gancio plugins to activate (linked under $WorkingDirectory/plugins/).
      '';

      example = literalExpression "[ pkgs.gancioPlugins.telegram-bridge ]";
      type = with types; listOf package;
    };

    settings = mkOption {
      description = ''
        Configuration for Gancio, see <https://gancio.org/install/config> for supported values.
      '';

      type = types.submodule {
        options = {
          baseurl = mkOption {
            default = "http${
              lib.optionalString config.services.nginx.virtualHosts."${cfg.settings.hostname}".enableACME "s"
            }://${cfg.settings.hostname}";

            defaultText = lib.literalExpression ''"https://''${config.services.gancio.settings.hostname}"'';
            description = "The full URL under which the server is reachable.";
            example = "https://demo.gancio.org/gancio";
            type = types.str;
          };

          db = {
            database = mkOption {
              default = if cfg.settings.db.dialect == "postgres" then cfg.user else null;
              defaultText = ''if config.services.gancio.settings.db.dialect == "postgres" then cfg.user else null'';

              description = ''
                Name of the PostgreSQL database
              '';

              readOnly = true;
              type = types.nullOr types.str;
            };

            dialect = mkOption {
              default = "sqlite";

              description = ''
                The database dialect to use
              '';

              type = types.enum [
                "sqlite"
                "postgres"
              ];
            };

            host = mkOption {
              default = if cfg.settings.db.dialect == "postgres" then "/run/postgresql" else null;
              defaultText = ''if config.services.gancio.settings.db.dialect == "postgres" then "/run/postgresql" else null'';

              description = ''
                Connection string for the PostgreSQL database
              '';

              readOnly = true;
              type = types.nullOr types.str;
            };

            storage = mkOption {
              default = if cfg.settings.db.dialect == "sqlite" then "/var/lib/gancio/db.sqlite" else null;
              defaultText = ''if config.services.gancio.settings.db.dialect == "sqlite" then "/var/lib/gancio/db.sqlite" else null'';

              description = ''
                Location for the SQLite database.
              '';

              readOnly = true;
              type = types.nullOr types.str;
            };
          };

          hostname = mkOption {
            description = "The domain name under which the server is reachable.";
            type = types.str;
          };

          log_level = mkOption {
            default = "info";
            description = "Gancio log level.";

            type = types.enum [
              "debug"
              "info"
              "warning"
              "error"
            ];
          };

          # FIXME upstream proper journald logging
          log_path = mkOption {
            default = "/var/log/gancio";
            description = "Directory Gancio logs into";
            readOnly = true;
            type = types.str;
          };

          server = {
            socket = mkOption {
              default = "/run/gancio/socket";

              description = ''
                The unix socket for the gancio server to listen on.
              '';

              readOnly = true;
              type = types.path;
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    user = mkOption {
      default = "gancio";
      description = "The user (and PostgreSQL database name) used to run the gancio server";
      type = types.str;
    };

    userLocale = mkOption {
      default = { };

      description = ''
        Override default locales within gancio.
        See [default languages and locales](https://framagit.org/les/gancio/tree/master/locales).
      '';

      example = {
        en.register.description = "My new registration page description";
      };

      type = with types; attrsOf (attrsOf (attrsOf str));
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.runCommand "gancio" { } ''
        mkdir -p $out/bin
        echo '#!${pkgs.runtimeShell}
        cd /var/lib/gancio/
        sudo=exec
        if [[ "$USER" != ${cfg.user} ]]; then
          sudo="exec /run/wrappers/bin/sudo -u ${cfg.user}"
        fi
        $sudo ${lib.getExe cfg.package} "''${@:--help}"
        ' > $out/bin/gancio
        chmod +x $out/bin/gancio
      '')
    ];

    services.nginx = {
      enable = true;

      virtualHosts."${cfg.settings.hostname}" = mkMerge [
        cfg.nginx
        {
          locations = {
            "/" = {
              index = "index.html";
              tryFiles = "$uri $uri @proxy";
            };

            "@proxy" = {
              proxyPass = "http://unix:${cfg.settings.server.socket}";
              proxyWebsockets = true;
              recommendedProxySettings = true;
            };
          };
        }
      ];
    };

    services.postgresql = mkIf (cfg.settings.db.dialect == "postgres") {
      enable = true;
      ensureDatabases = [ cfg.user ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.user;
        }
      ];
    };

    systemd.services.gancio =
      let
        configFile = settingsFormat.generate "gancio-config.json" cfg.settings;
      in
      {
        after = [
          "network.target"
        ]
        ++ optional (cfg.settings.db.dialect == "postgres") "postgresql.target";

        description = "Gancio server";
        documentation = [ "https://gancio.org/" ];

        environment = {
          NODE_ENV = "production";
        };

        path = [
          # required for sendmail
          "/run/wrappers"
        ];

        preStart = ''
          # We need this so the gancio executable run by the user finds the right settings.
          ln -sf ${configFile} config.json

          rm -f user_locale/*
          ${concatStringsSep "\n" (
            mapAttrsToList (
              l: c: "ln -sf ${settingsFormat.generate "gancio-${l}-locale.json" c} user_locale/${l}.json"
            ) cfg.userLocale
          )}

          rm -f plugins/*
          ${concatMapStringsSep "\n" (p: "ln -sf ${p} plugins/") cfg.plugins}
        '';

        serviceConfig = {
          CapabilityBoundingSet = "";
          ExecStart = "${getExe cfg.package} start ${configFile}";
          LockPersonality = true;
          LogsDirectory = "gancio";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictNamespaces = true;
          # hardening
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "gancio";
          StateDirectory = "gancio";
          SystemCallArchitectures = "native";
          # set umask so that nginx can write to the server socket
          # FIXME: upstream socket permission configuration in Nuxt
          UMask = "0002";
          User = cfg.user;
          WorkingDirectory = "/var/lib/gancio";
        };

        wantedBy = [ "multi-user.target" ];
      };

    systemd.tmpfiles.settings."10-gancio" =
      let
        rules = {
          group = config.users.users.${cfg.user}.group;
          mode = "0755";
          user = cfg.user;
        };
      in
      {
        "/var/lib/gancio/plugins".d = rules;
        "/var/lib/gancio/user_locale".d = rules;
      };

    users.groups.gancio = lib.mkIf (cfg.user == "gancio") { };

    # for nginx to access gancio socket
    users.users."${config.services.nginx.user}" = lib.mkIf (config.services.nginx.enable) {
      extraGroups = [ config.users.users.${cfg.user}.group ];
    };

    users.users.gancio = lib.mkIf (cfg.user == "gancio") {
      group = cfg.user;
      home = "/var/lib/gancio";
      isSystemUser = true;
    };
  };
}
