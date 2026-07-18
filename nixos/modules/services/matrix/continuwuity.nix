{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matrix-continuwuity;
  defaultUser = "continuwuity";
  defaultGroup = "continuwuity";

  format = pkgs.formats.toml { };
  configFile = format.generate "continuwuity.toml" cfg.settings;

  conduwuitWrapper = pkgs.writeShellScriptBin "conduwuit" ''
    exec ${lib.getExe cfg.package} --config ${configFile} "$@"
  '';
in
{
  options.services.matrix-continuwuity = {
    enable = lib.mkEnableOption "continuwuity";
    package = lib.mkPackageOption pkgs "matrix-continuwuity" { };

    admin = {
      enable = lib.mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.services.matrix-continuwuity.enable";
        description = "Add conduwuit command to PATH for administration";
        type = lib.types.bool;
      };
    };

    extraEnvironment = lib.mkOption {
      default = { };
      description = "Extra Environment variables to pass to the continuwuity server.";

      example = {
        RUST_BACKTRACE = "yes";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    group = lib.mkOption {
      default = defaultGroup;

      description = ''
        The group {command}`continuwuity` is run as.
      '';

      type = lib.types.nonEmptyStr;
    };

    settings = lib.mkOption {
      # TOML does not allow null values, so we use null to omit those fields
      apply = lib.filterAttrsRecursive (_: v: v != null);
      default = { };

      description = ''
        Generates the continuwuity.toml configuration file. Refer to
        <https://continuwuity.org/configuration.html>
        for details on supported values.
      '';

      type = lib.types.submodule {
        options = {
          global.address = lib.mkOption {
            default = null;

            description = ''
              Addresses (IPv4 or IPv6) to listen on for connections by the reverse proxy/tls terminator.
              If set to `null`, continuwuity will listen on IPv4 and IPv6 localhost.
              Must be `null` if `unix_socket_path` is set.
            '';

            example = [
              "127.0.0.1"
              "::1"
            ];

            type = lib.types.nullOr (lib.types.listOf lib.types.nonEmptyStr);
          };

          global.allow_announcements_check = lib.mkOption {
            default = true;

            description = ''
              If enabled, continuwuity will send a simple GET request periodically to
              <https://continuwuity.org/.well-known/continuwuity/announcements> for any new announcements made.
            '';

            type = lib.types.bool;
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

          global.database_path = lib.mkOption {
            default = "/var/lib/continuwuity/";

            description = ''
              Path to the continuwuity database, the directory where continuwuity will save its data.
              Note that database_path cannot be edited because of the service's reliance on systemd StateDir.
            '';

            readOnly = true;
            type = lib.types.path;
          };

          global.max_request_size = lib.mkOption {
            default = 20000000;
            description = "Max request size in bytes. Don't forget to also change it in the proxy.";
            type = lib.types.ints.positive;
          };

          global.port = lib.mkOption {
            default = [ 6167 ];

            description = ''
              The port(s) continuwuity will be running on.
              You need to set up a reverse proxy in your web server (e.g. apache or nginx),
              so all requests to /_matrix on port 443 and 8448 will be forwarded to the continuwuity
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

              Currently, continuwuity doesn't support inbound batched key requests, so
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
              `null` (the default value). The option {option}`services.continuwuity.group` must
              be set to a group your reverse proxy is part of.

              This will automatically add a system user "continuwuity" to your system if
              {option}`services.continuwuity.user` is left at the default, and a "continuwuity"
              group if {option}`services.continuwuity.group` is left at the default.
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

    user = lib.mkOption {
      default = defaultUser;

      description = ''
        The user {command}`continuwuity` is run as.
      '';

      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? global.unix_socket_path) || !(cfg.settings ? global.address);

        message = ''
          In `services.continuwuity.settings.global`, `unix_socket_path` and `address` cannot be set at the
          same time.
          Leave one of the two options unset or explicitly set them to `null`.
        '';
      }
      {
        assertion = cfg.user != defaultUser -> config ? users.users.${cfg.user};
        message = "If `services.continuwuity.user` is changed, the configured user must already exist.";
      }
      {
        assertion = cfg.group != defaultGroup -> config ? users.groups.${cfg.group};
        message = "If `services.continuwuity.group` is changed, the configured group must already exist.";
      }
    ];

    environment = lib.mkIf cfg.admin.enable {
      systemPackages = [ conduwuitWrapper ];
    };

    systemd.services.continuwuity = {
      after = [ "network-online.target" ];
      description = "Continuwuity Matrix Server";
      documentation = [ "https://continuwuity.org/" ];

      environment = lib.mkMerge [
        { CONTINUWUITY_CONFIG = configFile; }
        cfg.extraEnvironment
      ];

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
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
        RuntimeDirectory = "continuwuity";
        RuntimeDirectoryMode = "0750";
        StateDirectory = "continuwuity";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service @resources"
          "~@clock @debug @module @mount @reboot @swap @cpu-emulation @obsolete @timer @chown @setuid @privileged @keyring @ipc"
        ];

        # To avoid timing out during database migrations
        TimeoutStartSec = "10m";
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
    nyabinary
    snaki
  ];
}
