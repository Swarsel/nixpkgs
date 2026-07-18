{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.softether;

  package = cfg.package.override { inherit (cfg) dataDir; };

in
{

  ###### interface

  options = {

    services.softether = {

      enable = mkEnableOption "SoftEther VPN services";
      package = mkPackageOption pkgs "softether" { };

      dataDir = mkOption {
        default = "/var/lib/softether";

        description = ''
          Data directory for SoftEther VPN.
        '';

        type = types.path;
      };

      vpnbridge.enable = mkEnableOption "SoftEther VPN Bridge";

      vpnclient = {
        enable = mkEnableOption "SoftEther VPN Client";

        down = mkOption {
          default = "";

          description = ''
            Shell commands executed when the Virtual Network Adapter(s) is/are shutting down.
          '';

          type = types.lines;
        };

        up = mkOption {
          default = "";

          description = ''
            Shell commands executed when the Virtual Network Adapter(s) is/are starting.
          '';

          type = types.lines;
        };
      };

      vpnserver.enable = mkEnableOption "SoftEther VPN Server";

    };

  };

  ###### implementation

  config = mkIf cfg.enable (

    mkMerge [
      {
        environment.systemPackages = [ package ];

        systemd.services.softether-init = {
          description = "SoftEther VPN services initial task";

          script = ''
            for d in vpnserver vpnbridge vpnclient vpncmd; do
                if ! test -e ${cfg.dataDir}/$d; then
                    ${pkgs.coreutils}/bin/mkdir -m0700 -p ${cfg.dataDir}/$d
                    install -m0600 ${package}${cfg.dataDir}/$d/hamcore.se2 ${cfg.dataDir}/$d/hamcore.se2
                fi
            done
            rm -rf ${cfg.dataDir}/vpncmd/vpncmd
            ln -s ${package}${cfg.dataDir}/vpncmd/vpncmd ${cfg.dataDir}/vpncmd/vpncmd
          '';

          serviceConfig = {
            RemainAfterExit = false;
            Type = "oneshot";
          };

          wantedBy = [ "network.target" ];
        };
      }

      (mkIf cfg.vpnserver.enable {
        systemd.services.vpnserver = {
          after = [ "softether-init.service" ];
          description = "SoftEther VPN Server";

          postStop = ''
            rm -rf ${cfg.dataDir}/vpnserver/vpnserver
          '';

          preStart = ''
            rm -rf ${cfg.dataDir}/vpnserver/vpnserver
            ln -s ${package}${cfg.dataDir}/vpnserver/vpnserver ${cfg.dataDir}/vpnserver/vpnserver
          '';

          requires = [ "softether-init.service" ];

          serviceConfig = {
            ExecStart = "${package}/bin/vpnserver start";
            ExecStop = "${package}/bin/vpnserver stop";
            Type = "forking";
          };

          wantedBy = [ "network.target" ];
        };
      })

      (mkIf cfg.vpnbridge.enable {
        systemd.services.vpnbridge = {
          after = [ "softether-init.service" ];
          description = "SoftEther VPN Bridge";

          postStop = ''
            rm -rf ${cfg.dataDir}/vpnbridge/vpnbridge
          '';

          preStart = ''
            rm -rf ${cfg.dataDir}/vpnbridge/vpnbridge
            ln -s ${package}${cfg.dataDir}/vpnbridge/vpnbridge ${cfg.dataDir}/vpnbridge/vpnbridge
          '';

          requires = [ "softether-init.service" ];

          serviceConfig = {
            ExecStart = "${package}/bin/vpnbridge start";
            ExecStop = "${package}/bin/vpnbridge stop";
            Type = "forking";
          };

          wantedBy = [ "network.target" ];
        };
      })

      (mkIf cfg.vpnclient.enable {
        boot.kernelModules = [ "tun" ];

        systemd.services.vpnclient = {
          after = [ "softether-init.service" ];
          description = "SoftEther VPN Client";

          postStart = ''
            sleep 1
            ${cfg.vpnclient.up}
          '';

          postStop = ''
            rm -rf ${cfg.dataDir}/vpnclient/vpnclient
            sleep 1
            ${cfg.vpnclient.down}
          '';

          preStart = ''
            rm -rf ${cfg.dataDir}/vpnclient/vpnclient
            ln -s ${package}${cfg.dataDir}/vpnclient/vpnclient ${cfg.dataDir}/vpnclient/vpnclient
          '';

          requires = [ "softether-init.service" ];

          serviceConfig = {
            ExecStart = "${package}/bin/vpnclient start";
            ExecStop = "${package}/bin/vpnclient stop";
            Type = "forking";
          };

          wantedBy = [ "network.target" ];
        };
      })

    ]
  );

}
