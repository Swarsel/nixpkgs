{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Simple alias variables
  user = "freescout";
  group = user;
  cfg = config.services.freescout;
  datadir = "/var/lib/freescout";
  cachedir = "/var/cache/freescout";
  fpmService = "phpfpm-${user}";

  # Generated config and more complex templates / default variables
  autoDb = if !cfg.databaseSetup.enable then false else cfg.databaseSetup.kind;
  dbService = lib.optional (autoDb != false) (
    if autoDb == "mysql" then "mysql.service" else "postgresql.service"
  );
  db_config = lib.optionalAttrs (autoDb != false) (
    if autoDb == "mysql" then
      {
        DB_CONNECTION = "mysql";
        DB_DATABASE = user;
        DB_HOST = "";
        DB_SOCKET = "/run/mysqld/mysqld.sock";
        DB_USERNAME = user;
      }
    else
      {
        DB_CONNECTION = "pgsql";
        DB_DATABASE = user;
        DB_HOST = "/run/postgresql";
        DB_USERNAME = user;
      }
  );

  raw_config = {
    APP_DISABLE_UPDATING = true;
    APP_ENV = "production";
    APP_FORCE_HTTPS = true;
    APP_TIMEZONE = config.time.timeZone;
    APP_URL = "https://${cfg.domain}";
  }
  // cfg.settings
  // db_config;
  app_config = dropNull raw_config;
  baseService = {
    path = [
      pkgs.ps
      artisanWrapped
    ];

    requires = [
      # Using requires (instead of wants) since a failing config
      # is indeed critical and should not allow this service to continue
      "freescout-setup.service"
    ]
    ++ dbService;

    serviceConfig = {
      Group = group;
      User = user;
    };
  };

  # Custom built packages / files / scripts
  phpPackage = cfg.phpPackage.buildEnv {
    # As of php8.5 opcache is required and automatically compiled in and thus is not available in
    # all anymore. To keep compatibility with older versions, still add if available.
    extensions =
      { all, enabled }: enabled ++ [ all.iconv ] ++ (lib.optional (all ? opcache) all.opcache);

    # Don't log anything because we are not sure, if this may leak secrets
    # Logging can be increased, if we have time to check the logging library
    extraConfig = ''
      error_reporting = 0
    '';
  };

  package = cfg.package.overrideAttrs (prev: {
    pname = "${prev.pname}-${cfg.domain}";

    postInstall = prev.postInstall or "" + ''
      ln -s ${datadir} $out/share/freescout/data
    '';
  });

  artisanWrapped = pkgs.writeShellApplication {
    name = "artisan-wrapped";

    runtimeInputs = with pkgs; [
      util-linux
    ];

    text = ''
      cd ${datadir}
      _runuser='exec'
      if [[ "$USER" != ${user} ]]; then
        _runuser='exec runuser --user ${user}'
      fi
      ''${_runuser} ${lib.getExe phpPackage} ${package}/share/freescout/artisan "$@"
    '';
  };
  configFile = mkEnvFile "freescout.env" app_config;
  allSecrets = lib.catAttrs "_secret" (lib.collect isSecret app_config);

  configSetupScript = pkgs.writeShellScript "freescout-config-setup" ''
    set -o errexit -o pipefail -o nounset -o errtrace
    shopt -s inherit_errexit
    PATH=${lib.makeBinPath [ pkgs.replace-secret ]}:$PATH
    cp ${configFile} "/tmp/raw.env";
    ${mkSecretsReplacement "/tmp/raw.env" allSecrets}
    install -T --mode 400 -o ${user} -g ${group} "/tmp/raw.env" "${datadir}/.env"
    rm "/tmp/raw.env"
  '';

  freescoutSetupScript =
    let
      rwPaths = [
        "storage/app"
        "storage/framework"
        "storage/framework/sessions"
        "storage/framework/views"
        "storage/framework/cache/data"
        "storage/logs"
        "bootstrap/cache"
        "public/css/builds"
        "public/js/builds"
        "Modules"
        "public/modules"
      ];
    in
    ''
      set -x
      umask 027
      # Working arround https://github.com/freescout-helpdesk/freescout/issues/2547
      # and having to manually clear cache when migrating from something around
      # ~1.8.159 (╯°□°)╯︵ ┻━┻
      # See: https://github.com/freescout-help-desk/freescout/issues/4366#issuecomment-2495993397
      rm -f ${datadir}/bootstrap/cache.php ${datadir}/bootstrap/cache/{config,packages,services}.php

      ln -sf "${artisanWrapped}/bin/artisan-wrapped" "${datadir}/artisan"
      ${lib.concatMapStringsSep "\n" (p: "mkdir -p ${datadir}/${p}") rwPaths}

      # Migrate database and stuff
      # This does migrate, cache:clear, queue:restart
      ${lib.getExe artisanWrapped} freescout:after-app-update
    '';

  # Helper functions
  isSecret = v: lib.isAttrs v && v ? _secret && lib.strings.isConvertibleWithToString v._secret;
  hashSecret = p: builtins.hashString "sha256" (toString p);
  dropNull = lib.filterAttrsRecursive (
    _: v:
    !lib.elem v [
      null
      [ ]
      { }
    ]
  );
  mkEnvVars = lib.generators.toKeyValue {
    mkKeyValue =
      k: v:
      let
        value =
          with builtins;
          if isInt v then
            toString v
          else if isString v then
            v
          else if isBool v then
            lib.boolToString v
          else if isSecret v then
            hashSecret v._secret
          else
            throw "freescout: ${k} has unsupported type ${typeOf v}: ${(lib.generators.toPretty { }) v}";
      in
      "${k}=${value}";
  };
  mkEnvFile = fname: values: pkgs.writeText fname (mkEnvVars values);
  mkSecretsReplacement =
    filePath:
    lib.concatMapStringsSep "\n" (
      sp:
      "replace-secret ${
        lib.escapeShellArgs [
          (hashSecret sp)
          sp
        ]
      } ${filePath}"
    );
