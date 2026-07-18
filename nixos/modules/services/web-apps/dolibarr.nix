{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    boolToString
    concatStringsSep
    elem
    isBool
    isString
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    types
    mkPackageOption
    ;

  package = cfg.package.override { inherit (cfg) stateDir; };

  cfg = config.services.dolibarr;

  forcedTLS =
    if cfg.h2o != null then
      cfg.h2o.tls != null && cfg.h2o.tls.policy == "force"
    else if cfg.nginx != null then
      cfg.nginx.forceSSL
    else
      false;

  mkConfigFile =
    filename: settings:
    let
      # hack in special logic for secrets so we read them from a separate file avoiding the Nix store
      secretKeys = [
        "force_install_databasepass"
        "dolibarr_main_db_pass"
        "dolibarr_main_instance_unique_id"
      ];

      toStr =
        k: v:
        if (elem k secretKeys) then
          v
        else if isString v then
          "'${v}'"
        else if isBool v then
          boolToString v
        else if v == null then
          "null"
        else
          toString v;
    in
    pkgs.writeText filename ''
      <?php
      ${concatStringsSep "\n" (mapAttrsToList (k: v: "\$${k} = ${toStr k v};") settings)}
    '';

  dbUnit =
    {
      "mysql" = "mysql.service";
      "postgresql" = "postgresql.target";
    }
    .${cfg.database.type};

  dbPort =
    if cfg.database.createLocally then
      {
        "mysql" = config.services.mysql.settings.mysqld.port;
        "postgresql" = config.services.postgresql.settings.port;
      }
      .${cfg.database.type}
    else
      cfg.database.port;

  # exclusivity asserted in `assertions`
  webServerService =
    if cfg.h2o != null then
      "h2o.service"
    else if cfg.nginx != null then
      "nginx.service"
    else
      null;

  socketOwner = if cfg.h2o != null then config.services.h2o.user else cfg.user;

  # see https://github.com/Dolibarr/dolibarr/blob/develop/htdocs/install/install.forced.sample.php for all possible values
  install = {
    force_install_createuser = false;
    force_install_database = cfg.database.name;
    force_install_databaselogin = cfg.database.user;
    force_install_dbserver = cfg.database.host;
    force_install_distrib = "nixos";
    force_install_dolibarrlogin = null;
    force_install_lockinstall = "444";
    force_install_main_data_root = "${cfg.stateDir}/documents";
    force_install_mainforcehttps = forcedTLS;
    force_install_noedit = 2;
    force_install_nophpinfo = true;
    force_install_port = toString dbPort;

    force_install_type =
      {
        "mysql" = "mysqli";
        "postgresql" = "pgsql";
      }
      .${cfg.database.type};
  }
  // optionalAttrs (cfg.database.passwordFile != null) {
    force_install_databasepass = ''file_get_contents("${cfg.database.passwordFile}")'';
  };
