{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "roon-bridge";
  cfg = config.services.roon-bridge;
in
{
  options = {
    services.roon-bridge = {
      enable = lib.mkEnableOption "Roon Bridge";

      group = lib.mkOption {
        default = "roon-bridge";

        description = ''
          Group to run the Roon Bridge as.
        '';

        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the bridge.
        '';

        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "roon-bridge";

        description = ''
          User to run the Roon bridge as.
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
      ];

      allowedUDPPorts = [ 9003 ];

      extraCommands = lib.optionalString (!config.networking.nftables.enable) ''
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

    systemd.services.roon-bridge = {
      after = [ "network.target" ];
      description = "Roon Bridge";
      environment.ROON_DATAROOT = "/var/lib/${name}";

      serviceConfig = {
        ExecStart = "${pkgs.roon-bridge}/bin/RoonBridge";
        Group = cfg.group;
        LimitNOFILE = 8192;
        StateDirectory = name;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = lib.optionalAttrs (cfg.user == "roon-bridge") {
      description = "Roon Bridge user";
      extraGroups = [ "audio" ];
      group = cfg.group;
      isSystemUser = true;
    };
  };
}
