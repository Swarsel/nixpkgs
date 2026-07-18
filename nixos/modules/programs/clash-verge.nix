{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
  ];

  options.programs.clash-verge = {
    enable = lib.mkEnableOption "Clash Verge";

    package = lib.mkOption {
      default = pkgs.clash-verge-rev;
      defaultText = lib.literalExpression "pkgs.clash-verge-rev";

      description = ''
        The clash-verge package to use. Available options are
        clash-verge-rev and clash-nyanpasu, both are forks of
        the original clash-verge project.
      '';

      type = lib.types.package;
    };

    autoStart = lib.mkEnableOption "Clash Verge auto launch";

    group = lib.mkOption {
      default = "users";

      description = ''
        The group to grant access to clash-verge-rev's service socket.

        For better security, you should set a group that only contains
        users who need to access clash-verge-rev's service socket.
      '';

      example = "wheel";
      type = lib.types.str;
    };

    serviceMode = lib.mkEnableOption "Service Mode";

    tunMode = lib.mkEnableOption "" // {
      description = ''
        Whether to set the capabilities required for TUN mode.

        Without these capabilities, Clash Verge's DNS settings will not work in TUN mode.

        When enabled, reverse path filtering will be set to loose instead of strict.
      '';
    };
  };

  config =
    let
      cfg = config.programs.clash-verge;
    in
    lib.mkIf cfg.enable {

      assertions = [
        {
          assertion =
            cfg.tunMode
            ->
              config.networking.firewall.checkReversePath != true
              && config.networking.firewall.checkReversePath != "strict";

          message = ''
            {option}`programs.clash-verge.tunMode` requires {option}`networking.firewall.checkReversePath`
            to be set to `false` or `"loose"`.
          '';
        }
      ];

      environment.systemPackages = [
        cfg.package
        (lib.mkIf cfg.autoStart (
          pkgs.makeAutostartItem {
            package = cfg.package;
            name = "clash-verge";
          }
        ))
      ];

      networking.firewall.checkReversePath = lib.mkIf cfg.tunMode (lib.mkDefault "loose");

      security.wrappers.clash-verge = lib.mkIf cfg.tunMode {
        capabilities = "cap_net_bind_service,cap_net_raw,cap_net_admin=+ep";
        group = "root";
        owner = "root";
        source = "${lib.getExe cfg.package}";
      };

      systemd.services.clash-verge = lib.mkIf cfg.serviceMode {
        enable = true;
        description = "Clash Verge Service Mode";

        serviceConfig = {
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN CAP_NET_RAW CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_SETUID CAP_SETGID CAP_CHOWN CAP_MKNOD"
          ];

          ExecStart = "${cfg.package}/bin/clash-verge-service";
          Group = cfg.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_INET AF_INET6 AF_NETLINK AF_PACKET AF_UNIX"
          ];

          RestrictNamespaces = [ "~user cgroup mnt uts" ];
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "clash-verge-rev";
          StateDirectory = "clash-verge-service";
          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";

          SystemCallFilter = [
            "~@aio @chown @clock @cpu-emulation @debug @keyring @memlock @module @mount @obsolete @pkey @privileged @raw-io @reboot @sandbox @setuid @swap @timer"
          ];
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.maintainers = pkgs.clash-verge-rev.meta.maintainers;
}
