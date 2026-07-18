{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.monica;
  monica = pkgs.monica.override {
    dataDir = cfg.dataDir;
  };
  db = cfg.database;
  mail = cfg.mail;

  user = cfg.user;
  group = cfg.group;

  php = lib.getExe cfg.phpPackage;

  # shell script for local administration
  artisan = pkgs.writeScriptBin "monica" ''
    #! ${pkgs.runtimeShell}
    cd ${monica}
    sudo() {
      if [[ "$USER" != ${user} ]]; then
        exec /run/wrappers/bin/sudo -u ${user} "$@"
      else
        exec "$@"
      fi
    }
    sudo ${php} artisan "$@"
  '';

  tlsEnabled = cfg.nginx.addSSL || cfg.nginx.forceSSL || cfg.nginx.onlySSL || cfg.nginx.enableACME;
in
{
  options.services.monica = {
    config = mkOption {
      default = { };

      description = ''
        monica configuration options to set in the
        <filename>.env</filename> file.

        Refer to <https://github.com/monicahq/monica>
        for details on supported values.

        Settings containing secret data should be set to an attribute
        set containing the attribute `_secret` - a
        string pointing to a file containing the value the option
        should be set to. See the example to get a better picture of
        this: in the resulting <filename>.env</filename> file, the
        `OIDC_CLIENT_SECRET` key will be set to the
        contents of the <filename>/run/keys/oidc_secret</filename>
        file.
      '';

      example = ''
        {
          ALLOWED_IFRAME_HOSTS = "https://example.com";
          WKHTMLTOPDF = "/home/user/bins/wkhtmltopdf";
          AUTH_METHOD = "oidc";
          OIDC_NAME = "MyLogin";
          OIDC_DISPLAY_NAME_CLAIMS = "name";
          OIDC_CLIENT_ID = "monica";
          OIDC_CLIENT_SECRET = {_secret = "/run/keys/oidc_secret"};
          OIDC_ISSUER = "https://keycloak.example.com/auth/realms/My%20Realm";
          OIDC_ISSUER_DISCOVER = true;
        }
      '';

      type =
        with types;
        attrsOf (
          nullOr (
            either
              (oneOf [
                bool
                int
                port
                path
                str
              ])
              (submodule {
                options = {
                  _secret = mkOption {
                    description = ''
                      The path to a file containing the value the
                      option should be set to in the final
                      configuration file.
                    '';

                    type = nullOr str;
                  };
                };
              })
          )
        );
    };

    enable = mkEnableOption "monica";

    appKeyFile = mkOption {
      description = ''
        A file containing the Laravel APP_KEY - a 32 character long,
        base64 encoded key used for encryption where needed. Can be
        generated with <code>head -c 32 /dev/urandom | base64</code>.
      '';

      example = "/run/keys/monica-appkey";
      type = types.path;
    };

    appURL = mkOption {
      default = "http${lib.optionalString tlsEnabled "s"}://${cfg.hostname}";
      defaultText = ''http''${lib.optionalString tlsEnabled "s"}://''${cfg.hostname}'';

      description = ''
        The root URL that you want to host monica on. All URLs in monica will be generated using this value.
        If you change this in the future you may need to run a command to update stored URLs in the database.
        Command example: <code>php artisan monica:update-url https://old.example.com https://new.example.com</code>
      '';

      example = "https://example.com";
      type = types.str;
    };

    dataDir = mkOption {
      default = "/var/lib/monica";
      description = "monica data directory";
      type = types.path;
    };

    database = {
      createLocally = mkOption {
        default = true;
        description = "Create the database and database user locally.";
        type = types.bool;
      };

      host = mkOption {
        default = "localhost";
        description = "Database host address.";
        type = types.str;
      };

      name = mkOption {
        default = "monica";
        description = "Database name.";
        type = types.str;
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          A file containing the password corresponding to
          <option>database.user</option>.
        '';

        example = "/run/keys/monica-dbpassword";
        type = with types; nullOr path;
      };

      port = mkOption {
        default = 3306;
        description = "Database host port.";
        type = types.port;
      };

      user = mkOption {
        default = user;
        defaultText = lib.literalExpression "user";
        description = "Database username.";
        type = types.str;
      };
    };

    group = mkOption {
      default = "monica";
      description = "Group monica runs as.";
      type = types.str;
    };

    hostname = lib.mkOption {
      default =
        if config.networking.domain != null then config.networking.fqdn else config.networking.hostName;

      defaultText = lib.literalExpression "config.networking.fqdn";

      description = ''
        The hostname to serve monica on.
      '';

      example = "monica.example.com";
      type = lib.types.str;
    };

    mail = {
      driver = mkOption {
        default = "smtp";
        description = "Mail driver to use.";

        type = types.enum [
          "smtp"
          "sendmail"
        ];
      };

      encryption = mkOption {
        default = null;
        description = "SMTP encryption mechanism to use.";
        type = with types; nullOr (enum [ "tls" ]);
      };

      from = mkOption {
        default = "mail@monica.com";
        description = "Mail \"from\" email.";
        type = types.str;
      };

      fromName = mkOption {
        default = "monica";
        description = "Mail \"from\" name.";
        type = types.str;
      };

      host = mkOption {
        default = "localhost";
        description = "Mail host address.";
        type = types.str;
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          A file containing the password corresponding to
          <option>mail.user</option>.
        '';

        example = "/run/keys/monica-mailpassword";
        type = with types; nullOr path;
      };

      port = mkOption {
        default = 1025;
        description = "Mail host port.";
        type = types.port;
      };

      user = mkOption {
        default = null;
        description = "Mail username.";
        example = "monica";
        type = with types; nullOr str;
      };
    };

    maxUploadSize = mkOption {
      default = "18M";
      description = "The maximum size for uploads (e.g. images).";
      example = "1G";
      type = types.str;
    };

    nginx = mkOption {
      default = { };

      description = ''
        With this option, you can customize the nginx virtualHost settings.
      '';

      example = ''
        {
          serverAliases = [
            "monica.''${config.networking.domain}"
          ];
          # To enable encryption and let let's encrypt take care of certificate
          forceSSL = true;
          enableACME = true;
        }
      '';

      type = types.submodule (
        recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) { }
      );
    };

    phpPackage = mkPackageOption pkgs "php83" { };

    poolConfig = mkOption {
      default = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.max_spare_servers" = 4;
        "pm.min_spare_servers" = 2;
        "pm.start_servers" = 2;
      };

      description = ''
        Options for the monica PHP pool. See the documentation on <literal>php-fpm.conf</literal>
        for details on configuration directives.
      '';

      type =
        with types;
        attrsOf (oneOf [
          str
          int
          bool
        ]);
    };

    user = mkOption {
      default = "monica";
      description = "User monica runs as.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = db.createLocally -> db.user == user;
        message = "services.monica.database.user must be set to ${user} if services.monica.database.createLocally is set true.";
      }
      {
        assertion = db.createLocally -> db.passwordFile == null;
        message = "services.monica.database.passwordFile cannot be specified if services.monica.database.createLocally is set to true.";
      }
    ];

    environment.systemPackages = [ artisan ];

    services.monica.config = {
      APP_CONFIG_CACHE = "/run/monica/cache/config.php";
      APP_ENV = "production";
      APP_EVENTS_CACHE = "/run/monica/cache/events.php";
      APP_KEY._secret = cfg.appKeyFile;
      APP_PACKAGES_CACHE = "/run/monica/cache/packages.php";
      APP_ROUTES_CACHE = "/run/monica/cache/routes-v7.php";
      APP_SERVICES_CACHE = "/run/monica/cache/services.php";
      APP_URL = cfg.appURL;
      DB_DATABASE = db.name;
      DB_HOST = db.host;
      DB_PASSWORD._secret = db.passwordFile;
      DB_PORT = db.port;
      DB_USERNAME = db.user;
      MAIL_DRIVER = mail.driver;
      MAIL_ENCRYPTION = mail.encryption;
      MAIL_FROM_ADDRESS = mail.from;
      MAIL_FROM_NAME = mail.fromName;
      MAIL_HOST = mail.host;
      MAIL_PASSWORD._secret = mail.passwordFile;
      MAIL_PORT = mail.port;
      MAIL_USERNAME = mail.user;
      SESSION_SECURE_COOKIE = tlsEnabled;
    };

    services.mysql = mkIf db.createLocally {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ db.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${db.name}.*" = "ALL PRIVILEGES";
          };

          name = db.user;
        }
      ];
    };

    services.nginx = {
      enable = mkDefault true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts.${cfg.hostname} = mkMerge [
        cfg.nginx
        {
          locations = {
            "/" = {
              index = "index.php";
              tryFiles = "$uri $uri/ /index.php?$query_string";
            };

            "~ \\.(js|css|gif|png|ico|jpg|jpeg)$" = {
              extraConfig = "expires 365d;";
            };

            "~ \\.php$".extraConfig = ''
              fastcgi_pass unix:${config.services.phpfpm.pools."monica".socket};
            '';
          };

          root = mkForce "${monica}/public";
        }
      ];
    };

    services.phpfpm.pools.monica = {
      inherit user group;

      phpOptions = ''
        log_errors = on
        post_max_size = ${cfg.maxUploadSize}
        upload_max_filesize = ${cfg.maxUploadSize}
      '';

      phpPackage = cfg.phpPackage;

      settings = {
        "listen.group" = group;
        "listen.mode" = "0660";
        "listen.owner" = user;
      }
      // cfg.poolConfig;
    };

    systemd.services.monica-scheduler = {
      after = [ "monica-setup.service" ];
      description = "Background tasks for monica";

      serviceConfig = {
        ExecStart = "${php} ${monica}/artisan schedule:run -v";
        Type = "oneshot";
        User = user;
        WorkingDirectory = "${monica}";
      };

      startAt = "minutely";
    };

    systemd.services.monica-setup = {
      after = optional db.createLocally "mysql.service";
      before = [ "phpfpm-monica.service" ];
      description = "Preparation tasks for monica";
      path = [ pkgs.replace-secret ];

      script =
        let
          isSecret = v: isAttrs v && v ? _secret && isString v._secret;
          monicaEnvVars = lib.generators.toKeyValue {
            mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
              mkValueString =
                v:
                with builtins;
                if isInt v then
                  toString v
                else if isString v then
                  v
                else if true == v then
                  "true"
                else if false == v then
                  "false"
                else if isSecret v then
                  hashString "sha256" v._secret
                else
                  throw "unsupported type ${typeOf v}: ${(lib.generators.toPretty { }) v}";
            };
          };
          secretPaths = lib.mapAttrsToList (_: v: v._secret) (lib.filterAttrs (_: isSecret) cfg.config);
          mkSecretReplacement = file: ''
            replace-secret ${
              escapeShellArgs [
                (builtins.hashString "sha256" file)
                file
                "${cfg.dataDir}/.env"
              ]
            }
          '';
          secretReplacements = lib.concatMapStrings mkSecretReplacement secretPaths;
          filteredConfig = lib.converge (lib.filterAttrsRecursive (
            _: v:
            !elem v [
              { }
              null
            ]
          )) cfg.config;
          monicaEnv = pkgs.writeText "monica.env" (monicaEnvVars filteredConfig);
        in
        ''
          # error handling
          set -euo pipefail

          # create .env file
          install -T -m 0600 -o ${user} ${monicaEnv} "${cfg.dataDir}/.env"
          ${secretReplacements}
          if ! grep 'APP_KEY=base64:' "${cfg.dataDir}/.env" >/dev/null; then
            sed -i 's/APP_KEY=/APP_KEY=base64:/' "${cfg.dataDir}/.env"
          fi

          # migrate & seed db
          ${php} artisan key:generate --force
          ${php} artisan setup:production -v --force
        '';

      serviceConfig = {
        RemainAfterExit = true;
        RuntimeDirectory = "monica/cache";
        RuntimeDirectoryMode = 700;
        Type = "oneshot";
        UMask = 77;
        User = user;
        WorkingDirectory = "${monica}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                            0710 ${user} ${group} - -"
      "d ${cfg.dataDir}/public                     0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/public/uploads             0750 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage                    0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/app                0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/fonts              0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework          0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework/cache    0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework/sessions 0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/framework/views    0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/logs               0700 ${user} ${group} - -"
      "d ${cfg.dataDir}/storage/uploads            0700 ${user} ${group} - -"
    ];

    users = {
      groups = mkIf (group == "monica") {
        monica = { };
      };

      users = mkIf (user == "monica") {
        "${config.services.nginx.user}".extraGroups = [ group ];

        monica = {
          inherit group;
          isSystemUser = true;
        };
      };
    };
  };
}
