{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.phpfpm;

  runtimeDir = "/run/phpfpm";

  toStr =
    value:
    if true == value then
      "yes"
    else if false == value then
      "no"
    else if isString value then
      # Escape according to https://www.php.net/manual/en/function.parse-ini-file.php
      # Not escaping `$` since users might want to use that to interpolate environment variables.
      # Additionally, php-fpm applies post-processing to env values that start with `$` and replaces
      # them with the respective env variable, with no way to escape: https://github.com/php/php-src/blob/631c366f9f58c8ba4078a48d1f56187cfbf8e549/sapi/fpm/fpm/fpm_env.c#L171-L180
      # In all platforms except for Windows, PHP_EOL is the line feed `\n` character,
      # which we use here as an escape value since php-fpm parses the config line-by-line.
      # See https://github.com/NixOS/nixpkgs/pull/516530#issuecomment-4878738511 for more information.
      ''"${replaceString "\n" ''" PHP_EOL "'' (escape [ "\"" "\\" ] value)}"''
    else
      toString value;

  fpmCfgFile =
    pool: poolOpts:
    pkgs.writeText "phpfpm-${pool}.conf" ''
      [global]
      ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} = ${toStr v}") cfg.settings)}
      ${optionalString (cfg.extraConfig != null) cfg.extraConfig}

      [${pool}]
      ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} = ${toStr v}") poolOpts.settings)}
      ${concatStringsSep "\n" (mapAttrsToList (n: v: "env[${n}] = ${toStr v}") poolOpts.phpEnv)}
      ${optionalString (poolOpts.extraConfig != null) poolOpts.extraConfig}
    '';

  phpIni =
    poolOpts:
    pkgs.runCommand "php.ini"
      {
        inherit (poolOpts) phpPackage phpOptions;
        passAsFile = [ "phpOptions" ];
        preferLocalBuild = true;
      }
      ''
        cat ${poolOpts.phpPackage}/etc/php.ini $phpOptionsPath > $out
      '';

  poolOpts =
    { name, ... }:
    let
      poolOpts = cfg.pools.${name};
    in
    {
      options = {
        extraConfig = mkOption {
          default = null;

          description = ''
            Extra lines that go into the pool configuration.
            See the documentation on `php-fpm.conf` for
            details on configuration directives.
          '';

          type = with types; nullOr lines;
        };

        group = mkOption {
          description = "Group account under which this pool runs.";
          type = types.str;
        };

        listen = mkOption {
          default = "";

          description = ''
            The address on which to accept FastCGI requests.
          '';

          example = "/path/to/unix/socket";
          type = types.str;
        };

        phpEnv = lib.mkOption {
          default = { };

          description = ''
            Environment variables used for this PHP-FPM pool.
          '';

          example = literalExpression ''
            {
              HOSTNAME = "$HOSTNAME";
              TMP = "/tmp";
              TMPDIR = "/tmp";
              TEMP = "/tmp";
            }
          '';

          type = with types; attrsOf str;
        };

        phpOptions = mkOption {
          description = ''
            "Options appended to the PHP configuration file {file}`php.ini` used for this PHP-FPM pool."
          '';

          type = types.lines;
        };

        phpPackage = mkOption {
          default = cfg.phpPackage;
          defaultText = literalExpression "config.services.phpfpm.phpPackage";

          description = ''
            The PHP package to use for running this PHP-FPM pool.
          '';

          type = types.package;
        };

        settings = mkOption {
          default = { };

          description = ''
            PHP-FPM pool directives. Refer to the "List of pool directives" section of
            <https://www.php.net/manual/en/install.fpm.configuration.php>
            for details. Note that settings names must be enclosed in quotes (e.g.
            `"pm.max_children"` instead of `pm.max_children`).
          '';

          example = literalExpression ''
            {
              "pm" = "dynamic";
              "pm.max_children" = 75;
              "pm.start_servers" = 10;
              "pm.min_spare_servers" = 5;
              "pm.max_spare_servers" = 20;
              "pm.max_requests" = 500;
            }
          '';

          type =
            with types;
            attrsOf (oneOf [
              str
              int
              bool
            ]);
        };

        socket = mkOption {
          description = ''
            Path to the unix socket file on which to accept FastCGI requests.

            ::: {.note}
            This option is read-only and managed by NixOS.
            :::
          '';

          example = "${runtimeDir}/<name>.sock";
          readOnly = true;
          type = types.str;
        };

        user = mkOption {
          description = "User account under which this pool runs.";
          type = types.str;
        };
      };

      config = {
        group = mkDefault poolOpts.user;
        phpOptions = mkBefore cfg.phpOptions;

        settings = mapAttrs (name: mkDefault) {
          group = poolOpts.group;
          listen = poolOpts.socket;
          user = poolOpts.user;
        };

        socket = if poolOpts.listen == "" then "${runtimeDir}/${name}.sock" else poolOpts.listen;
      };
    };

