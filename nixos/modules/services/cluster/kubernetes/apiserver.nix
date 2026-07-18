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
  cfg = top.apiserver;

  isRBACEnabled = lib.elem "RBAC" cfg.authorizationMode;

  apiserverServiceIP = (
    lib.concatStringsSep "." (lib.take 3 (lib.splitString "." cfg.serviceClusterIpRange)) + ".1"
  );
in
{

  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "kubernetes" "apiserver" "admissionControl" ]
      [ "services" "kubernetes" "apiserver" "enableAdmissionPlugins" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubernetes" "apiserver" "address" ]
      [ "services" "kubernetes" "apiserver" "bindAddress" ]
    )
    (lib.mkRemovedOptionModule [ "services" "kubernetes" "apiserver" "insecureBindAddress" ] "")
    (lib.mkRemovedOptionModule [ "services" "kubernetes" "apiserver" "insecurePort" ] "")
    (lib.mkRemovedOptionModule [ "services" "kubernetes" "apiserver" "publicAddress" ] "")
    (lib.mkRenamedOptionModule
      [ "services" "kubernetes" "etcd" "servers" ]
      [ "services" "kubernetes" "apiserver" "etcd" "servers" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubernetes" "etcd" "keyFile" ]
      [ "services" "kubernetes" "apiserver" "etcd" "keyFile" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubernetes" "etcd" "certFile" ]
      [ "services" "kubernetes" "apiserver" "etcd" "certFile" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "kubernetes" "etcd" "caFile" ]
      [ "services" "kubernetes" "apiserver" "etcd" "caFile" ]
    )
  ];

  ###### interface
  options.services.kubernetes.apiserver =
    let
      inherit (lib.types)
        nullOr
        str
        bool
        listOf
        enum
        attrs
        path
        separatedString
        attrsOf
        int
        ;
    in
    {

      enable = lib.mkEnableOption "Kubernetes apiserver";

      advertiseAddress = lib.mkOption {
        default = null;

        description = ''
          Kubernetes apiserver IP address on which to advertise the apiserver
          to members of the cluster. This address must be reachable by the rest
          of the cluster.
        '';

        type = nullOr str;
      };

      allowPrivileged = lib.mkOption {
        default = false;
        description = "Whether to allow privileged containers on Kubernetes.";
        type = bool;
      };

      apiAudiences = lib.mkOption {
        default = "api,https://kubernetes.default.svc";

        description = ''
          Kubernetes apiserver ServiceAccount issuer.
        '';

        type = str;
      };

      authorizationMode = lib.mkOption {
        default = [
          "RBAC"
          "Node"
        ]; # Enabling RBAC by default, although kubernetes default is AllowAllow

        description = ''
          Kubernetes apiserver authorization mode (AlwaysAllow/AlwaysDeny/ABAC/Webhook/RBAC/Node). See
          <https://kubernetes.io/docs/reference/access-authn-authz/authorization/>
        '';

        type = listOf (enum [
          "AlwaysAllow"
          "AlwaysDeny"
          "ABAC"
          "Webhook"
          "RBAC"
          "Node"
        ]);
      };

      authorizationPolicy = lib.mkOption {
        default = [ ];

        description = ''
          Kubernetes apiserver authorization policy file. See
          <https://kubernetes.io/docs/reference/access-authn-authz/authorization/>
        '';

        type = listOf attrs;
      };

      basicAuthFile = lib.mkOption {
        default = null;

        description = ''
          Kubernetes apiserver basic authentication file. See
          <https://kubernetes.io/docs/reference/access-authn-authz/authentication>
        '';

        type = nullOr path;
      };

      bindAddress = lib.mkOption {
        default = "0.0.0.0";

        description = ''
          The IP address on which to listen for the --secure-port port.
          The associated interface(s) must be reachable by the rest
          of the cluster, and by CLI/web clients.
        '';

        type = str;
      };

      clientCaFile = lib.mkOption {
        default = top.caFile;
        defaultText = lib.literalExpression "config.${otop.caFile}";
        description = "Kubernetes apiserver CA file for client auth.";
        type = nullOr path;
      };

      disableAdmissionPlugins = lib.mkOption {
        default = [ ];

        description = ''
          Kubernetes admission control plugins to disable. See
          <https://kubernetes.io/docs/admin/admission-controllers/>
        '';

        type = listOf str;
      };

      enableAdmissionPlugins = lib.mkOption {
        default = [
          "NamespaceLifecycle"
          "LimitRanger"
          "ServiceAccount"
          "ResourceQuota"
          "DefaultStorageClass"
          "DefaultTolerationSeconds"
          "NodeRestriction"
        ];

        description = ''
          Kubernetes admission control plugins to enable. See
          <https://kubernetes.io/docs/admin/admission-controllers/>
        '';

        example = [
          "NamespaceLifecycle"
          "NamespaceExists"
          "LimitRanger"
          "SecurityContextDeny"
          "ServiceAccount"
          "ResourceQuota"
          "PodSecurityPolicy"
          "NodeRestriction"
          "DefaultStorageClass"
        ];

        type = listOf str;
      };

      etcd = {
        caFile = lib.mkOption {
          default = top.caFile;
          defaultText = lib.literalExpression "config.${otop.caFile}";
          description = "Etcd ca file.";
          type = nullOr path;
        };

        certFile = lib.mkOption {
          default = null;
          description = "Etcd cert file.";
          type = nullOr path;
        };

        keyFile = lib.mkOption {
          default = null;
          description = "Etcd key file.";
          type = nullOr path;
        };

        servers = lib.mkOption {
          default = [ "http://127.0.0.1:2379" ];
          description = "List of etcd servers.";
          type = listOf str;
        };
      };

      extraOpts = lib.mkOption {
        default = "";
        description = "Kubernetes apiserver extra command line options.";
        type = separatedString " ";
      };

      extraSANs = lib.mkOption {
        default = [ ];
        description = "Extra x509 Subject Alternative Names to be added to the kubernetes apiserver tls cert.";
        type = listOf str;
      };

      featureGates = lib.mkOption {
        default = top.featureGates;
        defaultText = lib.literalExpression "config.${otop.featureGates}";
        description = "Attribute set of feature gates.";
        type = attrsOf bool;
      };

      kubeletClientCaFile = lib.mkOption {
        default = top.caFile;
        defaultText = lib.literalExpression "config.${otop.caFile}";
        description = "Path to a cert file for connecting to kubelet.";
        type = nullOr path;
      };

      kubeletClientCertFile = lib.mkOption {
        default = null;
        description = "Client certificate to use for connections to kubelet.";
        type = nullOr path;
      };

      kubeletClientKeyFile = lib.mkOption {
        default = null;
        description = "Key to use for connections to kubelet.";
        type = nullOr path;
      };

      preferredAddressTypes = lib.mkOption {
        default = null;
        description = "List of the preferred NodeAddressTypes to use for kubelet connections.";
        type = nullOr str;
      };

      proxyClientCertFile = lib.mkOption {
        default = null;
        description = "Client certificate to use for connections to proxy.";
        type = nullOr path;
      };

      proxyClientKeyFile = lib.mkOption {
        default = null;
        description = "Key to use for connections to proxy.";
        type = nullOr path;
      };

      runtimeConfig = lib.mkOption {
        default = "authentication.k8s.io/v1beta1=true";

        description = ''
          Api runtime configuration. See
          <https://kubernetes.io/docs/tasks/administer-cluster/cluster-management/>
        '';

        example = "api/all=false,api/v1=true";
        type = str;
      };

      securePort = lib.mkOption {
        default = 6443;
        description = "Kubernetes apiserver secure port.";
        type = int;
      };

      serviceAccountIssuer = lib.mkOption {
        default = "https://kubernetes.default.svc";

        description = ''
          Kubernetes apiserver ServiceAccount issuer.
        '';

        type = str;
      };

      serviceAccountKeyFile = lib.mkOption {
        description = ''
          File containing PEM-encoded x509 RSA or ECDSA private or public keys,
          used to verify ServiceAccount tokens. The specified file can contain
          multiple keys, and the flag can be specified multiple times with
          different files. If unspecified, --tls-private-key-file is used.
          Must be specified when --service-account-signing-key is provided
        '';

        type = path;
      };

      serviceAccountSigningKeyFile = lib.mkOption {
        description = ''
          Path to the file that contains the current private key of the service
          account token issuer. The issuer will sign issued ID tokens with this
          private key.
        '';

        type = path;
      };

      serviceClusterIpRange = lib.mkOption {
        default = "10.0.0.0/24";

        description = ''
          A CIDR notation IP range from which to assign service cluster IPs.
          This must not overlap with any IP ranges assigned to nodes for pods.
        '';

        type = str;
      };

      storageBackend = lib.mkOption {
        default = "etcd3";

        description = ''
          Kubernetes apiserver storage backend.
        '';

        type = enum [
          "etcd2"
          "etcd3"
        ];
      };

      tlsCertFile = lib.mkOption {
        default = null;
        description = "Kubernetes apiserver certificate file.";
        type = nullOr path;
      };

      tlsKeyFile = lib.mkOption {
        default = null;
        description = "Kubernetes apiserver private key file.";
        type = nullOr path;
      };

      tokenAuthFile = lib.mkOption {
        default = null;

        description = ''
          Kubernetes apiserver token authentication file. See
          <https://kubernetes.io/docs/reference/access-authn-authz/authentication>
        '';

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

      webhookConfig = lib.mkOption {
        default = null;

        description = ''
          Kubernetes apiserver Webhook config file. It uses the kubeconfig file format.
          See <https://kubernetes.io/docs/reference/access-authn-authz/webhook/>
        '';

        type = nullOr path;
      };

    };

  ###### implementation
  config = lib.mkMerge [

    (lib.mkIf cfg.enable {
      services.etcd = {
        advertiseClientUrls = lib.mkDefault [ "https://${top.masterAddress}:2379" ];
        clientCertAuth = lib.mkDefault true;
        initialAdvertisePeerUrls = lib.mkDefault [ "https://${top.masterAddress}:2380" ];
        initialCluster = lib.mkDefault [ "${top.masterAddress}=https://${top.masterAddress}:2380" ];
        listenClientUrls = lib.mkDefault [ "https://0.0.0.0:2379" ];
        listenPeerUrls = lib.mkDefault [ "https://0.0.0.0:2380" ];
        name = lib.mkDefault top.masterAddress;
        peerClientCertAuth = lib.mkDefault true;
      };

      services.kubernetes.addonManager.bootstrapAddons = lib.mkIf isRBACEnabled {

        apiserver-kubelet-api-admin-crb = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRoleBinding";

          metadata = {
            name = "system:kube-apiserver:kubelet-api-admin";
          };

          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            name = "system:kubelet-api-admin";
          };

          subjects = [
            {
              kind = "User";
              name = "system:kube-apiserver";
            }
          ];
        };

      };

      services.kubernetes.pki.certs = with top.lib; {
        apiServer = mkCert {
          CN = "kubernetes";
          action = "systemctl restart kube-apiserver.service";

          hosts = [
            "kubernetes.default.svc"
            "kubernetes.default.svc.${top.addons.dns.clusterDomain}"
            cfg.advertiseAddress
            top.masterAddress
            apiserverServiceIP
            "127.0.0.1"
          ]
          ++ cfg.extraSANs;

          name = "kube-apiserver";
        };

        apiserverEtcdClient = mkCert {
          CN = "etcd-client";
          action = "systemctl restart kube-apiserver.service";
          name = "kube-apiserver-etcd-client";
        };

        apiserverKubeletClient = mkCert {
          CN = "system:kube-apiserver";
          action = "systemctl restart kube-apiserver.service";
          name = "kube-apiserver-kubelet-client";
        };

        apiserverProxyClient = mkCert {
          CN = "front-proxy-client";
          action = "systemctl restart kube-apiserver.service";
          name = "kube-apiserver-proxy-client";
        };

        clusterAdmin = mkCert {
          CN = "cluster-admin";

          fields = {
            O = "system:masters";
          };

          name = "cluster-admin";
          privateKeyOwner = "root";
        };

        etcd = mkCert {
          CN = top.masterAddress;
          action = "systemctl restart etcd.service";

          hosts = [
            "etcd.local"
            "etcd.${top.addons.dns.clusterDomain}"
            top.masterAddress
            cfg.advertiseAddress
          ];

          name = "etcd";
          privateKeyOwner = "etcd";
        };
      };

      systemd.services.kube-apiserver = {
        after = [ "network.target" ];
        description = "Kubernetes APIServer Service";

        serviceConfig = {
          AmbientCapabilities = "cap_net_bind_service";

          ExecStart = ''
            ${top.package}/bin/kube-apiserver \
            --allow-privileged=${lib.boolToString cfg.allowPrivileged} \
            --authorization-mode=${lib.concatStringsSep "," cfg.authorizationMode} \
              ${lib.optionalString (lib.elem "ABAC" cfg.authorizationMode) "--authorization-policy-file=${pkgs.writeText "kube-auth-policy.jsonl" (lib.concatMapStringsSep "\n" (l: builtins.toJSON l) cfg.authorizationPolicy)}"} \
              ${lib.optionalString (lib.elem "Webhook" cfg.authorizationMode) "--authorization-webhook-config-file=${cfg.webhookConfig}"} \
            --bind-address=${cfg.bindAddress} \
            ${lib.optionalString (cfg.advertiseAddress != null) "--advertise-address=${cfg.advertiseAddress}"} \
            ${lib.optionalString (cfg.clientCaFile != null) "--client-ca-file=${cfg.clientCaFile}"} \
            --disable-admission-plugins=${lib.concatStringsSep "," cfg.disableAdmissionPlugins} \
            --enable-admission-plugins=${lib.concatStringsSep "," cfg.enableAdmissionPlugins} \
            --etcd-servers=${lib.concatStringsSep "," cfg.etcd.servers} \
            ${lib.optionalString (cfg.etcd.caFile != null) "--etcd-cafile=${cfg.etcd.caFile}"} \
            ${lib.optionalString (cfg.etcd.certFile != null) "--etcd-certfile=${cfg.etcd.certFile}"} \
            ${lib.optionalString (cfg.etcd.keyFile != null) "--etcd-keyfile=${cfg.etcd.keyFile}"} \
            ${
              lib.optionalString (cfg.featureGates != { })
                "--feature-gates=${
                  (lib.concatStringsSep "," (
                    builtins.attrValues (lib.mapAttrs (n: v: "${n}=${lib.trivial.boolToString v}") cfg.featureGates)
                  ))
                }"
            } \
            ${lib.optionalString (cfg.basicAuthFile != null) "--basic-auth-file=${cfg.basicAuthFile}"} \
            ${
              lib.optionalString (
                cfg.kubeletClientCaFile != null
              ) "--kubelet-certificate-authority=${cfg.kubeletClientCaFile}"
            } \
            ${
              lib.optionalString (
                cfg.kubeletClientCertFile != null
              ) "--kubelet-client-certificate=${cfg.kubeletClientCertFile}"
            } \
            ${
              lib.optionalString (
                cfg.kubeletClientKeyFile != null
              ) "--kubelet-client-key=${cfg.kubeletClientKeyFile}"
            } \
            ${
              lib.optionalString (
                cfg.preferredAddressTypes != null
              ) "--kubelet-preferred-address-types=${cfg.preferredAddressTypes}"
            } \
            ${
              lib.optionalString (
                cfg.proxyClientCertFile != null
              ) "--proxy-client-cert-file=${cfg.proxyClientCertFile}"
            } \
            ${
              lib.optionalString (
                cfg.proxyClientKeyFile != null
              ) "--proxy-client-key-file=${cfg.proxyClientKeyFile}"
            } \
            ${lib.optionalString (cfg.runtimeConfig != "") "--runtime-config=${cfg.runtimeConfig}"} \
            --secure-port=${toString cfg.securePort} \
            --api-audiences=${toString cfg.apiAudiences} \
            --service-account-issuer=${toString cfg.serviceAccountIssuer} \
            --service-account-signing-key-file=${cfg.serviceAccountSigningKeyFile} \
            --service-account-key-file=${cfg.serviceAccountKeyFile} \
            --service-cluster-ip-range=${cfg.serviceClusterIpRange} \
            --storage-backend=${cfg.storageBackend} \
            ${lib.optionalString (cfg.tlsCertFile != null) "--tls-cert-file=${cfg.tlsCertFile}"} \
            ${lib.optionalString (cfg.tlsKeyFile != null) "--tls-private-key-file=${cfg.tlsKeyFile}"} \
            ${lib.optionalString (cfg.tokenAuthFile != null) "--token-auth-file=${cfg.tokenAuthFile}"} \
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

    })

  ];

  meta.buildDocsInSandbox = false;
}