in
{
  # interface
  options.services.dolibarr = {
    enable = mkEnableOption "dolibarr";
    package = mkPackageOption pkgs "dolibarr" { };

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
        default = "dolibarr";
        description = "Database name.";
        type = types.str;
      };

      passwordFile = mkOption {
        default = null;
        description = "Database password file.";
        example = "/run/keys/dolibarr-dbpassword";
        type = with types; nullOr path;
      };

      port = mkOption {
        default = 3306;
        description = "Database host port.";
        type = types.port;
      };

      type = mkOption {
        default = "mysql";
        description = "Database engine to use.";
        example = "postgresql";

        type = types.enum [
          "mysql"
          "postgresql"
        ];
      };

      user = mkOption {
        default = "dolibarr";
        description = "Database username.";
        type = types.str;
      };
    };

    domain = mkOption {
      default = "localhost";

      description = ''
        Domain name of your server.
      '';

      type = types.str;
    };

    group = mkOption {
      default = "dolibarr";

      description = ''
        Group account under which dolibarr runs.

        ::: {.note}
        If left as the default value this group will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the group exists before the dolibarr application starts.
        :::
      '';

      type = types.str;
    };

    h2o = mkOption {
      default = null;

      description = ''
        With this option, you can customize an H2O virtual host which already
        has sensible defaults for Dolibarr. Set to `{ }` if you do not need any
        customization to the virtual host. If enabled, then by default, the
        {option}`serverName` is `''${domain}`, If this is set to `null` (the
        default), no H2O `hosts` will be configured.
      '';

      example =
        lib.literalExpression # nix
          ''
            {
              acme.enable = true;
              tls.policy = "force";
              compress = "ON";
            }
          '';

      type = types.nullOr (
        types.submodule (import ../web-servers/h2o/vhost-options.nix { inherit config lib; })
      );
    };

    nginx = mkOption {
      default = null;

      description = ''
        With this option, you can customize an nginx virtual host which already has sensible defaults for Dolibarr.
        Set to {} if you do not need any customization to the virtual host.
        If enabled, then by default, the {option}`serverName` is
        `''${domain}`,
        SSL is active, and certificates are acquired via ACME.
        If this is set to null (the default), no nginx virtualHost will be configured.
      '';

      example = lib.literalExpression ''
        {
          serverAliases = [
            "dolibarr.''${config.networking.domain}"
            "erp.''${config.networking.domain}"
          ];
          enableACME = false;
        }
      '';

      type = types.nullOr (
        types.submodule (
          lib.recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) {
            options.enableACME.default = true;
            # enable encryption by default,
            # as sensitive login and Dolibarr (ERP) data should not be transmitted in clear text.
            options.forceSSL.default = true;
          }
        )
      );
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
        Options for the Dolibarr PHP pool. See the documentation on [`php-fpm.conf`](https://www.php.net/manual/en/install.fpm.configuration.php)
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
      description = "Dolibarr settings, see <https://github.com/Dolibarr/dolibarr/blob/develop/htdocs/conf/conf.php.example> for details.";

      type =
        with types;
        (attrsOf (oneOf [
          bool
          int
          str
        ]));
    };

    stateDir = mkOption {
      default = "/var/lib/dolibarr";

      description = ''
        State and configuration directory dolibarr will use.
      '';

      type = types.str;
    };

    user = mkOption {
      default = "dolibarr";

      description = ''
        User account under which dolibarr runs.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the user exists before the dolibarr application starts.
        :::
      '';

      type = types.str;
    };
  };

  # implementation
  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.user == cfg.user;
        message = "services.dolibarr.database.user must match services.dolibarr.user if the database is to be automatically provisioned";
      }
      (
        let
          webServers = [
            "h2o"
            "nginx"
          ];
          checkConfigs = lib.concatMapStringsSep ", " (ws: "services.dolibarr.${ws}") webServers;
        in
        {
          assertion = builtins.length (lib.lists.filter (ws: cfg.${ws} != null) webServers) <= 1;

          message = ''
            At most 1 web server virtual host configuration should be enabled
            for Dolibarr at a time. Check ${checkConfigs}.
          '';
        }
      )
    ];

    services.dolibarr.settings = {
      dolibarr_mailing_limit_sendbyweb = false;
      # Authentication settings
      dolibarr_main_authentication = mkDefault "dolibarr";
      dolibarr_main_data_root = "${cfg.stateDir}/documents";
      dolibarr_main_db_character_set = mkDefault "utf8";
      dolibarr_main_db_collation = mkDefault "utf8_unicode_ci";
      dolibarr_main_db_host = cfg.database.host;
      dolibarr_main_db_name = cfg.database.name;

      dolibarr_main_db_pass = mkIf (cfg.database.passwordFile != null) ''
        file_get_contents("${cfg.database.passwordFile}")
      '';

      dolibarr_main_db_port = toString dbPort;
      dolibarr_main_db_prefix = "llx_";

      dolibarr_main_db_type =
        {
          "mysql" = "mysqli";
          "postgresql" = "pgsql";
        }
        .${cfg.database.type};

      dolibarr_main_db_user = cfg.database.user;
      dolibarr_main_document_root = "${package}/htdocs";
      dolibarr_main_force_https = forcedTLS;

      dolibarr_main_instance_unique_id = ''
        file_get_contents("${cfg.stateDir}/dolibarr_main_instance_unique_id")
      '';

      # Security settings
      dolibarr_main_prod = true;

      dolibarr_main_restrict_os_commands =
        {
          "mysql" = "${pkgs.mariadb}/bin/mysqldump, ${pkgs.mariadb}/bin/mysql";

          "postgresql" =
            let
              pkg = config.services.postgresql.package;
            in
            "${pkg}/bin/pg_dump, ${pkg}/bin/psql";
        }
        .${cfg.database.type};

      dolibarr_main_url_root = "https://${cfg.domain}";
      dolibarr_main_url_root_alt = "/custom";
      dolibarr_nocsrfcheck = false;
    };

    services.h2o = mkIf (cfg.h2o != null) {
      enable = true;

      hosts."${cfg.domain}" = mkMerge [
        {
          settings = {
            "file.custom-handler" = {
              extension = [ ".php" ];

              "fastcgi.connect" = {
                port = config.services.phpfpm.pools.dolibarr.socket;
                type = "unix";
              };

              "fastcgi.document_root" = "${package}/htdocs";
            };

            paths = {
              "/" = {
                "file.dir" = "${package}/htdocs";

                "file.index" = [
                  "index.php"
                  "index.html"
                ];

                redirect = {
                  internal = "YES";
                  status = 307;
                  url = "/index.php/";
                };
              };
            };
          };
        }
        cfg.h2o
      ];
    };

    services.mysql = mkIf (cfg.database.createLocally && cfg.database.type == "mysql") {
      enable = mkDefault true;
      package = mkDefault pkgs.mariadb;
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

    services.nginx.enable = mkIf (cfg.nginx != null) true;

    services.nginx.virtualHosts."${cfg.domain}" = mkIf (cfg.nginx != null) (
      lib.mkMerge [
        cfg.nginx
        {
          locations."/".index = "index.php";

          locations."~ [^/]\\.php(/|$)" = {
            extraConfig = ''
              fastcgi_split_path_info ^(.+?\.php)(/.*)$;
              fastcgi_pass unix:${config.services.phpfpm.pools.dolibarr.socket};
            '';
          };

          root = lib.mkForce "${package}/htdocs";
        }
      ]
    );

    services.phpfpm.pools.dolibarr = {
      inherit (cfg) user group;

      phpPackage = pkgs.php83.buildEnv {
        extensions = { all, enabled }: enabled ++ [ all.calendar ];

        # recommended by Dolibarr web application
        extraConfig = ''
          session.use_strict_mode = 1
          session.cookie_samesite = "Lax"
          ; open_basedir = "${package}/htdocs, ${cfg.stateDir}"
          allow_url_fopen = 0
          disable_functions = "pcntl_alarm, pcntl_fork, pcntl_waitpid, pcntl_wait, pcntl_wifexited, pcntl_wifstopped, pcntl_wifsignaled, pcntl_wifcontinued, pcntl_wexitstatus, pcntl_wtermsig, pcntl_wstopsig, pcntl_signal, pcntl_signal_get_handler, pcntl_signal_dispatch, pcntl_get_last_error, pcntl_strerror, pcntl_sigprocmask, pcntl_sigwaitinfo, pcntl_sigtimedwait, pcntl_exec, pcntl_getpriority, pcntl_setpriority, pcntl_async_signals"
        '';
      };

      settings = {
        "listen.group" = cfg.group;
        "listen.mode" = "0660";
        "listen.owner" = socketOwner;
      }
      // cfg.poolConfig;
    };

    services.postgresql = mkIf (cfg.database.createLocally && cfg.database.type == "postgresql") {
      enable = mkDefault true;

      authentication = ''
        host ${cfg.database.name} ${cfg.database.user} localhost trust
      '';

      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    # There are several challenges with Dolibarr and NixOS which we can address here
    # - the Dolibarr installer cannot be entirely automated, though it can partially be by including a file called install.forced.php
    # - the Dolibarr installer requires write access to its config file during installation, though not afterwards
    # - the Dolibarr config file generally holds secrets generated by the installer, though the config file is a PHP file so we can read and write these secrets from an external file
    systemd.services.dolibarr-config = {
      after = lib.optional cfg.database.createLocally dbUnit;
      description = "dolibarr configuration file management via NixOS";

      script =
        let
          php = lib.getExe config.services.phpfpm.pools.dolibarr.phpPackage;
        in
        ''
          # extract the 'main instance unique id' secret that the dolibarr installer generated for us, store it in a file for use by our own NixOS generated configuration file
          ${php} -r "include '${cfg.stateDir}/conf.php'; file_put_contents('${cfg.stateDir}/dolibarr_main_instance_unique_id', \$dolibarr_main_instance_unique_id);"

          # replace configuration file generated by installer with the NixOS generated configuration file
          install -m 440 ${mkConfigFile "conf.php" cfg.settings} '${cfg.stateDir}/conf.php'
        '';

      serviceConfig = {
        Group = cfg.group;
        RemainAfterExit = "yes";
        Type = "oneshot";
        User = cfg.user;
      };

      unitConfig = {
        ConditionFileNotEmpty = "${cfg.stateDir}/conf.php";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."phpfpm-dolibarr" = {
      after = lib.optional cfg.database.createLocally dbUnit;
      before = lib.optional (webServerService != null) webServerService;
      requires = lib.optional cfg.database.createLocally dbUnit;
      wantedBy = lib.optional (webServerService != null) webServerService;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group}"
      "d '${cfg.stateDir}/documents' 0750 ${cfg.user} ${cfg.group}"
      "f '${cfg.stateDir}/conf.php' 0660 ${cfg.user} ${cfg.group}"
      "L '${cfg.stateDir}/install.forced.php' - ${cfg.user} ${cfg.group} - ${mkConfigFile "install.forced.php" install}"
    ];

    users = {
      groups = optionalAttrs (cfg.group == "dolibarr") {
        dolibarr = { };
      };

      users = {
        dolibarr = mkIf (cfg.user == "dolibarr") {
          group = cfg.group;
          isSystemUser = true;
        };
      }
      // lib.optionalAttrs (cfg.h2o != null) {
        "${config.services.h2o.user}".extraGroups = [ cfg.group ];
      }
      // lib.optionalAttrs (cfg.nginx != null) {
        "${config.services.nginx.user}".extraGroups = [ cfg.group ];
      };
    };
  };
}
