{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.users.mysql;
in
{
  options = {
    users.mysql = {
      enable = lib.mkEnableOption "authentication against a MySQL/MariaDB database";

      database = lib.mkOption {
        description = "The name of the database containing the users";
        example = "auth";
        type = lib.types.str;
      };

      host = lib.mkOption {
        description = "The hostname of the MySQL/MariaDB server";
        example = "localhost";
        type = lib.types.str;
      };

      nss = lib.mkOption {
        description = ''
          Settings for `libnss-mysql`.

          All examples are from the [minimal example](https://github.com/saknopper/libnss-mysql/tree/master/sample/minimal)
          of `libnss-mysql`, but they are modified with NixOS paths for bash.
        '';

        type = lib.types.submodule {
          options = {
            getgrent = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getgrent](https://man7.org/linux/man-pages/man3/getgrent.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT name,password,gid FROM groups
              '';

              type = lib.types.nullOr lib.types.str;
            };

            getgrgid = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getgrgid](https://man7.org/linux/man-pages/man3/getgrgid.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT name,password,gid FROM groups WHERE gid='%1$u' LIMIT 1
              '';

              type = lib.types.nullOr lib.types.str;
            };

            getgrnam = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getgrnam](https://man7.org/linux/man-pages/man3/getgrnam.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT name,password,gid FROM groups WHERE name='%1$s' LIMIT 1
              '';

              type = lib.types.nullOr lib.types.str;
            };

            getpwent = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getpwent](https://man7.org/linux/man-pages/man3/getpwent.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT username,'x',uid,'5000','MySQL User', CONCAT('/home/',username),'/run/sw/current-system/bin/bash' FROM users
              '';

              type = lib.types.nullOr lib.types.str;
            };

            getpwnam = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getpwnam](https://man7.org/linux/man-pages/man3/getpwnam.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT username,'x',uid,'5000','MySQL User', CONCAT('/home/',username),'/run/sw/current-system/bin/bash' \
                FROM users \
                WHERE username='%1$s' \
                LIMIT 1
              '';

              type = lib.types.nullOr lib.types.str;
            };

            getpwuid = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getpwuid](https://man7.org/linux/man-pages/man3/getpwuid.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT username,'x',uid,'5000','MySQL User', CONCAT('/home/',username),'/run/sw/current-system/bin/bash' \
                FROM users \
                WHERE uid='%1$u' \
                LIMIT 1
              '';

              type = lib.types.nullOr lib.types.str;
            };

            getspent = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getspent](https://man7.org/linux/man-pages/man3/getspent.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT username,password,'1','0','99999','0','0','-1','0' FROM users
              '';

              type = lib.types.nullOr lib.types.str;
            };

            getspnam = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [getspnam](https://man7.org/linux/man-pages/man3/getspnam.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT username,password,'1','0','99999','0','0','-1','0' \
                FROM users \
                WHERE username='%1$s' \
                LIMIT 1
              '';

              type = lib.types.nullOr lib.types.str;
            };

            gidsbymem = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [gidsbymem](https://man7.org/linux/man-pages/man3/gidsbymem.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT gid FROM grouplist WHERE username='%1$s'
              '';

              type = lib.types.nullOr lib.types.str;
            };

            memsbygid = lib.mkOption {
              default = null;

              description = ''
                SQL query for the [memsbygid](https://man7.org/linux/man-pages/man3/memsbygid.3.html)
                syscall.
              '';

              example = lib.literalExpression ''
                SELECT username FROM grouplist WHERE gid='%1$u'
              '';

              type = lib.types.nullOr lib.types.str;
            };
          };
        };
      };

      pam = lib.mkOption {
        description = "Settings for `pam_mysql`";

        type = lib.types.submodule {
          options = {
            cryptDefault = lib.mkOption {
              default = null;
              description = "The default encryption method to use for `passwordCrypt = 1`.";
              example = "blowfish";

              type = lib.types.nullOr (
                lib.types.enum [
                  "md5"
                  "sha256"
                  "sha512"
                  "blowfish"
                ]
              );
            };

            disconnectEveryOperation = lib.mkOption {
              default = false;

              description = ''
                By default, `pam_mysql` keeps the connection to the MySQL
                database until the session is closed. If this option is set to true it
                disconnects every time the PAM operation has finished. This option may
                be useful in case the session lasts quite long.
              '';

              type = lib.types.bool;
            };

            logging = {
              enable = lib.mkOption {
                default = false;
                description = "Enables logging of authentication attempts in the MySQL database.";
                type = lib.types.bool;
              };

              hostColumn = lib.mkOption {
                description = ''
                  The name of the column in the log table to which the name of the user
                  being authenticated is stored.
                '';

                example = "host";
                type = lib.types.str;
              };

              msgColumn = lib.mkOption {
                description = ''
                  The name of the column in the log table to which the description
                  of the performed operation is stored.
                '';

                example = "msg";
                type = lib.types.str;
              };

              pidColumn = lib.mkOption {
                description = ''
                  The name of the column in the log table to which the pid of the
                  process utilising the `pam_mysql` authentication
                  service is stored.
                '';

                example = "pid";
                type = lib.types.str;
              };

              rHostColumn = lib.mkOption {
                description = ''
                  The name of the column in the log table to which the name of the remote
                  host that initiates the session is stored. The value is supposed to be
                  set by the PAM-aware application with `pam_set_item(PAM_RHOST)`.
                '';

                example = "rhost";
                type = lib.types.str;
              };

              table = lib.mkOption {
                description = "The name of the table to which logs are written.";
                example = "logs";
                type = lib.types.str;
              };

              timeColumn = lib.mkOption {
                description = ''
                  The name of the column in the log table to which the timestamp of the
                  log entry is stored.
                '';

                example = "timestamp";
                type = lib.types.str;
              };

              userColumn = lib.mkOption {
                description = ''
                  The name of the column in the log table to which the name of the
                  user being authenticated is stored.
                '';

                example = "user";
                type = lib.types.str;
              };
            };

            passwordColumn = lib.mkOption {
              description = "The name of the column that contains a (encrypted) password string.";
              example = "password";
              type = lib.types.str;
            };

            passwordCrypt = lib.mkOption {
              description = ''
                The method to encrypt the user's password:

                - `0` (or `"plain"`):
                  No encryption. Passwords are stored in plaintext. HIGHLY DISCOURAGED.
                - `1` (or `"Y"`):
                  Use {manpage}`crypt(3)` function.
                - `2` (or `"mysql"`):
                  Use the MySQL PASSWORD() function. It is possible that the encryption function used
                  by `pam_mysql` is different from that of the MySQL server, as
                  `pam_mysql` uses the function defined in MySQL's C-client API
                  instead of using PASSWORD() SQL function in the query.
                - `3` (or `"md5"`):
                  Use plain hex MD5.
                - `4` (or `"sha1"`):
                  Use plain hex SHA1.
                - `5` (or `"drupal7"`):
                  Use Drupal7 salted passwords.
                - `6` (or `"joomla15"`):
                  Use Joomla15 salted passwords.
                - `7` (or `"ssha"`):
                  Use ssha hashed passwords.
                - `8` (or `"sha512"`):
                  Use sha512 hashed passwords.
                - `9` (or `"sha256"`):
                  Use sha256 hashed passwords.
              '';

              example = "2";

              type = lib.types.enum [
                "0"
                "plain"
                "1"
                "Y"
                "2"
                "mysql"
                "3"
                "md5"
                "4"
                "sha1"
                "5"
                "drupal7"
                "6"
                "joomla15"
                "7"
                "ssha"
                "8"
                "sha512"
                "9"
                "sha256"
              ];
            };

            statusColumn = lib.mkOption {
              default = null;

              description = ''
                The name of the column or an SQL expression that indicates the status of
                the user. The status is expressed by the combination of two bitfields
                shown below:

                - `bit 0 (0x01)`:
                   if flagged, `pam_mysql` deems the account to be expired and
                   returns `PAM_ACCT_EXPIRED`. That is, the account is supposed
                   to no longer be available. Note this doesn't mean that `pam_mysql`
                   rejects further authentication operations.
                -  `bit 1 (0x02)`:
                   if flagged, `pam_mysql` deems the authentication token
                   (password) to be expired and returns `PAM_NEW_AUTHTOK_REQD`.
                   This ends up requiring that the user enter a new password.
              '';

              example = "status";
              type = lib.types.nullOr lib.types.str;
            };

            table = lib.mkOption {
              description = "The name of table that maps unique login names to the passwords.";
              example = "users";
              type = lib.types.str;
            };

            updateTable = lib.mkOption {
              default = null;

              description = ''
                The name of the table used for password alteration. If not defined, the value
                of the `table` option will be used instead.
              '';

              example = "users_updates";
              type = lib.types.nullOr lib.types.str;
            };

            userColumn = lib.mkOption {
              description = "The name of the column that contains a unix login name.";
              example = "username";
              type = lib.types.str;
            };

            verbose = lib.mkOption {
              default = false;

              description = ''
                If enabled, produces logs with detailed messages that describes what
                `pam_mysql` is doing. May be useful for debugging.
              '';

              type = lib.types.bool;
            };

            where = lib.mkOption {
              default = null;
              description = "Additional criteria for the query.";
              example = "host.name='web' AND user.active=1";
              type = lib.types.nullOr lib.types.str;
            };
          };
        };
      };

      passwordFile = lib.mkOption {
        description = "The path to the file containing the password for the user";
        example = "/run/secrets/mysql-auth-db-passwd";
        type = lib.types.path;
      };

      user = lib.mkOption {
        description = "The username to use when connecting to the database";
        example = "nss-user";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."libnss-mysql-root.cfg" = {
      group = config.services.nscd.group;
      mode = "0600";

      # password will be added from password file in systemd oneshot
      text = ''
        username ${cfg.user}
      '';

      user = config.services.nscd.user;
    };

    environment.etc."libnss-mysql.cfg" = {
      group = config.services.nscd.group;
      mode = "0600";

      text =
        lib.optionalString (cfg.nss.getpwnam != null) ''
          getpwnam ${cfg.nss.getpwnam}
        ''
        + lib.optionalString (cfg.nss.getpwuid != null) ''
          getpwuid ${cfg.nss.getpwuid}
        ''
        + lib.optionalString (cfg.nss.getspnam != null) ''
          getspnam ${cfg.nss.getspnam}
        ''
        + lib.optionalString (cfg.nss.getpwent != null) ''
          getpwent ${cfg.nss.getpwent}
        ''
        + lib.optionalString (cfg.nss.getspent != null) ''
          getspent ${cfg.nss.getspent}
        ''
        + lib.optionalString (cfg.nss.getgrnam != null) ''
          getgrnam ${cfg.nss.getgrnam}
        ''
        + lib.optionalString (cfg.nss.getgrgid != null) ''
          getgrgid ${cfg.nss.getgrgid}
        ''
        + lib.optionalString (cfg.nss.getgrent != null) ''
          getgrent ${cfg.nss.getgrent}
        ''
        + lib.optionalString (cfg.nss.memsbygid != null) ''
          memsbygid ${cfg.nss.memsbygid}
        ''
        + lib.optionalString (cfg.nss.gidsbymem != null) ''
          gidsbymem ${cfg.nss.gidsbymem}
        ''
        + ''
          host ${cfg.host}
          database ${cfg.database}
        '';

      user = config.services.nscd.user;
    };

    environment.etc."security/pam_mysql.conf" = {
      group = "root";
      mode = "0600";

      # password will be added from password file in systemd oneshot
      text = ''
        users.host=${cfg.host}
        users.db_user=${cfg.user}
        users.database=${cfg.database}
        users.table=${cfg.pam.table}
        users.user_column=${cfg.pam.userColumn}
        users.password_column=${cfg.pam.passwordColumn}
        users.password_crypt=${cfg.pam.passwordCrypt}
        users.disconnect_every_operation=${if cfg.pam.disconnectEveryOperation then "1" else "0"}
        verbose=${if cfg.pam.verbose then "1" else "0"}
      ''
      + lib.optionalString (cfg.pam.cryptDefault != null) ''
        users.use_${cfg.pam.cryptDefault}=1
      ''
      + lib.optionalString (cfg.pam.where != null) ''
        users.where_clause=${cfg.pam.where}
      ''
      + lib.optionalString (cfg.pam.statusColumn != null) ''
        users.status_column=${cfg.pam.statusColumn}
      ''
      + lib.optionalString (cfg.pam.updateTable != null) ''
        users.update_table=${cfg.pam.updateTable}
      ''
      + lib.optionalString cfg.pam.logging.enable ''
        log.enabled=true
        log.table=${cfg.pam.logging.table}
        log.message_column=${cfg.pam.logging.msgColumn}
        log.pid_column=${cfg.pam.logging.pidColumn}
        log.user_column=${cfg.pam.logging.userColumn}
        log.host_column=${cfg.pam.logging.hostColumn}
        log.rhost_column=${cfg.pam.logging.rHostColumn}
        log.time_column=${cfg.pam.logging.timeColumn}
      '';

      user = "root";
    };

    system.nssDatabases.group = [ "mysql" ];
    system.nssDatabases.passwd = [ "mysql" ];
    system.nssDatabases.shadow = [ "mysql" ];
    system.nssModules = [ pkgs.libnss-mysql ];

    systemd.services.mysql-auth-pw-init = {
      before = [ "nscd.service" ];
      description = "Adds the mysql password to the mysql auth config files";

      restartTriggers = [
        config.environment.etc."security/pam_mysql.conf".source
        config.environment.etc."libnss-mysql.cfg".source
        config.environment.etc."libnss-mysql-root.cfg".source
      ];

      script = ''
        if [[ -r ${cfg.passwordFile} ]]; then
          umask 0077
          conf_nss="$(mktemp)"
          cp /etc/libnss-mysql-root.cfg $conf_nss
          printf 'password %s\n' "$(cat ${cfg.passwordFile})" >> $conf_nss
          mv -fT "$conf_nss" /etc/libnss-mysql-root.cfg
          chown ${config.services.nscd.user}:${config.services.nscd.group} /etc/libnss-mysql-root.cfg

          conf_pam="$(mktemp)"
          cp /etc/security/pam_mysql.conf $conf_pam
          printf 'users.db_passwd=%s\n' "$(cat ${cfg.passwordFile})" >> $conf_pam
          mv -fT "$conf_pam" /etc/security/pam_mysql.conf
        fi
      '';

      serviceConfig = {
        Group = "root";
        Type = "oneshot";
        User = "root";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.netali ];
}
