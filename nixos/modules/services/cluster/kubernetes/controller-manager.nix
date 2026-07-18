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
  cfg = top.controllerManager;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "kubernetes" "controllerManager" "address" ]
      [ "services" "kubernetes" "controllerManager" "bindAddress" ]
    )
    (lib.mkRemovedOptionModule [ "services" "kubernetes" "controllerManager" "insecurePort" ] "")
  ];

  ###### interface
  options.services.kubernetes.controllerManager = with lib.types; {

    enable = lib.mkEnableOption "Kubernetes controller manager";

    allocateNodeCIDRs = lib.mkOption {
      default = true;
      description = "Whether to automatically allocate CIDR ranges for cluster nodes.";
      type = bool;
    };

    bindAddress = lib.mkOption {
      default = "127.0.0.1";
      description = "Kubernetes controller manager listening address.";
      type = str;
    };

    clusterCidr = lib.mkOption {
      default = top.clusterCidr;
      defaultText = lib.literalExpression "config.${otop.clusterCidr}";
      description = "Kubernetes CIDR Range for Pods in cluster.";
      type = str;
    };

    extraOpts = lib.mkOption {
      default = "";
      description = "Kubernetes controller manager extra command line options.";
      type = separatedString " ";
    };

    featureGates = lib.mkOption {
      default = top.featureGates;
      defaultText = lib.literalExpression "config.${otop.featureGates}";
      description = "Attribute set of feature gates.";
      type = attrsOf bool;
    };

    kubeconfig = top.lib.mkKubeConfigOptions "Kubernetes controller manager";

    leaderElect = lib.mkOption {
      default = true;
      description = "Whether to start leader election before executing main loop.";
      type = bool;
    };

    rootCaFile = lib.mkOption {
      default = top.caFile;
      defaultText = lib.literalExpression "config.${otop.caFile}";

      description = ''
        Kubernetes controller manager certificate authority file included in
        service account's token secret.
      '';

      type = nullOr path;
    };

    securePort = lib.mkOption {
      default = 10252;
      description = "Kubernetes controller manager secure listening port.";
      type = int;
    };

    serviceAccountKeyFile = lib.mkOption {
      default = null;

      description = ''
        Kubernetes controller manager PEM-encoded private RSA key file used to
        sign service account tokens
      '';

      type = nullOr path;
    };

    tlsCertFile = lib.mkOption {
      default = null;
      description = "Kubernetes controller-manager certificate file.";
      type = nullOr path;
    };

    tlsKeyFile = lib.mkOption {
      default = null;
      description = "Kubernetes controller-manager private key file.";
      type = nullOr path;
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
    services.kubernetes.controllerManager.kubeconfig.server = lib.mkDefault top.apiserverAddress;

    services.kubernetes.pki.certs = with top.lib; {
      controllerManager = mkCert {
        CN = "kube-controller-manager";
        action = "systemctl restart kube-controller-manager.service";
        name = "kube-controller-manager";
      };

      controllerManagerClient = mkCert {
        CN = "system:kube-controller-manager";
        action = "systemctl restart kube-controller-manager.service";
        name = "kube-controller-manager-client";
      };
    };

    systemd.services.kube-controller-manager = {
      after = [ "kube-apiserver.service" ];
      description = "Kubernetes Controller Manager Service";
      path = top.path;

      serviceConfig = {
        ExecStart = ''
          ${top.package}/bin/kube-controller-manager \
                    --allocate-node-cidrs=${lib.boolToString cfg.allocateNodeCIDRs} \
                    --bind-address=${cfg.bindAddress} \
                    ${lib.optionalString (cfg.clusterCidr != null) "--cluster-cidr=${cfg.clusterCidr}"} \
                    ${
                      lib.optionalString (cfg.featureGates != { })
                        "--feature-gates=${
                          lib.concatStringsSep "," (
                            builtins.attrValues (lib.mapAttrs (n: v: "${n}=${lib.trivial.boolToString v}") cfg.featureGates)
                          )
                        }"
                    } \
                    --kubeconfig=${top.lib.mkKubeConfig "kube-controller-manager" cfg.kubeconfig} \
                    --leader-elect=${lib.boolToString cfg.leaderElect} \
                    ${lib.optionalString (cfg.rootCaFile != null) "--root-ca-file=${cfg.rootCaFile}"} \
                    --secure-port=${toString cfg.securePort} \
                    ${
                      lib.optionalString (
                        cfg.serviceAccountKeyFile != null
                      ) "--service-account-private-key-file=${cfg.serviceAccountKeyFile}"
                    } \
                    ${lib.optionalString (cfg.tlsCertFile != null) "--tls-cert-file=${cfg.tlsCertFile}"} \
                    ${
                      lib.optionalString (cfg.tlsKeyFile != null) "--tls-private-key-file=${cfg.tlsKeyFile}"
                    } \
                    ${lib.optionalString (lib.elem "RBAC" top.apiserver.authorizationMode) "--use-service-account-credentials"} \
                    ${lib.optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
                    ${cfg.extraOpts}
        '';

        Group = "kubernetes";
        Restart = "on-failure";
        RestartSec = "30s";
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
