{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.librenms;
  settingsFormat = pkgs.formats.json { };
  configJson = settingsFormat.generate "librenms-config.json" cfg.settings;

  package = cfg.package.override {
    inherit (cfg) logDir dataDir;
  };

  toKeyValue = lib.generators.toKeyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  };

  defaultPHPSettings = {
    "date.timezone" = config.time.timeZone;
    log_errors = "on";
    memory_limit = "${toString cfg.settings.php_memory_limit}M";
    post_max_size = "100M";
    upload_max_filesize = "100M";
  };

  phpIni =
    pkgs.runCommand "php.ini"
      {
        inherit (package) phpPackage;
        passAsFile = [ "phpOptions" ];
        phpOptions = toKeyValue cfg.phpOptions;
        preferLocalBuild = true;
      }
      ''
        cat $phpPackage/etc/php.ini $phpOptionsPath > $out
      '';

  artisanWrapper = pkgs.writeShellScriptBin "librenms-artisan" ''
    cd ${package}
    sudo=exec
    if [[ "$USER" != ${cfg.user} ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${cfg.user}'
    fi
    $sudo ${package}/artisan "$@"
  '';

  lnmsWrapper = pkgs.writeShellScriptBin "lnms" ''
    cd ${package}
    sudo=exec
    if [[ "$USER" != ${cfg.user} ]]; then
    sudo='exec /run/wrappers/bin/sudo -u ${cfg.user}'
    fi
    $sudo ${package}/lnms "$@"
  '';

  configFile = pkgs.writeText "config.php" ''
    <?php
    $new_config = json_decode(file_get_contents("${cfg.dataDir}/config.json"), true);
    $config = ($config == null) ? $new_config : array_merge($config, $new_config);

    ${lib.optionalString (cfg.extraConfig != null) cfg.extraConfig}
  '';

in
{
  options.services.librenms = with lib; {
    enable = mkEnableOption "LibreNMS network monitoring system";
    package = lib.mkPackageOption pkgs "librenms" { };

    dataDir = mkOption {
      default = "/var/lib/librenms";

      description = ''
        Path of the LibreNMS state directory.
      '';

      type = types.path;
    };

    database = {
      createLocally = mkOption {
        default = false;

        description = ''
          Whether to create a local database automatically.
        '';

        type = types.bool;
      };

      database = mkOption {
        default = "librenms";

        description = ''
          Name of the database on the MySQL/MariaDB server.
        '';

        type = types.str;
      };

      host = mkOption {
        default = "localhost";

        description = ''
          Hostname or IP of the MySQL/MariaDB server.
          Ignored if 'socket' is defined.
        '';
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          A file containing the password for the user of the MySQL/MariaDB server.
          Must be readable for the LibreNMS user.
          Ignored if 'socket' is defined, mandatory otherwise.
        '';

        example = "/run/secrets/mysql.pass";
        type = types.nullOr types.path;
      };

      port = mkOption {
        default = 3306;

        description = ''
          Port of the MySQL/MariaDB server.
          Ignored if 'socket' is defined.
        '';

        type = types.port;
      };

      socket = mkOption {
        default = null;

        description = ''
          A unix socket to mysql, accessible by the librenms user.
          Useful when mysql is on the localhost.
        '';

        example = "/run/mysqld/mysqld.sock";
        type = types.nullOr types.str;
      };

      username = mkOption {
        default = "librenms";

        description = ''
          Name of the user on the MySQL/MariaDB server.
          Ignored if 'socket' is defined.
        '';

        type = types.str;
      };
    };

    distributedPoller = {
      enable = mkOption {
        default = false;

        description = ''
          Configure this LibreNMS instance as a [distributed poller](https://docs.librenms.org/Extensions/Distributed-Poller/).
          This will disable all web features and just configure the poller features.
          Use the `mysql` database of your main LibreNMS instance in the database settings.
        '';

        type = types.bool;
      };

      distributedBilling = mkOption {
        default = false;

        description = ''
          Enable distributed billing on this poller.

          Note: according to [the docs](https://docs.librenms.org/Extensions/Distributed-Poller/#discovery),
          billing should only be calculated on a single node per poller group. You can disable billing on
          some nodes with the `services.librenms.enableLocalBilling` option.
        '';

        type = types.bool;
      };

      group = mkOption {
        default = "0";

        description = ''
          Group(s) of this poller.
        '';

        example = "1,2";
        type = types.str;
      };

      memcachedHost = mkOption {
        description = ''
          Hostname or IP of the `memcached` server.
        '';

        type = types.str;
      };

      memcachedPort = mkOption {
        default = 11211;

        description = ''
          Port of the `memcached` server.
        '';

        type = types.port;
      };

      name = mkOption {
        default = null;

        description = ''
          Custom name of this poller.
        '';

        type = types.nullOr types.str;
      };

      rrdcachedHost = mkOption {
        description = ''
          Hostname or IP of the `rrdcached` server.
        '';

        type = types.str;
      };

      rrdcachedPort = mkOption {
        default = 42217;

        description = ''
          Port of the `memcached` server.
        '';

        type = types.port;
      };
    };

    enableLocalBilling = mkOption {
      default = true;

      description = ''
        Enable billing Cron-Jobs on the local instance. Enabled by default, but you may disable it
        on some nodes within a distributed poller setup. See [the docs](https://docs.librenms.org/Extensions/Distributed-Poller/#discovery)
        for more informations about billing with distributed pollers.
      '';

      type = types.bool;
    };

    enableOneMinutePolling = mkOption {
      default = false;

      description = ''
        Enables the [1-Minute Polling](https://docs.librenms.org/Support/1-Minute-Polling/).
        Changing this option will automatically convert your existing rrd files.
      '';

      type = types.bool;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        File containing env-vars to be substituted into the final config. Useful for secrets.
        Does not apply to settings defined in `extraConfig`.
      '';

      type = types.nullOr types.str;
    };

    extraConfig = mkOption {
      default = null;

      description = ''
        Additional config for LibreNMS that will be appended to the `config.php`. See
        <https://github.com/librenms/librenms/blob/master/misc/config_definitions.json>
        for possible options. Useful if you want to use PHP-Functions in your config.
      '';

      type = types.nullOr types.str;
    };

    finalPackage = lib.mkOption {
      default = package;
      defaultText = lib.literalExpression "package";

      description = ''
        The final package used by the module. This is the package that has all overrides.
      '';

      readOnly = true;
      type = lib.types.package;
    };

    group = mkOption {
      default = "librenms";

      description = ''
        Name of the LibreNMS group.
      '';

      type = types.str;
    };

    hostname = mkOption {
      default = config.networking.fqdnOrHostName;
      defaultText = literalExpression "config.networking.fqdnOrHostName";

      description = ''
        The hostname to serve LibreNMS on.
      '';

      type = types.str;
    };

    logDir = mkOption {
      default = "/var/log/librenms";

      description = ''
        Path of the LibreNMS logging directory.
      '';

      type = types.path;
    };

    nginx = mkOption {
      default = { };

      description = ''
        With this option, you can customize the nginx virtualHost settings.
      '';

      example = literalExpression ''
        {
          serverAliases = [
            "librenms.''${config.networking.domain}"
          ];
          # To enable encryption and let let's encrypt take care of certificate
          forceSSL = true;
          enableACME = true;
          # To set the LibreNMS virtualHost as the default virtualHost;
          default = true;
        }
      '';

      type = types.submodule (
        recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) { }
      );
    };

    phpOptions = mkOption {
      defaultText = literalExpression (
        generators.toPretty { } (
          defaultPHPSettings
          // {
            "date.timezone" = lib.literalExpression "config.time.timeZone";
            memory_limit = lib.literalExpression "\${toString cfg.settings.php_memory_limit}M";
            "opcache.enable" = lib.literalExpression "1";
            "opcache.memory_consumption" = lib.literalExpression "256";
            "zend_extension" = lib.literalExpression "opcache";
          }
        )
      );

      description = ''
        Options for PHP's php.ini file for librenms.

        Please note that this option is _additive_ on purpose while the
        attribute values inside the default are option defaults: that means that

        ```nix
        {
          services.librenms.phpOptions."opcache.enable" = 1;
        }
        ```

        will override the `php.ini` option `opcache.enable` without discarding the rest of the defaults.

        Overriding all of `phpOptions` can be done like this:

        ```nix
        {
          services.librenms.phpOptions = lib.mkForce {
            /* ... */
          };
        }
        ```
      '';

      type =
        with types;
        attrsOf (oneOf [
          str
          int
        ]);
    };

    pollerThreads = mkOption {
      default = 16;

      description = ''
        Amount of threads of the cron-poller.
      '';

      type = types.int;
    };

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
        Options for the LibreNMS PHP pool. See the documentation on `php-fpm.conf`
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
      default = { };

      description = ''
        Attrset of the LibreNMS configuration.
        See <https://docs.librenms.org/Support/Configuration/> for reference.
        All possible options are listed [here](https://github.com/librenms/librenms/blob/master/resources/definitions/config_definitions.json).
        See <https://docs.librenms.org/Extensions/Authentication/> for setting other authentication methods.
      '';

      example = {
        base_url = "/librenms/";
        top_devices = true;
        top_ports = false;
      };

      type = types.submodule {
        options = { };
        freeformType = settingsFormat.type;
      };
    };

    useDistributedPollers = mkOption {
      default = false;

      description = ''
        Enables [distributed pollers](https://docs.librenms.org/Extensions/Distributed-Poller/)
        for this LibreNMS instance. This will enable a local `rrdcached` and `memcached` server.

        To use this feature, make sure to configure your firewall that the distributed pollers
        can reach the local `mysql`, `rrdcached` and `memcached` ports.
      '';

      type = types.bool;
    };

    user = mkOption {
      default = "librenms";

      description = ''
        Name of the LibreNMS user.
      '';

      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.time.timeZone != null;
        message = "You must set `time.timeZone` to use the LibreNMS module.";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.host == "localhost";
        message = "The database host must be \"localhost\" if services.librenms.database.createLocally is set to true.";
      }
      {
        assertion = !(cfg.useDistributedPollers && cfg.distributedPoller.enable);
        message = "The LibreNMS instance can't be a distributed poller and a full instance at the same time.";
      }
    ];

    environment.systemPackages = [
      artisanWrapper
      lnmsWrapper
    ];

    security.wrappers = {
      fping = {
        group = "root";
        owner = "root";
        setuid = true;
        source = "${pkgs.fping}/bin/fping";
      };
    };

    services.cron = {
      enable = true;

      systemCronJobs =
        let
          env = "PHPRC=${phpIni}";
        in
        [
          # based on crontab provided by LibreNMS
          "33 */6 * * * ${cfg.user} ${env} ${package}/cronic ${package}/discovery-wrapper.py 1"
          "*/5 * * * * ${cfg.user} ${env} ${package}/discovery.php -h new >> /dev/null 2>&1"

          "${
            if cfg.enableOneMinutePolling then "*" else "*/5"
          } * * * * ${cfg.user} ${env} ${package}/cronic ${package}/poller-wrapper.py ${toString cfg.pollerThreads}"
          "* * * * * ${cfg.user} ${env} ${package}/alerts.php >> /dev/null 2>&1"

          "*/5 * * * * ${cfg.user} ${env} ${package}/check-services.php >> /dev/null 2>&1"

          # extra: fast ping
          "* * * * * ${cfg.user} ${env} ${package}/ping.php >> /dev/null 2>&1"

          # daily.sh tasks are split to exclude update
          "19 0 * * * ${cfg.user} ${env} ${package}/daily.sh cleanup >> /dev/null 2>&1"
          "19 0 * * * ${cfg.user} ${env} ${package}/daily.sh notifications >> /dev/null 2>&1"
          "19 0 * * * ${cfg.user} ${env} ${package}/daily.sh peeringdb >> /dev/null 2>&1"
          "19 0 * * * ${cfg.user} ${env} ${package}/daily.sh mac_oui >> /dev/null 2>&1"
        ]
        ++ lib.optionals cfg.enableLocalBilling [
          "*/5 * * * * ${cfg.user} ${env} ${package}/poll-billing.php >> /dev/null 2>&1"
          "01 * * * * ${cfg.user} ${env} ${package}/billing-calculate.php >> /dev/null 2>&1"
        ];
    };

    services.librenms.phpOptions = lib.mapAttrs (lib.const lib.mkOptionDefault) defaultPHPSettings;

    services.librenms.settings = {
      "auth_mechanism" = lib.mkDefault "mysql";
      "base_url" = lib.mkDefault "/";
      "own_hostname" = cfg.hostname;
      # set default memory limit to 1G
      "php_memory_limit" = lib.mkDefault 1024;
      # enable fast ping by default
      "ping_rrd_step" = 60;
      "rrd.heartbeat" = if cfg.enableOneMinutePolling then 120 else 600;
      # one minute polling
      "rrd.step" = if cfg.enableOneMinutePolling then 60 else 300;
      # disable auto update function (won't work with NixOS)
      "update" = false;
      # basic configs
      "user" = cfg.user;
    }
    // (lib.optionalAttrs cfg.distributedPoller.enable {
      "distributed_billing" = cfg.distributedPoller.distributedBilling;
      "distributed_poller" = true;
      "distributed_poller_group" = cfg.distributedPoller.group;
      "distributed_poller_memcached_host" = cfg.distributedPoller.memcachedHost;
      "distributed_poller_memcached_port" = cfg.distributedPoller.memcachedPort;

      "distributed_poller_name" = lib.mkIf (
        cfg.distributedPoller.name != null
      ) cfg.distributedPoller.name;

      "rrdcached" =
        "${cfg.distributedPoller.rrdcachedHost}:${toString cfg.distributedPoller.rrdcachedPort}";
    })
    // (lib.optionalAttrs cfg.useDistributedPollers {
      "distributed_billing" = lib.mkDefault true;
      "distributed_poller" = true;
      # still enable a local poller with distributed polling
      "distributed_poller_group" = lib.mkDefault "0";
      "distributed_poller_memcached_host" = "localhost";
      "distributed_poller_memcached_port" = 11211;
      "rrdcached" = "localhost:42217";
    });

    services.logrotate = {
      enable = true;

      settings."${cfg.logDir}/librenms.log" = {
        compress = true;
        create = "0640 ${cfg.user} ${cfg.group}";
        delaycompress = true;
        frequency = "weekly";
        missingok = true;
        notifempty = true;
        rotate = 6;
        su = "${cfg.user} ${cfg.group}";
      };
    };

    services.memcached = lib.mkIf cfg.useDistributedPollers {
      enable = true;
      listen = "0.0.0.0";
    };

    services.mysql = lib.mkIf cfg.database.createLocally {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.database ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.database}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.username;
        }
      ];

      initialScript = lib.mkIf cfg.useDistributedPollers (
        pkgs.writeText "mysql-librenms-init" ''
          CREATE USER IF NOT EXISTS '${cfg.database.username}'@'%';
          GRANT ALL PRIVILEGES ON ${cfg.database.database}.* TO '${cfg.database.username}'@'%';
        ''
      );

      settings.mysqld = {
        innodb_file_per_table = 1;
        lower_case_table_names = 0;
      }
      // (lib.optionalAttrs cfg.useDistributedPollers {
        bind-address = "0.0.0.0";
      });
    };

    services.nginx = lib.mkIf (!cfg.distributedPoller.enable) {
      enable = true;

      virtualHosts."${cfg.hostname}" = lib.mkMerge [
        cfg.nginx
        {
          locations."/" = {
            index = "index.php";
            tryFiles = "$uri $uri/ /index.php?$query_string";
          };

          locations."~ .php$".extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools."librenms".socket};
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
          '';

          root = lib.mkForce "${package}/html";
        }
      ];
    };

    services.phpfpm.pools.librenms = lib.mkIf (!cfg.distributedPoller.enable) {
      inherit (package) phpPackage;
      group = cfg.group;
      phpOptions = toKeyValue cfg.phpOptions;

      settings = {
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0660";
        "listen.owner" = config.services.nginx.user;
      }
      // cfg.poolConfig;

      user = cfg.user;
    };

    systemd.services.librenms-scheduler = {
      description = "LibreNMS Scheduler";
      path = [ pkgs.unixtools.whereis ];

      serviceConfig = {
        ExecStart = "${artisanWrapper}/bin/librenms-artisan schedule:run";
        Group = cfg.group;
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = package;
      };
    };

    systemd.services.librenms-setup = {
      after = [
        "systemd-tmpfiles-setup.service"
        "network.target"
      ]
      ++ (lib.optional (cfg.database.host == "localhost") "mysql.service");

      before = [ "phpfpm-librenms.service" ];
      description = "Preparation tasks for LibreNMS";

      path = [
        pkgs.mariadb
        pkgs.unixtools.whereis
        pkgs.gnused
      ];

      restartTriggers = [
        package
        configFile
      ];

      script =
        let
          nginxHasSSL =
            with config.services.nginx.virtualHosts."${cfg.hostname}";
            onlySSL || addSSL || forceSSL;
        in
        ''
          set -euo pipefail

          PATH=$PATH:${lib.makeBinPath (with pkgs; [ gnused ])}

          # config setup
          ln -sf ${configFile} ${cfg.dataDir}/config.php
          ${pkgs.envsubst}/bin/envsubst -i ${configJson} -o ${cfg.dataDir}/config.json
          export PHPRC=${phpIni}

          INIT=false
          if [[ ! -s ${cfg.dataDir}/.env ]]; then
            INIT=true
            # init .env file
            echo "APP_KEY=" > ${cfg.dataDir}/.env
            ${artisanWrapper}/bin/librenms-artisan key:generate --ansi
            ${artisanWrapper}/bin/librenms-artisan webpush:vapid
            echo "" >> ${cfg.dataDir}/.env
            echo -n "NODE_ID=" >> ${cfg.dataDir}/.env
            ${package.phpPackage}/bin/php -r "echo uniqid();" >> ${cfg.dataDir}/.env
            echo "" >> ${cfg.dataDir}/.env
          else
            # .env file already exists --> only update database and cache config
            sed -i /^APP_URL=/d ${cfg.dataDir}/.env
            sed -i /^DB_/d ${cfg.dataDir}/.env
            sed -i /^CACHE_DRIVER=/d ${cfg.dataDir}/.env
          fi
          ${lib.optionalString (cfg.useDistributedPollers || cfg.distributedPoller.enable) ''
            echo "CACHE_DRIVER=memcached" >> ${cfg.dataDir}/.env
          ''}
          echo "APP_URL=http${lib.optionalString nginxHasSSL "s"}://${cfg.hostname}/" >> ${cfg.dataDir}/.env
          echo "DB_DATABASE=${cfg.database.database}" >> ${cfg.dataDir}/.env
        ''
        + (
          if !isNull cfg.database.socket then
            ''
              # use socket connection
              echo "DB_SOCKET=${cfg.database.socket}" >> ${cfg.dataDir}/.env
              echo "DB_PASSWORD=null" >> ${cfg.dataDir}/.env
            ''
          else
            ''
              # use TCP connection
              echo "DB_HOST=${cfg.database.host}" >> ${cfg.dataDir}/.env
              echo "DB_PORT=${toString cfg.database.port}" >> ${cfg.dataDir}/.env
              echo "DB_USERNAME=${cfg.database.username}" >> ${cfg.dataDir}/.env
              echo -n "DB_PASSWORD=" >> ${cfg.dataDir}/.env
              cat ${cfg.database.passwordFile} >> ${cfg.dataDir}/.env
            ''
        )
        + ''
          # clear cache if package has changed (cache may contain cached paths
          # to the old package)
          OLD_PACKAGE=$(cat ${cfg.dataDir}/package)
          if [[ $OLD_PACKAGE != "${package}" ]]; then
            rm -r ${cfg.dataDir}/cache/*
          fi

          # convert rrd files when the oneMinutePolling option is changed
          OLD_ENABLED=$(cat ${cfg.dataDir}/one_minute_enabled)
          if [[ $OLD_ENABLED != "${lib.boolToString cfg.enableOneMinutePolling}" ]]; then
            ${artisanWrapper}/bin/librenms-artisan maintenance:rrd-step all
            echo "${lib.boolToString cfg.enableOneMinutePolling}" > ${cfg.dataDir}/one_minute_enabled
          fi

          # migrate db if package version has changed
          # not necessary for every package change
          OLD_VERSION=$(cat ${cfg.dataDir}/version)
          if [[ $OLD_VERSION != "${package.version}" ]]; then
            ${artisanWrapper}/bin/librenms-artisan migrate --force --no-interaction
            echo "${package.version}" > ${cfg.dataDir}/version
          fi

          if [[ $INIT == "true" ]]; then
            ${artisanWrapper}/bin/librenms-artisan db:seed --force --no-interaction
          fi

          # regenerate cache if package has changed
          if [[ $OLD_PACKAGE != "${package}" ]]; then
            ${artisanWrapper}/bin/librenms-artisan view:clear
            ${artisanWrapper}/bin/librenms-artisan optimize:clear
            ${artisanWrapper}/bin/librenms-artisan view:cache
            ${artisanWrapper}/bin/librenms-artisan optimize
            echo "${package}" > ${cfg.dataDir}/package
          fi

          # to make sure to not read an outdated .env file
          ${artisanWrapper}/bin/librenms-artisan config:cache
        '';

      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];

        ExecStartPre = lib.mkIf cfg.database.createLocally [
          "!${
            pkgs.writeShellScript "librenms-db-init" (
              if !isNull cfg.database.socket then
                ''
                  echo "ALTER USER '${cfg.database.username}'@'localhost' IDENTIFIED VIA unix_socket;" | ${pkgs.mariadb}/bin/mysql --socket='${cfg.database.socket}'
                  ${lib.optionalString cfg.useDistributedPollers ''
                    echo "ALTER USER '${cfg.database.username}'@'%' IDENTIFIED VIA unix_socket;" | ${pkgs.mariadb}/bin/mysql --socket='${cfg.database.socket}'
                  ''}
                ''
              else
                ''
                  DB_PASSWORD=$(cat ${cfg.database.passwordFile} | tr -d '\n')
                  echo "ALTER USER '${cfg.database.username}'@'localhost' IDENTIFIED BY '$DB_PASSWORD';" | ${pkgs.mariadb}/bin/mysql
                  ${lib.optionalString cfg.useDistributedPollers ''
                    echo "ALTER USER '${cfg.database.username}'@'%' IDENTIFIED BY '$DB_PASSWORD';" | ${pkgs.mariadb}/bin/mysql
                  ''}
                ''
            )
          }"
        ];

        Group = cfg.group;
        RemainAfterExit = true;
        Type = "oneshot";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.rrdcached = lib.mkIf cfg.useDistributedPollers {
      after = [ "librenms-setup.service" ];
      description = "rrdcached";

      serviceConfig = {
        # rrdcached params from https://docs.librenms.org/Extensions/Distributed-Poller/#config-sample
        ExecStart = "${pkgs.rrdtool}/bin/rrdcached -l 0:42217 -R -j ${cfg.dataDir}/rrdcached-journal/ -F -b ${cfg.dataDir}/rrd -B -w 1800 -z 900 -p /run/rrdcached/rrdcached.pid";
        Group = cfg.group;
        LimitNOFILE = 16384;
        PidFile = "/run/rrdcached/rrdcached.pid";
        RuntimeDirectory = "rrdcached";
        Type = "forking";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.timers.librenms-scheduler = {
      description = "LibreNMS Scheduler";

      timerConfig = {
        AccuracySec = "1second";
        OnCalendar = "minutely";
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.logDir}                               0750 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.logDir}/librenms.log                  0640 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}                              0750 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/.env                         0600 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/version                      0600 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/package                      0600 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/one_minute_enabled           0600 ${cfg.user} ${cfg.group} - -"
      "f ${cfg.dataDir}/config.json                  0600 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage                      0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/app                  0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/debugbar             0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework            0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/cache      0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/sessions   0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/framework/views      0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/storage/logs                 0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/rrd                          0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/cache                        0700 ${cfg.user} ${cfg.group} - -"
    ]
    ++ lib.optionals cfg.useDistributedPollers [
      "d ${cfg.dataDir}/rrdcached-journal            0700 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      group = "${cfg.group}";
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [
    netali
    johannwagner
  ];
}
