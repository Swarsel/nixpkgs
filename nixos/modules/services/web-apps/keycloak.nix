{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.keycloak;
  opt = options.services.keycloak;

  inherit (lib)
    types
    mkMerge
    mkOption
    mkChangedOptionModule
    mkRenamedOptionModule
    mkRemovedOptionModule
    mkPackageOption
    concatStringsSep
    mapAttrsToList
    escapeShellArg
    mkIf
    optionalString
    optionals
    mkDefault
    literalExpression
    isAttrs
    literalMD
    maintainers
    catAttrs
    collect
    hasPrefix
    ;

  inherit (builtins)
    elem
    typeOf
    isInt
    isString
    hashString
    isPath
    ;

  prefixUnlessEmpty = prefix: string: optionalString (string != "") "${prefix}${string}";
in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "keycloak" "bindAddress" ]
      [ "services" "keycloak" "settings" "http-host" ]
    )
    (mkRenamedOptionModule
      [ "services" "keycloak" "forceBackendUrlToFrontendUrl" ]
      [ "services" "keycloak" "settings" "hostname-strict-backchannel" ]
    )
    (mkChangedOptionModule
      [ "services" "keycloak" "httpPort" ]
      [ "services" "keycloak" "settings" "http-port" ]
      (config: builtins.fromJSON config.services.keycloak.httpPort)
    )
    (mkChangedOptionModule
      [ "services" "keycloak" "httpsPort" ]
      [ "services" "keycloak" "settings" "https-port" ]
      (config: builtins.fromJSON config.services.keycloak.httpsPort)
    )
    (mkRemovedOptionModule [ "services" "keycloak" "frontendUrl" ] ''
      Set `services.keycloak.settings.hostname' and `services.keycloak.settings.http-relative-path' instead.
      NOTE: You likely want to set 'http-relative-path' to '/auth' to keep compatibility with your clients.
            See its description for more information.
    '')
    (mkRemovedOptionModule [
      "services"
      "keycloak"
      "extraConfig"
    ] "Use `services.keycloak.settings' instead.")
  ];

  options.services.keycloak =
    let
      inherit (types)
        bool
        str
        int
        nullOr
        attrsOf
        oneOf
        path
        enum
        package
        port
        listOf
        ;

      assertStringPath =
        optionName: value:
        if isPath value then
          throw ''
            services.keycloak.${optionName}:
              ${toString value}
              is a Nix path, but should be a string, since Nix
              paths are copied into the world-readable Nix store.
          ''
        else
          value;
    in
    {
      enable = mkOption {
        default = false;

        description = ''
          Whether to enable the Keycloak identity and access management
          server.
        '';

        example = true;
        type = bool;
      };

      package = mkPackageOption pkgs "keycloak" { };

      database = {
        caCert = mkOption {
          default = null;

          description = ''
            The SSL / TLS CA certificate that verifies the identity of the
            database server.

            Required when PostgreSQL is used and SSL is turned on.

            For MySQL, if left at `null`, the default
            Java keystore is used, which should suffice if the server
            certificate is issued by an official CA.
          '';

          type = nullOr path;
        };

        createLocally = mkOption {
          default = true;

          description = ''
            Whether a database should be automatically created on the
            local host. Set this to false if you plan on provisioning a
            local database yourself. This has no effect if
            services.keycloak.database.host is customized.
          '';

          type = bool;
        };

        host = mkOption {
          default = "localhost";

          description = ''
            Hostname of the database to connect to.

            For PostgreSQL, this can also be a path to a Unix socket
            directory (e.g., `/run/postgresql`) to use peer authentication.
            This requires adding `junixsocket-common` and `junixsocket-native-common`
            to [](#opt-services.keycloak.plugins).
          '';

          type = str;
        };

        name = mkOption {
          default = "keycloak";

          description = ''
            Database name to use when connecting to an external or
            manually provisioned database; has no effect when a local
            database is automatically provisioned.

            To use this with a local database, set [](#opt-services.keycloak.database.createLocally) to
            `false` and create the database and user
            manually.
          '';

          type = str;
        };

        passwordFile = mkOption {
          apply = assertStringPath "passwordFile";
          default = null;

          description = ''
            The path to a file containing the database password.

            Not required when using Unix socket authentication (peer auth)
            by setting `host` to a socket path like `/run/postgresql`.
          '';

          example = "/run/keys/db_password";
          type = nullOr path;
        };

        port =
          let
            dbPorts = {
              mariadb = 3306;
              mysql = 3306;
              postgresql = 5432;
            };
          in
          mkOption {
            default = dbPorts.${cfg.database.type};
            defaultText = literalMD "default port of selected database";

            description = ''
              Port of the database to connect to.
            '';

            type = port;
          };

        type = mkOption {
          default = "postgresql";

          description = ''
            The type of database Keycloak should connect to.
          '';

          example = "mariadb";

          type = enum [
            "mysql"
            "mariadb"
            "postgresql"
          ];
        };

        useSSL = mkOption {
          default = cfg.database.host != "localhost" && !hasPrefix "/" cfg.database.host;
          defaultText = literalExpression ''config.${opt.database.host} != "localhost" && !lib.hasPrefix "/" config.${opt.database.host}'';

          description = ''
            Whether the database connection should be secured by SSL / TLS.

            Defaults to `false` for localhost and Unix socket connections.
          '';

          type = bool;
        };

        username = mkOption {
          default = "keycloak";

          description = ''
            Username to use when connecting to an external or manually
            provisioned database; has no effect when a local database is
            automatically provisioned.

            To use this with a local database, set [](#opt-services.keycloak.database.createLocally) to
            `false` and create the database and user
            manually.
          '';

          type = str;
        };
      };

      initialAdminPassword = mkOption {
        default = null;

        description = ''
          Initial password set for the temporary `admin` user.
          The password is not stored safely and should be changed
          immediately in the admin panel.

          See [Admin bootstrap and recovery](https://www.keycloak.org/server/bootstrap-admin-recovery) for details.
        '';

        type = nullOr str;
      };

      plugins = lib.mkOption {
        default = [ ];

        description = ''
          Keycloak plugin jar, ear files or derivations containing
          them. Packaged plugins are available through
          `pkgs.keycloak.plugins`.
        '';

        type = lib.types.listOf lib.types.path;
      };

      realmFiles = mkOption {
        default = [ ];

        description = ''
          Realm files that the server is going to import during startup.
          If a realm already exists in the server, the import operation is
          skipped. Importing the master realm is not supported. All files are
          expected to be in `json` format. See the
          [documentation](https://www.keycloak.org/server/importExport) for
          further information.
        '';

        example = lib.literalExpression ''
          [
            ./some/realm.json
            ./another/realm.json
          ]
        '';

        type = listOf path;
      };

      settings = mkOption {
        description = ''
          Configuration options corresponding to parameters set in
          {file}`conf/keycloak.conf`.

          Most available options are documented at <https://www.keycloak.org/server/all-config>.

          Options containing secret data should be set to an attribute
          set containing the attribute `_secret` - a
          string pointing to a file containing the value the option
          should be set to. See the example to get a better picture of
          this: in the resulting
          {file}`conf/keycloak.conf` file, the
          `https-key-store-password` key will be set
          to the contents of the
          {file}`/run/keys/store_password` file.
        '';

        example = literalExpression ''
          {
            hostname = "keycloak.example.com";
            https-key-store-file = "/path/to/file";
            https-key-store-password = { _secret = "/run/keys/store_password"; };
          }
        '';

        type = lib.types.submodule {
          options = {
            hostname = mkOption {
              description = ''
                The hostname part of the public URL used as base for
                all frontend requests.

                See <https://www.keycloak.org/server/hostname>
                for more information about hostname configuration.
              '';

              example = "keycloak.example.com";
              type = nullOr str;
            };

            hostname-backchannel-dynamic = mkOption {
              default = false;

              description = ''
                Enables dynamic resolving of backchannel URLs,
                including hostname, scheme, port and context path.

                See <https://www.keycloak.org/server/hostname>
                for more information about hostname configuration.
              '';

              example = true;
              type = bool;
            };

            http-host = mkOption {
              default = "::";

              description = ''
                On which address Keycloak should accept new connections.
              '';

              example = "::1";
              type = str;
            };

            http-port = mkOption {
              default = 80;

              description = ''
                On which port Keycloak should listen for new HTTP connections.
              '';

              example = 8080;
              type = port;
            };

            http-relative-path = mkOption {
              apply = x: if !(hasPrefix "/") x then "/" + x else x;
              default = "/";

              description = ''
                The path relative to `/` for serving
                resources.

                ::: {.note}
                In versions of Keycloak using Wildfly (&lt;17),
                this defaulted to `/auth`. If
                upgrading from the Wildfly version of Keycloak,
                i.e. a NixOS version before 22.05, you'll likely
                want to set this to `/auth` to
                keep compatibility with your clients.

                See <https://www.keycloak.org/migration/migrating-to-quarkus>
                for more information on migrating from Wildfly to Quarkus.
                :::
              '';

              example = "/auth";
              type = str;
            };

            https-port = mkOption {
              default = 443;

              description = ''
                On which port Keycloak should listen for new HTTPS connections.
              '';

              example = 8443;
              type = port;
            };
          };

          freeformType = attrsOf (
            nullOr (oneOf [
              str
              int
              bool
              (attrsOf path)
            ])
          );
        };
      };

      sslCertificate = mkOption {
        apply = assertStringPath "sslCertificate";
        default = null;

        description = ''
          The path to a PEM formatted certificate to use for TLS/SSL
          connections.
        '';

        example = "/run/keys/ssl_cert";
        type = nullOr path;
      };

      sslCertificateKey = mkOption {
        apply = assertStringPath "sslCertificateKey";
        default = null;

        description = ''
          The path to a PEM formatted private key to use for TLS/SSL
          connections.
        '';

        example = "/run/keys/ssl_key";
        type = nullOr path;
      };

      themes = mkOption {
        default = { };

        description = ''
          Additional theme packages for Keycloak. Each theme is linked into
          subdirectory with a corresponding attribute name.

          Theme packages consist of several subdirectories which provide
          different theme types: for example, `account`,
          `login` etc. After adding a theme to this option you
          can select it by its name in Keycloak administration console.
        '';

        type = attrsOf package;
      };
    };

  config =
    let
      # We only want to create a database if we're actually going to
      # connect to it.
      databaseActuallyCreateLocally = cfg.database.createLocally && cfg.database.host == "localhost";
      createLocalPostgreSQL = databaseActuallyCreateLocally && cfg.database.type == "postgresql";
      createLocalMySQL =
        databaseActuallyCreateLocally
        && elem cfg.database.type [
          "mysql"
          "mariadb"
        ];

      mySqlCaKeystore = pkgs.runCommand "mysql-ca-keystore" { } ''
        ${pkgs.jre}/bin/keytool -importcert -trustcacerts -alias MySQLCACert -file ${cfg.database.caCert} -keystore $out -storepass notsosecretpassword -noprompt
      '';

      # Both theme and theme type directories need to be actual
      # directories in one hierarchy to pass Keycloak checks.
      themesBundle = pkgs.runCommand "keycloak-themes" { } ''
        linkTheme() {
          theme="$1"
          name="$2"

          mkdir "$out/$name"
          for typeDir in "$theme"/*; do
            if [ -d "$typeDir" ]; then
              type="$(basename "$typeDir")"
              mkdir "$out/$name/$type"
              for file in "$typeDir"/*; do
                ln -sn "$file" "$out/$name/$type/$(basename "$file")"
              done
            fi
          done
        }

        mkdir -p "$out"
        for theme in ${keycloakBuild}/themes/*; do
          if [ -d "$theme" ]; then
            linkTheme "$theme" "$(basename "$theme")"
          fi
        done

        ${concatStringsSep "\n" (
          mapAttrsToList (name: theme: "linkTheme ${theme} ${escapeShellArg name}") cfg.themes
        )}
      '';

      keycloakConfig = lib.generators.toKeyValue {
        mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
          mkValueString =
            v:
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

      isSecret = v: isAttrs v && v ? _secret && isString v._secret;
      filteredConfig = lib.converge (lib.filterAttrsRecursive (
        _: v:
        !elem v [
          { }
          null
        ]
      )) cfg.settings;
      confFile = pkgs.writeText "keycloak.conf" (keycloakConfig filteredConfig);
      keycloakBuild = cfg.package.override {
        inherit confFile;

        plugins =
          cfg.package.enabledPlugins
          ++ cfg.plugins
          ++ (with cfg.package.plugins; [
            quarkus-systemd-notify
            quarkus-systemd-notify-deployment
          ]);
      };
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion =
            (cfg.database.useSSL && cfg.database.type == "postgresql") -> (cfg.database.caCert != null);

          message = "A CA certificate must be specified (in 'services.keycloak.database.caCert') when PostgreSQL is used with SSL";
        }
        {
          assertion =
            createLocalPostgreSQL -> config.services.postgresql.settings.standard_conforming_strings or true;

          message = "Setting up a local PostgreSQL db for Keycloak requires `standard_conforming_strings` turned on to work reliably";
        }
        {
          assertion = cfg.settings.hostname != null || !cfg.settings.hostname-strict or true;
          message = "Setting the Keycloak hostname is required, see `services.keycloak.settings.hostname`";
        }
        {
          assertion = cfg.settings.hostname-url or null == null;

          message = ''
            The option `services.keycloak.settings.hostname-url' has been removed.
            Set `services.keycloak.settings.hostname' instead.
            See [New Hostname options](https://www.keycloak.org/docs/25.0.0/upgrading/#new-hostname-options) for details.
          '';
        }
        {
          assertion = cfg.settings.hostname-strict-backchannel or null == null;

          message = ''
            The option `services.keycloak.settings.hostname-strict-backchannel' has been removed.
            Set `services.keycloak.settings.hostname-backchannel-dynamic' instead.
            See [New Hostname options](https://www.keycloak.org/docs/25.0.0/upgrading/#new-hostname-options) for details.
          '';
        }
        {
          assertion = cfg.settings.proxy or null == null;

          message = ''
            The option `services.keycloak.settings.proxy' has been removed.
            Set `services.keycloak.settings.proxy-headers` in combination
            with other hostname options as needed instead.
            See [Proxy option removed](https://www.keycloak.org/docs/latest/upgrading/index.html#proxy-option-removed)
            for more information.
          '';
        }
        {
          assertion = cfg.database.passwordFile != null || hasPrefix "/" cfg.database.host;

          message = ''
            services.keycloak.database.passwordFile must be set unless using
            Unix socket authentication (host starting with /).
          '';
        }
      ];

      environment.systemPackages = [ keycloakBuild ];

      services.keycloak.settings =
        let
          postgresParams = concatStringsSep "&" (
            optionals cfg.database.useSSL [
              "ssl=true"
            ]
            ++ optionals (cfg.database.caCert != null) [
              "sslrootcert=${cfg.database.caCert}"
              "sslmode=verify-ca"
            ]
          );
          mariadbParams = concatStringsSep "&" (
            [
              "characterEncoding=UTF-8"
            ]
            ++ optionals cfg.database.useSSL [
              "useSSL=true"
              "requireSSL=true"
              "verifyServerCertificate=true"
            ]
            ++ optionals (cfg.database.caCert != null) [
              "trustCertificateKeyStoreUrl=file:${mySqlCaKeystore}"
              "trustCertificateKeyStorePassword=notsosecretpassword"
            ]
          );

          dbName = if databaseActuallyCreateLocally then "keycloak" else cfg.database.name;
          dbProps = if cfg.database.type == "postgresql" then postgresParams else mariadbParams;

          # Unix socket connection requires junixsocket library and special JDBC URL
          isUnixSocket = hasPrefix "/" cfg.database.host;
          unixSocketUrl = "jdbc:postgresql://localhost/${dbName}?socketFactory=org.newsclub.net.unix.AFUNIXSocketFactory$FactoryArg&socketFactoryArg=${cfg.database.host}/.s.PGSQL.${toString cfg.database.port}&sslMode=disable";
        in
        mkMerge [
          {
            db = if cfg.database.type == "postgresql" then "postgres" else cfg.database.type;

            db-password = mkIf (cfg.database.passwordFile != null) {
              _secret = cfg.database.passwordFile;
            };

            db-username = if databaseActuallyCreateLocally then "keycloak" else cfg.database.username;
          }
          (mkIf isUnixSocket {
            db-url = unixSocketUrl;
          })
          (mkIf (!isUnixSocket) {
            db-url = null;
            db-url-database = dbName;
            db-url-host = cfg.database.host;
            db-url-port = toString cfg.database.port;
            db-url-properties = prefixUnlessEmpty "?" dbProps;
          })
          (mkIf (cfg.sslCertificate != null && cfg.sslCertificateKey != null) {
            https-certificate-file = "/run/keycloak/ssl/ssl_cert";
            https-certificate-key-file = "/run/keycloak/ssl/ssl_key";
          })
        ];

      services.mysql.enable = mkDefault createLocalMySQL;

      services.mysql.package =
        let
          dbPkg = if cfg.database.type == "mariadb" then pkgs.mariadb else pkgs.mysql84;
        in
        mkIf createLocalMySQL (mkDefault dbPkg);

      services.postgresql.enable = mkDefault createLocalPostgreSQL;

      systemd.services.keycloak =
        let
          databaseServices =
            if createLocalPostgreSQL then
              [
                "keycloakPostgreSQLInit.service"
                "postgresql.target"
              ]
            else if createLocalMySQL then
              [
                "keycloakMySQLInit.service"
                "mysql.service"
              ]
            else
              [ ];
          secretPaths = catAttrs "_secret" (collect isSecret cfg.settings);
          mkSecretReplacement = file: ''
            replace-secret ${hashString "sha256" file} "$CREDENTIALS_DIRECTORY/${baseNameOf file}" /run/keycloak/conf/keycloak.conf
          '';
          secretReplacements = lib.concatMapStrings mkSecretReplacement secretPaths;
        in
        {
          after = databaseServices;
          bindsTo = databaseServices;
          enableStrictShellChecks = true;

          environment = {
            KC_CONF_DIR = "/run/keycloak/conf";
            KC_HOME_DIR = "/run/keycloak";
          }
          // lib.optionalAttrs (cfg.initialAdminPassword != null) {
            KC_BOOTSTRAP_ADMIN_PASSWORD = cfg.initialAdminPassword;
            KC_BOOTSTRAP_ADMIN_USERNAME = "admin";
          };

          path = with pkgs; [
            keycloakBuild
            openssl
            replace-secret
          ];

          script = ''
            set -o errexit -o pipefail -o nounset -o errtrace
            shopt -s inherit_errexit

            umask u=rwx,g=,o=

            ln -s ${themesBundle} /run/keycloak/themes
            ln -s ${keycloakBuild}/providers /run/keycloak/
            ln -s ${keycloakBuild}/lib /run/keycloak/

            install -D -m 0600 ${confFile} /run/keycloak/conf/keycloak.conf

            ${secretReplacements}

            # Escape any backslashes in the db parameters, since
            # they're otherwise unexpectedly read as escape
            # sequences.
            sed -i '/db-/ s|\\|\\\\|g' /run/keycloak/conf/keycloak.conf

          ''
          + optionalString (cfg.sslCertificate != null && cfg.sslCertificateKey != null) ''
            mkdir -p /run/keycloak/ssl
            cp "$CREDENTIALS_DIRECTORY"/ssl_{cert,key} /run/keycloak/ssl/
          ''
          + ''
            kc.sh --verbose start --optimized ${lib.optionalString (cfg.realmFiles != [ ]) "--import-realm"}
          '';

          serviceConfig = {
            AmbientCapabilities = "CAP_NET_BIND_SERVICE";
            DynamicUser = true;
            Group = "keycloak";

            LoadCredential =
              map (p: "${baseNameOf p}:${p}") secretPaths
              ++ optionals (cfg.sslCertificate != null && cfg.sslCertificateKey != null) [
                "ssl_cert:${cfg.sslCertificate}"
                "ssl_key:${cfg.sslCertificateKey}"
              ];

            NotifyAccess = "all";
            RuntimeDirectory = "keycloak";
            RuntimeDirectoryMode = "0700";
            Type = "notify"; # Requires quarkus-systemd-notify plugin
            User = "keycloak";
          };

          wantedBy = [ "multi-user.target" ];
        };

      systemd.services.keycloakMySQLInit = mkIf createLocalMySQL {
        after = [ "mysql.service" ];
        before = [ "keycloak.service" ];
        bindsTo = [ "mysql.service" ];
        enableStrictShellChecks = true;
        path = [ config.services.mysql.package ];

        script = ''
          set -o errexit -o pipefail -o nounset -o errtrace
          shopt -s inherit_errexit

          # Read the password from the credentials directory and
          # escape any single quotes by adding additional single
          # quotes after them, following the rules laid out here:
          # https://dev.mysql.com/doc/refman/8.0/en/string-literals.html
          db_password="$(<"$CREDENTIALS_DIRECTORY/db_password")"
          db_password="''${db_password//\'/\'\'}"

          ( echo "SET sql_mode = 'NO_BACKSLASH_ESCAPES';"
            echo "CREATE USER IF NOT EXISTS 'keycloak'@'localhost' IDENTIFIED BY '$db_password';"
            echo "CREATE DATABASE IF NOT EXISTS keycloak CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
            echo "GRANT ALL PRIVILEGES ON keycloak.* TO 'keycloak'@'localhost';"
          ) | mysql -N
        '';

        serviceConfig = {
          Group = config.services.mysql.group;
          LoadCredential = [ "db_password:${cfg.database.passwordFile}" ];
          RemainAfterExit = true;
          Type = "oneshot";
          User = config.services.mysql.user;
        };
      };

      systemd.services.keycloakPostgreSQLInit = mkIf createLocalPostgreSQL {
        after = [ "postgresql.target" ];
        before = [ "keycloak.service" ];
        bindsTo = [ "postgresql.target" ];
        enableStrictShellChecks = true;
        path = [ config.services.postgresql.package ];

        script = ''
          set -o errexit -o pipefail -o nounset -o errtrace
          shopt -s inherit_errexit

          create_role="$(mktemp)"
          trap 'rm -f "$create_role"' EXIT

          # Read the password from the credentials directory and
          # escape any single quotes by adding additional single
          # quotes after them, following the rules laid out here:
          # https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS
          db_password="$(<"$CREDENTIALS_DIRECTORY/db_password")"
          db_password="''${db_password//\'/\'\'}"

          echo "CREATE ROLE keycloak WITH LOGIN PASSWORD '$db_password' CREATEDB" > "$create_role"
          psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='keycloak'" | grep -q 1 || psql -tA --file="$create_role"
          psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'keycloak'" | grep -q 1 || psql -tAc 'CREATE DATABASE "keycloak" OWNER "keycloak"'
        '';

        serviceConfig = {
          Group = "postgres";
          LoadCredential = [ "db_password:${cfg.database.passwordFile}" ];
          RemainAfterExit = true;
          Type = "oneshot";
          User = "postgres";
        };
      };

      systemd.tmpfiles.settings."10-keycloak" =
        let
          mkTarget =
            file:
            let
              baseName = baseNameOf file;
              name = if lib.hasSuffix ".json" baseName then baseName else "${baseName}.json";
            in
            "/run/keycloak/data/import/${name}";
          settingsList = map (f: {
            name = mkTarget f;

            value = {
              "L+".argument = "${f}";
            };
          }) cfg.realmFiles;
        in
        builtins.listToAttrs settingsList;
    };

  meta.doc = ./keycloak.md;

  meta.maintainers = with maintainers; [
    talyz
    anish
  ];
}
