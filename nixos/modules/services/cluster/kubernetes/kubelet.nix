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
  cfg = top.kubelet;

  cniConfig =
    if cfg.cni.config != [ ] && cfg.cni.configDir != null then
      throw "Verbatim CNI-config and CNI configDir cannot both be set."
    else if cfg.cni.configDir != null then
      cfg.cni.configDir
    else
      (pkgs.buildEnv {
        name = "kubernetes-cni-config";

        paths = imap (
          i: entry: pkgs.writeTextDir "${toString (10 + i)}-${entry.type}.conf" (builtins.toJSON entry)
        ) cfg.cni.config;
      });

  infraContainer = pkgs.dockerTools.buildImage {
    config.Cmd = [ "/bin/pause" ];

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ top.package.pause ];
      pathsToLink = [ "/bin" ];
    };

    name = "pause";
    tag = "latest";
  };

  kubeconfig = top.lib.mkKubeConfig "kubelet" cfg.kubeconfig;

  # Flag based settings are deprecated, use the `--config` flag with a
  # `KubeletConfiguration` struct.
  # https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
  #
  # NOTE: registerWithTaints requires a []core/v1.Taint, therefore requires
  # additional work to be put in config format.
  #
  kubeletConfig = pkgs.writeText "kubelet-config" (
    builtins.toJSON (
      {
        address = cfg.address;
        apiVersion = "kubelet.config.k8s.io/v1beta1";

        authentication = {
          webhook = {
            cacheTTL = "10s";
            enabled = true;
          };

          x509 = lib.optionalAttrs (cfg.clientCaFile != null) { clientCAFile = cfg.clientCaFile; };
        };

        authorization = {
          mode = "Webhook";
        };

        cgroupDriver = "systemd";
        containerRuntimeEndpoint = cfg.containerRuntimeEndpoint;
        hairpinMode = "hairpin-veth";
        healthzBindAddress = cfg.healthz.bind;
        healthzPort = cfg.healthz.port;
        kind = "KubeletConfiguration";
        port = cfg.port;
        registerNode = cfg.registerNode;
      }
      // lib.optionalAttrs (cfg.tlsCertFile != null) { tlsCertFile = cfg.tlsCertFile; }
      // lib.optionalAttrs (cfg.tlsKeyFile != null) { tlsPrivateKeyFile = cfg.tlsKeyFile; }
      // lib.optionalAttrs (cfg.clusterDomain != "") { clusterDomain = cfg.clusterDomain; }
      // lib.optionalAttrs (cfg.clusterDns != [ ]) { clusterDNS = cfg.clusterDns; }
      // lib.optionalAttrs (cfg.featureGates != { }) { featureGates = cfg.featureGates; }
      // lib.optionalAttrs (cfg.extraConfig != { }) cfg.extraConfig
    )
  );

  manifestPath = "kubernetes/manifests";

  taintOptions =
    with lib.types;
    { name, ... }:
    {
      options = {
        effect = mkOption {
          description = "Effect of taint.";
          example = "NoSchedule";

          type = enum [
            "NoSchedule"
            "PreferNoSchedule"
            "NoExecute"
          ];
        };

        key = mkOption {
          default = name;
          defaultText = literalMD "Name of this submodule.";
          description = "Key of taint.";
          type = str;
        };

        value = mkOption {
          description = "Value of taint.";
          type = str;
        };
      };
    };

  taints = concatMapStringsSep "," (v: "${v.key}=${v.value}:${v.effect}") (attrValues cfg.taints);
