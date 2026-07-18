{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.networking.rxe;

in
{
  ###### interface

  options = {
    networking.rxe = {
      enable = mkEnableOption "RDMA over converged ethernet";

      interfaces = mkOption {
        default = [ ];

        description = ''
          Enable RDMA on the listed interfaces. The corresponding virtual
          RDMA interfaces will be named rxe_\<interface\>.
          UDP port 4791 must be open on the respective ethernet interfaces.
        '';

        example = [ "eth0" ];
        type = types.listOf types.str;
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.rxe = {
      after = [
        "systemd-modules-load.service"
        "network-online.target"
      ];

      description = "RoCE interfaces";

      serviceConfig = {
        ExecStart = map (
          x: "${pkgs.iproute2}/bin/rdma link add rxe_${x} type rxe netdev ${x}"
        ) cfg.interfaces;

        ExecStop = map (x: "${pkgs.iproute2}/bin/rdma link delete rxe_${x}") cfg.interfaces;
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-pre.target"
        "network-online.target"
      ];
    };
  };
}
