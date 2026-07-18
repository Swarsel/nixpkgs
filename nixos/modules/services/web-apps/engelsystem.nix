{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    mkRenamedOptionModule
    types
    ;

  cfg = config.services.engelsystem;
in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "engelsystem" "config" ]
      [ "services" "engelsystem" "settings" ]
    )
  ];

  options.services.engelsystem = {
    enable = mkEnableOption "engelsystem, an online tool for coordinating volunteers and shifts on large events";
    package = mkPackageOption pkgs "engelsystem" { };

    createDatabase = mkOption {
      default = true;

      description = ''
        Whether to create a local database automatically.
        This will override every database setting in {option}`services.engelsystem.settings`.
      '';

      type = types.bool;
    };

    domain = mkOption {
      description = "Domain to serve on.";
      example = "engelsystem.example.com";
      type = types.str;
    };

    settings = mkOption {
      default = {
        database = {
          database = "engelsystem";
          host = "localhost";
          username = "engelsystem";
        };
      };

      description = ''
        Options to be added to config.php, as a nix attribute set. Options containing secret data
        should be set to an attribute set containing the attribute _secret - a string pointing to a
        file containing the value the option should be set to. See the example to get a better
        picture of this: in the resulting config.php file, the email.password key will be set to
        the contents of the /var/keys/engelsystem/mail file.

        See <https://engelsystem.de/doc/admin/configuration/> for available options.

        Note that the admin user login credentials cannot be set here - they always default to
        admin:asdfasdf. Log in and change them immediately.
      '';

      example = {
        autoarrive = true;

        database = {
          database = "engelsystem";
          host = "database.example.com";
          password._secret = "/var/keys/engelsystem/database";
          username = "engelsystem";
        };

        default_locale = "de_DE";

        email = {
          driver = "smtp";
          encryption = "tls";
          from.address = "engelsystem@example.com";
          from.name = "example engelsystem";
          host = "smtp.example.com";
          password._secret = "/var/keys/engelsystem/mail";
          port = 587;
          username = "engelsystem@example.com";
        };

        maintenance = false;
        min_password_length = 6;
      };

      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."engelsystem/config.php".source = pkgs.writeText "config.php" ''
      <?php
      return json_decode(file_get_contents("/var/lib/engelsystem/config.json"), true);
    '';

    # create database
    services.mysql = mkIf cfg.createDatabase {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ "engelsystem" ];

      ensureUsers = [
        {
          ensurePermissions = {
            "engelsystem.*" = "ALL PRIVILEGES";
          };

          name = "engelsystem";
        }
      ];
    };

    services.nginx = {
      enable = true;

      virtualHosts."${cfg.domain}".locations = {
        "/" = {
          extraConfig = ''
            index index.php;
            try_files $uri $uri/ /index.php?$args;
            autoindex off;
          '';

          root = "${cfg.package}/share/php/engelsystem/public";
        };

        "~ \\.php$" = {
          extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.engelsystem.socket};
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include ${config.services.nginx.package}/conf/fastcgi_params;
            include ${config.services.nginx.package}/conf/fastcgi.conf;
          '';

          root = "${cfg.package}/share/php/engelsystem/public";
        };
      };
    };

    services.phpfpm.pools.engelsystem = {
      settings = {
        "catch_workers_output" = true;
        "listen.owner" = config.services.nginx.user;
        "php_admin_flag[log_errors]" = true;
        "php_admin_value[error_log]" = "stderr";
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.max_spare_servers" = 5;
        "pm.min_spare_servers" = 2;
        "pm.start_servers" = 2;
      };

      user = "engelsystem";
    };

    systemd.services."engelsystem-init" = {
      script =
        let
          genConfigScript = pkgs.writeScript "engelsystem-gen-config.sh" (
            utils.genJqSecretsReplacementSnippet cfg.settings "config.json"
          );
        in
        ''
          umask 077
          mkdir -p /var/lib/engelsystem/storage/app
          mkdir -p /var/lib/engelsystem/storage/cache/views
          cd /var/lib/engelsystem
          ${genConfigScript}
          chmod 400 config.json
          chown -R engelsystem .
        '';

      serviceConfig = {
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."engelsystem-migrate" = {
      after = [
        "engelsystem-init.service"
        "mysql.service"
      ];

      script = ''
        versionFile="/var/lib/engelsystem/.version"
        version=$(cat "$versionFile" 2>/dev/null || echo 0)

        if [[ $version != ${cfg.package.version} ]]; then
          # prune template cache between releases
          rm -rfv /var/lib/engelsystem/storage/cache/*

          ${cfg.package}/bin/migrate

          echo ${cfg.package.version} > "$versionFile"
        fi
      '';

      serviceConfig = {
        Group = "engelsystem";
        Type = "oneshot";
        User = "engelsystem";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."phpfpm-engelsystem".after = [ "engelsystem-migrate.service" ];
    users.groups.engelsystem = { };

    users.users.engelsystem = {
      createHome = true;
      group = "engelsystem";
      home = "/var/lib/engelsystem/storage";
      isSystemUser = true;
    };
  };
}
