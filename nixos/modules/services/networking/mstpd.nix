{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mstpd;
in
with lib;
{
  options.services.mstpd = {

    enable = mkOption {
      default = false;

      description = ''
        Whether to enable the multiple spanning tree protocol daemon.
      '';

      type = types.bool;
    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mstpd ];

    systemd.services.mstpd = {
      description = "Multiple Spanning Tree Protocol Daemon";

      serviceConfig = {
        ExecStart = "@${pkgs.mstpd}/bin/mstpd mstpd";
        PIDFile = "/run/mstpd.pid";
        Type = "forking";
      };

      unitConfig.ConditionCapability = "CAP_NET_ADMIN";
      wantedBy = [ "network.target" ];
    };
  };
}
