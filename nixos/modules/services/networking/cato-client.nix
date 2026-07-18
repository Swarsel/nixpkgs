{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkPackageOption;

  cfg = config.services.cato-client;
in
{
  options.services.cato-client = {
    enable = mkEnableOption "cato-client service";
    package = mkPackageOption pkgs "cato-client" { };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    # set up Security wrapper Same as intended in deb post install
    security.wrappers.cato-clientd = {
      group = "cato-client";
      owner = "root";
      permissions = "u+rwx,g+rwx"; # 770
      setgid = true;
      source = "${cfg.package}/bin/cato-clientd";
    };

    security.wrappers.cato-sdp = {
      group = "cato-client";
      owner = "root";
      permissions = "u+rwx,g+rx,a+rx"; # 755
      setgid = true;
      source = "${cfg.package}/bin/cato-sdp";
    };

    systemd.services.cato-client = {
      enable = true;
      after = [ "network.target" ];
      description = "Cato Networks Linux client - connects tunnel to Cato cloud";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/cato-clientd systemd";
        Group = "cato-client";
        # Cato client seems to do the following:
        # - Look in each user's ~/.cato/ for configuration and keys
        # - Write to /var/log/cato-client.log
        # - Create and use sockets /var/run/cato-sdp.i, /var/run/cato-sdp.o
        # - Read and Write to /opt/cato/ for runtime settings
        # - Read /etc/systemd/resolved.conf (but fine if fails)
        # - Restart systemd-resolved (also fine if doesn't exist)
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
        Restart = "always";
        Type = "simple";
        User = "root"; # Note: daemon runs as root, tools sticky to group
        WorkingDirectory = "${cfg.package}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.cato-client = { };
    };
  };
}
