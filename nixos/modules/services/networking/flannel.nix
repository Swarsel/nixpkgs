{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.flannel;

  networkConfig =
    (lib.filterAttrs (n: v: v != null) {
      Backend = cfg.backend;
      Network = cfg.network;
      SubnetLen = cfg.subnetLen;
      SubnetMax = cfg.subnetMax;
      SubnetMin = cfg.subnetMin;
    })
    // cfg.extraNetworkConfig;
in
{
  options.services.flannel = {
    enable = lib.mkEnableOption "flannel";
    package = lib.mkPackageOption pkgs "flannel" { };

    backend = lib.mkOption {
      default = {
        Type = "vxlan";
      };

      description = "Type of backend to use and specific configurations for that backend.";
      type = lib.types.attrs;
    };

    etcd = {
      caFile = lib.mkOption {
        default = null;
        description = "Etcd certificate authority file";
        type = lib.types.nullOr lib.types.path;
      };

      certFile = lib.mkOption {
        default = null;
        description = "Etcd cert file";
        type = lib.types.nullOr lib.types.path;
      };

      endpoints = lib.mkOption {
        default = [ "http://127.0.0.1:2379" ];
        description = "Etcd endpoints";
        type = lib.types.listOf lib.types.str;
      };

      keyFile = lib.mkOption {
        default = null;
        description = "Etcd key file";
        type = lib.types.nullOr lib.types.path;
      };

      prefix = lib.mkOption {
        default = "/coreos.com/network";
        description = "Etcd key prefix";
        type = lib.types.str;
      };
    };

    extraNetworkConfig = lib.mkOption {
      default = { };
      description = "Extra configuration to be added to the net-conf.json/etcd-backed network configuration.";

      example = {
        EnableIPv6 = true;
      };

      type = (pkgs.formats.json { }).type;
    };

    iface = lib.mkOption {
      default = null;

      description = ''
        Interface to use (IP or name) for inter-host communication.
        Defaults to the interface for the default route on the machine.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    kubeconfig = lib.mkOption {
      default = null;

      description = ''
        Path to kubeconfig to use for storing flannel config using the
        Kubernetes API
      '';

      type = lib.types.nullOr lib.types.path;
    };

    network = lib.mkOption {
      description = "IPv4 network in CIDR format to use for the entire flannel network";
      type = lib.types.str;
    };

    nodeName = lib.mkOption {
      default = config.networking.fqdnOrHostName;
      defaultText = lib.literalExpression "config.networking.fqdnOrHostName";

      description = ''
        Needed when running with Kubernetes as backend as this cannot be auto-detected";
      '';

      example = "node1.example.com";
      type = lib.types.nullOr lib.types.str;
    };

    publicIp = lib.mkOption {
      default = null;

      description = ''
        IP accessible by other nodes for inter-host communication.
        Defaults to the IP of the interface being used for communication.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    storageBackend = lib.mkOption {
      default = "etcd";
      description = "Determines where flannel stores its configuration at runtime";

      type = lib.types.enum [
        "etcd"
        "kubernetes"
      ];
    };

    subnetLen = lib.mkOption {
      default = 24;

      description = ''
        The size of the subnet allocated to each host. Defaults to 24 (i.e. /24)
        unless the Network was configured to be smaller than a /24 in which case
        it is one less than the network.
      '';

      type = lib.types.int;
    };

    subnetMax = lib.mkOption {
      default = null;

      description = ''
        The end of IP range which the subnet allocation should start with.
        Defaults to the last subnet of Network.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    subnetMin = lib.mkOption {
      default = null;

      description = ''
        The beginning of IP range which the subnet allocation should start with.
        Defaults to the first subnet of Network.
      '';

      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "br_netfilter" ];

    # for some reason, flannel doesn't let you configure this path
    # see: https://github.com/coreos/flannel/blob/master/Documentation/configuration.md#configuration
    environment.etc."kube-flannel/net-conf.json" = lib.mkIf (cfg.storageBackend == "kubernetes") {
      source = pkgs.writeText "net-conf.json" (builtins.toJSON networkConfig);
    };

    services.etcd.enable = lib.mkDefault (
      cfg.storageBackend == "etcd" && cfg.etcd.endpoints == [ "http://127.0.0.1:2379" ]
    );

    systemd.services.flannel = {
      after = [ "network.target" ];
      description = "Flannel Service";

      environment = {
        FLANNELD_IFACE = cfg.iface;
        FLANNELD_PUBLIC_IP = cfg.publicIp;
      }
      // lib.optionalAttrs (cfg.storageBackend == "etcd") {
        ETCDCTL_API = "3";
        ETCDCTL_CACERT = cfg.etcd.caFile;
        ETCDCTL_CERT = cfg.etcd.certFile;
        ETCDCTL_ENDPOINTS = lib.concatStringsSep "," cfg.etcd.endpoints;
        ETCDCTL_KEY = cfg.etcd.keyFile;
        FLANNELD_ETCD_CAFILE = cfg.etcd.caFile;
        FLANNELD_ETCD_CERTFILE = cfg.etcd.certFile;
        FLANNELD_ETCD_ENDPOINTS = lib.concatStringsSep "," cfg.etcd.endpoints;
        FLANNELD_ETCD_KEYFILE = cfg.etcd.keyFile;
      }
      // lib.optionalAttrs (cfg.storageBackend == "kubernetes") {
        FLANNELD_KUBECONFIG_FILE = cfg.kubeconfig;
        FLANNELD_KUBE_SUBNET_MGR = "true";
        NODE_NAME = cfg.nodeName;
      };

      path = [ pkgs.iptables ];

      preStart = lib.optionalString (cfg.storageBackend == "etcd") ''
        echo "setting network configuration"
        until ${pkgs.etcd}/bin/etcdctl put /coreos.com/network/config '${builtins.toJSON networkConfig}'
        do
          echo "setting network configuration, retry"
          sleep 1
        done
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/flannel";
        Restart = "always";
        RestartSec = "10s";
        RuntimeDirectory = "flannel";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
