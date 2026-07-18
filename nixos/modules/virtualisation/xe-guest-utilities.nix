{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.xe-guest-utilities;
in
{
  options = {
    services.xe-guest-utilities = {
      enable = lib.mkEnableOption "the XenServer guest utilities daemon";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.xe-guest-utilities ];

    systemd.mounts = [
      {
        description = "Mount /proc/xen files";
        type = "xenfs";

        unitConfig = {
          ConditionPathExists = "/proc/xen";
          RefuseManualStop = "true";
        };

        what = "xenfs";
        where = "/proc/xen";
      }
    ];

    systemd.services.xe-daemon = {
      after = [ "xe-linux-distribution.service" ];
      description = "xen daemon file";

      path = [
        pkgs.coreutils
        pkgs.iproute2
      ];

      requires = [ "proc-xen.mount" ];

      serviceConfig = {
        ExecStart = "${pkgs.xe-guest-utilities}/bin/xe-daemon -p /run/xe-daemon.pid";
        ExecStop = "${pkgs.procps}/bin/pkill -TERM -F /run/xe-daemon.pid";
        PIDFile = "/run/xe-daemon.pid";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.xe-linux-distribution = {
      before = [ "xend.service" ];
      description = "xen linux distribution service";

      path = [
        pkgs.xe-guest-utilities
        pkgs.coreutils
        pkgs.gawk
        pkgs.gnused
      ];

      serviceConfig = {
        ExecStart = "${pkgs.xe-guest-utilities}/bin/xe-linux-distribution /var/cache/xe-linux-distribution";
        RemainAfterExit = "yes";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [ "d /run/xenstored 0755 - - -" ];
  };
}
