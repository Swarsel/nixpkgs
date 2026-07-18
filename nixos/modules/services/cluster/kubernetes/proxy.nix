{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let
  top = config.services.kubernetes;
  otop = options.services.kubernetes;
  cfg = top.proxy;
in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "kubernetes" "proxy" "address" ]
      [ "services" "kubernetes" "proxy" "bindAddress" ]
    )
  ];

  ###### interface
  options.services.kubernetes.proxy = with lib.types; {

    enable = mkEnableOption "Kubernetes proxy";

    bindAddress = mkOption {
      default = "0.0.0.0";
      description = "Kubernetes proxy listening address.";
      type = str;
    };

    extraOpts = mkOption {
      default = "";
      description = "Kubernetes proxy extra command line options.";
      type = separatedString " ";
    };

    featureGates = mkOption {
      default = top.featureGates;
      defaultText = literalExpression "config.${otop.featureGates}";
      description = "Attribute set of feature gates.";
      type = attrsOf bool;
    };

    hostname = mkOption {
      default = config.networking.hostName;
      defaultText = literalExpression "config.networking.hostName";
      description = "Kubernetes proxy hostname override.";
      type = str;
    };

    kubeconfig = top.lib.mkKubeConfigOptions "Kubernetes proxy";

    verbosity = mkOption {
      default = null;

      description = ''
        Optional glog verbosity level for logging statements. See
        <https://github.com/kubernetes/community/blob/master/contributors/devel/logging.md>
      '';

      type = nullOr int;
    };

  };

  ###### implementation
  config = mkIf cfg.enable {
    services.kubernetes.pki.certs = {
      kubeProxyClient = top.lib.mkCert {
        CN = "system:kube-proxy";
        action = "systemctl restart kube-proxy.service";
        name = "kube-proxy-client";
      };
    };

    services.kubernetes.proxy.hostname = with config.networking; mkDefault hostName;
    services.kubernetes.proxy.kubeconfig.server = mkDefault top.apiserverAddress;

    systemd.services.kube-proxy = {
      after = [ "kube-apiserver.service" ];
      description = "Kubernetes Proxy Service";

      path = with pkgs; [
        iptables
        conntrack-tools
      ];

      serviceConfig = {
        ExecStart = ''
          ${top.package}/bin/kube-proxy \
          --bind-address=${cfg.bindAddress} \
          ${optionalString (top.clusterCidr != null) "--cluster-cidr=${top.clusterCidr}"} \
          ${
            optionalString (cfg.featureGates != { })
              "--feature-gates=${
                concatStringsSep "," (
                  builtins.attrValues (mapAttrs (n: v: "${n}=${trivial.boolToString v}") cfg.featureGates)
                )
              }"
          } \
          --hostname-override=${cfg.hostname} \
          --kubeconfig=${top.lib.mkKubeConfig "kube-proxy" cfg.kubeconfig} \
          ${optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
          ${cfg.extraOpts}
        '';

        Restart = "on-failure";
        RestartSec = 5;
        Slice = "kubernetes.slice";
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
