{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dependency-track;

  settingsFormat = pkgs.formats.javaProperties { };

  frontendConfigFormat = pkgs.formats.json { };
  frontendConfigFile = frontendConfigFormat.generate "config.json" {
    API_BASE_URL = cfg.frontend.baseUrl;
    OIDC_CLIENT_ID = cfg.oidc.clientId;
    OIDC_FLOW = cfg.oidc.flow;
    OIDC_ISSUER = cfg.oidc.issuer;
    OIDC_LOGIN_BUTTON_TEXT = cfg.oidc.loginButtonText;
    OIDC_SCOPE = cfg.oidc.scope;
  };

  sslEnabled =
    config.services.nginx.virtualHosts.${cfg.nginx.domain}.addSSL
    || config.services.nginx.virtualHosts.${cfg.nginx.domain}.forceSSL
    || config.services.nginx.virtualHosts.${cfg.nginx.domain}.onlySSL
    || config.services.nginx.virtualHosts.${cfg.nginx.domain}.enableACME;

  assertStringPath =
    optionName: value:
    if lib.isPath value then
      throw ''
        services.dependency-track.${optionName}:
          ${toString value}
          is a Nix path, but should be a string, since Nix
          paths are copied into the world-readable Nix store.
      ''
    else
      value;

  filterNull = lib.filterAttrs (_: v: v != null);

  renderSettings =
    settings:
    lib.mapAttrs' (
      n: v:
      lib.nameValuePair (lib.toUpper (lib.replaceStrings [ "." ] [ "_" ] n)) (
        if lib.isBool v then lib.boolToString v else v
      )
    ) (filterNull settings);
