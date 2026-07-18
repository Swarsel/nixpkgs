# Tests in: nixos/tests/php/fpm-modular.nix

# Non-module dependencies (importApply)
{ coreutils, formats }:

# Service module
{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.php-fpm;
  format = formats.iniWithGlobalSection { };
  configFile = format.generate "php-fpm.conf" {
    globalSection = lib.filterAttrs (_: v: !lib.isAttrs v) cfg.settings;
    sections = lib.filterAttrs (_: lib.isAttrs) cfg.settings;
  };

  poolOpts =
    { name, ... }:
    {
      freeformType =
        with lib.types;
        attrsOf (oneOf [
          str
          int
          bool
        ]);

      options = {
        listen = lib.mkOption {
          default = "/run/php-fpm/${name}.sock";

          description = ''
            The address on which to accept FastCGI requests. Valid syntaxes are: `ip.add.re.ss:port`, `port`, `/path/to/unix/socket`.
          '';

          type =
            with lib.types;
            oneOf [
              path
              port
              str
            ];
        };

        pm = lib.mkOption {
          description = ''
            Choose how the process manager will control the number of child processes.

            `static` - the number of child processes is fixed (`pm.max_children`).
            `ondemand` - the processes spawn on demand (when requested, as opposed to `dynamic`, where `pm.start_servers` are started when the service is started).
            `dynamic` - the number of child processes is set dynamically based on the following directives: `pm.max_children`, `pm.start_servers`, pm.min_spare_servers, `pm.max_spare_servers`.
          '';

          type = lib.types.enum [
            "static"
            "ondemand"
            "dynamic"
          ];
        };

        "pm.max_children" = lib.mkOption {
          description = ''
            The number of child processes to be created when `pm` is set to `static` and the maximum
            number of child processes to be created when `pm` is set to `dynamic`.

            This option sets the limit on the number of simultaneous requests that will be served.
          '';

          type = lib.types.int;
        };

        user = lib.mkOption {
          description = ''
            Unix user of FPM processes.
          '';

          type = lib.types.str;
        };
      };
    };
in
{
  _class = "service";

  config = {
    php-fpm.settings = {
      daemonize = false;
      error_log = "syslog";
    };

    process.argv = [
      "${cfg.package}/bin/php-fpm"
      "-y"
      configFile
    ];
  }
  // lib.optionalAttrs (options ? systemd) {

    systemd.service = {
      after = [ "network.target" ];
      documentation = [ "man:php-fpm(8)" ];

      serviceConfig = {
        ExecReload = "${coreutils}/bin/kill -USR2 $MAINPID";
        Restart = "always";
        RuntimeDirectory = "php-fpm";
        RuntimeDirectoryPreserve = true;
        Type = "notify";
      };
    };

  }
  // lib.optionalAttrs (options ? finit) {

    finit.service = {
      conditions = [ "service/syslogd/ready" ];
      notify = "systemd";
      reload = "${coreutils}/bin/kill -USR2 $MAINPID";
    };
  };

  options.php-fpm = {
    package = lib.mkOption {
      defaultText = lib.literalMD "The PHP package that provided this module.";
      description = "PHP package to use for php-fpm";

      example = lib.literalExpression ''
        php.buildEnv {
          extensions =
            { all, ... }:
            with all;
            [
              imagick
              opcache
            ];
          extraConfig = "memory_limit=256M";
        }
      '';

      type = lib.types.package;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        PHP FPM configuration. Refer to [upstream documentation](https://www.php.net/manual/en/install.fpm.configuration.php) for details on supported values.
      '';

      example = lib.literalExpression ''
        {
          log_level = "debug";
          log_limit = 2048;

          mypool = {
            "user" = "php";
            "group" = "php";
            "listen.owner" = "caddy";
            "listen.group" = "caddy";
            "pm" = "dynamic";
            "pm.max_children" = 75;
            "pm.start_servers" = 10;
            "pm.min_spare_servers" = 5;
            "pm.max_spare_servers" = 20;
            "pm.max_requests" = 500;
          }
        }
      '';

      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
            (submodule poolOpts)
          ]);

        options = {
          log_level = lib.mkOption {
            default = "notice";

            description = ''
              Error log level.
            '';

            type = lib.types.enum [
              "alert"
              "error"
              "warning"
              "notice"
              "debug"
            ];
          };
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    aanderse
  ];
}
