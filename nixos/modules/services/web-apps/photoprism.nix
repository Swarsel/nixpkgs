{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.photoprism;

  env = {
    PHOTOPRISM_HTTP_HOST = cfg.address;
    PHOTOPRISM_HTTP_PORT = toString cfg.port;
    PHOTOPRISM_IMPORT_PATH = cfg.importPath;
    PHOTOPRISM_ORIGINALS_PATH = cfg.originalsPath;
    PHOTOPRISM_STORAGE_PATH = cfg.storagePath;
  }
  // (lib.mapAttrs (_: toString) cfg.settings);

  manage = pkgs.writeShellScript "manage" ''
    set -o allexport # Export the following env vars
    ${lib.toShellVars env}
    eval "$(${config.systemd.package}/bin/systemctl show -pUID,MainPID photoprism.service | ${pkgs.gnused}/bin/sed "s/UID/ServiceUID/")"
    exec ${pkgs.util-linux}/bin/nsenter \
      -t $MainPID -m -S $ServiceUID -G $ServiceUID --wdns=${cfg.storagePath} \
      ${cfg.package}/bin/photoprism "$@"
  '';
in
{
  options.services.photoprism = {

    enable = lib.mkEnableOption "Photoprism web server";
    package = lib.mkPackageOption pkgs "photoprism" { };

    address = lib.mkOption {
      default = "localhost";

      description = ''
        Web interface address.
      '';

      type = lib.types.str;
    };

    databasePasswordFile = lib.mkOption {
      default = null;

      description = ''
        Database password file.
      '';

      type = lib.types.nullOr lib.types.externalPath;
    };

    group = lib.mkOption {
      default = "photoprism";
      description = "Group under which photoprism runs.";
      type = lib.types.str;
    };

    importPath = lib.mkOption {
      default = "import";

      description = ''
        Relative or absolute to the `originalsPath` from where the files should be imported.
      '';

      type = lib.types.str;
    };

    originalsPath = lib.mkOption {
      default = null;

      description = ''
        Storage path of your original media files (photos and videos).
      '';

      example = "/data/photos";
      type = lib.types.path;
    };

    passwordFile = lib.mkOption {
      default = null;

      description = ''
        Admin password file.
      '';

      type = lib.types.nullOr lib.types.externalPath;
    };

    port = lib.mkOption {
      default = 2342;

      description = ''
        Web interface port.
      '';

      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        See [the getting-started guide](https://docs.photoprism.app/getting-started/config-options/) for available options.
      '';

      example = {
        PHOTOPRISM_ADMIN_USER = "root";
        PHOTOPRISM_DEFAULT_LOCALE = "de";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    storagePath = lib.mkOption {
      default = "/var/lib/photoprism";

      description = ''
        Location for sidecar, cache, and database files.
      '';

      type = lib.types.path;
    };

    user = lib.mkOption {
      default = "photoprism";
      description = "User under which photoprism runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.photoprism = {
      description = "Photoprism server";
      environment = env;

      preStart = ''
        ln -sf ${manage} photoprism-manage
        ${lib.optionalString (cfg.passwordFile != null) ''
          export PHOTOPRISM_ADMIN_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/PHOTOPRISM_ADMIN_PASSWORD_FILE
        ''}
        ${lib.optionalString (cfg.databasePasswordFile != null) ''
          export PHOTOPRISM_DATABASE_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/PHOTOPRISM_DATABASE_PASSWORD")
        ''}
        exec ${cfg.package}/bin/photoprism migrations run -f
      '';

      script = ''
        ${lib.optionalString (cfg.passwordFile != null) ''
          export PHOTOPRISM_ADMIN_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/PHOTOPRISM_ADMIN_PASSWORD_FILE
        ''}
        ${lib.optionalString (cfg.databasePasswordFile != null) ''
          export PHOTOPRISM_DATABASE_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/PHOTOPRISM_DATABASE_PASSWORD")
        ''}
        exec ${cfg.package}/bin/photoprism start
      '';

      serviceConfig = {
        DynamicUser = true;
        Group = cfg.group;

        LoadCredential = [
          (lib.optionalString (cfg.passwordFile != null) "PHOTOPRISM_ADMIN_PASSWORD_FILE:${cfg.passwordFile}")
          (lib.optionalString (
            cfg.databasePasswordFile != null
          ) "PHOTOPRISM_DATABASE_PASSWORD:${cfg.databasePasswordFile}")
        ];

        LockPersonality = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;

        ReadWritePaths = [
          cfg.originalsPath
          cfg.importPath
          cfg.storagePath
        ];

        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "photoprism";
        StateDirectory = "photoprism";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@setuid @keyring"
        ];

        UMask = "0066";
        User = cfg.user;
        WorkingDirectory = cfg.storagePath;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ stunkymonkey ];
}
