{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  ###### interface

  options = {
    services.tinydns = {
      enable = mkOption {
        default = false;
        description = "Whether to run the tinydns dns server";
        type = types.bool;
      };

      data = mkOption {
        default = "";
        description = "The DNS data to serve, in the format described by {manpage}`tinydns-data(8)`";
        type = types.lines;
      };

      ip = mkOption {
        default = "0.0.0.0";
        description = "IP address on which to listen for connections";
        type = types.str;
      };
    };
  };

  ###### implementation

  config = mkIf config.services.tinydns.enable {
    environment.systemPackages = [ pkgs.djbdns ];

    systemd.services.tinydns = {
      after = [ "network.target" ];
      description = "djbdns tinydns server";

      path = with pkgs; [
        daemontools
        djbdns
      ];

      preStart = ''
        rm -rf /var/lib/tinydns
        tinydns-conf tinydns tinydns /var/lib/tinydns ${config.services.tinydns.ip}
        cd /var/lib/tinydns/root/
        ln -sf ${pkgs.writeText "tinydns-data" config.services.tinydns.data} data
        tinydns-data
      '';

      script = ''
        cd /var/lib/tinydns
        exec ./run
      '';

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.tinydns = { };

    users.users.tinydns = {
      group = "tinydns";
      isSystemUser = true;
    };
  };
}
