{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.redmine;
  format = pkgs.formats.yaml { };
  bundle = "${cfg.package}/share/redmine/bin/bundle";

  databaseSettings = {
    production = {
      adapter = cfg.database.type;

      database =
        if cfg.database.type == "sqlite3" then "${cfg.stateDir}/database.sqlite3" else cfg.database.name;
    }
    // lib.optionalAttrs (cfg.database.type != "sqlite3") {
      host =
        if (cfg.database.type == "postgresql" && cfg.database.socket != null) then
          cfg.database.socket
        else
          cfg.database.host;

      port = cfg.database.port;
      username = cfg.database.user;
    }
    // lib.optionalAttrs (cfg.database.type != "sqlite3" && cfg.database.passwordFile != null) {
      password = "#dbpass#";
    }
    // lib.optionalAttrs (cfg.database.type == "mysql2" && cfg.database.socket != null) {
      socket = cfg.database.socket;
    };
  };

  databaseYml = format.generate "database.yml" databaseSettings;

  configurationYml = format.generate "configuration.yml" cfg.settings;
  additionalEnvironment = pkgs.writeText "additional_environment.rb" cfg.extraEnv;

  unpackTheme = unpack "theme";
  unpackPlugin = unpack "plugin";
  unpack =
    id:
    (
      name: source:
      pkgs.stdenv.mkDerivation {
        buildCommand = ''
          mkdir -p $out
          cd $out
          unpackFile ${source}
        '';

        name = "redmine-${id}-${name}";
        nativeBuildInputs = [ pkgs.unzip ];
      }
    );

  mysqlLocal = cfg.database.createLocally && cfg.database.type == "mysql2";
  pgsqlLocal = cfg.database.createLocally && cfg.database.type == "postgresql";

