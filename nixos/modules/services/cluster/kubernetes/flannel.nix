{
  config,
  lib,
  pkgs,
  ...
}:
let
  top = config.services.kubernetes;
  cfg = top.flannel;

  # we want flannel to use kubernetes itself as configuration backend, not direct etcd
  storageBackend = "kubernetes";
in
{
  ###### interface
  options.services.kubernetes.flannel = {
    enable = lib.mkEnableOption "flannel networking";

    openFirewallPorts = lib.mkOption {
      default = true;
      description = "Whether to open the Flannel UDP ports in the firewall on all interfaces.";
      type = lib.types.bool;
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    networking = {
      dhcpcd.denyInterfaces = [
        "mynet*"
        "flannel*"
      ];

      firewall.allowedUDPPorts = lib.mkIf cfg.openFirewallPorts [
        8285 # flannel udp
        8472 # flannel vxlan
      ];
    };

    services.flannel = {

      inherit storageBackend;
      enable = lib.mkDefault true;
      network = lib.mkDefault top.clusterCidr;
      nodeName = config.services.kubernetes.kubelet.hostname;
    };

    # give flannel some kubernetes rbac permissions if applicable
    services.kubernetes.addonManager.bootstrapAddons =
      lib.mkIf ((storageBackend == "kubernetes") && (lib.elem "RBAC" top.apiserver.authorizationMode))
        {

          flannel-cr = {
            apiVersion = "rbac.authorization.k8s.io/v1";
            kind = "ClusterRole";

            metadata = {
              name = "flannel";
            };

            rules = [
              {
                apiGroups = [ "" ];
                resources = [ "pods" ];
                verbs = [ "get" ];
              }
              {
                apiGroups = [ "" ];
                resources = [ "nodes" ];

                verbs = [
                  "list"
                  "watch"
                ];
              }
              {
                apiGroups = [ "" ];
                resources = [ "nodes/status" ];
                verbs = [ "patch" ];
              }
            ];
          };

          flannel-crb = {
            apiVersion = "rbac.authorization.k8s.io/v1";
            kind = "ClusterRoleBinding";

            metadata = {
              name = "flannel";
            };

            roleRef = {
              apiGroup = "rbac.authorization.k8s.io";
              kind = "ClusterRole";
              name = "flannel";
            };

            subjects = [
              {
                kind = "User";
                name = "flannel-client";
              }
            ];
          };

        };

    services.kubernetes.kubelet = {
      cni.config = lib.mkDefault [
        {
          cniVersion = "0.3.1";

          delegate = {
            bridge = "mynet";
            hairpinMode = true;
            isDefaultGateway = true;
          };

          name = "mynet";
          type = "flannel";
        }
      ];
    };

    services.kubernetes.pki.certs = {
      flannelClient = top.lib.mkCert {
        CN = "flannel-client";
        action = "systemctl restart flannel.service";
        name = "flannel-client";
      };
    };
  };

  meta.buildDocsInSandbox = false;
}
