{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sshwifty;
  format = pkgs.formats.json { };
  settings = format.generate "sshwifty.json" cfg.settings;
in
{
  options.services.sshwifty = {
    enable = lib.mkEnableOption "Sshwifty";
    package = lib.mkPackageOption pkgs "sshwifty" { };

    settings = lib.mkOption {
      description = ''
        Configuration for Sshwifty. See
        [the Sshwifty documentation](https://github.com/nirui/sshwifty/tree/master?tab=readme-ov-file#configuration)
        for possible options.
      '';

      type = format.type;
    };

    sharedKeyFile = lib.mkOption {
      default = null;
      description = "Path to a file containing the shared key.";
      type = lib.types.nullOr lib.types.path;
    };

    socks5PasswordFile = lib.mkOption {
      default = null;
      description = "Path to a file containing the SOCKS5 password.";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sshwifty = {
      after = [ "network.target" ];
      description = "Sshwifty";

      script = ''
        ${lib.optionalString (cfg.sharedKeyFile != null || cfg.socks5PasswordFile != null) (
          lib.concatStringsSep " " [
            (lib.getExe pkgs.jq)
            "-s"
            "'.[0] * .[1]"
            (lib.optionalString (cfg.sharedKeyFile != null && cfg.socks5PasswordFile != null) "* .[2]")
            "'"
            settings
            (lib.optionalString (
              cfg.sharedKeyFile != null
            ) "<(echo \"{\\\"SharedKey\\\":\\\"$(cat $CREDENTIALS_DIRECTORY/sharedkey)\\\"}\")")
            (lib.optionalString (
              cfg.socks5PasswordFile != null
            ) "<(echo \"{\\\"Socks5Password\\\":\\\"$(cat $CREDENTIALS_DIRECTORY/socks5pass)\\\"}\")")
            "> /run/sshwifty/sshwifty.json"
          ]
        )}
        ${lib.optionalString (
          cfg.sharedKeyFile != null || cfg.socks5PasswordFile != null
        ) "export SSHWIFTY_CONFIG=/run/sshwifty/sshwifty.json"}
        ${lib.optionalString (
          cfg.sharedKeyFile == null && cfg.socks5PasswordFile == null
        ) "export SSHWIFTY_CONFIG=${settings}"}
        exec ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;

        LoadCredential =
          [ ]
          ++ lib.optionals (cfg.sharedKeyFile != null) [ "sharedkey:${cfg.sharedKeyFile}" ]
          ++ lib.optionals (cfg.socks5PasswordFile != null) [ "socks5pass:${cfg.socks5PasswordFile}" ];

        # Hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = "disconnected";
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
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = [
          "~cgroup"
          "~ipc"
          "~mnt"
          "~net"
          "~pid"
          "~user"
          "~uts"
        ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "sshwifty";
        RuntimeDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@module"
          "~@mount"
          "~@obsolete"
          "~@privileged"
          "~@raw-io"
          "~@reboot"
          "~@resources"
          "~@swap"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.ungeskriptet ];
}