in
{
  imports = [
    (mkRemovedOptionModule [ "services" "phpfpm" "poolConfigs" ] "Use services.phpfpm.pools instead.")
    (mkRemovedOptionModule [ "services" "phpfpm" "phpIni" ] "")
  ];

  options = {
    services.phpfpm = {
      extraConfig = mkOption {
        default = null;

        description = ''
          Extra configuration that should be put in the global section of
          the PHP-FPM configuration file. Do not specify the options
          `error_log` or
          `daemonize` here, since they are generated by
          NixOS.
        '';

        type = with types; nullOr lines;
      };

      phpOptions = mkOption {
        default = "";

        description = ''
          Options appended to the PHP configuration file {file}`php.ini`.
        '';

        example = ''
          date.timezone = "CET"
        '';

        type = types.lines;
      };

      phpPackage = mkPackageOption pkgs "php" { };

      pools = mkOption {
        default = { };

        description = ''
          PHP-FPM pools. If no pools are defined, the PHP-FPM
          service is disabled.
        '';

        example = literalExpression ''
          {
            mypool = {
              user = "php";
              group = "php";
              phpPackage = pkgs.php;
              settings = {
                "pm" = "dynamic";
                "pm.max_children" = 75;
                "pm.start_servers" = 10;
                "pm.min_spare_servers" = 5;
                "pm.max_spare_servers" = 20;
                "pm.max_requests" = 500;
              };
            }
          }'';

        type = types.attrsOf (types.submodule poolOpts);
      };

      settings = mkOption {
        default = { };

        description = ''
          PHP-FPM global directives. Refer to the "List of global php-fpm.conf directives" section of
          <https://www.php.net/manual/en/install.fpm.configuration.php>
          for details. Note that settings names must be enclosed in quotes (e.g.
          `"pm.max_children"` instead of `pm.max_children`).
          You need not specify the options `error_log` or
          `daemonize` here, since they are generated by NixOS.
        '';

        type =
          with types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
      };
    };
  };

  config = mkIf (cfg.pools != { }) {

    services.phpfpm.settings = {
      daemonize = false;
      error_log = "syslog";
    };

    systemd.services = mapAttrs' (
      pool: poolOpts:
      nameValuePair "phpfpm-${pool}" {
        after = [ "network.target" ];
        description = "PHP FastCGI Process Manager service for pool ${pool}";
        documentation = [ "man:php-fpm(8)" ];
        partOf = [ "phpfpm.target" ];

        serviceConfig =
          let
            cfgFile = fpmCfgFile pool poolOpts;
            iniFile = phpIni poolOpts;
          in
          {
            ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
            ExecStart = "${poolOpts.phpPackage}/bin/php-fpm -y ${cfgFile} -c ${iniFile}";
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectHome = true;
            ProtectSystem = "full";
            Restart = "always";
            # XXX: We need AF_NETLINK to make the sendmail SUID binary from postfix work
            RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
            RuntimeDirectory = "phpfpm";
            RuntimeDirectoryPreserve = true; # Relevant when multiple processes are running
            Slice = "system-phpfpm.slice";
            Type = "notify";
            WatchdogSec = 15;
          };

        wantedBy = [ "phpfpm.target" ];
      }
    ) cfg.pools;

    systemd.slices.system-phpfpm = {
      description = "PHP FastCGI Process Manager Slice";
    };

    systemd.targets.phpfpm = {
      description = "PHP FastCGI Process manager pools target";
      wantedBy = [ "multi-user.target" ];
    };

    warnings =
      mapAttrsToList (pool: poolOpts: ''
        Using config.services.phpfpm.pools.${pool}.listen is deprecated and will become unsupported in a future release. Please reference the read-only option config.services.phpfpm.pools.${pool}.socket to access the path of your socket.
      '') (filterAttrs (pool: poolOpts: poolOpts.listen != "") cfg.pools)
      ++ mapAttrsToList (pool: poolOpts: ''
        Using config.services.phpfpm.pools.${pool}.extraConfig is deprecated and will become unsupported in a future release. Please migrate your configuration to config.services.phpfpm.pools.${pool}.settings.
      '') (filterAttrs (pool: poolOpts: poolOpts.extraConfig != null) cfg.pools)
      ++ optional (cfg.extraConfig != null) ''
        Using config.services.phpfpm.extraConfig is deprecated and will become unsupported in a future release. Please migrate your configuration to config.services.phpfpm.settings.
      '';
  };
}