in
{
  options.services.dependency-track = {
    enable = lib.mkEnableOption "dependency-track";
    package = lib.mkPackageOption pkgs "dependency-track" { };

    database = {
      createLocally = lib.mkOption {
        default = true;

        description = ''
          Whether a database should be automatically created on the
          local host. Set this to false if you plan on provisioning a
          local database yourself.
        '';

        type = lib.types.bool;
      };

      databaseName = lib.mkOption {
        default = "dependency-track";

        description = ''
          Database name to use when connecting to an external or
          manually provisioned database; has no effect when a local
          database is automatically provisioned.

          To use this with a local database, set {option}`services.dependency-track.database.createLocally`
          to `false` and create the database and user.
        '';

        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        apply = assertStringPath "passwordFile";

        description = ''
          The path to a file containing the database password.
        '';

        example = "/run/keys/db_password";
        type = lib.types.path;
      };

      type = lib.mkOption {
        default = "postgresql";

        description = ''
          `h2` database is not recommended for a production setup.
          `postgresql` this settings it recommended for production setups.
          `manual` the module doesn't handle database settings.
        '';

        type = lib.types.enum [
          "h2"
          "postgresql"
          "manual"
        ];
      };

      username = lib.mkOption {
        default = "dependency-track";

        description = ''
          Username to use when connecting to an external or manually
          provisioned database; has no effect when a local database is
          automatically provisioned.

          To use this with a local database, set {option}`services.dependency-track.database.createLocally`
          to `false` and create the database and user.
        '';

        type = lib.types.str;
      };
    };

    frontend = {
      baseUrl = lib.mkOption {
        default = lib.optionalString cfg.nginx.enable "${
          if sslEnabled then "https" else "http"
        }://${cfg.nginx.domain}";

        defaultText = lib.literalExpression ''
          lib.optionalString config.services.dependency-track.nginx.enable "''${
            if sslEnabled then "https" else "http"
          }://''${config.services.dependency-track.nginx.domain}";
        '';

        description = ''
          The base URL of the API server.

          NOTE:
          * This URL must be reachable by the browsers of your users.
          * The frontend container itself does NOT communicate with the API server directly, it just serves static files.
          * When deploying to dedicated servers, please use the external IP or domain of the API server.
        '';

        type = lib.types.str;
      };
    };

    javaArgs = lib.mkOption {
      default = [ ];

      description = ''
        Java options passed to JVM. Configuring this is usually not necessary, but for small systems
        it can be useful to tweak the JVM heap size.
      '';

      example = lib.literalExpression ''[ "-Xmx16G" ] '';
      type = lib.types.listOf lib.types.str;
    };

    ldap.bindPasswordFile = lib.mkOption {
      apply = assertStringPath "bindPasswordFile";

      description = ''
        The path to a file containing the LDAP bind password.
      '';

      example = "/run/keys/ldap_bind_password";
      type = lib.types.path;
    };

    logLevel = lib.mkOption {
      default = "INFO";
      description = "Log level for dependency-track";

      type = lib.types.enum [
        "INFO"
        "WARN"
        "ERROR"
        "DEBUG"
        "TRACE"
      ];
    };

    nginx = {
      enable = lib.mkOption {
        default = true;

        description = ''
          Whether to set up an nginx virtual host.
        '';

        example = false;
        type = lib.types.bool;
      };

      domain = lib.mkOption {
        description = ''
          The domain name under which to set up the virtual host.
        '';

        example = "dtrack.example.com";
        type = lib.types.str;
      };
    };

    oidc = {
      enable = lib.mkEnableOption "oidc support";

      clientId = lib.mkOption {
        default = "";

        description = ''
          Defines the client ID for OpenID Connect.
        '';

        type = lib.types.str;
      };

      flow = lib.mkOption {
        default = "code";

        description = ''
          Specifies the OpenID Connect flow to use.
          Values other than "implicit" will result in the Code+PKCE flow to be used.
          Usage of the implicit flow is strongly discouraged, but may be necessary when
          the IdP of choice does not support the Code+PKCE flow.
          See also:
            - <https://oauth.net/2/grant-types/implicit/>
            - <https://oauth.net/2/pkce/>
        '';

        type = lib.types.enum [
          "code"
          "implicit"
        ];
      };

      issuer = lib.mkOption {
        default = "";

        description = ''
          Defines the issuer URL to be used for OpenID Connect.
          See alpine.oidc.issuer property of the API server.
        '';

        type = lib.types.str;
      };

      loginButtonText = lib.mkOption {
        default = "Login with OpenID Connect";

        description = ''
          Defines the scopes to request for OpenID Connect.
          See also: <https://openid.net/specs/openid-connect-basic-1_0.html#Scopes>
        '';

        type = lib.types.str;
      };

      scope = lib.mkOption {
        default = "openid profile email";

        description = ''
          Defines the scopes to request for OpenID Connect.
          See also: <https://openid.net/specs/openid-connect-basic-1_0.html#Scopes>
        '';

        type = lib.types.str;
      };

      teamSynchronization = lib.mkOption {
        default = false;

        description = ''
          This option will ensure that team memberships for OpenID Connect users are dynamic and
          synchronized with membership of OpenID Connect groups or assigned roles. When a team is
          mapped to an OpenID Connect group, all local OpenID Connect users will automatically be
          assigned to the team if they are a member of the group the team is mapped to. If the user
          is later removed from the OpenID Connect group, they will also be removed from the team. This
          option provides the ability to dynamically control user permissions via the identity provider.
          Note that team synchronization is only performed during user provisioning and after successful
          authentication.
        '';

        example = true;
        type = lib.types.bool;
      };

      teams = {
        claim = lib.mkOption {
          default = "groups";

          description = ''
            Defines the name of the claim that contains group memberships or role assignments in the provider's userinfo endpoint.
            The claim must be an array of strings. Most public identity providers do not support group or role management.
            When using a customizable / on-demand hosted identity provider, name, content, and inclusion in the userinfo endpoint
            will most likely need to be configured.
          '';

          type = lib.types.str;
        };

        default = lib.mkOption {
          default = null;

          description = ''
            Defines one or more team names that auto-provisioned OIDC users shall be added to.
            Multiple team names may be provided as comma-separated list.

            Has no effect when {option}`services.dependency-track.oidc.userProvisioning`=false,
            or {option}`services.dependency-track.oidc.teamSynchronization`=true.
          '';

          type = lib.types.nullOr lib.types.commas;
        };
      };

      userProvisioning = lib.mkOption {
        default = false;

        description = ''
          Specifies if mapped OpenID Connect accounts are automatically created upon successful
          authentication. When a user logs in with a valid access token but an account has
          not been previously provisioned, an authentication failure will be returned.
          This allows admins to control specifically which OpenID Connect users can access the
          system and which users cannot. When this value is set to true, a local OpenID Connect
          user will be created and mapped to the OpenID Connect account automatically. This
          automatic provisioning only affects authentication, not authorization.
        '';

        example = true;
        type = lib.types.bool;
      };

      usernameClaim = lib.mkOption {
        default = "name";

        description = ''
          Defines the name of the claim that contains the username in the provider's userinfo endpoint.
          Common claims are "name", "username", "preferred_username" or "nickname".
          See also: <https://openid.net/specs/openid-connect-core-1_0.html#UserInfoResponse>
        '';

        example = "preferred_username";
        type = lib.types.str;
      };
    };

    port = lib.mkOption {
      default = 8080;

      description = ''
        On which port dependency-track should listen for new HTTP connections.
      '';

      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };
      description = "See <https://docs.dependencytrack.org/getting-started/configuration/#default-configuration> for possible options";

      type = lib.types.submodule {
        options = {
          "alpine.data.directory" = lib.mkOption {
            default = "/var/lib/dependency-track";

            description = ''
              Defines the path to the data directory. This directory will hold logs, keys,
              and any database or index files along with application-specific files or
              directories.
            '';

            type = lib.types.path;
          };

          "alpine.database.driver" = lib.mkOption {
            default =
              if cfg.database.type == "h2" then
                "org.h2.Driver"
              else if cfg.database.type == "postgresql" then
                "org.postgresql.Driver"
              else
                null;

            defaultText = lib.literalExpression ''
              if config.services.dependency-track.database.type == "h2" then "org.h2.Driver"
              else if config.services.dependency-track.database.type == "postgresql" then "org.postgresql.Driver"
              else null;
            '';

            description = "Specifies the JDBC driver class to use.";

            type = lib.types.enum [
              "org.h2.Driver"
              "org.postgresql.Driver"
              "com.microsoft.sqlserver.jdbc.SQLServerDriver"
              "com.mysql.cj.jdbc.Driver"
            ];
          };

          "alpine.database.mode" = lib.mkOption {
            default =
              if cfg.database.type == "h2" then
                "embedded"
              else if cfg.database.type == "postgresql" then
                "external"
              else
                null;

            defaultText = lib.literalExpression ''
              if config.services.dependency-track.database.type == "h2" then "embedded"
              else if config.services.dependency-track.database.type == "postgresql" then "external"
              else null
            '';

            description = ''
              Defines the database mode of operation. Valid choices are:
              'server', 'embedded', and 'external'.
              In server mode, the database will listen for connections from remote hosts.
              In embedded mode, the system will be more secure and slightly faster.
              External mode should be used when utilizing an external database server
              (i.e. mysql, postgresql, etc).
            '';

            type = lib.types.enum [
              "server"
              "embedded"
              "external"
            ];
          };

          "alpine.database.url" = lib.mkOption {
            default =
              if cfg.database.type == "h2" then
                "jdbc:h2:/var/lib/dependency-track/db"
              else if cfg.database.type == "postgresql" then
                "jdbc:postgresql:${cfg.database.databaseName}?socketFactory=org.newsclub.net.unix.AFUNIXSocketFactory$FactoryArg&socketFactoryArg=/run/postgresql/.s.PGSQL.5432"
              else
                null;

            defaultText = lib.literalExpression ''
              if config.services.dependency-track.database.type == "h2" then "jdbc:h2:/var/lib/dependency-track/db"
                else if config.services.dependency-track.database.type == "postgresql" then "jdbc:postgresql:''${config.services.dependency-track.database.name}?socketFactory=org.newsclub.net.unix.AFUNIXSocketFactory$FactoryArg&socketFactoryArg=/run/postgresql/.s.PGSQL.5432"
                else null
            '';

            description = "Specifies the JDBC URL to use when connecting to the database.";
            type = lib.types.str;
          };

          "alpine.database.username" = lib.mkOption {
            default = if cfg.database.createLocally then "dependency-track" else cfg.database.username;

            defaultText = lib.literalExpression ''
              if config.services.dependency-track.database.createLocally then "dependency-track"
              else config.services.dependency-track.database.username
            '';

            description = "Specifies the username to use when authenticating to the database.";
            type = lib.types.str;
          };

          "alpine.ldap.enabled" = lib.mkOption {
            default = false;

            description = ''
              Defines if LDAP will be used for user authentication. If enabled,
              alpine.ldap.* properties should be set accordingly.
            '';

            type = lib.types.bool;
          };

          "alpine.oidc.client.id" = lib.mkOption {
            default = cfg.oidc.clientId;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.clientId";

            description = ''
              Defines the client ID to be used for OpenID Connect.
              The client ID should be the same as the one configured for the frontend,
              and will only be used to validate ID tokens.
            '';

            type = lib.types.str;
          };

          "alpine.oidc.enabled" = lib.mkOption {
            default = cfg.oidc.enable;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.enable";

            description = ''
              Defines if OpenID Connect will be used for user authentication.
              If enabled, alpine.oidc.* properties should be set accordingly.
            '';

            type = lib.types.bool;
          };

          "alpine.oidc.issuer" = lib.mkOption {
            default = cfg.oidc.issuer;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.issuer";

            description = ''
              Defines the issuer URL to be used for OpenID Connect.
              This issuer MUST support provider configuration via the /.well-known/openid-configuration endpoint.
              See also:
              - <https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata>
              - <https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig>
            '';

            type = lib.types.str;
          };

          "alpine.oidc.team.synchronization" = lib.mkOption {
            default = cfg.oidc.teamSynchronization;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.teamSynchronization";

            description = ''
              This option will ensure that team memberships for OpenID Connect users are dynamic and
              synchronized with membership of OpenID Connect groups or assigned roles. When a team is
              mapped to an OpenID Connect group, all local OpenID Connect users will automatically be
              assigned to the team if they are a member of the group the team is mapped to. If the user
              is later removed from the OpenID Connect group, they will also be removed from the team. This
              option provides the ability to dynamically control user permissions via the identity provider.
              Note that team synchronization is only performed during user provisioning and after successful
              authentication.
            '';

            type = lib.types.bool;
          };

          "alpine.oidc.teams.claim" = lib.mkOption {
            default = cfg.oidc.teams.claim;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.teams.claim";

            description = ''
              Defines the name of the claim that contains group memberships or role assignments in the provider's userinfo endpoint.
              The claim must be an array of strings. Most public identity providers do not support group or role management.
              When using a customizable / on-demand hosted identity provider, name, content, and inclusion in the userinfo endpoint
              will most likely need to be configured.
            '';

            type = lib.types.str;
          };

          "alpine.oidc.teams.default" = lib.mkOption {
            default = cfg.oidc.teams.default;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.teams.default";

            description = ''
              Defines one or more team names that auto-provisioned OIDC users shall be added to.
              Multiple team names may be provided as comma-separated list.

              Has no effect when {option}`services.dependency-track.oidc.userProvisioning`=false,
              or {option}`services.dependency-track.oidc.teamSynchronization`=true.
            '';

            type = lib.types.nullOr lib.types.commas;
          };

          "alpine.oidc.user.provisioning" = lib.mkOption {
            default = cfg.oidc.userProvisioning;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.userProvisioning";

            description = ''
              Specifies if mapped OpenID Connect accounts are automatically created upon successful
              authentication. When a user logs in with a valid access token but an account has
              not been previously provisioned, an authentication failure will be returned.
              This allows admins to control specifically which OpenID Connect users can access the
              system and which users cannot. When this value is set to true, a local OpenID Connect
              user will be created and mapped to the OpenID Connect account automatically. This
              automatic provisioning only affects authentication, not authorization.
            '';

            type = lib.types.bool;
          };

          "alpine.oidc.username.claim" = lib.mkOption {
            default = cfg.oidc.usernameClaim;
            defaultText = lib.literalExpression "config.services.dependency-track.oidc.usernameClaim";

            description = ''
              Defines the name of the claim that contains the username in the provider's userinfo endpoint.
              Common claims are "name", "username", "preferred_username" or "nickname".
              See also: <https://openid.net/specs/openid-connect-core-1_0.html#UserInfoResponse>
            '';

            type = lib.types.str;
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf cfg.nginx.enable {
      enable = true;
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;
      upstreams.dependency-track.servers."localhost:${toString cfg.port}" = { };

      virtualHosts.${cfg.nginx.domain} = {
        locations = {
          "/" = {
            alias = "${cfg.package.frontend}/dist/";

            extraConfig = ''
              location ~ (index\.html)$ {
                add_header Cache-Control "max-age=0, no-cache, no-store, must-revalidate";
                add_header Pragma "no-cache";
                add_header Expires 0;
              }
            '';

            index = "index.html";
            tryFiles = "$uri $uri/ /index.html";
          };

          "/api".proxyPass = "http://dependency-track";

          "= /static/config.json" = {
            alias = frontendConfigFile;

            extraConfig = ''
              add_header Cache-Control "max-age=0, no-cache, no-store, must-revalidate";
              add_header Pragma "no-cache";
              add_header Expires 0;
            '';
          };
        };
      };
    };

    services.postgresql.enable = lib.mkIf cfg.database.createLocally (lib.mkDefault true);

    systemd.services."dependency-track" =
      let
        databaseServices =
          if cfg.database.createLocally then
            [
              "dependency-track-postgresql-init.service"
              "postgresql.target"
            ]
          else
            [ ];
      in
      {
        after = databaseServices;
        description = "Dependency Track";

        # provide settings via env vars to allow overriding default settings.
        environment = {
          HOME = "%S/dependency-track";
        }
        // renderSettings cfg.settings;

        requires = databaseServices;

        script = ''
          set -eou pipefail
          shopt -s inherit_errexit

          export ALPINE_DATABASE_PASSWORD_FILE="$CREDENTIALS_DIRECTORY/db_password"
          ${lib.optionalString cfg.settings."alpine.ldap.enabled" ''
            export ALPINE_LDAP_BIND_PASSWORD="$(<"$CREDENTIALS_DIRECTORY/ldap_bind_password")"
          ''}

          exec ${lib.getExe pkgs.jre_headless} ${
            lib.escapeShellArgs (
              cfg.javaArgs
              ++ [
                "-DdependencyTrack.logging.level=${cfg.logLevel}"
                "-jar"
                "${cfg.package}/share/dependency-track/dependency-track.jar"
                "-port"
                "${toString cfg.port}"
              ]
            )
          }
        '';

        serviceConfig = {
          DynamicUser = true;
          Group = "dependency-track";

          LoadCredential = [
            "db_password:${cfg.database.passwordFile}"
          ]
          ++
            lib.optional cfg.settings."alpine.ldap.enabled"
              "ldap_bind_password:${cfg.ldap.bindPasswordFile}";

          StateDirectory = "dependency-track";
          User = "dependency-track";
        };

        wantedBy = [ "multi-user.target" ];
      };

    systemd.services.dependency-track-postgresql-init = lib.mkIf cfg.database.createLocally {
      after = [ "postgresql.target" ];
      before = [ "dependency-track.service" ];
      bindsTo = [ "postgresql.target" ];
      path = [ config.services.postgresql.package ];

      script = ''
        set -eou pipefail
        shopt -s inherit_errexit

        # Read the password from the credentials directory and
        # escape any single quotes by adding additional single
        # quotes after them, following the rules laid out here:
        # https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS
        db_password="$(<"$CREDENTIALS_DIRECTORY/db_password")"
        db_password="''${db_password//\'/\'\'}"

        echo "CREATE ROLE \"dependency-track\" WITH LOGIN PASSWORD '$db_password' CREATEDB" > /tmp/create_role.sql
        psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='dependency-track'" | grep -q 1 || psql -tA --file="/tmp/create_role.sql"
        psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'dependency-track'" | grep -q 1 || psql -tAc 'CREATE DATABASE "dependency-track" OWNER "dependency-track"'
      '';

      serviceConfig = {
        Group = "postgres";
        LoadCredential = [ "db_password:${cfg.database.passwordFile}" ];
        PrivateTmp = true;
        RemainAfterExit = true;
        Type = "oneshot";
        User = "postgres";
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      e1mo
      xanderio
    ];
  };
}
