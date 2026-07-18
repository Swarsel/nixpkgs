{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types literalExpression;

  cfg = config.services.hedgedoc;

  # 21.03 will not be an official release - it was instead 21.05.  This
  # versionAtLeast statement remains set to 21.03 for backwards compatibility.
  # See https://github.com/NixOS/nixpkgs/pull/108899 and
  # https://github.com/NixOS/rfcs/blob/master/rfcs/0080-nixos-release-schedule.md.
  name = if lib.versionAtLeast config.system.stateVersion "21.03" then "hedgedoc" else "codimd";

  settingsFormat = pkgs.formats.json { };
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "codimd" ] [ "services" "hedgedoc" ])
    (lib.mkRenamedOptionModule
      [ "services" "hedgedoc" "configuration" ]
      [ "services" "hedgedoc" "settings" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "hedgedoc" "groups" ]
      [ "users" "users" "hedgedoc" "extraGroups" ]
    )
    (lib.mkRemovedOptionModule [ "services" "hedgedoc" "workDir" ] ''
      This option has been removed in favor of systemd managing the state directory.

      If you have set this option without specifying `services.hedgedoc.settings.uploadsPath`,
      please move these files to `/var/lib/hedgedoc/uploads`, or set the option to point
      at the correct location.
    '')
  ];

  options.services.hedgedoc = {
    enable = lib.mkEnableOption "the HedgeDoc Markdown Editor";
    package = lib.mkPackageOption pkgs "hedgedoc" { };

    configureNginx = lib.mkOption {
      default = false;
      description = "Whether to configure nginx as a reverse proxy.";
      type = lib.types.bool;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.

        Secrets may be passed to the service without adding them to the world-readable
        Nix store, by specifying placeholder variables as the option value in Nix and
        setting these variables accordingly in the environment file.


        Snippet of HedgeDoc config containing a secret:
        ```
        services.hedgedoc.settings.dbURL = "postgres://hedgedoc:\''${DB_PASSWORD}@db-host:5432/hedgedocdb";
        ```

        and the content of this environment file:
        ````
          DB_PASSWORD=verysecretdbpassword
        ```
      '';

      example = "/var/lib/hedgedoc/hedgedoc.env";
      type = with types; nullOr path;
    };

    settings = mkOption {
      description = ''
        HedgeDoc configuration, see
        <https://docs.hedgedoc.org/configuration/>
        for documentation.
      '';

      type = types.submodule {
        options = {
          # Declared because we change the default to false.
          allowGravatar = mkOption {
            default = false;

            description = ''
              Whether to enable [Libravatar](https://wiki.libravatar.org/) as
              profile picture source on your instance.

              Despite the naming of the setting, Hedgedoc replaced Gravatar
              with Libravatar in [CodiMD 1.4.0](https://hedgedoc.org/releases/1.4.0/)
            '';

            example = true;
            type = types.bool;
          };

          allowOrigin = mkOption {
            default = with cfg.settings; [ host ] ++ lib.optionals (domain != null) [ domain ];

            defaultText = literalExpression ''
              with config.services.hedgedoc.settings; [ host ] ++ lib.optionals (domain != null) [ domain ]
            '';

            description = ''
              List of domains to whitelist.
            '';

            example = [
              "localhost"
              "hedgedoc.org"
            ];

            type = with types; listOf str;
          };

          db = mkOption {
            default = {
              dialect = "sqlite";
              storage = "/var/lib/${name}/db.sqlite";
            };

            defaultText = literalExpression ''
              {
                dialect = "sqlite";
                storage = "/var/lib/hedgedoc/db.sqlite";
              }
            '';

            description = ''
              Specify the configuration for sequelize.
              HedgeDoc supports `mysql`, `postgres`, `sqlite` and `mssql`.
              See <https://sequelize.readthedocs.io/en/v3/>
              for more information.

              ::: {.note}
                The relevant parts will be overriden if you set {option}`dbURL`.
              :::
            '';

            example = literalExpression ''
              db = {
                username = "hedgedoc";
                database = "hedgedoc";
                host = "localhost:5432";
                # or via socket
                # host = "/run/postgresql";
                dialect = "postgresql";
              };
            '';

            type = types.attrs;
          };

          domain = mkOption {
            default = null;

            description = ''
              Domain to use for website.

              This is useful if you are trying to run hedgedoc behind
              a reverse proxy.
            '';

            example = "hedgedoc.org";
            type = with types; nullOr str;
          };

          host = mkOption {
            default = "localhost";

            description = ''
              Address to listen on.
            '';

            type = with types; nullOr str;
          };

          path = mkOption {
            default = null;

            description = ''
              Path to UNIX domain socket to listen on

              ::: {.note}
                If specified, {option}`host` and {option}`port` will be ignored.
              :::
            '';

            example = "/run/hedgedoc/hedgedoc.sock";
            type = with types; nullOr path;
          };

          port = mkOption {
            default = 3000;

            description = ''
              Port to listen on.
            '';

            example = 80;
            type = types.port;
          };

          protocolUseSSL = mkOption {
            default = false;

            description = ''
              Use `https://` for all links.

              This is useful if you are trying to run hedgedoc behind
              a reverse proxy.

              ::: {.note}
                Only applied if {option}`domain` is set.
              :::
            '';

            example = true;
            type = types.bool;
          };

          uploadsPath = mkOption {
            default = "/var/lib/${name}/uploads";
            defaultText = "/var/lib/hedgedoc/uploads";

            description = ''
              Directory for storing uploaded images.
            '';

            type = types.path;
          };

          urlPath = mkOption {
            default = null;

            description = ''
              URL path for the website.

              This is useful if you are hosting hedgedoc on a path like
              `www.example.com/hedgedoc`
            '';

            example = "hedgedoc";
            type = with types; nullOr str;
          };

          useSSL = mkOption {
            default = false;

            description = ''
              Enable to use SSL server.

              ::: {.note}
                This will also enable {option}`protocolUseSSL`.

                It will also require you to set the following:

                - {option}`sslKeyPath`
                - {option}`sslCertPath`
                - {option}`sslCAPath`
                - {option}`dhParamPath`
              :::
            '';

            type = types.bool;
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      hedgedoc.settings = {
        defaultNotePath = lib.mkDefault "${cfg.package}/share/hedgedoc/public/default.md";
        docsPath = lib.mkDefault "${cfg.package}/share/hedgedoc/public/docs";
        path = lib.mkIf cfg.configureNginx "/run/hedgedoc/hedgedoc.sock";
        viewPath = lib.mkDefault "${cfg.package}/share/hedgedoc/public/views";
      };

      nginx = lib.mkIf cfg.configureNginx {
        enable = true;
        upstreams.hedgedoc.servers."unix:${cfg.settings.path}" = { };

        virtualHosts."${cfg.settings.domain}" = {
          forceSSL = true;

          locations = {
            "/" = {
              proxyPass = "http://hedgedoc";
              recommendedProxySettings = lib.mkDefault true;
            };

            "/socket.io/" = {
              proxyPass = "http://hedgedoc";
              proxyWebsockets = true;
              recommendedProxySettings = lib.mkDefault true;
            };
          };
        };
      };
    };

    systemd.services.hedgedoc = {
      after = [ "network.target" ];
      description = "HedgeDoc Service";
      documentation = [ "https://docs.hedgedoc.org/" ];

      preStart =
        let
          configFile = settingsFormat.generate "hedgedoc-config.json" {
            production = cfg.settings;
          };
        in
        ''
          ${pkgs.envsubst}/bin/envsubst \
            -o /run/${name}/config.json \
            -i ${configFile}
          ${pkgs.coreutils}/bin/mkdir -p ${cfg.settings.uploadsPath}
        '';

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";

        Environment = [
          "CMD_CONFIG_FILE=/run/${name}/config.json"
          "NODE_ENV=production"
        ];

        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = lib.getExe cfg.package;
        Group = name;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        ReadWritePaths = [
          "-${cfg.settings.uploadsPath}"
        ]
        ++ lib.optionals (cfg.settings.db ? "storage") [ "-${cfg.settings.db.storage}" ];

        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          # Required for connecting to database sockets,
          # and listening to unix socket at `cfg.settings.path`
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = [ name ];
        SocketBindAllow = lib.mkIf (cfg.settings.path == null) cfg.settings.port;
        SocketBindDeny = "any";
        StateDirectory = [ name ];
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged @obsolete"
          "@pkey"
          "fchown" # needed for filesystem image backend
        ];

        UMask = "0007";
        User = name;
        WorkingDirectory = "/run/${name}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.${name} = { };

      users = {
        ${name} = {
          description = "HedgeDoc service user";
          group = name;
          isSystemUser = true;
        };

        nginx = lib.mkIf cfg.configureNginx {
          extraGroups = [ "hedgedoc" ];
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    SuperSandro2000
    h7x4
  ];
}
