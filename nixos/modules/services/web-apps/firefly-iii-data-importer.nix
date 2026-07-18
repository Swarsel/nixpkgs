{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firefly-iii-data-importer;

  user = cfg.user;
  group = cfg.group;

  defaultUser = "firefly-iii-data-importer";
  defaultGroup = "firefly-iii-data-importer";

  artisan = "${cfg.package}/artisan";

  env-file-values = lib.attrsets.mapAttrs' (
    n: v: lib.attrsets.nameValuePair (lib.strings.removeSuffix "_FILE" n) v
  ) (lib.attrsets.filterAttrs (n: v: lib.strings.hasSuffix "_FILE" n) cfg.settings);
  env-nonfile-values = lib.attrsets.filterAttrs (n: v: !lib.strings.hasSuffix "_FILE" n) cfg.settings;

  data-importer-maintenance = pkgs.writeShellScript "data-importer-maintenance.sh" ''
    set -a
    ${lib.strings.toShellVars env-nonfile-values}
    ${lib.strings.concatLines (
      lib.attrsets.mapAttrsToList (n: v: "${n}=\"$(< ${v})\"") env-file-values
    )}
    set +a
    ${artisan} package:discover
    rm ${cfg.dataDir}/cache/*.php
    ${artisan} config:cache
  '';

  commonServiceConfig = {
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
    Group = group;
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateNetwork = false;
    PrivateTmp = true;
    PrivateUsers = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = "tmpfs";
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    ReadWritePaths = [ cfg.dataDir ];
    RemoveIPC = true;
    RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    StateDirectory = "firefly-iii-data-importer";
    SystemCallArchitectures = "native";

    SystemCallFilter = [
      "@system-service @resources"
      "~@obsolete @privileged"
    ];

    Type = "oneshot";
    User = user;
    WorkingDirectory = cfg.package;
  };

in
{

  options.services.firefly-iii-data-importer = {
    enable = lib.mkEnableOption "Firefly III Data Importer";

    package = lib.mkOption {
      apply =
        firefly-iii-data-importer:
        firefly-iii-data-importer.override (prev: {
          dataDir = cfg.dataDir;
        });

      default = pkgs.firefly-iii-data-importer;
      defaultText = lib.literalExpression "pkgs.firefly-iii-data-importer";

      description = ''
        The firefly-iii-data-importer package served by php-fpm and the webserver of choice.
        This option can be used to point the webserver to the correct root. It
        may also be used to set the package to a different version, say a
        development version.
      '';

      type = lib.types.package;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/firefly-iii-data-importer";

      description = ''
        The place where firefly-iii data importer stores its state.
      '';

      type = lib.types.path;
    };

    enableNginx = lib.mkOption {
      default = false;

      description = ''
        Whether to enable nginx or not. If enabled, an nginx virtual host will
        be created for access to firefly-iii data importer. If not enabled, then you may use
        `''${config.services.firefly-iii-data-importer.package}` as your document root in
        whichever webserver you wish to setup.
      '';

      type = lib.types.bool;
    };

    group = lib.mkOption {
      default = if cfg.enableNginx then "nginx" else defaultGroup;
      defaultText = "If `services.firefly-iii-data-importer.enableNginx` is true then `nginx` else ${defaultGroup}";

      description = ''
        Group under which firefly-iii-data-importer runs. It is best to set this to the group
        of whatever webserver is being used as the frontend.
      '';

      type = lib.types.str;
    };

    poolConfig = lib.mkOption {
      default = { };

      defaultText = lib.literalExpression ''
        {
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 500;
        }
      '';

      description = ''
        Options for the Firefly III Data Importer PHP pool. See the documentation on <literal>php-fpm.conf</literal>
        for details on configuration directives.
      '';

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
          lib.types.bool
        ]
      );
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Options for firefly-iii data importer configuration. Refer to
        <https://github.com/firefly-iii/data-importer/blob/main/.env.example> for
        details on supported values. All <option>_FILE values supported by
        upstream are supported here.

        APP_URL will be the same as `services.firefly-iii-data-importer.virtualHost` if the
        former is unset in `services.firefly-iii-data-importer.settings`.
      '';

      example = lib.literalExpression ''
        {
          APP_ENV = "local";
          LOG_CHANNEL = "syslog";
          FIREFLY_III_ACCESS_TOKEN= = "/var/secrets/firefly-iii-access-token.txt";
        }
      '';

      type = lib.types.submodule {
        freeformType = lib.types.attrsOf (
          lib.types.oneOf [
            lib.types.str
            lib.types.int
            lib.types.bool
          ]
        );
      };
    };

    user = lib.mkOption {
      default = defaultUser;
      description = "User account under which firefly-iii-data-importer runs.";
      type = lib.types.str;
    };

    virtualHost = lib.mkOption {
      default = "localhost";

      description = ''
        The hostname at which you wish firefly-iii-data-importer to be served. If you have
        enabled nginx using `services.firefly-iii-data-importer.enableNginx` then this will
        be used.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf cfg.enableNginx {
      enable = true;
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;

      virtualHosts.${cfg.virtualHost} = {
        locations = {
          "/" = {
            extraConfig = ''
              sendfile off;
            '';

            index = "index.php";
            tryFiles = "$uri $uri/ /index.php?$query_string";
          };

          "~ \\.php$" = {
            extraConfig = ''
              include ${config.services.nginx.package}/conf/fastcgi_params ;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_param modHeadersAvailable true;
              fastcgi_pass unix:${config.services.phpfpm.pools.firefly-iii-data-importer.socket};
            '';
          };
        };

        root = "${cfg.package}/public";
      };
    };

    services.phpfpm.pools.firefly-iii-data-importer = {
      inherit user group;

      phpOptions = ''
        log_errors = on
      '';

      phpPackage = cfg.package.phpPackage;

      settings = {
        "listen.group" = group;
        "listen.mode" = "0660";
        "listen.owner" = user;
        "pm" = lib.mkDefault "dynamic";
        "pm.max_children" = lib.mkDefault 32;
        "pm.max_requests" = lib.mkDefault 500;
        "pm.max_spare_servers" = lib.mkDefault 4;
        "pm.min_spare_servers" = lib.mkDefault 2;
        "pm.start_servers" = lib.mkDefault 2;
      }
      // cfg.poolConfig;
    };

    systemd.services.firefly-iii-data-importer-setup = {
      before = [ "phpfpm-firefly-iii-data-importer.service" ];
      requiredBy = [ "phpfpm-firefly-iii-data-importer.service" ];
      restartTriggers = [ cfg.package ];

      serviceConfig = {
        ExecStart = data-importer-maintenance;
        RemainAfterExit = true;
      }
      // commonServiceConfig;

      unitConfig.JoinsNamespaceOf = "phpfpm-firefly-iii-data-importer.service";
    };

    systemd.tmpfiles.settings."10-firefly-iii-data-importer" =
      lib.attrsets.genAttrs
        [
          "${cfg.dataDir}/storage"
          "${cfg.dataDir}/storage/app"
          "${cfg.dataDir}/storage/app/public"
          "${cfg.dataDir}/storage/configurations"
          "${cfg.dataDir}/storage/conversion-routines"
          "${cfg.dataDir}/storage/debugbar"
          "${cfg.dataDir}/storage/framework"
          "${cfg.dataDir}/storage/framework/cache"
          "${cfg.dataDir}/storage/framework/sessions"
          "${cfg.dataDir}/storage/framework/testing"
          "${cfg.dataDir}/storage/framework/views"
          "${cfg.dataDir}/storage/import-jobs"
          "${cfg.dataDir}/storage/jobs"
          "${cfg.dataDir}/storage/logs"
          "${cfg.dataDir}/storage/submission-routines"
          "${cfg.dataDir}/storage/uploads"
          "${cfg.dataDir}/cache"
        ]
        (n: {
          d = {
            group = group;
            mode = "0710";
            user = user;
          };
        })
      // {
        "${cfg.dataDir}".d = {
          group = group;
          mode = "0700";
          user = user;
        };
      };

    users = {
      groups = lib.mkIf (group == defaultGroup) { ${defaultGroup} = { }; };

      users = lib.mkIf (user == defaultUser) {
        ${defaultUser} = {
          inherit group;
          description = "Firefly-iii Data Importer service user";
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };
}
