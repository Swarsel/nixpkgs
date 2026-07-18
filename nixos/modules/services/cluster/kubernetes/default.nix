{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.kubernetes;
  opt = options.services.kubernetes;

  defaultContainerdSettings = {
    grpc = {
      address = "/run/containerd/containerd.sock";
    };

    oom_score = 0;

    plugins."io.containerd.grpc.v1.cri" = {
      cni = {
        bin_dir = "/opt/cni/bin";
        max_conf_num = 0;
      };

      containerd.runtimes.runc = {
        options.SystemdCgroup = true;
        runtime_type = "io.containerd.runc.v2";
      };

      sandbox_image = "docker.io/library/pause:latest";
    };

    root = "/var/lib/containerd";
    state = "/run/containerd";
    version = 2;
  };

  mkKubeConfig =
    name: conf:
    pkgs.writeText "${name}-kubeconfig" (
      builtins.toJSON {
        apiVersion = "v1";

        clusters = [
          {
            cluster.certificate-authority = conf.caFile or cfg.caFile;
            cluster.server = conf.server;
            name = "local";
          }
        ];

        contexts = [
          {
            context = {
              cluster = "local";
              user = name;
            };

            name = "local";
          }
        ];

        current-context = "local";
        kind = "Config";

        users = [
          {
            inherit name;

            user = {
              client-certificate = conf.certFile;
              client-key = conf.keyFile;
            };
          }
        ];
      }
    );

  caCert = secret "ca";

  etcdEndpoints = [ "https://${cfg.masterAddress}:2379" ];

  mkCert =
    {
      CN,
      name,
      action ? "",
      fields ? { },
      hosts ? [ ],
      privateKeyGroup ? "kubernetes",
      privateKeyOwner ? "kubernetes",
    }:
    rec {
      inherit
        name
        caCert
        CN
        hosts
        fields
        action
        ;

      cert = secret name;
      key = secret "${name}-key";

      privateKeyOptions = {
        group = privateKeyGroup;
        mode = "0600";
        owner = privateKeyOwner;
        path = key;
      };
    };

  secret = name: "${cfg.secretsPath}/${name}.pem";

  mkKubeConfigOptions = prefix: {
    caFile = lib.mkOption {
      default = cfg.caFile;
      defaultText = lib.literalExpression "config.${opt.caFile}";
      description = "${prefix} certificate authority file used to connect to kube-apiserver.";
      type = lib.types.nullOr lib.types.path;
    };

    certFile = lib.mkOption {
      default = null;
      description = "${prefix} client certificate file used to connect to kube-apiserver.";
      type = lib.types.nullOr lib.types.path;
    };

    keyFile = lib.mkOption {
      default = null;
      description = "${prefix} client key file used to connect to kube-apiserver.";
      type = lib.types.nullOr lib.types.path;
    };

    server = lib.mkOption {
      description = "${prefix} kube-apiserver server address.";
      type = lib.types.str;
    };
  };
in
{

  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "kubernetes"
      "addons"
      "dashboard"
    ] "Removed due to it being an outdated version")
    (lib.mkRemovedOptionModule [ "services" "kubernetes" "verbose" ] "")
  ];

  ###### interface

  options.services.kubernetes = {
    package = lib.mkPackageOption pkgs "kubernetes" { };

    apiserverAddress = lib.mkOption {
      description = ''
        Clusterwide accessible address for the kubernetes apiserver,
        including protocol and optional port.
      '';

      example = "https://kubernetes-apiserver.example.com:6443";
      type = lib.types.str;
    };

    caFile = lib.mkOption {
      default = null;
      description = "Default kubernetes certificate authority";
      type = lib.types.nullOr lib.types.path;
    };

    clusterCidr = lib.mkOption {
      default = "10.1.0.0/16";
      description = "Kubernetes controller manager and proxy CIDR Range for Pods in cluster.";
      type = lib.types.nullOr lib.types.str;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/kubernetes";
      description = "Kubernetes root directory for managing kubelet files.";
      type = lib.types.path;
    };

    easyCerts = lib.mkOption {
      default = false;
      description = "Automatically setup x509 certificates and keys for the entire cluster.";
      type = lib.types.bool;
    };

    featureGates = lib.mkOption {
      default = { };
      description = "List set of feature gates.";
      type = lib.types.attrsOf lib.types.bool;
    };

    kubeconfig = mkKubeConfigOptions "Default kubeconfig";

    lib = lib.mkOption {
      default = {
        inherit mkCert;
        inherit mkKubeConfig;
        inherit mkKubeConfigOptions;
      };

      description = "Common functions for the kubernetes modules.";
      type = lib.types.attrs;
    };

    masterAddress = lib.mkOption {
      description = "Clusterwide available network address or hostname for the kubernetes master server.";
      example = "master.example.com";
      type = lib.types.str;
    };

    path = lib.mkOption {
      default = [ ];
      description = "Packages added to the services' PATH environment variable. Both the bin and sbin subdirectories of each package are added.";
      type = lib.types.listOf lib.types.package;
    };

    roles = lib.mkOption {
      default = [ ];

      description = ''
        Kubernetes role that this machine should take.

        Master role will enable etcd, apiserver, scheduler, controller manager
        addon manager, flannel and proxy services.
        Node role will enable flannel, docker, kubelet and proxy services.
      '';

      type = lib.types.listOf (
        lib.types.enum [
          "master"
          "node"
        ]
      );
    };

    secretsPath = lib.mkOption {
      default = cfg.dataDir + "/secrets";

      defaultText = lib.literalExpression ''
        config.${opt.dataDir} + "/secrets"
      '';

      description = "Default location for kubernetes secrets. Not a store location.";
      type = lib.types.path;
    };
  };

  ###### implementation

  config = lib.mkMerge [

    (lib.mkIf cfg.easyCerts {
      services.kubernetes.caFile = caCert;
      services.kubernetes.pki.enable = lib.mkDefault true;
    })

    (lib.mkIf (lib.elem "master" cfg.roles) {
      services.etcd.enable = true; # Cannot mkDefault because of flannel default options
      services.kubernetes.addonManager.enable = lib.mkDefault true;
      services.kubernetes.apiserver.enable = lib.mkDefault true;
      services.kubernetes.controllerManager.enable = lib.mkDefault true;

      services.kubernetes.kubelet = {
        enable = lib.mkDefault true;

        taints = lib.mkIf (!(lib.elem "node" cfg.roles)) {
          master = {
            effect = "NoSchedule";
            key = "node-role.kubernetes.io/master";
            value = "true";
          };
        };
      };

      services.kubernetes.proxy.enable = lib.mkDefault true;
      services.kubernetes.scheduler.enable = lib.mkDefault true;
    })

    (lib.mkIf (lib.all (el: el == "master") cfg.roles) {
      # if this node is only a master make it unschedulable by default
      services.kubernetes.kubelet.unschedulable = lib.mkDefault true;
    })

    (lib.mkIf (lib.elem "node" cfg.roles) {
      services.kubernetes.kubelet.enable = lib.mkDefault true;
      services.kubernetes.proxy.enable = lib.mkDefault true;
    })

    # Using "services.kubernetes.roles" will automatically enable easyCerts and flannel
    (lib.mkIf (cfg.roles != [ ]) {
      services.flannel.etcd.endpoints = lib.mkDefault etcdEndpoints;
      services.kubernetes.easyCerts = lib.mkDefault true;
      services.kubernetes.flannel.enable = lib.mkDefault true;
    })

    (lib.mkIf cfg.apiserver.enable {
      services.kubernetes.apiserver.etcd.servers = lib.mkDefault etcdEndpoints;
      services.kubernetes.pki.etcClusterAdminKubeconfig = lib.mkDefault "kubernetes/cluster-admin.kubeconfig";
    })

    (lib.mkIf cfg.kubelet.enable {
      virtualisation.containerd = {
        enable = lib.mkDefault true;
        settings = lib.mapAttrsRecursive (name: lib.mkDefault) defaultContainerdSettings;
      };
    })

    (lib.mkIf (cfg.apiserver.enable || cfg.controllerManager.enable) {
      services.kubernetes.pki.certs = {
        serviceAccount = mkCert {
          CN = "system:service-account-signer";

          action = ''
            systemctl restart \
              kube-apiserver.service \
              kube-controller-manager.service
          '';

          name = "service-account";
        };
      };
    })

    (lib.mkIf
      (
        cfg.apiserver.enable
        || cfg.scheduler.enable
        || cfg.controllerManager.enable
        || cfg.kubelet.enable
        || cfg.proxy.enable
        || cfg.addonManager.enable
      )
      {
        # dns addon is enabled by default
        services.kubernetes.addons.dns.enable = lib.mkDefault true;

        services.kubernetes.apiserverAddress = lib.mkDefault "https://${
          if cfg.apiserver.advertiseAddress != null then
            cfg.apiserver.advertiseAddress
          else
            "${cfg.masterAddress}:${toString cfg.apiserver.securePort}"
        }";

        systemd.targets.kubernetes = {
          description = "Kubernetes";
          wantedBy = [ "multi-user.target" ];
        };

        systemd.tmpfiles.rules = [
          "d /opt/cni/bin 0755 root root -"
          "d /run/kubernetes 0755 kubernetes kubernetes -"
          "d ${cfg.dataDir} 0755 kubernetes kubernetes -"
        ];

        users.groups.kubernetes.gid = config.ids.gids.kubernetes;

        users.users.kubernetes = {
          createHome = true;
          description = "Kubernetes user";
          group = "kubernetes";
          home = cfg.dataDir;
          homeMode = "755";
          uid = config.ids.uids.kubernetes;
        };
      }
    )
  ];

  meta.buildDocsInSandbox = false;
}
