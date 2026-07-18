{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tandoor-recipes;
  pkg = cfg.package;
  stateDir = "/var/lib/tandoor-recipes";
  useNewMediaRoot = lib.versionAtLeast config.system.stateVersion "26.05";

  # SECRET_KEY through an env file
  env = {
    ALLOWED_HOSTS = cfg.address;
    DEBUG = "0";
    DEBUG_TOOLBAR = "0";
    GUNICORN_CMD_ARGS = "--bind=${cfg.address}:${toString cfg.port}";
    MEDIA_ROOT = "${stateDir}${lib.optionalString useNewMediaRoot "/media"}";
  }
  // lib.optionalAttrs (config.time.timeZone != null) {
    TZ = config.time.timeZone;
  }
  // (lib.mapAttrs (_: toString) cfg.extraConfig);

  manage = pkgs.writeShellScript "manage" ''
    set -o allexport # Export the following env vars
    ${lib.toShellVars env}
    # UID is a read-only shell variable
    eval "$(${config.systemd.package}/bin/systemctl show -pUID,GID,MainPID tandoor-recipes.service | tr '[:upper:]' '[:lower:]')"
    exec ${pkgs.util-linux}/bin/nsenter \
      -t $mainpid -m -S $uid -G $gid --wdns=${stateDir} \
      ${pkg}/bin/tandoor-recipes "$@"
  '';
in
{
  options.services.tandoor-recipes = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enable Tandoor Recipes.

        When started, the Tandoor Recipes database is automatically created if
        it doesn't exist and updated if the package has changed. Both tasks are
        achieved by running a Django migration.

        A script to manage the instance (by wrapping Django's manage.py) is linked to
        `/var/lib/tandoor-recipes/tandoor-recipes-manage`.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "tandoor-recipes" { };

    address = lib.mkOption {
      default = "localhost";
      description = "Web interface address.";
      type = lib.types.str;
    };

    database = {
      createLocally = lib.mkOption {
        default = false;

        description = ''
          Configure local PostgreSQL database server for Tandoor Recipes.
        '';

        type = lib.types.bool;
      };
    };

    extraConfig = lib.mkOption {
      default = { };

      description = ''
        Extra tandoor recipes config options.

        See [the example dot-env file](https://raw.githubusercontent.com/vabene1111/recipes/master/.env.template)
        for available options.
      '';

      example = {
        ENABLE_SIGNUP = "1";
      };

      type = lib.types.attrs;
    };

    group = lib.mkOption {
      default = "tandoor_recipes";
      description = "Group under which Tandoor runs.";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 8080;
      description = "Web interface port.";
      type = lib.types.port;
    };

    user = lib.mkOption {
      default = "tandoor_recipes";
      description = "User account under which Tandoor runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "tandoor_recipes" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "tandoor_recipes";
        }
      ];
    };

    services.tandoor-recipes.extraConfig = lib.mkIf cfg.database.createLocally {
      DB_ENGINE = "django.db.backends.postgresql";
      POSTGRES_DB = "tandoor_recipes";
      POSTGRES_HOST = "/run/postgresql";
      POSTGRES_USER = "tandoor_recipes";
    };

    systemd.services.tandoor-recipes = {
      after = lib.optional cfg.database.createLocally "postgresql.target";
      description = "Tandoor Recipes server";

      environment = env // {
        PYTHONPATH = "${pkg.python.pkgs.makePythonPath pkg.propagatedBuildInputs}:${pkg}/lib/tandoor-recipes";
      };

      preStart = ''
        ln -sf ${manage} tandoor-recipes-manage

        # Let django migrate the DB as needed
        ${pkg}/bin/tandoor-recipes migrate
      '';

      requires = lib.optional cfg.database.createLocally "postgresql.target";

      serviceConfig = {
        BindReadOnlyPaths = [
          "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
          builtins.storeDir
          "-/etc/resolv.conf"
          "-/etc/nsswitch.conf"
          "-/etc/hosts"
          "-/etc/localtime"
          "-/run/postgresql"
        ];

        CapabilityBoundingSet = "";

        ExecStart = ''
          ${pkg.python.pkgs.gunicorn}/bin/gunicorn recipes.wsgi
        '';

        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "tandoor-recipes";

        StateDirectory = [
          "tandoor-recipes"
        ]
        ++ lib.optional (env.MEDIA_ROOT == "/var/lib/tandoor-recipes/media") "tandoor-recipes/media";

        SystemCallArchitectures = "native";

        # gunicorn needs setuid
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "@resources"
          "@setuid"
          "@keyring"
        ];

        UMask = "0066";
        User = cfg.user;
        WorkingDirectory = stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "tandoor_recipes") {
      tandoor_recipes = { };
    };

    users.users = lib.mkIf (cfg.user == "tandoor_recipes") {
      tandoor_recipes = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    warnings = lib.mkIf (!useNewMediaRoot && !(cfg.extraConfig ? MEDIA_ROOT)) [
      "`services.tandoor-recipes.extraConfig.MEDIA_ROOT` is unset. This is considered insecure for `system.stateVersion` < 26.05. See https://nixos.org/manual/nixos/unstable/#module-services-tandoor-recipes-migrating-media for migration instructions."
    ];
  };

  meta = {
    doc = ./tandoor-recipes.md;
    maintainers = with lib.maintainers; [ jvanbruegge ];
  };
}
