{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.homebox;
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkDefault
    mkOption
    types
    mkIf
    ;

  defaultUser = "homebox";
  defaultGroup = "homebox";
in
{
  options.services.homebox = {
    enable = mkEnableOption "homebox";
    package = mkPackageOption pkgs "homebox" { };

    database = {
      createLocally = mkOption {
        default = false;

        description = ''
          Configure local PostgreSQL database server for Homebox.
        '';

        type = lib.types.bool;
      };
    };

    group = mkOption {
      default = defaultGroup;
      description = "Group under which Homebox runs.";
      type = types.str;
    };

    settings = mkOption {
      defaultText = lib.literalExpression ''
        {
          HBOX_STORAGE_CONN_STRING = "file:///var/lib/homebox";
          HBOX_STORAGE_PREFIX_PATH = "data";
          HBOX_DATABASE_DRIVER = "sqlite3";
          HBOX_DATABASE_SQLITE_PATH = "/var/lib/homebox/data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
          HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
          HBOX_OPTIONS_GITHUB_RELEASE_CHECK = "false";
          HBOX_MODE = "production";
          HOME = "/var/lib/homebox";
          TMPDIR = "/var/lib/homebox/tmp";
        }
      '';

      description = ''
        The homebox configuration as environment variables. For definitions and available options see the upstream
        [documentation](https://homebox.software/en/configure/#configure-homebox).
      '';

      type = types.submodule { freeformType = types.attrsOf (types.nullOr types.str); };
    };

    user = mkOption {
      default = defaultUser;
      description = "User account under which Homebox runs.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? HBOX_STORAGE_DATA);

        message = ''
          `services.homebox.settings.HBOX_STORAGE_DATA` has been deprecated.
          Please use `services.homebox.settings.HBOX_STORAGE_CONN_STRING` and `services.homebox.settings.HBOX_STORAGE_PREFIX_PATH` instead.
        '';
      }
    ];

    services.homebox.settings = lib.mkMerge [
      (lib.mapAttrs (_: mkDefault) {
        HBOX_DATABASE_DRIVER = "sqlite3";
        HBOX_DATABASE_SQLITE_PATH = "/var/lib/homebox/data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
        HBOX_MODE = "production";
        HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
        HBOX_OPTIONS_CHECK_GITHUB_RELEASE = "false";
        HBOX_STORAGE_CONN_STRING = "file:///var/lib/homebox";
        HBOX_STORAGE_PREFIX_PATH = "data";
        # Fix this startup issue:
        #   failed to create modcache index dir: mkdir /var/empty/.cache: read-only file system
        HOME = "/var/lib/homebox";
        # Fix uploading/saving attachments/images:
        # [...] rename /tmp/ced4804c80b1ed1f6e88060f6d829db421e6dbf3a189715265900b5d6b0243ed.1889b3d16ab36e22.tmp /var/lib/homebox/data/5f42f81b-e9ad-4495-b6a6-9e9f704db30e/documents/ced4804c80b1ed1f6e88060f6d829db421e6dbf3a189715265900b5d6b0243ed: invalid cross-device link" [...]
        TMPDIR = "/var/lib/homebox/tmp";
      })

      (mkIf cfg.database.createLocally {
        HBOX_DATABASE_DATABASE = "homebox";
        HBOX_DATABASE_DRIVER = "postgres";
        HBOX_DATABASE_HOST = "/run/postgresql";
        HBOX_DATABASE_PORT = toString config.services.postgresql.settings.port;
        HBOX_DATABASE_USERNAME = "homebox";
      })
    ];

    services.postgresql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "homebox" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "homebox";
        }
      ];
    };

    systemd.services.homebox = {
      after = lib.optional cfg.database.createLocally "postgresql.target";
      environment = lib.filterAttrs (_: v: v != null) cfg.settings;

      preStart = ''
        "${pkgs.coreutils}/bin/rm" -rf /var/lib/homebox/tmp
        "${pkgs.coreutils}/bin/mkdir" -p /var/lib/homebox/tmp
      '';

      requires = lib.optional cfg.database.createLocally "postgresql.target";

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        ExecStart = lib.getExe cfg.package;
        Group = cfg.group;
        LimitNOFILE = "1048576";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "homebox";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@pkey"
        ];

        UMask = "0077";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups = mkIf (cfg.group == defaultGroup) { ${defaultGroup} = { }; };

      users = mkIf (cfg.user == defaultUser) {
        ${defaultUser} = {
          inherit (cfg) group;
          description = "homebox service user";
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    patrickdag
    swarsel
  ];
}
