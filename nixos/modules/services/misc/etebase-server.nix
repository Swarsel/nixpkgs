{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.etebase-server;

  iniFmt = pkgs.formats.ini { };

  configIni = iniFmt.generate "etebase-server.ini" cfg.settings;

  defaultUser = "etebase-server";
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "etebase-server"
      "customIni"
    ] "Set the option `services.etebase-server.settings' instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "etebase-server"
      "database"
    ] "Set the option `services.etebase-server.settings.database' instead.")
    (lib.mkRenamedOptionModule
      [ "services" "etebase-server" "secretFile" ]
      [ "services" "etebase-server" "settings" "secret_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "etebase-server" "host" ]
      [ "services" "etebase-server" "settings" "allowed_hosts" "allowed_host1" ]
    )
  ];

  options = {
    services.etebase-server = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Etebase server.

          Once enabled you need to create an admin user by invoking the
          shell command `etebase-server createsuperuser` with
          the user specified by the `user` option or a superuser.
          Then you can login and create accounts on your-etebase-server.com/admin
        '';

        example = true;
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "etebase-server" { };

      dataDir = lib.mkOption {
        default = "/var/lib/etebase-server";
        description = "Directory to store the Etebase server data.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open ports in the firewall for the server.
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 8001;
        description = "Port to listen on.";
        type = with lib.types; nullOr port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for `etebase-server`. Refer to
          <https://github.com/etesync/server/blob/master/etebase-server.ini.example>
          and <https://github.com/etesync/server/wiki>
          for details on supported values.
        '';

        example = {
          allowed_hosts = {
            allowed_host2 = "localhost";
          };

          global = {
            debug = true;
            media_root = "/path/to/media";
          };
        };

        type = lib.types.submodule {
          options = {
            allowed_hosts = {
              allowed_host1 = lib.mkOption {
                default = "0.0.0.0";

                description = ''
                  The main host that is allowed access.
                '';

                example = "localhost";
                type = lib.types.str;
              };
            };

            database = {
              engine = lib.mkOption {
                default = "django.db.backends.sqlite3";
                description = "The database engine to use.";

                type = lib.types.enum [
                  "django.db.backends.sqlite3"
                  "django.db.backends.postgresql"
                ];
              };

              name = lib.mkOption {
                default = "${cfg.dataDir}/db.sqlite3";
                defaultText = lib.literalExpression ''"''${config.services.etebase-server.dataDir}/db.sqlite3"'';
                description = "The database name.";
                type = lib.types.str;
              };
            };

            global = {
              debug = lib.mkOption {
                default = false;

                description = ''
                  Whether to set django's DEBUG flag.
                '';

                type = lib.types.bool;
              };

              media_root = lib.mkOption {
                default = "${cfg.dataDir}/media";
                defaultText = lib.literalExpression ''"''${config.services.etebase-server.dataDir}/media"'';
                description = "The media directory.";
                type = lib.types.str;
              };

              secret_file = lib.mkOption {
                default = null;

                description = ''
                  The path to a file containing the secret
                  used as django's SECRET_KEY.
                '';

                type = with lib.types; nullOr str;
              };

              static_root = lib.mkOption {
                default = "${cfg.dataDir}/static";
                defaultText = lib.literalExpression ''"''${config.services.etebase-server.dataDir}/static"'';
                description = "The directory for static files.";
                type = lib.types.str;
              };
            };
          };

          freeformType = iniFmt.type;
        };
      };

      unixSocket = lib.mkOption {
        default = null;
        description = "The path to the socket to bind to.";
        example = "/run/etebase-server/etebase-server.sock";
        type = with lib.types; nullOr str;
      };

      user = lib.mkOption {
        default = defaultUser;
        description = "User under which Etebase server runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      (runCommand "etebase-server"
        {
          nativeBuildInputs = [ makeWrapper ];
        }
        ''
          makeWrapper ${cfg.package}/bin/etebase-server \
            $out/bin/etebase-server \
            --chdir ${lib.escapeShellArg cfg.dataDir} \
            --prefix ETEBASE_EASY_CONFIG_PATH : "${configIni}"
        ''
      )
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.etebase-server = {
      after = [
        "network.target"
        "systemd-tmpfiles-setup.service"
      ];

      description = "An Etebase (EteSync 2.0) server";

      environment = {
        ETEBASE_EASY_CONFIG_PATH = configIni;
        PYTHONPATH = cfg.package.pythonPath;
      };

      path = [ cfg.package ];

      preStart = ''
        # Auto-migrate on first run or if the package has changed
        versionFile="${cfg.dataDir}/src-version"
        if [[ $(cat "$versionFile" 2>/dev/null) != ${cfg.package} ]]; then
          etebase-server migrate --no-input
          etebase-server collectstatic --no-input --clear
          echo ${cfg.package} > "$versionFile"
        fi
      '';

      script =
        let
          python = cfg.package.python;
          networking =
            if cfg.unixSocket != null then
              "--uds ${cfg.unixSocket}"
            else
              "--host 0.0.0.0 --port ${toString cfg.port}";
        in
        ''
          ${python.pkgs.uvicorn}/bin/uvicorn ${networking} \
            --app-dir ${cfg.package}/${cfg.package.python.sitePackages} \
            etebase_server.asgi:application
        '';

      serviceConfig = {
        Restart = "always";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - ${cfg.user} ${config.users.users.${cfg.user}.group} - -"
    ]
    ++ lib.optionals (cfg.unixSocket != null) [
      "d '${dirOf cfg.unixSocket}' - ${cfg.user} ${config.users.users.${cfg.user}.group} - -"
    ];

    users = lib.optionalAttrs (cfg.user == defaultUser) {
      groups.${defaultUser} = { };

      users.${defaultUser} = {
        group = defaultUser;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };
}
