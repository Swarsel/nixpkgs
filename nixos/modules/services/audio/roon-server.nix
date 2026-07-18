{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "roon-server";
  cfg = config.services.roon-server;
in
{
  options = {
    services.roon-server = {
      enable = lib.mkEnableOption "Roon Server";
      package = lib.mkPackageOption pkgs "roon-server" { };

      group = lib.mkOption {
        default = "roon-server";

        description = ''
          Group to run the Roon Server as.
        '';

        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the server.
        '';

        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "roon-server";

        description = ''
          User to run the Roon Server as.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPortRanges = [
        {
          from = 9100;
          to = 9200;
        }
        {
          from = 9330;
          to = 9339;
        }
        {
          from = 30000;
          to = 30010;
        }
      ];

      allowedUDPPorts = [ 9003 ];

      extraCommands = lib.optionalString (!config.networking.nftables.enable) ''
        ## IGMP / Broadcast ##
        iptables -A INPUT -s 224.0.0.0/4 -j ACCEPT
        iptables -A INPUT -d 224.0.0.0/4 -j ACCEPT
        iptables -A INPUT -s 240.0.0.0/5 -j ACCEPT
        iptables -A INPUT -m pkttype --pkt-type multicast -j ACCEPT
        iptables -A INPUT -m pkttype --pkt-type broadcast -j ACCEPT
      '';

      extraInputRules = lib.optionalString config.networking.nftables.enable ''
        ip saddr { 224.0.0.0/4, 240.0.0.0/5 } accept
        ip daddr 224.0.0.0/4 accept
        pkttype { multicast, broadcast } accept
      '';
    };

    systemd.services.roon-server = {
      after = [ "network.target" ];
      description = "Roon Server";
      environment.ROON_DATAROOT = "/var/lib/${name}";
      environment.ROON_ID_DIR = "/var/lib/${name}";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        Group = cfg.group;
        LimitNOFILE = 8192;
        StateDirectory = name;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = lib.optionalAttrs (cfg.user == "roon-server") {
      description = "Roon Server user";
      extraGroups = [ "audio" ];
      group = cfg.group;
      isSystemUser = true;
    };
  };
}
