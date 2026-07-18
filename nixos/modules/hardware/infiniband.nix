{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.hardware.infiniband;
  opensm-services = {
    "opensm@" = {
      enable = true;
      before = [ "network.target" ];
      description = "Starts OpenSM Infiniband fabric Subnet Managers";

      serviceConfig = {
        ExecStart = "${pkgs.opensm}/bin/opensm --guid %I --log_file /var/log/opensm.%I.log";
        Type = "simple";
      };

      unitConfig = {
        ConditionPathExists = "/sys/class/infiniband_mad/abi_version";
      };
    };
  }
  // (builtins.listToAttrs (
    map (guid: {
      name = "opensm@${guid}";

      value = {
        enable = true;
        overrideStrategy = "asDropin";
        wantedBy = [ "machines.target" ];
      };
    }) cfg.guids
  ));

in

{
  options.hardware.infiniband = {
    enable = lib.mkEnableOption "Infiniband support";

    guids = lib.mkOption {
      default = [ ];

      description = ''
        A list of infiniband port guids on the system. This is discoverable using `ibstat -p`
      '';

      example = [ "0xe8ebd30000eee2e1" ];
      type = with lib.types; listOf str;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.kernelModules = [
      "mlx5_core"
      "mlx5_ib"
      "ib_cm"
      "rdma_cm"
      "rdma_ucm"
      "rpcrdma"
      "ib_ipoib"
      "ib_isert"
      "ib_umad"
      "ib_uverbs"
    ];

    # rdma-core exposes ibstat, mstflint exposes mstconfig (which can be needed for
    # setting link configurations), qperf needed to affirm link speeds
    environment.systemPackages = with pkgs; [
      rdma-core
      mstflint
      qperf
    ];

    systemd.services = opensm-services;
  };
}