in
{
  options.services.freescout = with lib; {
    enable = mkEnableOption "FreeScout helpdesk application";
    package = mkPackageOption pkgs "freescout" { };

    databaseSetup = {
      enable = mkOption {
        default = true;
        description = "Whether to enable automatic database setup and configuration";
        type = types.bool;
      };

      kind = mkOption {
        default = "pgsql";
        description = "Type of database to automatically set up";
        example = "mysql";

        type = types.enum [
          "mysql"
          "pgsql"
        ];
      };
    };

    domain = mkOption {
      description = "Domain the freescout installation will run under";
      example = "support.mydomain.net";
      type = types.str;
    };

    phpPackage = mkOption {
      default = pkgs.php;
      defaultText = literalExpression "pkgs.php";
      description = "The php package to use";
      type = types.package;
    };

    poolConfig = mkOption {
      default = {
        "pm" = "ondemand";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.process_idle_timeout" = "120s";
      };

      description = ''
        Options for the freescout PHP pool. See the documentation on `php-fpm.conf`
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

    settings = mkOption {
      apply = mapAttrs' (
        k: v: {
          name = toUpper k;
          value = v;
        }
      );

      default = { };

      defaultText = lib.literalExpression ''
        {
          APP_ENV = "production";
          APP_FORCE_HTTPS = true;
          APP_URL = "https://''${config.services.freescout.domain}";
          APP_TIMEZONE = config.time.timeZone;
          APP_DISABLE_UPDATING = true;
        }
      '';

      description = ''
        Settings to be set in the `.env` file. See
        <https://github.com/freescout-help-desk/freescout/blob/master/.env.example>
        for reference on available environment variables.

        Will be merged with the shown defaults.
      '';

      example = lib.literalExpression ''
        {
          # NOTE: MUST be 256 bits (32 bytes) in length, the form of base64:<base64 encoded key> is recommended.
          # You can generate a valid one using `echo "base64:$(openssl rand -base64 32)"`
          APP_KEY_FILE = "/run/secret/freescout/app_key";
          DB_CONNECTION = "mysql";
          DB_HOST = "localhost";
          DB_PORT = 3306;
          DB_DATABASE = "freescout";
          DB_USERNAME = "freescout";
          DB_PASSWORD._secret = "/run/secret/freescout/db_pass";
        }
      '';

      type = with types; attrsOf anything;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (app_config ? "APP_KEY" || app_config ? "APP_KEY_FILE");
        message = "`services.freescout.settings.APP_KEY_FILE` is required!";
      }
    ];

    services.mysql = lib.mkIf (autoDb == "mysql") {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;

      ensureDatabases = [
        app_config.DB_DATABASE
      ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${app_config.DB_DATABASE}.*" = "ALL PRIVILEGES";
          };

          name = user;
        }
      ];
    };

    services.nginx = {
      enable = true;

      virtualHosts.${cfg.domain} =
        let
          vhostCfg = config.services.nginx.virtualHosts.${cfg.domain};
          optSsl = lib.optionalString (vhostCfg.forceSSL || vhostCfg.onlySSL) "fastcgi_param HTTPS on;";
        in
        {
          locations = {
            "/" = {
              extraConfig = ''
                # Defeats E-Mail open tracking or possibly "real" exploits
                add_header X-XSS-Protection "1; mode=block" always;
                add_header X-Content-Type-Options "nosniff" always;
                add_header Referrer-Policy "no-referrer-when-downgrade" always;
                add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'";
              '';

              index = "index.php";
              tryFiles = "$uri $uri/ /index.php$is_args$args";
            };

            "^~ /(css|js)/builds/".root = "${cachedir}/public/";

            "^~ /storage/app/attachment/" = {
              alias = "${datadir}/storage/app/attachment/";

              extraConfig = ''
                internal;
              '';
            };

            "~ /\\.".extraConfig = ''
              deny all;
            '';

            "~ \\.php$" = {
              extraConfig = ''
                fastcgi_index index.php;
                include ${pkgs.nginx}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_pass unix:${config.services.phpfpm.pools.${user}.socket};
                ${optSsl}

                # Defeats E-Mail open tracking or possibly "real" exploits
                add_header X-XSS-Protection "1; mode=block" always;
                add_header X-Content-Type-Options "nosniff" always;
                add_header Referrer-Policy "no-referrer-when-downgrade" always;
                add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'";
              '';

              tryFiles = "$uri $uri/ =404";
            };

            "~* ^/(?:css|fonts|img|installer|js|modules)$".extraConfig = ''
              expires 1M;
              access_log off;
              add_header Cache-Control "public, must-revalidate";
            '';

            "~* ^/(?:css|js)/.*\\.(?:css|js)$".extraConfig = ''
              expires 2d;
              access_log off;
              add_header Cache-Control "public, must-revalidate";
              # Defeats E-Mail open tracking or possibly "real" exploits
              add_header X-XSS-Protection "1; mode=block" always;
              add_header X-Content-Type-Options "nosniff" always;
              add_header Referrer-Policy "no-referrer-when-downgrade" always;
              add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'";
            '';

            "~* ^/storage/attachment/" = {
              extraConfig = ''
                expires 1M;
                access_log off;
              '';

              tryFiles = "$uri $uri/ /index.php?$query_string";
            };
          };

          root = lib.mkForce "${package}/share/freescout/public";
        };
    };

    services.phpfpm.pools.${user} = {
      inherit phpPackage user group;

      phpOptions = ''
        display_errors = On
        display_startup_errors = On
      '';

      settings = {
        "catch_workers_output" = true;
        "listen.group" = config.services.nginx.group;
        "listen.owner" = user;
      }
      // cfg.poolConfig;
    };

    services.postgresql = lib.mkIf (autoDb == "pgsql") {
      enable = true;

      ensureDatabases = [
        app_config.DB_DATABASE
      ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = user;
        }
      ];
    };

    systemd.services.${fpmService} = {
      # Somehow the webinterface shows
      inherit (baseService) path;
    };

    # This is both long-running but also stops quite frequently.
    # Seeing job restart counts in the thousands here is normal.
    systemd.services."freescout-queue" = lib.recursiveUpdate baseService {
      after = [ "freescout-setup.service" ] ++ dbService;

      # Copying the output to storage/logs because it makes
      # debugging connection issues easier for the user.
      script = ''
        ${lib.getExe artisanWrapped} \
          queue:work \
          --queue emails,default \
          --sleep=5 \
          -vv \
          --tries=20 \
          | tee -a ${datadir}/storage/logs/queue-jobs.log
      '';

      serviceConfig = {
        Restart = "always";
        RestartSec = "15s";
        RuntimeMaxSec = "1h";
      };

      wantedBy = [ "multi-user.target" ];
    };

    # This needs to be manually started again and again
    # Freescout has its own scheduler built in to ensure tasks run at the desired frequency
    # --no-interaction makes sure, that the queue worker is not executed.
    # This is needed, because otherweise the queue worker process would continue running
    # thus block further schedule invocations until the queue worker terminates.
    # See https://github.com/freescout-help-desk/freescout/blob/74fa4b7d4f8288f8d3fb1d343308d3289c4d72e2/app/Console/Kernel.php#L195-L267
    systemd.services."freescout-schedule-run" = baseService // {
      script = "${lib.getExe artisanWrapped} schedule:run --no-interaction";
      startAt = "minutely";
    };

    systemd.services.freescout-setup = lib.recursiveUpdate baseService {
      after = dbService;
      description = "Preparational tasks for freescout";
      requires = dbService;
      script = freescoutSetupScript;

      serviceConfig = {
        ExecStartPre = "+${configSetupScript}";
        PrivateTmp = true;
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${group} = { };
    users.users.${config.services.nginx.user}.extraGroups = [ group ];

    users.users.${user} = {
      inherit group;
      createHome = true;
      home = datadir;
      homeMode = "750";
      isSystemUser = true;
    };

    warnings =
      lib.optional (app_config ? "APP_KEY" && lib.isString app_config.APP_KEY)
        "`services.freescout.settings.APP_KEY` will be stored in the world readable nix store. Use `APP_KEY._secret` or `APP_KEY_FILE` instead!";
  };
}
