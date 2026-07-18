{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options = {
    services.toxvpn = {
      enable = mkEnableOption "toxvpn running on startup";

      auto_add_peers = mkOption {
        default = [ ];
        description = "peers to automatically connect to on startup";

        example = [
          "toxid1"
          "toxid2"
        ];

        type = types.listOf types.str;
      };

      localip = mkOption {
        default = "10.123.123.1";
        description = "your ip on the vpn";
        type = types.str;
      };

      port = mkOption {
        default = 33445;
        description = "udp port for toxcore, port-forward to help with connectivity if you run many nodes behind one NAT";
        type = types.port;
      };
    };
  };

  config = mkIf config.services.toxvpn.enable {
    environment.systemPackages = [ pkgs.toxvpn ];

    systemd.services.toxvpn = {
      after = [ "network.target" ];
      description = "toxvpn daemon";
      path = [ pkgs.toxvpn ];

      preStart = ''
        mkdir -p /run/toxvpn || true
        chown toxvpn /run/toxvpn
      '';

      restartIfChanged = false; # Likely to be used for remote admin

      script = ''
        exec toxvpn -i ${config.services.toxvpn.localip} -l /run/toxvpn/control -u toxvpn -p ${toString config.services.toxvpn.port} ${
          lib.concatMapStringsSep " " (x: "-a ${x}") config.services.toxvpn.auto_add_peers
        }
      '';

      serviceConfig = {
        KillMode = "process";
        Restart = "on-success";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.toxvpn = { };

    users.users = {
      toxvpn = {
        createHome = true;
        group = "toxvpn";
        home = "/var/lib/toxvpn";
        isSystemUser = true;
      };
    };
  };
}
