# LXC Configuration

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.lxc.lxcfs;
in
{
  ###### interface
  options.virtualisation.lxc.lxcfs = {
    enable = lib.mkOption {
      default = false;

      description = ''
        This enables LXCFS, a FUSE filesystem for LXC.
        To use lxcfs in include the following configuration in your
        container configuration:
        ```
        virtualisation.lxc.defaultConfig = "lxc.include = ''${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf";
        ```
      '';

      type = lib.types.bool;
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    systemd.services.lxcfs = {
      before = [ "lxc.service" ];
      description = "FUSE filesystem for LXC";
      restartIfChanged = false;

      serviceConfig = {
        ExecStart = "${pkgs.lxcfs}/bin/lxcfs /var/lib/lxcfs";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/lxcfs";
        ExecStopPost = "-${pkgs.fuse3}/bin/fusermount3 -u /var/lib/lxcfs";
        KillMode = "process";
        Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    teams = [ lib.teams.lxc ];
  };
}
