{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.virtualisation.cri-o;

  crioPackage = pkgs.cri-o.override {
    extraPackages =
      cfg.extraPackages
      ++ lib.optional (config.boot.supportedFilesystems.zfs or false) config.boot.zfs.package;
  };

  format = pkgs.formats.toml { };

  cfgFile = format.generate "00-default.conf" cfg.settings;
in
{
  options.virtualisation.cri-o = {
    enable = mkEnableOption "Container Runtime Interface for OCI (CRI-O)";

    package = mkOption {
      default = crioPackage;

      description = ''
        The final CRI-O package (including extra packages).
      '';

      internal = true;
      type = types.package;
    };

    extraPackages = mkOption {
      default = [ ];

      description = ''
        Extra packages to be installed in the CRI-O wrapper.
      '';

      example = literalExpression ''
        [
          pkgs.gvisor
        ]
      '';

      type = with types; listOf package;
    };

    logLevel = mkOption {
      default = "info";
      description = "Log level to be used";

      type = types.enum [
        "trace"
        "debug"
        "info"
        "warn"
        "error"
        "fatal"
      ];
    };

    networkDir = mkOption {
      default = null;
      description = "Override the network_dir option.";
      internal = true;
      type = types.nullOr types.path;
    };

    pauseCommand = mkOption {
      default = null;
      description = "Override the default pause command";
      example = "/pause";
      type = types.nullOr types.str;
    };

    pauseImage = mkOption {
      default = null;
      description = "Override the default pause image for pod sandboxes";
      example = "k8s.gcr.io/pause:3.2";
      type = types.nullOr types.str;
    };

    runtime = mkOption {
      default = null;
      description = "Override the default runtime";
      example = "crun";
      type = types.nullOr types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for cri-o, see
        <https://github.com/cri-o/cri-o/blob/master/docs/crio.conf.5.md>.
      '';

      type = format.type;
    };

    storageDriver = mkOption {
      default = "overlay";
      description = "Storage driver to be used";

      type = types.enum [
        "aufs"
        "btrfs"
        "devmapper"
        "overlay"
        "vfs"
        "zfs"
      ];
    };
  };

  config = mkIf cfg.enable {
    environment.etc."cni/net.d/10-crio-bridge.conflist".source =
      "${cfg.package}/etc/cni/net.d/10-crio-bridge.conflist";

    environment.etc."cni/net.d/99-loopback.conflist".source =
      "${cfg.package}/etc/cni/net.d/99-loopback.conflist";

    environment.etc."crictl.yaml".source = "${cfg.package}/etc/crictl.yaml";
    environment.etc."crio/crio.conf.d/00-default.conf".source = cfgFile;

    environment.systemPackages = [
      cfg.package
      pkgs.cri-tools
    ];

    systemd.services.crio = {
      after = [ "network.target" ];
      description = "Container Runtime Interface for OCI (CRI-O)";
      documentation = [ "https://github.com/cri-o/cri-o" ];
      path = [ cfg.package ];
      restartTriggers = [ cfgFile ];

      serviceConfig = {
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -s HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/crio";
        LimitCORE = "infinity";
        LimitNOFILE = "1048576";
        LimitNPROC = "1048576";
        OOMScoreAdjust = "-999";
        Restart = "on-abnormal";
        TasksMax = "infinity";
        TimeoutStartSec = "0";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };

    # Enable common /etc/containers configuration
    virtualisation.containers.enable = true;

    virtualisation.cri-o.settings.crio = {
      image = {
        pause_command = mkIf (cfg.pauseCommand != null) cfg.pauseCommand;
        pause_image = mkIf (cfg.pauseImage != null) cfg.pauseImage;
      };

      network = {
        network_dir = mkIf (cfg.networkDir != null) cfg.networkDir;
        plugin_dirs = [ "${pkgs.cni-plugins}/bin" ];
      };

      runtime = {
        cgroup_manager = "systemd";
        default_runtime = mkIf (cfg.runtime != null) cfg.runtime;
        hooks_dir = optional (config.virtualisation.containers.ociSeccompBpfHook.enable) config.boot.kernelPackages.oci-seccomp-bpf-hook;
        log_level = cfg.logLevel;
        manage_ns_lifecycle = true;
        pinns_path = "${cfg.package}/bin/pinns";

        runtimes = mkIf (cfg.runtime != null) {
          "${cfg.runtime}" = { };
        };
      };

      storage_driver = cfg.storageDriver;
    };
  };

  meta = {
    teams = [ teams.podman ];
  };
}
