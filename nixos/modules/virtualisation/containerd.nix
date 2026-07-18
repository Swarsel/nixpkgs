{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.virtualisation.containerd;

  configFile =
    if cfg.configFile == null then
      settingsFormat.generate "containerd.toml" cfg.settings
    else
      cfg.configFile;

  containerdConfigChecked =
    pkgs.runCommand "containerd-config-checked.toml"
      {
        nativeBuildInputs = [ pkgs.containerd ];
      }
      ''
        containerd -c ${configFile} config dump >/dev/null
        ln -s ${configFile} $out
      '';

  settingsFormat = pkgs.formats.toml { };
in
{

  options.virtualisation.containerd = with lib.types; {
    enable = lib.mkEnableOption "containerd container runtime";

    args = lib.mkOption {
      default = { };
      description = "extra args to append to the containerd cmdline";
      type = attrsOf str;
    };

    configFile = lib.mkOption {
      default = null;

      description = ''
        Path to containerd config file.
        Setting this option will override any configuration applied by the settings option.
      '';

      type = nullOr path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Verbatim lines to add to containerd.toml
      '';

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.containerd ];

    systemd.services.containerd = {
      after = [
        "network.target"
        "local-fs.target"
        "dbus.service"
      ];

      description = "containerd - container runtime";

      path =
        with pkgs;
        [
          containerd
          runc
          iptables
        ]
        ++ lib.optional config.boot.zfs.enabled config.boot.zfs.package;

      serviceConfig = {
        Delegate = "yes";

        ExecStart = "${pkgs.containerd}/bin/containerd ${
          lib.concatStringsSep " " (lib.cli.toCommandLineGNU { } cfg.args)
        }";

        KillMode = "process";
        LimitCORE = "infinity";
        # "limits" defined below are adopted from upstream: https://github.com/containerd/containerd/blob/master/containerd.service
        LimitNPROC = "infinity";
        OOMScoreAdjust = "-999";
        Restart = "always";
        RestartSec = "10";
        RuntimeDirectory = "containerd";
        RuntimeDirectoryPreserve = "yes";
        StateDirectory = "containerd";
        TasksMax = "infinity";
        Type = "notify";
      };

      unitConfig = {
        StartLimitBurst = "16";
        StartLimitIntervalSec = "120s";
      };

      wantedBy = [ "multi-user.target" ];
    };

    virtualisation.containerd = {
      args.config = toString containerdConfigChecked;

      settings = {
        plugins."io.containerd.grpc.v1.cri" = {
          cni.bin_dir = lib.mkOptionDefault "${pkgs.cni-plugins}/bin";
          containerd.snapshotter = lib.mkIf config.boot.zfs.enabled (lib.mkOptionDefault "zfs");
        };

        version = 2;
      };
    };

    warnings = lib.optional (cfg.configFile != null) ''
      `virtualisation.containerd.configFile` is deprecated. use `virtualisation.containerd.settings` instead.
    '';
  };
}
