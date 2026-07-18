{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.radicale;

  format = pkgs.formats.ini {
    listToValue = concatMapStringsSep ", " (generators.mkValueStringDefault { });
  };

  pkg = if cfg.package == null then pkgs.radicale else cfg.package;

  confFile =
    if cfg.settings == { } then
      pkgs.writeText "radicale.conf" cfg.config
    else
      format.generate "radicale.conf" cfg.settings;

  rightsFile = format.generate "radicale.rights" cfg.rights;

  bindLocalhost = cfg.settings != { } && !hasAttrByPath [ "server" "hosts" ] cfg.settings;

in
{
  options.services.radicale = {
    config = mkOption {
      default = "";

      description = ''
        Radicale configuration, this will set the service
        configuration file.
        This option is mutually exclusive with {option}`settings`.
        This option is deprecated.  Use {option}`settings` instead.
      '';

      type = types.str;
    };

    enable = mkEnableOption "Radicale CalDAV and CardDAV server";

    package = mkOption {
      default = null;
      defaultText = literalExpression "pkgs.radicale";
      description = "Radicale package to use.";
      # Default cannot be pkgs.radicale because non-null values suppress
      # warnings about incompatible configuration and storage formats.
      type = with types; nullOr package // { inherit (package) description; };
    };

    extraArgs = mkOption {
      default = [ ];
      description = "Extra arguments passed to the Radicale daemon.";
      type = types.listOf types.str;
    };

    group = mkOption {
      default = "radicale";
      description = "Group under which Radicale runs.";
      type = types.str;
    };

    rights = mkOption {
      default = { };

      description = ''
        Configuration for Radicale's rights file. See
        <https://radicale.org/v3.html#authentication-and-rights>.
        This option only works in conjunction with {option}`settings`.
        Setting this will also set {option}`settings.rights.type` and
        {option}`settings.rights.file` to appropriate values.
      '';

      example = literalExpression ''
        root = {
          user = ".+";
          collection = "";
          permissions = "R";
        };
        principal = {
          user = ".+";
          collection = "{user}";
          permissions = "RW";
        };
        calendars = {
          user = ".+";
          collection = "{user}/[^/]+";
          permissions = "rw";
        };
      '';

      type = format.type;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for Radicale. See
        <https://radicale.org/v3.html#configuration>.
        This option is mutually exclusive with {option}`config`.
      '';

      example = literalExpression ''
        server = {
          hosts = [ "0.0.0.0:5232" "[::]:5232" ];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/etc/radicale/users";
          htpasswd_encryption = "bcrypt";
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
        };
      '';

      type = format.type;
    };

    user = mkOption {
      default = "radicale";
      description = "User account under which Radicale runs.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings == { } || cfg.config == "";

        message = ''
          The options services.radicale.config and services.radicale.settings
          are mutually exclusive.
        '';
      }
      {
        assertion = cfg.config != "" || (cfg.settings ? auth && cfg.settings.auth ? type);

        message = ''
          Radicale 3.5.0 changed the default value for `auth.type` from `none` to `denyall`.
          You probably don't want `denyall`, so please set this explicitly.
          https://github.com/Kozea/Radicale/blob/v3.5.0/CHANGELOG.md
        '';
      }
    ];

    environment.systemPackages = [ pkg ];

    services.radicale.settings.rights = mkIf (cfg.rights != { }) {
      file = toString rightsFile;
      type = "from_file";
    };

    systemd.services.radicale = {
      after = [ "network.target" ];
      description = "A Simple Calendar and Contact Server";
      requires = [ "network.target" ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];

        DeviceAllow = [
          "/dev/stdin"
          "/dev/urandom"
        ];

        DevicePolicy = "strict";

        ExecStart = concatStringsSep " " (
          [
            "${pkg}/bin/radicale"
            "-C"
            confFile
          ]
          ++ (map escapeShellArg cfg.extraArgs)
        );

        Group = cfg.group;
        IPAddressAllow = mkIf bindLocalhost "localhost";
        IPAddressDeny = mkIf bindLocalhost "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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

        ReadWritePaths = lib.optional (hasAttrByPath [
          "storage"
          "filesystem_folder"
        ] cfg.settings) cfg.settings.storage.filesystem_folder;

        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX" # To log with systemd
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "radicale/collections";
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0027";
        User = cfg.user;
        WorkingDirectory = "/var/lib/radicale";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.group == "radicale") {
      radicale = { };
    };

    users.users = mkIf (cfg.user == "radicale") {
      radicale = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    warnings =
      optional (cfg.package == null && versionOlder config.system.stateVersion "17.09") ''
        The configuration and storage formats of your existing Radicale
        installation might be incompatible with the newest version.
        For upgrade instructions see
        https://radicale.org/2.1.html#documentation/migration-from-1xx-to-2xx.
        Set services.radicale.package to suppress this warning.
      ''
      ++ optional (cfg.package == null && versionOlder config.system.stateVersion "20.09") ''
        The configuration format of your existing Radicale installation might be
        incompatible with the newest version.  For upgrade instructions see
        https://github.com/Kozea/Radicale/blob/3.0.6/NEWS.md#upgrade-checklist.
        Set services.radicale.package to suppress this warning.
      ''
      ++ optional (cfg.config != "") ''
        The option services.radicale.config is deprecated.
        Use services.radicale.settings instead.
      '';
  };

  meta.maintainers = with lib.maintainers; [ dotlambda ];
}
