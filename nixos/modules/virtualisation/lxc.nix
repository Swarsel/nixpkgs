# LXC Configuration

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.lxc;
in

{
  options.virtualisation.lxc = {
    enable = lib.mkOption {
      default = false;

      description = ''
        This enables Linux Containers (LXC), which provides tools
        for creating and managing system or application containers
        on Linux.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "lxc" { };

    bridgeConfig = lib.mkOption {
      default = "";

      description = ''
        This is the config file for override lxc-net bridge default settings.
      '';

      type = lib.types.lines;
    };

    defaultConfig = lib.mkOption {
      default = "";

      description = ''
        Default config (default.conf) for new containers, i.e. for
        network config. See {manpage}`lxc.container.conf(5)`.
      '';

      type = lib.types.lines;
    };

    systemConfig = lib.mkOption {
      default = "";

      description = ''
        This is the system-wide LXC config. See
        {manpage}`lxc.system.conf(5)`.
      '';

      type = lib.types.lines;
    };

    unprivilegedContainers = lib.mkEnableOption "support for unprivileged users to launch containers";

    usernetConfig = lib.mkOption {
      default = "";

      description = ''
        This is the config file for managing unprivileged user network
        administration access in LXC. See {manpage}`lxc-usernet(5)`.
      '';

      type = lib.types.lines;
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    environment.etc."lxc/default.conf".text = cfg.defaultConfig;
    environment.etc."lxc/lxc-net".text = cfg.bridgeConfig;
    environment.etc."lxc/lxc-usernet".text = cfg.usernetConfig;
    environment.etc."lxc/lxc.conf".text = cfg.systemConfig;
    environment.pathsToLink = [ "/share/lxc" ];
    environment.systemPackages = [ cfg.package ];
    security.apparmor.packages = [ cfg.package ];

    security.apparmor.policies = {
      "bin.lxc-start".profile = ''
        include ${cfg.package}/etc/apparmor.d/usr.bin.lxc-start
      '';

      "lxc-containers".profile = ''
        include ${cfg.package}/etc/apparmor.d/lxc-containers
      '';
    };

    # `lxc-user-nic` needs suid to attach to bridge for unpriv containers.
    security.wrappers = lib.mkIf cfg.unprivilegedContainers {
      lxcUserNet = {
        group = "lxc-user";
        owner = "root";
        permissions = "u+rx,g+x,o-rx";
        program = "lxc-user-nic";
        setuid = true;
        source = "${pkgs.lxc}/libexec/lxc/lxc-user-nic";
      };
    };

    # Add lxc-net service if unpriv mode is enabled.
    systemd.packages = lib.mkIf cfg.unprivilegedContainers [ pkgs.lxc ];

    systemd.services = lib.mkIf cfg.unprivilegedContainers {
      lxc-net = {
        enable = true;

        path = [
          pkgs.iproute2
          pkgs.iptables
          pkgs.getent
          pkgs.dnsmasq
        ];

        wantedBy = [ "multi-user.target" ];
      };
    };

    systemd.tmpfiles.rules = [ "d /var/lib/lxc/rootfs 0755 root root -" ];
    # We don't need the `lxc-user` group, unless the unprivileged containers are enabled.
    users.groups = lib.mkIf cfg.unprivilegedContainers { lxc-user = { }; };
  };

  meta = {
    teams = [ lib.teams.lxc ];
  };
}
