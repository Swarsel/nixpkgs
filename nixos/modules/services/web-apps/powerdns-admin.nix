{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.powerdns-admin;

  configText = ''
    ${cfg.config}
  ''
  + optionalString (cfg.secretKeyFile != null) ''
    with open('${cfg.secretKeyFile}') as file:
      SECRET_KEY = file.read()
  ''
  + optionalString (cfg.saltFile != null) ''
    with open('${cfg.saltFile}') as file:
      SALT = file.read()
  '';
in
{
  options.services.powerdns-admin = {
    config = mkOption {
      default = "";

      description = ''
        Configuration python file.
        See [the example configuration](https://github.com/ngoduykhanh/PowerDNS-Admin/blob/v${pkgs.powerdns-admin.version}/configs/development.py)
        for options.
        Also see [Flask Session configuration](https://flask-session.readthedocs.io/en/latest/config.html#SESSION_TYPE)
        as the version shipped with NixOS is more recent than the one PowerDNS-Admin expects
        and it requires explicit configuration.
      '';

      example = ''
        import cachelib

        BIND_ADDRESS = '127.0.0.1'
        PORT = 8000
        SQLALCHEMY_DATABASE_URI = 'postgresql://powerdnsadmin@/powerdnsadmin?host=/run/postgresql'
        SESSION_TYPE = 'cachelib'
        SESSION_CACHELIB = cachelib.simple.SimpleCache()
      '';

      type = types.str;
    };

    enable = mkEnableOption "the PowerDNS web interface";

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments passed to powerdns-admin.
      '';

      example = literalExpression ''
        [ "-b" "127.0.0.1:8000" ]
      '';

      type = types.listOf types.str;
    };

    saltFile = mkOption {
      description = ''
        The salt used for serialization.
        This should be set, otherwise the default is used.
        Set this to null to ignore this setting and configure it through another way.
      '';

      example = "/etc/powerdns-admin/salt";
      type = types.nullOr types.path;
    };

    secretKeyFile = mkOption {
      description = ''
        The secret used to create cookies.
        This needs to be set, otherwise the default is used and everyone can forge valid login cookies.
        Set this to null to ignore this setting and configure it through another way.
      '';

      example = "/etc/powerdns-admin/secret";
      type = types.nullOr types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.powerdns-admin = {
      after = [ "network.target" ];
      description = "PowerDNS web interface";
      environment.FLASK_CONF = builtins.toFile "powerdns-admin-config.py" configText;
      environment.PYTHONPATH = pkgs.powerdns-admin.pythonPath;

      serviceConfig = {
        BindReadOnlyPaths = [
          "/nix/store"
          "-/etc/resolv.conf"
          "-/etc/nsswitch.conf"
          "-/etc/hosts"
          "-/etc/localtime"
        ]
        ++ (optional (cfg.secretKeyFile != null) cfg.secretKeyFile)
        ++ (optional (cfg.saltFile != null) cfg.saltFile);

        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.powerdns-admin}/bin/powerdns-admin --pid /run/powerdns-admin/pid ${escapeShellArgs cfg.extraArgs}";
        # Set environment variables only for starting flask database upgrade
        ExecStartPre = "${pkgs.coreutils}/bin/env FLASK_APP=${pkgs.powerdns-admin}/share/powerdnsadmin/__init__.py ${pkgs.python3Packages.flask}/bin/flask db upgrade -d ${pkgs.powerdns-admin}/share/migrations";
        ExecStop = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
        Group = "powerdnsadmin";
        # Implies ProtectSystem=strict, which re-mounts all paths
        #DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PIDFile = "/run/powerdns-admin/pid";
        PrivateDevices = true;
        PrivateMounts = true;
        # Needs to start a server
        #PrivateNetwork = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        # Would re-mount paths ignored by temporary root
        #ProtectSystem = "strict";
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "powerdns-admin";
        SystemCallArchitectures = "native";

        # gunicorn needs setuid
        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources @keyring"
          # These got removed by the line above but are needed
          "@setuid @chown"
        ];

        TemporaryFileSystem = "/:ro";
        User = "powerdnsadmin";
        # Does not work well with the temporary root
        #UMask = "0066";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.powerdnsadmin = { };

    users.users.powerdnsadmin = {
      description = "PowerDNS web interface user";
      group = "powerdnsadmin";
      isSystemUser = true;
    };
  };

  # uses attributes of the linked package
  meta.buildDocsInSandbox = false;
}
