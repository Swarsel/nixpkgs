{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.roundcube;
  fpm = config.services.phpfpm.pools.roundcube;
  localDB = cfg.database.host == "localhost";
  user = cfg.database.username;
  phpWithPspell = pkgs.php84.withExtensions ({ all, enabled }: [ all.pspell ] ++ enabled);

  env = {
    ASPELL_CONF = "dict-dir ${pkgs.aspellWithDicts (_: cfg.dicts)}/lib/aspell";
  };
in
{
  options.services.roundcube = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable roundcube.

        Also enables nginx virtual host management.
        Further nginx configuration can be done by adapting `services.nginx.virtualHosts.<name>`.
        See [](#opt-services.nginx.virtualHosts) for further information.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "roundcube" {
      example = "roundcube.withPlugins (plugins: [ plugins.persistent_login ])";
    };

    configureNginx = lib.mkOption {
      default = true;
      description = "Configure nginx as a reverse proxy for roundcube.";
      type = lib.types.bool;
    };

    database = {
      dbname = lib.mkOption {
        default = "roundcube";
        description = "Name of the postgresql database";
        type = lib.types.str;
      };

      host = lib.mkOption {
        default = "localhost";

        description = ''
          Host of the postgresql server. If this is not set to
          `localhost`, you have to create the
          postgresql user and database yourself, with appropriate
          permissions.
        '';

        type = lib.types.str;
      };

      password = lib.mkOption {
        default = "";
        description = "Password for the postgresql connection. Do not use: the password will be stored world readable in the store; use `passwordFile` instead.";
        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        description = ''
          Password file for the postgresql connection.
          Must be formatted according to PostgreSQL .pgpass standard (see <https://www.postgresql.org/docs/current/libpq-pgpass.html>)
          but only one line, no comments and readable by user `nginx`.
          Ignored if `database.host` is set to `localhost`, as peer authentication will be used.
        '';

        example = lib.literalExpression ''
          pkgs.writeText "roundcube-postgres-passwd.txt" '''
            hostname:port:database:username:password
          '''
        '';

        type = lib.types.path;
      };

      username = lib.mkOption {
        default = "roundcube";

        description = ''
          Username for the postgresql connection.
          If `database.host` is set to `localhost`, a unix user and group of the same name will be created as well.
        '';

        type = lib.types.str;
      };
    };

    dicts = lib.mkOption {
      default = [ ];

      description = ''
        List of aspell dictionaries for spell checking. If empty, spell checking is disabled.
      '';

      example = lib.literalExpression "with pkgs.aspellDicts; [ en fr de ]";
      type = lib.types.listOf lib.types.package;
    };

    extraConfig = lib.mkOption {
      default = "";
      description = "Extra configuration for roundcube webmail instance";
      type = lib.types.lines;
    };

    hostName = lib.mkOption {
      description = "Hostname to use for the nginx vhost";
      example = "webmail.example.com";
      type = lib.types.str;
    };

    maxAttachmentSize = lib.mkOption {
      apply =
        configuredMaxAttachmentSize: "${toString (builtins.ceil (configuredMaxAttachmentSize * 1.37))}M";

      default = 18;

      description = ''
        The maximum attachment size in MB.
        [upstream issue comment]: https://github.com/roundcube/roundcubemail/issues/7979#issuecomment-808879209
        ::: {.note}
        Since there is some overhead in base64 encoding applied to attachments, + 37% will be added
        to the value set in this option in order to offset the overhead. For example, setting
        `maxAttachmentSize` to `100` would result in `137M` being the real value in the configuration.
        See [upstream issue comment] for more details on the motivations behind this.
        :::
      '';

      type = lib.types.int;
    };

    plugins = lib.mkOption {
      default = [ ];

      description = ''
        List of roundcube plugins to enable. Currently, only those directly shipped with Roundcube are supported.
      '';

      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = localDB -> cfg.database.username == cfg.database.dbname;

        message = ''
          When setting up a DB and its owner user, the owner and the DB name must be
          equal!
        '';
      }
    ];

    environment.etc."roundcube/config.inc.php".text = ''
      <?php

      ${lib.optionalString (!localDB) ''
        $password = file('${cfg.database.passwordFile}')[0];
        $password = preg_split('~\\\\.(*SKIP)(*FAIL)|\:~s', $password);
        $password = rtrim(end($password));
        $password = str_replace("\\:", ":", $password);
        $password = str_replace("\\\\", "\\", $password);
      ''}

      $config = array();
      $config['db_dsnw'] = 'pgsql://${cfg.database.username}${
        lib.optionalString (!localDB) ":' . $password . '"
      }@${if localDB then "unix(/run/postgresql)" else cfg.database.host}/${cfg.database.dbname}';
      $config['log_driver'] = 'syslog';
      $config['max_message_size'] =  '${cfg.maxAttachmentSize}';
      $config['plugins'] = [${lib.concatMapStringsSep "," (p: "'${p}'") cfg.plugins}];
      $config['des_key'] = file_get_contents('/var/lib/roundcube/des_key');
      $config['mime_types'] = '${pkgs.nginx}/conf/mime.types';
      # Roundcube uses PHP-FPM which has `PrivateTmp = true;`
      $config['temp_dir'] = '/tmp';
      $config['enable_spellcheck'] = ${if cfg.dicts == [ ] then "false" else "true"};
      # by default, spellchecking uses a third-party cloud services
      $config['spellcheck_engine'] = 'pspell';
      $config['spellcheck_languages'] = array(${
        lib.concatMapStringsSep ", " (
          dict:
          let
            p = builtins.parseDrvName dict.shortName;
          in
          "'${p.name}' => '${dict.fullName}'"
        ) cfg.dicts
      });

      ${cfg.extraConfig}
    '';

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = true;

      virtualHosts = {
        ${cfg.hostName} = {
          enableACME = lib.mkDefault true;
          forceSSL = lib.mkDefault true;

          locations."/" = {
            extraConfig = ''
              add_header Cache-Control 'public, max-age=604800, must-revalidate';
            '';

            index = "index.php";
            priority = 1100;
          };

          locations."~* \\.php(/|$)" = {
            extraConfig = ''
              fastcgi_pass unix:${fpm.socket};
              fastcgi_param PATH_INFO $fastcgi_path_info;
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              include ${config.services.nginx.package}/conf/fastcgi.conf;

              client_max_body_size ${toString cfg.maxAttachmentSize};
            '';

            priority = 3130;
          };

          root = cfg.package + "/public_html";
        };
      };
    };

    services.phpfpm.pools.roundcube = {
      phpEnv = env;

      phpOptions = ''
        error_log = '/dev/stderr'
        log_errors = on
        post_max_size = ${cfg.maxAttachmentSize}
        upload_max_filesize = ${cfg.maxAttachmentSize}
      '';

      phpPackage = phpWithPspell;

      settings = lib.mapAttrs (name: lib.mkDefault) {
        "catch_workers_output" = true;
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0660";
        "listen.owner" = config.services.nginx.user;
        "pm" = "dynamic";
        "pm.max_children" = 75;
        "pm.max_requests" = 500;
        "pm.max_spare_servers" = 20;
        "pm.min_spare_servers" = 1;
        "pm.start_servers" = 2;
      };

      user = if localDB then user else "nginx";
    };

    services.postgresql = lib.mkIf localDB {
      enable = true;
      ensureDatabases = [ cfg.database.dbname ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.username;
        }
      ];
    };

    # backward compatibility: if password is set but not passwordFile, make one.
    services.roundcube.database.passwordFile = lib.mkIf (!localDB && cfg.database.password != "") (
      lib.mkDefault "${pkgs.writeText "roundcube-password" cfg.database.password}"
    );

    systemd.services.phpfpm-roundcube.after = [ "roundcube-setup.service" ];

    # Restart on config changes.
    systemd.services.phpfpm-roundcube.restartTriggers = [
      config.environment.etc."roundcube/config.inc.php".source
    ];

    systemd.services.roundcube-setup = lib.mkMerge [
      (lib.mkIf localDB {
        after = [ "postgresql.target" ];
        requires = [ "postgresql.target" ];
      })
      {
        after = [ "network-online.target" ];
        environment = env;

        path = [
          (if localDB then config.services.postgresql.package else pkgs.postgresql)
        ];

        script =
          let
            psql = "${lib.optionalString (!localDB) "PGPASSFILE=${cfg.database.passwordFile}"} psql ${
              lib.optionalString (!localDB) "-h ${cfg.database.host} -U ${cfg.database.username} "
            } ${cfg.database.dbname}";
          in
          ''
            version="$(${psql} -t <<< "select value from system where name = 'roundcube-version';" || true)"
            if ! (grep -E '[a-zA-Z0-9]' <<< "$version"); then
              ${psql} -f ${cfg.package}/SQL/postgres.initial.sql
            fi

            if [ ! -f /var/lib/roundcube/des_key ]; then
              base64 /dev/urandom | head -c 24 > /var/lib/roundcube/des_key;
              # we need to log out everyone in case change the des_key
              # from the default when upgrading from nixos 19.09
              ${psql} <<< 'TRUNCATE TABLE session;'
            fi

            ${phpWithPspell}/bin/php ${cfg.package}/bin/update.sh
          '';

        serviceConfig = {
          StateDirectory = "roundcube";
          # so that the des_key is not world readable
          StateDirectoryMode = "0700";
          Type = "oneshot";
          User = if localDB then user else "nginx";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      }
    ];

    users.groups.${user} = lib.mkIf localDB { };

    users.users.${user} = lib.mkIf localDB {
      createHome = false;
      group = user;
      isSystemUser = true;
    };

    warnings =
      lib.optional (!localDB && cfg.database.password != "")
        "services.roundcube.database.password is deprecated and insecure; use services.roundcube.database.passwordFile instead";
  };
}
