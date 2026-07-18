# GNU Virtual Private Ethernet

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption mkIf types;

  cfg = config.services.gvpe;

  finalConfig =
    if cfg.configFile != null then
      cfg.configFile
    else if cfg.configText != null then
      pkgs.writeTextFile {
        name = "gvpe.conf";
        text = cfg.configText;
      }
    else
      throw "You must either specify contents of the config file or the config file itself for GVPE";

  ifupScript =
    if cfg.ipAddress == null || cfg.subnet == null then
      throw "Specify IP address and subnet (with mask) for GVPE"
    else if cfg.nodename == null then
      throw "You must set node name for GVPE"
    else
      (pkgs.writeTextFile {
        executable = true;
        name = "gvpe-if-up";

        text = ''
          #! /bin/sh

          export PATH=$PATH:${pkgs.iproute2}/sbin

          ip link set dev $IFNAME up
          ip address add ${cfg.ipAddress} dev $IFNAME
          ip route add ${cfg.subnet} dev $IFNAME

          ${cfg.customIFSetup}
        '';
      });
in

{
  options = {
    services.gvpe = {
      enable = lib.mkEnableOption "gvpe";

      configFile = mkOption {
        default = null;

        description = ''
          GVPE config file, if already present
        '';

        example = "/root/my-gvpe-conf";
        type = types.nullOr types.path;
      };

      configText = mkOption {
        default = null;

        description = ''
          GVPE config contents
        '';

        example = ''
          tcp-port = 655
          udp-port = 655
          mtu = 1480
          ifname = vpn0

          node = alpha
          hostname = alpha.example.org
          connect = always
          enable-udp = true
          enable-tcp = true
          on alpha if-up = if-up-0
          on alpha pid-file = /var/gvpe/gvpe.pid
        '';

        type = types.nullOr types.lines;
      };

      customIFSetup = mkOption {
        default = "";

        description = ''
          Additional commands to apply in ifup script
        '';

        type = types.lines;
      };

      ipAddress = mkOption {
        default = null;

        description = ''
          IP address to assign to GVPE interface
        '';

        type = types.nullOr types.str;
      };

      nodename = mkOption {
        default = null;

        description = ''
          GVPE node name
        '';

        type = types.nullOr types.str;
      };

      subnet = mkOption {
        default = null;

        description = ''
          IP subnet assigned to GVPE network
        '';

        example = "10.0.0.0/8";
        type = types.nullOr types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gvpe = {
      after = [ "network.target" ];
      description = "GNU Virtual Private Ethernet node";

      documentation = [
        "info:gvpe"
        "man:gvpe(8)"
      ];

      preStart = ''
        mkdir -p /var/gvpe
        mkdir -p /var/gvpe/pubkey
        chown root /var/gvpe
        chmod 700 /var/gvpe
        cp ${finalConfig} /var/gvpe/gvpe.conf
        cp ${ifupScript} /var/gvpe/if-up
      '';

      script =
        "${pkgs.gvpe}/sbin/gvpe -c /var/gvpe -D ${cfg.nodename} "
        + " ${cfg.nodename}.pid-file=/var/gvpe/gvpe.pid"
        + " ${cfg.nodename}.if-up=if-up"
        + " &> /var/log/gvpe";

      serviceConfig.Restart = "always";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
