# Module for rdnssd, a daemon that configures DNS servers in
# /etc/resolv/conf from IPv6 RDNSS advertisements.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  mergeHook = pkgs.writeScript "rdnssd-merge-hook" ''
    #! ${pkgs.runtimeShell} -e
    ${pkgs.openresolv}/bin/resolvconf -u
  '';
in
{

  ###### interface

  options = {

    services.rdnssd.enable = mkOption {
      default = false;

      #default = config.networking.enableIPv6;
      description = ''
        Whether to enable the RDNSS daemon
        ({command}`rdnssd`), which configures DNS servers in
        {file}`/etc/resolv.conf` from RDNSS
        advertisements sent by IPv6 routers.
      '';

      type = types.bool;
    };

  };

  ###### implementation

  config = mkIf config.services.rdnssd.enable {

    assertions = [
      {
        assertion = config.networking.resolvconf.enable;
        message = "rdnssd needs resolvconf to work (probably something sets up a static resolv.conf)";
      }
    ];

    systemd.services.rdnssd = {
      after = [ "network.target" ];
      description = "RDNSS daemon";

      postStop = ''
        rm -f /run/resolvconf/interfaces/rdnssd
        ${mergeHook}
      '';

      preStart = ''
        # Create the proper run directory
        mkdir -p /run/rdnssd
        touch /run/rdnssd/resolv.conf
        chown -R rdnssd /run/rdnssd

        # Link the resolvconf interfaces to rdnssd
        rm -f /run/resolvconf/interfaces/rdnssd
        ln -s /run/rdnssd/resolv.conf /run/resolvconf/interfaces/rdnssd
        ${mergeHook}
      '';

      serviceConfig = {
        ExecStart = "@${pkgs.ndisc6}/bin/rdnssd rdnssd -p /run/rdnssd/rdnssd.pid -r /run/rdnssd/resolv.conf -u rdnssd -H ${mergeHook}";
        PIDFile = "/run/rdnssd/rdnssd.pid";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.rdnssd = { };

    users.users.rdnssd = {
      description = "RDNSSD Daemon User";
      group = "rdnssd";
      isSystemUser = true;
    };

  };

}
