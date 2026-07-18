{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.epgstation;
  opt = options.services.epgstation;

  description = "EPGStation: DVR system for Mirakurun-managed TV tuners";

  username = config.users.users.epgstation.name;
  groupname = config.users.users.epgstation.group;
  mirakurun = {
    option = options.services.mirakurun.unixSocket;
    sock = config.services.mirakurun.unixSocket;
  };

  yaml = pkgs.formats.yaml { };
  settingsTemplate = yaml.generate "config.yml" cfg.settings;
  preStartScript = pkgs.writeScript "epgstation-prestart" ''
    #!${pkgs.runtimeShell}

    DB_PASSWORD_FILE=${lib.escapeShellArg cfg.database.passwordFile}

    if [[ ! -f "$DB_PASSWORD_FILE" ]]; then
      printf "[FATAL] File containing the DB password was not found in '%s'. Double check the NixOS option '%s'." \
        "$DB_PASSWORD_FILE" ${lib.escapeShellArg opt.database.passwordFile} >&2
      exit 1
    fi

    DB_PASSWORD="$(head -n1 ${lib.escapeShellArg cfg.database.passwordFile})"

    # setup configuration
    touch /etc/epgstation/config.yml
    chmod 640 /etc/epgstation/config.yml
    sed \
      -e "s,@dbPassword@,$DB_PASSWORD,g" \
      ${settingsTemplate} > /etc/epgstation/config.yml
    chown "${username}:${groupname}" /etc/epgstation/config.yml

    # NOTE: Use password authentication, since mysqljs does not yet support auth_socket
    if [ ! -e /var/lib/epgstation/db-created ]; then
      ${pkgs.mariadb}/bin/mysql -e \
        "GRANT ALL ON \`${cfg.database.name}\`.* TO '${username}'@'localhost' IDENTIFIED by '$DB_PASSWORD';"
      touch /var/lib/epgstation/db-created
    fi
  '';

  streamingConfig = lib.importJSON ./streaming.json;
  logConfig = yaml.generate "logConfig.yml" {
    appenders.stdout.type = "stdout";

    categories = {
      access = {
        appenders = [ "stdout" ];
        level = "info";
      };

      default = {
        appenders = [ "stdout" ];
        level = "info";
      };

      stream = {
        appenders = [ "stdout" ];
        level = "info";
      };

      system = {
        appenders = [ "stdout" ];
        level = "info";
      };
    };
  };

  # Deprecate top level options that are redundant.
  deprecateTopLevelOption =
    config:
    lib.mkRenamedOptionModule
      (
        [
          "services"
          "epgstation"
        ]
        ++ config
      )
      (
        [
          "services"
          "epgstation"
          "settings"
        ]
        ++ config
      );

  removeOption =
    config: instruction:
    lib.mkRemovedOptionModule (
      [
        "services"
        "epgstation"
      ]
      ++ config
    ) instruction;
in
{
  imports = [
    (deprecateTopLevelOption [ "port" ])
    (deprecateTopLevelOption [ "socketioPort" ])
    (deprecateTopLevelOption [ "clientSocketioPort" ])
    (removeOption [ "basicAuth" ] "Use a TLS-terminated reverse proxy with authentication instead.")
  ];

  options.services.epgstation = {
    enable = lib.mkEnableOption description;
    package = lib.mkPackageOption pkgs "epgstation" { };

    database = {
      name = lib.mkOption {
        default = "epgstation";

        description = ''
          Name of the MySQL database that holds EPGStation's data.
        '';

        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        description = ''
          A file containing the password for the database named
          {option}`database.name`.
        '';

        example = "/run/keys/epgstation-db-password";
        type = lib.types.path;
      };
    };

    ffmpeg = lib.mkPackageOption pkgs "ffmpeg" {
      default = "ffmpeg-headless";
      example = "ffmpeg-full";
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports in the firewall for the EPGStation web interface.

        ::: {.warning}
        Exposing EPGStation to the open internet is generally advised
        against. Only use it inside a trusted local network, or consider
        putting it behind a VPN if you want remote access.
        :::
      '';

      type = lib.types.bool;
    };

    # The defaults for some options come from the upstream template
    # configuration, which is the one that users would get if they follow the
    # upstream instructions. This is, in some cases, different from the
    # application defaults. Some options like encodeProcessNum and
    # concurrentEncodeNum doesn't have an optimal default value that works for
    # all hardware setups and/or performance requirements. For those kind of
    # options, the application default wouldn't always result in the expected
    # out-of-the-box behavior because it's the responsibility of the user to
    # configure them according to their needs. In these cases, the value in the
    # upstream template configuration should serve as a "good enough" default.
    settings = lib.mkOption {
      default = { };

      description = ''
        Options to add to config.yml.

        Documentation:
        <https://github.com/l3tnun/EPGStation/blob/master/doc/conf-manual.md>
      '';

      example = {
        conflictPriority = 10;
        recPriority = 20;
      };

      type = lib.types.submodule {
        options.clientSocketioPort = lib.mkOption {
          default = cfg.settings.socketioPort;
          defaultText = lib.literalExpression "config.${opt.settings}.socketioPort";

          description = ''
            Socket.io port that the web client is going to connect to. This may
            be different from {option}`${opt.settings}.socketioPort` if
            EPGStation is hidden behind a reverse proxy.
          '';

          type = lib.types.port;
        };

        options.concurrentEncodeNum = lib.mkOption {
          default = 1;

          description = ''
            The maximum number of encoding jobs that EPGStation would run at the
            same time.
          '';

          type = lib.types.ints.positive;
        };

        options.encode = lib.mkOption {
          default = [
            {
              cmd = "%NODE% ${cfg.package}/libexec/enc.js";
              name = "H.264";
              suffix = ".mp4";
            }
          ];

          defaultText = lib.literalExpression ''
            [
              {
                name = "H.264";
                cmd = "%NODE% config.${opt.package}/libexec/enc.js";
                suffix = ".mp4";
              }
            ]
          '';

          description = "Encoding presets for recorded videos.";
          type = with lib.types; listOf attrs;
        };

        options.encodeProcessNum = lib.mkOption {
          default = 4;

          description = ''
            The maximum number of processes that EPGStation would allow to run
            at the same time for encoding or streaming videos.
          '';

          type = lib.types.ints.positive;
        };

        options.mirakurunPath =
          with mirakurun;
          lib.mkOption {
            default = "http+unix://${lib.replaceStrings [ "/" ] [ "%2F" ] sock}";

            defaultText = lib.literalExpression ''
              "http+unix://''${lib.replaceStrings ["/"] ["%2F"] config.${option}}"
            '';

            description = "URL to connect to Mirakurun.";
            example = "http://localhost:40772";
            type = lib.types.str;
          };

        options.port = lib.mkOption {
          default = 20772;

          description = ''
            HTTP port for EPGStation to listen on.
          '';

          type = lib.types.port;
        };

        options.socketioPort = lib.mkOption {
          default = cfg.settings.port + 1;
          defaultText = lib.literalExpression "config.${opt.settings}.port + 1";

          description = ''
            Socket.io port for EPGStation to listen on. It is valid to share
            ports with {option}`${opt.settings}.port`.
          '';

          type = lib.types.port;
        };

        freeformType = yaml.type;
      };
    };

    usePreconfiguredStreaming = lib.mkOption {
      default = true;

      description = ''
        Use preconfigured default streaming options.

        Upstream defaults:
        <https://github.com/l3tnun/EPGStation/blob/master/config/config.yml.template>
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(lib.hasAttr "readOnlyOnce" cfg.settings);

        message = ''
          The option config.${opt.settings}.readOnlyOnce can no longer be used
          since it's been removed. No replacements are available.
        '';
      }
    ];

    environment.etc = {
      "epgstation/epgUpdaterLogConfig.yml".source = logConfig;
      "epgstation/operatorLogConfig.yml".source = logConfig;
      "epgstation/serviceLogConfig.yml".source = logConfig;
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = with cfg.settings; [
        port
        socketioPort
      ];
    };

    services.epgstation.settings =
      let
        defaultSettings = {
          dbtype = lib.mkDefault "mysql";
          ffmpeg = lib.mkDefault "${cfg.ffmpeg}/bin/ffmpeg";
          ffprobe = lib.mkDefault "${cfg.ffmpeg}/bin/ffprobe";

          mysql = {
            database = cfg.database.name;
            password = lib.mkDefault "@dbPassword@";
            socketPath = lib.mkDefault "/run/mysqld/mysqld.sock";
            user = username;
          };

          # for disambiguation with TypeScript files
          recordedFileExtension = lib.mkDefault ".m2ts";
        };
      in
      lib.mkMerge [
        defaultSettings
        (lib.mkIf cfg.usePreconfiguredStreaming streamingConfig)
      ];

    services.mirakurun.enable = lib.mkDefault true;

    services.mysql = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];
      # FIXME: enable once mysqljs supports auth_socket
      # https://github.com/mysqljs/mysql/issues/1507
      #
      # ensureUsers = [ {
      #   name = username;
      #   ensurePermissions = { "${cfg.database.name}.*" = "ALL PRIVILEGES"; };
      # } ];
    };

    systemd.services.epgstation = {
      inherit description;

      after = [
        "network.target"
      ]
      ++ lib.optional config.services.mirakurun.enable "mirakurun.service"
      ++ lib.optional config.services.mysql.enable "mysql.service";

      environment.NODE_ENV = "production";

      serviceConfig = {
        CacheDirectory = "epgstation";
        ConfigurationDirectory = "epgstation";
        ExecStart = "${cfg.package}/bin/epgstation start";
        ExecStartPre = "+${preStartScript}";
        Group = groupname;
        LogsDirectory = "epgstation";
        StateDirectory = "epgstation";
        User = username;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-epgstation" = lib.listToAttrs (
      map
        (
          dir:
          lib.nameValuePair dir {
            d = {
              group = groupname;
              user = username;
            };
          }
        )
        [
          "/var/lib/epgstation/key"
          "/var/lib/epgstation/streamfiles"
          "/var/lib/epgstation/drop"
          "/var/lib/epgstation/recorded"
          "/var/lib/epgstation/thumbnail"
          "/var/lib/epgstation/db/subscribers"
          "/var/lib/epgstation/db/migrations/mysql"
          "/var/lib/epgstation/db/migrations/postgres"
          "/var/lib/epgstation/db/migrations/sqlite"
        ]
    );

    users.groups.epgstation = { };

    users.users.epgstation = {
      description = "EPGStation user";
      group = config.users.groups.epgstation.name;
      # npm insists on creating ~/.npm
      home = "/var/cache/epgstation";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ midchildan ];
}
