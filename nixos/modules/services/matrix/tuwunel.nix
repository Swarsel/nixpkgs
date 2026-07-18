{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matrix-tuwunel;
  defaultUser = "tuwunel";
  defaultGroup = "tuwunel";

  format = pkgs.formats.toml { };
  configFile = format.generate "tuwunel.toml" cfg.settings;
in
{
  options.services.matrix-tuwunel = {
    enable = lib.mkEnableOption "tuwunel";
    package = lib.mkPackageOption pkgs "matrix-tuwunel" { };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing sensitive environment variables as described in {manpage}`systemd.exec(5).

        Refer to
        <https://matrix-construct.github.io/tuwunel/configuration.html#environment-variables>
        for specifying options as environment variables.
      '';

      example = "/run/secrets/matrix-tuwunel.env";
      type = lib.types.nullOr lib.types.path;
    };

    extraEnvironment = lib.mkOption {
      default = { };
      description = "Extra Environment variables to pass to the tuwunel server.";

      example = {
        RUST_BACKTRACE = "yes";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    group = lib.mkOption {
      default = defaultGroup;

      description = ''
        The group {command}`tuwunel` is run as.  If left as the default, the group will
        automatically be created by the service.
      '';

      example = "conduit";
      type = lib.types.nonEmptyStr;
    };

    settings = lib.mkOption {
      # TOML does not allow null values, so we use null to omit those fields
      apply = lib.filterAttrsRecursive (_: v: v != null);
      default = { };

      description = ''
        Generates the tuwunel.toml configuration file. Refer to
        <https://matrix-construct.github.io/tuwunel/configuration.html>
        for details on supported values.
      '';

      type = lib.types.submodule {
        options = {
          global.address = lib.mkOption {
            default = null;

            description = ''
              Addresses (IPv4 or IPv6) to listen on for connections by the reverse proxy/tls terminator.
              If set to `null`, tuwunel will listen on IPv4 and IPv6 localhost.
            '';

            example = [
              "127.0.0.1"
              "::1"
            ];

            type = lib.types.nullOr (lib.types.listOf lib.types.nonEmptyStr);
          };

          global.allow_encryption = lib.mkOption {
            default = true;
            description = "Whether new encrypted rooms can be created. Note: existing rooms will continue to work.";
            type = lib.types.bool;
          };

          global.allow_federation = lib.mkOption {
            default = true;

            description = ''
              Whether this server federates with other servers.
            '';

            type = lib.types.bool;
          };

          global.allow_registration = lib.mkOption {
            default = false;

            description = ''
              Whether new users can register on this server.

              Registration with token requires `registration_token` or `registration_token_file` to be set.

              If set to true without a token configured, and
              `yes_i_am_very_very_sure_i_want_an_open_registration_server_prone_to_abuse`
              is set to true, users can freely register.
            '';

            type = lib.types.bool;
          };

          global.max_request_size = lib.mkOption {
            default = 20000000;
            description = "Max request size in bytes. Don't forget to also change it in the proxy.";
            type = lib.types.ints.positive;
          };

          global.port = lib.mkOption {
            default = [ 6167 ];

            description = ''
              The port(s) tuwunel will be running on.
              You need to set up a reverse proxy in your web server (e.g. apache or nginx),
              so all requests to /_matrix on port 443 and 8448 will be forwarded to the tuwunel
              instance running on this port.
            '';

            type = lib.types.listOf lib.types.port;
          };

          global.server_name = lib.mkOption {
            description = "The server_name is the name of this server. It is used as a suffix for user and room ids.";
            example = "example.com";
            type = lib.types.nonEmptyStr;
          };

          global.trusted_servers = lib.mkOption {
            default = [ "matrix.org" ];

            description = ''
              Servers listed here will be used to gather public keys of other servers
              (notary trusted key servers).

              Currently, tuwunel doesn't support inbound batched key requests, so
              this list should only contain other Synapse servers.

              Example: `[ "matrix.org" "constellatory.net" "tchncs.de" ]`
            '';

            type = lib.types.listOf lib.types.nonEmptyStr;
          };

          global.unix_socket_path = lib.mkOption {
            default = null;

            description = ''
              Listen on a UNIX socket at the specified path. If listening on a UNIX socket,
              listening on an address will be disabled. The `address` option must be set to
              `null` (the default value). The option {option}`services.tuwunel.group` must
              be set to a group your reverse proxy is part of.
            '';

            type = lib.types.nullOr lib.types.path;
          };

          global.unix_socket_perms = lib.mkOption {
            default = 660;
            description = "The default permissions (in octal) to create the UNIX socket with.";
            type = lib.types.ints.positive;
          };
        };

        freeformType = format.type;
      };
    };

    stateDirectory = lib.mkOption {
      default = "tuwunel";

      description = ''
        The name of the directory under /var/lib/ where the database will be stored.

        Note that `stateDirectory` cannot be changed once created because of the service's reliance on
        systemd `StateDirectory`.
      '';

      example = "matrix-conduit";
      type = lib.types.nonEmptyStr;
    };

    user = lib.mkOption {
      default = defaultUser;

      description = ''
        The user {command}`tuwunel` is run as.  If left as the default, the user will
        automatically be created by the service.
      '';

      example = "conduit";
      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != defaultUser -> config ? users.users.${cfg.user};
        message = "If `services.matrix-tuwunel.user` is changed, the configured user must already exist.";
      }
      {
        assertion = cfg.group != defaultGroup -> config ? users.groups.${cfg.group};
        message = "If `services.matrix-tuwunel.group` is changed, the configured group must already exist.";
      }
      {
        assertion = "/var/lib/${cfg.settings.global.database_path}" != cfg.stateDirectory;
        message = "The `services.matrix-tuwunel.stateDirectory` and `services.matrix-tuwunel.settings.global.database_path` options must match.";
      }
    ];

    services.matrix-tuwunel.settings.global.database_path = "/var/lib/${cfg.stateDirectory}/";

    systemd.services.tuwunel = {
      after = [ "network-online.target" ];
      description = "Tuwunel Matrix Server";
      documentation = [ "https://matrix-construct.github.io/tuwunel/" ];

      environment = lib.mkMerge [
        { TUWUNEL_CONFIG = configFile; }
        cfg.extraEnvironment
      ];

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = lib.getExe cfg.package;
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "tuwunel";
        RuntimeDirectoryMode = "0750";
        StateDirectory = cfg.stateDirectory;
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service @resources"
          "~@clock @debug @module @mount @reboot @swap @cpu-emulation @obsolete @timer @chown @setuid @privileged @keyring @ipc"
        ];

        Type = "notify";
        User = cfg.user;
      };

      startLimitBurst = 5;
      startLimitIntervalSec = 60;
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups = lib.mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = { };
    };

    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        group = cfg.group;
        home = cfg.settings.global.database_path;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    scvalex
  ];
}
