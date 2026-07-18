{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pgadmin;

  _base = with lib.types; [
    int
    bool
    str
  ];
  base =
    with lib.types;
    oneOf (
      [
        (listOf (oneOf _base))
        (attrsOf (oneOf _base))
      ]
      ++ _base
    );

  formatAttrset =
    attr:
    "{${
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (key: value: "${builtins.toJSON key}: ${formatPyValue value},") attr
      )
    }}";

  formatPyValue =
    value:
    if builtins.isString value then
      builtins.toJSON value
    else if value ? _expr then
      value._expr
    else if builtins.isInt value then
      toString value
    else if builtins.isBool value then
      (if value then "True" else "False")
    else if builtins.isAttrs value then
      (formatAttrset value)
    else if builtins.isList value then
      "[${lib.concatStringsSep "\n" (map (v: "${formatPyValue v},") value)}]"
    else
      throw "Unrecognized type";

  formatPy =
    attrs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: "${key} = ${formatPyValue value}") attrs
    );

  pyType =
    with lib.types;
    attrsOf (oneOf [
      (attrsOf base)
      (listOf base)
      base
    ]);
in
{
  options.services.pgadmin = {
    enable = lib.mkEnableOption "PostgreSQL Admin 4";
    package = lib.mkPackageOption pkgs "pgadmin4" { };

    emailServer = {
      enable = lib.mkEnableOption "SMTP email server. This is necessary, if you want to use password recovery or change your own password";

      address = lib.mkOption {
        default = "localhost";
        description = "SMTP server for email delivery";
        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        description = ''
          Password for SMTP email account.
          NOTE: Should be string not a store path, to prevent the password from being world readable
        '';

        type = lib.types.path;
      };

      port = lib.mkOption {
        default = 25;
        description = "SMTP server port for email delivery";
        type = lib.types.port;
      };

      sender = lib.mkOption {
        description = ''
          SMTP server sender email for email delivery. Some servers require this to be a valid email address from that server
        '';

        example = "noreply@example.com";
        type = lib.types.str;
      };

      useSSL = lib.mkEnableOption "SSL for connecting to the SMTP server";
      useTLS = lib.mkEnableOption "TLS for connecting to the SMTP server";

      username = lib.mkOption {
        default = null;
        description = "SMTP server username for email delivery";
        type = lib.types.nullOr lib.types.str;
      };
    };

    initialEmail = lib.mkOption {
      description = "Initial email for the pgAdmin account";
      type = lib.types.str;
    };

    initialPasswordFile = lib.mkOption {
      description = ''
        Initial password file for the pgAdmin account. Minimum length by default is 6.
        Please see `services.pgadmin.minimumPasswordLength`.
        NOTE: Should be string not a store path, to prevent the password from being world readable
      '';

      type = lib.types.path;
    };

    minimumPasswordLength = lib.mkOption {
      default = 6;
      description = "Minimum length of the password";
      type = lib.types.int;
    };

    openFirewall = lib.mkEnableOption "firewall passthrough for pgadmin4";

    port = lib.mkOption {
      default = 5050;
      description = "Port for pgadmin4 to run on";
      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Settings for pgadmin4.
        [Documentation](https://www.pgadmin.org/docs/pgadmin4/development/config_py.html)
      '';

      type = pyType;
    };
  };

  config = lib.mkIf (cfg.enable) {
    environment.etc."pgadmin/config_system.py" = {
      group = "pgadmin";
      mode = "0600";

      text =
        lib.optionalString cfg.emailServer.enable ''
          import os
          with open(os.path.join(os.environ['CREDENTIALS_DIRECTORY'], 'email_password')) as f:
            pw = f.read()
          MAIL_PASSWORD = pw
        ''
        + formatPy cfg.settings;

      user = "pgadmin";
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall) [ cfg.port ];

    services.pgadmin.settings = {
      DEFAULT_SERVER_PORT = cfg.port;
      PASSWORD_LENGTH_MIN = cfg.minimumPasswordLength;
      SERVER_MODE = true;
      UPGRADE_CHECK_ENABLED = false;
    }
    // (lib.optionalAttrs cfg.openFirewall {
      DEFAULT_SERVER = lib.mkDefault "::";
    })
    // (lib.optionalAttrs cfg.emailServer.enable {
      MAIL_PORT = cfg.emailServer.port;
      MAIL_SERVER = cfg.emailServer.address;
      MAIL_USERNAME = cfg.emailServer.username;
      MAIL_USE_SSL = cfg.emailServer.useSSL;
      MAIL_USE_TLS = cfg.emailServer.useTLS;
      SECURITY_EMAIL_SENDER = cfg.emailServer.sender;
    });

    systemd.services.pgadmin = {
      after = [ "network.target" ];

      path = [
        config.services.postgresql.package
        pkgs.coreutils
        pkgs.bash
      ];

      preStart = ''
        # NOTE: this is idempotent (aka running it twice has no effect)
        # Check here for password length to prevent pgadmin from starting
        # and presenting a hard to find error message
        # see https://github.com/NixOS/nixpkgs/issues/270624
        PW_FILE="$CREDENTIALS_DIRECTORY/initial_password"
        PW_LENGTH=$(wc -m < "$PW_FILE")
        if [ $PW_LENGTH -lt ${toString cfg.minimumPasswordLength} ]; then
            echo "Password must be at least ${toString cfg.minimumPasswordLength} characters long"
            exit 1
        fi
        (
          # Email address:
          echo ${lib.escapeShellArg cfg.initialEmail}

          # file might not contain newline. echo hack fixes that.
          PW=$(cat "$PW_FILE")

          # Password:
          echo "$PW"
          # Retype password:
          echo "$PW"
        ) | ${cfg.package}/bin/pgadmin4-cli setup-db
      '';

      requires = [ "network.target" ];

      restartTriggers = [
        "/etc/pgadmin/config_system.py"
      ];

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/pgadmin4";

        LoadCredential = [
          "initial_password:${cfg.initialPasswordFile}"
        ]
        ++ lib.optional cfg.emailServer.enable "email_password:${cfg.emailServer.passwordFile}";

        LockPersonality = true;
        LogsDirectory = "pgadmin";
        LogsDirectoryMode = "750";
        MemoryDenyWriteExecute = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "pgadmin";
        StateDirectoryMode = "750";
        SystemCallArchitectures = "native";
        UMask = 27;
        User = "pgadmin";
      };

      wantedBy = [ "multi-user.target" ];
      # we're adding this optionally so just in case there's any race it'll be caught
      # in case postgres doesn't start, pgadmin will just start normally
      wants = [ "postgresql.target" ];
    };

    users.groups.pgadmin = { };

    users.users.pgadmin = {
      group = "pgadmin";
      isSystemUser = true;
    };
  };
}
