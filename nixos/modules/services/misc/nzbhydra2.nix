{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nzbhydra2;

in
{
  options = {
    services.nzbhydra2 = {
      enable = lib.mkEnableOption "NZBHydra2, Usenet meta search";
      package = lib.mkPackageOption pkgs "nzbhydra2" { };

      dataDir = lib.mkOption {
        default = "/var/lib/nzbhydra2";
        description = "The directory where NZBHydra2 stores its data files.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the NZBHydra2 web interface.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ 5076 ]; };

    systemd.services.nzbhydra2 = {
      after = [ "network.target" ];
      description = "NZBHydra2";

      serviceConfig = {
        DevicePolicy = "closed";
        ExecStart = "${cfg.package}/bin/nzbhydra2 --nobrowser --datafolder '${cfg.dataDir}'";
        Group = "nzbhydra2";
        LockPersonality = true;
        # Hardening
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = "read-only";
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = cfg.dataDir;
        Restart = "on-failure";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        Type = "simple";
        User = "nzbhydra2";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0700 nzbhydra2 nzbhydra2 - -" ];
    users.groups.nzbhydra2 = { };

    users.users.nzbhydra2 = {
      group = "nzbhydra2";
      isSystemUser = true;
    };
  };
}
