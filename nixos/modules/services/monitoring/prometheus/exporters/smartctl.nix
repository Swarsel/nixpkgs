{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.smartctl;

  inherit (lib) mkOption types literalExpression;

  args = lib.escapeShellArgs (
    [
      "--web.listen-address=${cfg.listenAddress}:${toString cfg.port}"
      "--smartctl.interval=${cfg.maxInterval}"
    ]
    ++ map (device: "--smartctl.device=${device}") cfg.devices
    ++ cfg.extraFlags
  );

in
{
  extraOpts = {
    devices = mkOption {
      default = [ ];

      description = ''
        Paths to the disks that will be monitored. Will autodiscover
        all disks if none given.
      '';

      example = literalExpression ''
        [ "/dev/sda", "/dev/nvme0n1" ];
      '';

      type = types.listOf types.str;
    };

    maxInterval = mkOption {
      default = "60s";

      description = ''
        Interval that limits how often a disk can be queried.
      '';

      example = "2m";
      type = types.str;
    };
  };

  port = 9633;

  serviceOpts = {
    serviceConfig = {
      AmbientCapabilities = [
        "CAP_SYS_RAWIO"
        "CAP_SYS_ADMIN"
      ];

      CapabilityBoundingSet = [
        "CAP_SYS_RAWIO"
        "CAP_SYS_ADMIN"
      ];

      DeviceAllow = lib.mkOverride 50 [
        "block-blkext rw"
        "block-sd rw"
        "char-nvme rw"
      ];

      DevicePolicy = "closed";
      ExecStart = "${pkgs.prometheus-smartctl-exporter}/bin/smartctl_exporter ${args}";
      PrivateDevices = lib.mkForce false;
      ProcSubset = "pid";
      ProtectProc = "invisible";

      SupplementaryGroups = [
        "disk"
        "smartctl-exporter-access"
      ];

      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
    };
  };
}
