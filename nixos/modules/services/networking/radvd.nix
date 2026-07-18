# Module for the IPv6 Router Advertisement Daemon.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.radvd;

  confFile = pkgs.writeText "radvd.conf" cfg.config;

in

{

  ###### interface

  options.services.radvd = {

    config = mkOption {
      description = ''
        The contents of the radvd configuration file.
      '';

      example = ''
        interface eth0 {
          AdvSendAdvert on;
          prefix 2001:db8:1234:5678::/64 { };
        };
      '';

      type = types.lines;
    };

    enable = mkOption {
      default = false;

      description = ''
        Whether to enable the Router Advertisement Daemon
        ({command}`radvd`), which provides link-local
        advertisements of IPv6 router addresses and prefixes using
        the Neighbor Discovery Protocol (NDP).  This enables
        stateless address autoconfiguration in IPv6 clients on the
        network.
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "radvd" { };

    debugLevel = mkOption {
      default = 0;

      description = ''
        The debugging level is an integer in the range from 1 to 5,
        from quiet to very verbose. A debugging level of 0 completely
        turns off debugging.
      '';

      example = 5;
      type = types.ints.between 0 5;
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.radvd = {
      after = [ "network.target" ];
      description = "IPv6 Router Advertisement Daemon";

      serviceConfig = {
        ExecStart = "@${cfg.package}/bin/radvd radvd -n -u radvd -d ${toString cfg.debugLevel} -C ${confFile}";
        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.radvd = { };

    users.users.radvd = {
      description = "Router Advertisement Daemon User";
      group = "radvd";
      isSystemUser = true;
    };

  };

}