in
{
  imports = [
    (mkRemovedOptionModule [ "services" "kubernetes" "kubelet" "applyManifests" ] "")
    (mkRemovedOptionModule [ "services" "kubernetes" "kubelet" "cadvisorPort" ] "")
    (mkRemovedOptionModule [ "services" "kubernetes" "kubelet" "allowPrivileged" ] "")
    (mkRemovedOptionModule [ "services" "kubernetes" "kubelet" "networkPlugin" ] "")
    (mkRemovedOptionModule [ "services" "kubernetes" "kubelet" "containerRuntime" ] "")
  ];

  ###### interface
  options.services.kubernetes.kubelet = with lib.types; {

    enable = mkEnableOption "Kubernetes kubelet";

    address = mkOption {
      default = "0.0.0.0";
      description = "Kubernetes kubelet info server listening address.";
      type = str;
    };

    clientCaFile = mkOption {
      default = top.caFile;
      defaultText = literalExpression "config.${otop.caFile}";
      description = "Kubernetes apiserver CA file for client authentication.";
      type = nullOr path;
    };

    clusterDns = mkOption {
      default = [ "10.1.0.1" ];
      description = "Use alternative DNS.";
      type = listOf str;
    };

    clusterDomain = mkOption {
      default = config.services.kubernetes.addons.dns.clusterDomain;
      defaultText = literalExpression "config.${options.services.kubernetes.addons.dns.clusterDomain}";
      description = "Use alternative domain.";
      type = str;
    };

    cni = {
      config = mkOption {
        default = [ ];
        description = "Kubernetes CNI configuration.";

        example = literalExpression ''
          [{
            "cniVersion": "0.3.1",
            "name": "mynet",
            "type": "bridge",
            "bridge": "cni0",
            "isGateway": true,
            "ipMasq": true,
            "ipam": {
                "type": "host-local",
                "subnet": "10.22.0.0/16",
                "routes": [
                    { "dst": "0.0.0.0/0" }
                ]
            }
          } {
            "cniVersion": "0.3.1",
            "type": "loopback"
          }]
        '';

        type = listOf attrs;
      };

      configDir = mkOption {
        default = null;
        description = "Path to Kubernetes CNI configuration directory.";
        type = nullOr path;
      };

      packages = mkOption {
        default = [ ];
        description = "List of network plugin packages to install.";
        type = listOf package;
      };
    };

    containerRuntimeEndpoint = mkOption {
      default = "unix:///run/containerd/containerd.sock";
      description = "Endpoint at which to find the container runtime api interface/socket";
      type = str;
    };

    extraConfig = mkOption {
      default = { };

      description = ''
        Kubernetes kubelet extra configuration file entries.

        See also [Set Kubelet Parameters Via A Configuration File](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/)
        and [Kubelet Configuration](https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/).
      '';

      type = attrsOf ((pkgs.formats.json { }).type);
    };

    extraOpts = mkOption {
      default = "";
      description = "Kubernetes kubelet extra command line options.";
      type = separatedString " ";
    };

    featureGates = mkOption {
      default = top.featureGates;
      defaultText = literalExpression "config.${otop.featureGates}";
      description = "Attribute set of feature gate";
      type = attrsOf bool;
    };

    healthz = {
      bind = mkOption {
        default = "127.0.0.1";
        description = "Kubernetes kubelet healthz listening address.";
        type = str;
      };

      port = mkOption {
        default = 10248;
        description = "Kubernetes kubelet healthz port.";
        type = port;
      };
    };

    hostname = mkOption {
      defaultText = literalExpression "config.networking.fqdnOrHostName";
      description = "Kubernetes kubelet hostname override.";
      type = str;
    };

    kubeconfig = top.lib.mkKubeConfigOptions "Kubelet";

    manifests = mkOption {
      default = { };
      description = "List of manifests to bootstrap with kubelet (only pods can be created as manifest entry)";
      type = attrsOf attrs;
    };

    nodeIp = mkOption {
      default = null;
      description = "IP address of the node. If set, kubelet will use this IP address for the node.";
      type = nullOr str;
    };

    port = mkOption {
      default = 10250;
      description = "Kubernetes kubelet info server listening port.";
      type = port;
    };

    registerNode = mkOption {
      default = true;
      description = "Whether to auto register kubelet with API server.";
      type = bool;
    };

    seedDockerImages = mkOption {
      default = [ ];
      description = "List of docker images to preload on system";
      type = listOf package;
    };

    taints = mkOption {
      default = { };
      description = "Node taints (https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).";
      type = attrsOf (submodule [ taintOptions ]);
    };

    tlsCertFile = mkOption {
      default = null;
      description = "File containing x509 Certificate for HTTPS.";
      type = nullOr path;
    };

    tlsKeyFile = mkOption {
      default = null;
      description = "File containing x509 private key matching tlsCertFile.";
      type = nullOr path;
    };

    unschedulable = mkOption {
      default = false;
      description = "Whether to set node taint to unschedulable=true as it is the case of node that has only master role.";
      type = bool;
    };

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
  config = mkMerge [
    (mkIf cfg.enable {

      boot.kernel.sysctl = {
        "net.bridge.bridge-nf-call-ip6tables" = 1;
        "net.bridge.bridge-nf-call-iptables" = 1;
        "net.ipv4.ip_forward" = 1;
      };

      boot.kernelModules = [
        "br_netfilter"
        "overlay"
      ];

      environment.etc."cni/net.d".source = cniConfig;

      # Always include cni plugins
      services.kubernetes.kubelet.cni.packages = [
        pkgs.cni-plugins
        pkgs.cni-plugin-flannel
      ];

      services.kubernetes.kubelet.hostname = mkDefault (lib.toLower config.networking.fqdnOrHostName);
      services.kubernetes.kubelet.kubeconfig.server = mkDefault top.apiserverAddress;
      services.kubernetes.kubelet.seedDockerImages = [ infraContainer ];

      services.kubernetes.pki.certs = with top.lib; {
        kubelet = mkCert {
          CN = top.kubelet.hostname;
          action = "systemctl restart kubelet.service";
          name = "kubelet";

        };

        kubeletClient = mkCert {
          CN = "system:node:${top.kubelet.hostname}";
          action = "systemctl restart kubelet.service";

          fields = {
            O = "system:nodes";
          };

          name = "kubelet-client";
        };
      };

      systemd.services.kubelet = {
        after = [
          "containerd.service"
          "network.target"
          "kube-apiserver.service"
        ];

        description = "Kubernetes Kubelet Service";

        path =
          with pkgs;
          [
            gitMinimal
            openssh
            util-linuxMinimal
            iproute2
            ethtool
            thin-provisioning-tools
            iptables
            socat
          ]
          ++ lib.optional config.boot.zfs.enabled config.boot.zfs.package
          ++ top.path;

        preStart = ''
          ${concatMapStrings (img: ''
            echo "Seeding container image: ${img}"
            ${
              if (lib.hasSuffix "gz" img) then
                ''${pkgs.gzip}/bin/zcat "${img}" | ${pkgs.containerd}/bin/ctr -n k8s.io image import -''
              else
                ''${pkgs.coreutils}/bin/cat "${img}" | ${pkgs.containerd}/bin/ctr -n k8s.io image import -''
            }
          '') cfg.seedDockerImages}

          rm /opt/cni/bin/* || true
          ${concatMapStrings (package: ''
            echo "Linking cni package: ${package}"
            ln -fs ${package}/bin/* /opt/cni/bin
          '') cfg.cni.packages}
        '';

        serviceConfig = {
          ExecStart = ''
            ${top.package}/bin/kubelet \
                        --config=${kubeletConfig} \
                        --hostname-override=${cfg.hostname} \
                        --kubeconfig=${kubeconfig} \
                        ${optionalString (cfg.nodeIp != null) "--node-ip=${cfg.nodeIp}"} \
                        ${optionalString (cfg.manifests != { }) "--pod-manifest-path=/etc/${manifestPath}"} \
                        ${optionalString (taints != "") "--register-with-taints=${taints}"} \
                        --root-dir=${top.dataDir} \
                        ${optionalString (cfg.verbosity != null) "--v=${toString cfg.verbosity}"} \
                        ${cfg.extraOpts}
          '';

          MemoryAccounting = true;
          Restart = "on-failure";
          RestartSec = "1000ms";
          Slice = "kubernetes.slice";
          WorkingDirectory = top.dataDir;
        };

        unitConfig = {
          StartLimitIntervalSec = 0;
        };

        wantedBy = [ "kubernetes.target" ];
      };
    })

    (mkIf (cfg.enable && cfg.manifests != { }) {
      environment.etc = mapAttrs' (
        name: manifest:
        nameValuePair "${manifestPath}/${name}.json" {
          mode = "0755";
          text = builtins.toJSON manifest;
        }
      ) cfg.manifests;
    })

    (mkIf (cfg.unschedulable && cfg.enable) {
      services.kubernetes.kubelet.taints.unschedulable = {
        effect = "NoSchedule";
        value = "true";
      };
    })

  ];

  meta.buildDocsInSandbox = false;
}
