{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  top = config.services.kubernetes;
  otop = options.services.kubernetes;
  cfg = top.scheduler;
in
{
  ###### interface
  options.services.kubernetes.scheduler = with lib.types; {

    enable = lib.mkEnableOption "Kubernetes scheduler";

    address = lib.mkOption {
      default = "127.0.0.1";
      description = "Kubernetes scheduler listening address.";
      type = str;
    };

    extraOpts = lib.mkOption {
      default = "";
      description = "Kubernetes scheduler extra command line options.";
      type = separatedString " ";
    };

    featureGates = lib.mkOption {
      default = top.featureGates;
      defaultText = lib.literalExpression "config.${otop.featureGates}";
      description = "Attribute set of feature gates.";
      type = attrsOf bool;
    };

    kubeconfig = top.lib.mkKubeConfigOptions "Kubernetes scheduler";

    leaderElect = lib.mkOption {
      default = true;
      description = "Whether to start leader election before executing main loop.";
      type = bool;
    };

    port = lib.mkOption {
      default = 10251;
      description = "Kubernetes scheduler listening port.";
      type = port;
    };

    verbosity = lib.mkOption {
      default = null;

      description = ''
        Optional glog verbosity level for logging statements. See
        <https://github.com/kubernetes/community/blob/master/contributors/devel/logging.md>
      '';

      type = nullOr int;
    };

  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    services.kubernetes.pki.certs = {
      schedulerClient = top.lib.mkCert {
        CN = "system:kube-scheduler";
        action = "systemctl restart kube-scheduler.service";
        name = "kube-scheduler-client";
      };
    };

    services.kubernetes.scheduler.kubeconfig.server = lib.mkDefault top.apiserverAddress;

    systemd.services.kube-scheduler = {
      after = [ "kube-apiserver.service" ];
      description = "Kubernetes Scheduler Service";

      serviceConfig = {
        ExecStart = ''
          ${top.package}/bin/kube-scheduler \
                    --bind-address=${cfg.address} \
                    ${
                      lib.optionalString (cfg.featureGates != { })
                        "--feature-gates=${
                          lib.concatStringsSep "," (
                            builtins.attrValues (lib.mapAttrs (n: v: "${n}=${lib.trivial.boolToString v}") cfg.featureGates)
                          )
                        }"
                    } \
                    --kubeconfig=${top.lib.mkKubeConfig "kube-scheduler" cfg.kubeconfig} \
                    --leader-elect=${lib.boolToString cfg.leaderElect} \
                    --secure-port=${toString cfg.port} \
                    ${lib.optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
                    ${cfg.extraOpts}
        '';

        Group = "kubernetes";
        Restart = "on-failure";
        RestartSec = 5;
        Slice = "kubernetes.slice";
        User = "kubernetes";
        WorkingDirectory = top.dataDir;
      };

      unitConfig = {
        StartLimitIntervalSec = 0;
      };

      wantedBy = [ "kubernetes.target" ];
    };
  };

  meta.buildDocsInSandbox = false;
}