in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "redmine"
      "extraConfig"
    ] "Use services.redmine.settings instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "redmine"
      "database"
      "password"
    ] "Use services.redmine.database.passwordFile instead.")
  ];

  # interface
  options = {
    services.redmine = {
      enable = lib.mkEnableOption "Redmine, a project management web application";

      package = lib.mkPackageOption pkgs "redmine" {
        example = "redmine.override { ruby = pkgs.ruby_3_3; }";
      };

      address = lib.mkOption {
        default = "0.0.0.0";
        description = "IP address Redmine should bind to.";
        type = lib.types.str;
      };

      components = {
        breezy = lib.mkEnableOption "bazaar integration";
        cvs = lib.mkEnableOption "cvs integration";
        ghostscript = lib.mkEnableOption "exporting Gant diagrams as PDF";
        git = lib.mkEnableOption "git integration";
        imagemagick = lib.mkEnableOption "exporting Gant diagrams as PNG";
        mercurial = lib.mkEnableOption "Mercurial integration";

        minimagick_font_path = lib.mkOption {
          default = "";
          description = "MiniMagick font path";
          example = "/run/current-system/sw/share/X11/fonts/LiberationSans-Regular.ttf";
          type = lib.types.str;
        };

        pandoc = lib.mkEnableOption "pandoc integration for previewing LibreOffice and Microsoft Office documents";
        subversion = lib.mkEnableOption "Subversion integration";
      };

      database = {
        createLocally = lib.mkOption {
          default = true;
          description = "Create the database and database user locally.";
          type = lib.types.bool;
        };

        host = lib.mkOption {
          default = "localhost";
          description = "Database host address.";
          type = lib.types.str;
        };

        name = lib.mkOption {
          default = "redmine";
          description = "Database name.";
          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = null;

          description = ''
            A file containing the password corresponding to
            {option}`database.user`.
          '';

          example = "/run/keys/redmine-dbpassword";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = if cfg.database.type == "postgresql" then 5432 else 3306;
          defaultText = lib.literalExpression "3306";
          description = "Database host port.";
          type = lib.types.port;
        };

        socket = lib.mkOption {
          default =
            if mysqlLocal then
              "/run/mysqld/mysqld.sock"
            else if pgsqlLocal then
              "/run/postgresql"
            else
              null;

          defaultText = lib.literalExpression "/run/mysqld/mysqld.sock";
          description = "Path to the unix socket file to use for authentication.";
          example = "/run/mysqld/mysqld.sock";
          type = lib.types.nullOr lib.types.path;
        };

        type = lib.mkOption {
          default = "mysql2";
          description = "Database engine to use.";
          example = "postgresql";

          type = lib.types.enum [
            "mysql2"
            "postgresql"
            "sqlite3"
          ];
        };

        user = lib.mkOption {
          default = "redmine";
          description = "Database user.";
          type = lib.types.str;
        };
      };

      extraEnv = lib.mkOption {
        default = "";

        description = ''
          Extra configuration in additional_environment.rb.

          See <https://svn.redmine.org/redmine/trunk/config/additional_environment.rb.example>
          for details.
        '';

        example = ''
          config.logger.level = Logger::DEBUG
        '';

        type = lib.types.lines;
      };

      group = lib.mkOption {
        default = "redmine";
        description = "Group under which Redmine is ran.";
        type = lib.types.str;
      };

      plugins = lib.mkOption {
        default = { };
        description = "Set of plugins.";

        example = lib.literalExpression ''
          {
            redmine_env_auth = builtins.fetchurl {
              url = "https://github.com/Intera/redmine_env_auth/archive/0.6.zip";
              sha256 = "0yyr1yjd8gvvh832wdc8m3xfnhhxzk2pk3gm2psg5w9jdvd6skak";
            };
          }
        '';

        type = lib.types.attrsOf lib.types.path;
      };

      port = lib.mkOption {
        default = 3000;
        description = "Port on which Redmine is ran.";
        type = lib.types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Redmine configuration ({file}`configuration.yml`). Refer to
          <https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration>
          for details.
        '';

        example = lib.literalExpression ''
          {
            email_delivery = {
              delivery_method = "smtp";
              smtp_settings = {
                address = "mail.example.com";
                port = 25;
              };
            };
          }
        '';

        type = format.type;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/redmine";
        description = "The state directory, logs and plugins are stored here.";
        type = lib.types.path;
      };

      themes = lib.mkOption {
        default = { };
        description = "Set of themes.";

        example = lib.literalExpression ''
          {
            dkuk-redmine_alex_skin = builtins.fetchurl {
              url = "https://bitbucket.org/dkuk/redmine_alex_skin/get/1842ef675ef3.zip";
              sha256 = "0hrin9lzyi50k4w2bd2b30vrf1i4fi1c0gyas5801wn8i7kpm9yl";
            };
          }
        '';

        type = lib.types.attrsOf lib.types.path;
      };

      user = lib.mkOption {
        default = "redmine";
        description = "User under which Redmine is ran.";
        type = lib.types.str;
      };
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.database.type != "sqlite3" -> cfg.database.passwordFile != null || cfg.database.socket != null;

        message = "one of services.redmine.database.socket or services.redmine.database.passwordFile must be set";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.user == cfg.user;
        message = "services.redmine.database.user must be set to ${cfg.user} if services.redmine.database.createLocally is set true";
      }
      {
        assertion = pgsqlLocal -> cfg.database.user == cfg.database.name;
        message = "services.redmine.database.user and services.redmine.database.name must be the same when using a local postgresql database";
      }
      {
        assertion =
          (cfg.database.createLocally && cfg.database.type != "sqlite3") -> cfg.database.socket != null;

        message = "services.redmine.database.socket must be set if services.redmine.database.createLocally is set to true and no sqlite database is used";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.host == "localhost";
        message = "services.redmine.database.host must be set to localhost if services.redmine.database.createLocally is set to true";
      }
      {
        assertion = cfg.components.imagemagick -> cfg.components.minimagick_font_path != "";
        message = "services.redmine.components.minimagick_font_path must be configured with a path to a font file if services.redmine.components.imagemagick is set to true.";
      }
    ];

    services.mysql = lib.mkIf mysqlLocal {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.user;
        }
      ];
    };

    services.postgresql = lib.mkIf pgsqlLocal {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    services.redmine.extraEnv = lib.mkBefore ''
      config.logger = Logger.new("${cfg.stateDir}/log/production.log", 14, 1048576)
      config.logger.level = Logger::INFO
    '';

    services.redmine.settings = {
      production = {
        gs_command = lib.optionalString cfg.components.ghostscript "${pkgs.ghostscript}/bin/gs";
        imagemagick_convert_command = lib.optionalString cfg.components.imagemagick "${pkgs.imagemagick}/bin/convert";
        minimagick_font_path = "${cfg.components.minimagick_font_path}";
        pandoc_command = lib.optionalString cfg.components.pandoc "${pkgs.pandoc}/bin/pandoc";
        scm_bazaar_command = lib.optionalString cfg.components.breezy "${pkgs.breezy}/bin/bzr";
        scm_cvs_command = lib.optionalString cfg.components.cvs "${pkgs.cvs}/bin/cvs";
        scm_git_command = lib.optionalString cfg.components.git "${pkgs.git}/bin/git";
        scm_mercurial_command = lib.optionalString cfg.components.mercurial "${pkgs.mercurial}/bin/hg";
        scm_subversion_command = lib.optionalString cfg.components.subversion "${pkgs.subversion}/bin/svn";
      };
    };

    systemd.services.redmine = {
      after = [
        "network.target"
      ]
      ++ lib.optional mysqlLocal "mysql.service"
      ++ lib.optional pgsqlLocal "postgresql.target";

      environment.RAILS_CACHE = "${cfg.stateDir}/cache";
      environment.RAILS_ENV = "production";
      environment.REDMINE_LANG = "en";
      environment.SCHEMA = "${cfg.stateDir}/cache/schema.db";

      path =
        with pkgs;
        [
        ]
        ++ lib.optional cfg.components.subversion subversion
        ++ lib.optional cfg.components.mercurial mercurial
        ++ lib.optional cfg.components.git git
        ++ lib.optional cfg.components.cvs cvs
        ++ lib.optional cfg.components.breezy breezy
        ++ lib.optional cfg.components.imagemagick imagemagick
        ++ lib.optional cfg.components.ghostscript ghostscript;

      preStart = ''
        # Create symlinks for the basic directory layout the redmine package
        # expects. This part must be done in preStart rather than tmpfiles,
        # because /run/redmine is re-created when the service is restarted
        mkdir /run/redmine/public
        ln -s "${cfg.stateDir}/config" /run/redmine/config
        ln -s "${cfg.stateDir}/files" /run/redmine/files
        ln -s "${cfg.stateDir}/log" /run/redmine/log
        ln -s "${cfg.stateDir}/plugins" /run/redmine/plugins
        ln -s "${cfg.stateDir}/public/assets" /run/redmine/public/assets
        ln -s "${cfg.stateDir}/public/plugin_assets" /run/redmine/public/plugin_assets
        ln -s "${cfg.stateDir}/themes" /run/redmine/themes
        ln -s "${cfg.stateDir}/tmp" /run/redmine/tmp

        rm -rf "${cfg.stateDir}/plugins/"*
        rm -rf "${cfg.stateDir}/themes/"*

        # start with a fresh config directory
        # the config directory is copied instead of linked as some mutable data is stored in there
        find "${cfg.stateDir}/config" ! -name "secret_token.rb" -type f -exec rm -f {} +
        cp -r ${cfg.package}/share/redmine/config.dist/* "${cfg.stateDir}/config/"

        chmod -R u+w "${cfg.stateDir}/config"

        # link in the application configuration
        ln -fs ${configurationYml} "${cfg.stateDir}/config/configuration.yml"

        # link in the additional environment configuration
        ln -fs ${additionalEnvironment} "${cfg.stateDir}/config/additional_environment.rb"


        # link in all user specified themes
        for theme in ${lib.concatStringsSep " " (lib.mapAttrsToList unpackTheme cfg.themes)}; do
          ln -fs $theme/* "${cfg.stateDir}/themes"
        done

        # link in redmine provided themes
        ln -sf ${cfg.package}/share/redmine/themes.dist/* "${cfg.stateDir}/themes/"


        # link in all user specified plugins
        for plugin in ${lib.concatStringsSep " " (lib.mapAttrsToList unpackPlugin cfg.plugins)}; do
          ln -fs $plugin/* "${cfg.stateDir}/plugins/''${plugin##*-redmine-plugin-}"
        done


        # handle database.passwordFile & permissions
        cp -f ${databaseYml} "${cfg.stateDir}/config/database.yml"

        ${lib.optionalString ((cfg.database.type != "sqlite3") && (cfg.database.passwordFile != null)) ''
          DBPASS="$(head -n1 ${cfg.database.passwordFile})"
          sed -e "s,#dbpass#,$DBPASS,g" -i "${cfg.stateDir}/config/database.yml"
        ''}

        chmod 440 "${cfg.stateDir}/config/database.yml"


        # generate a secret token if required
        if ! test -e "${cfg.stateDir}/config/initializers/secret_token.rb"; then
          ${bundle} exec rake generate_secret_token
          chmod 440 "${cfg.stateDir}/config/initializers/secret_token.rb"
        fi

        # execute redmine required commands prior to starting the application
        ${bundle} exec rake db:migrate
        ${bundle} exec rake redmine:plugins:migrate
        ${bundle} exec rake redmine:load_default_data
        ${bundle} exec rake assets:precompile
      '';

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        ExecStart = "${bundle} exec rails server -u webrick -e production -b ${toString cfg.address} -p ${toString cfg.port} -P '${cfg.stateDir}/redmine.pid'";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        ReadWritePaths = [
          cfg.stateDir
        ];

        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "redmine";
        RuntimeDirectoryMode = "0750";
        SystemCallArchitectures = "native";
        TimeoutSec = "300";
        Type = "simple";
        UMask = 27;
        User = cfg.user;
        WorkingDirectory = "${cfg.package}/share/redmine";
      };

      wantedBy = [ "multi-user.target" ];
    };

    # create symlinks for the basic directory layout the redmine package expects
    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/cache' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/config' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/files' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/log' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/plugins' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/public' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/public/assets' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/public/plugin_assets' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/themes' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/tmp' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "redmine") {
      redmine.gid = config.ids.gids.redmine;
    };

    users.users = lib.optionalAttrs (cfg.user == "redmine") {
      redmine = {
        group = cfg.group;
        home = cfg.stateDir;
        uid = config.ids.uids.redmine;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ felixsinger ];
}
