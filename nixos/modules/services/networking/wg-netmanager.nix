{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.wg-netmanager;
in
{

  options = {
    services.wg-netmanager = {
      enable = mkEnableOption "Wireguard network manager";
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    # NOTE: wg-netmanager runs as root
    systemd.services.wg-netmanager = {
      after = [ "network.target" ];
      description = "Wireguard network manager";

      path = with pkgs; [
        wireguard-tools
        iproute2
        wireguard-go
      ];

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.wg-netmanager}/bin/wg_netmanager";
        ExecStop = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ReadWritePaths = [
          "/tmp" # wg-netmanager creates files in /tmp before deleting them after use
        ];

        Restart = "on-failure";
        Type = "simple";
      };

      unitConfig = {
        ConditionPathExists = [
          "/etc/wg_netmanager/network.yaml"
          "/etc/wg_netmanager/peer.yaml"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ gin66 ];
}
