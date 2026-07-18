{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  top = config.services.kubernetes;
  cfg = top.pki;

  csrCA = pkgs.writeText "kube-pki-cacert-csr.json" (
    builtins.toJSON {
      key = {
        algo = "rsa";
        size = 2048;
      };

      names = singleton cfg.caSpec;
    }
  );

  csrCfssl = pkgs.writeText "kube-pki-cfssl-csr.json" (
    builtins.toJSON {
      CN = top.masterAddress;
      hosts = [ top.masterAddress ] ++ cfg.cfsslAPIExtraSANs;

      key = {
        algo = "rsa";
        size = 2048;
      };
    }
  );

  cfsslAPITokenBaseName = "apitoken.secret";
  cfsslAPITokenPath = "${config.services.cfssl.dataDir}/${cfsslAPITokenBaseName}";
  certmgrAPITokenPath = "${top.secretsPath}/${cfsslAPITokenBaseName}";
  cfsslAPITokenLength = 32;

  clusterAdminKubeconfig =
    with cfg.certs.clusterAdmin;
    top.lib.mkKubeConfig "cluster-admin" {
      certFile = cert;
      keyFile = key;
      server = top.apiserverAddress;
    };

  remote = with config.services; "https://${kubernetes.masterAddress}:${toString cfssl.port}";
in
{
  ###### interface
  options.services.kubernetes.pki = with lib.types; {

    enable = mkEnableOption "easyCert issuer service";

    caCertPathPrefix = mkOption {
      default = "${config.services.cfssl.dataDir}/ca";
      defaultText = literalExpression ''"''${config.services.cfssl.dataDir}/ca"'';

      description = ''
        Path-prefrix for the CA-certificate to be used for cfssl signing.
        Suffixes ".pem" and "-key.pem" will be automatically appended for
        the public and private keys respectively.
      '';

      type = str;
    };

    caSpec = mkOption {
      default = {
        CN = "kubernetes-cluster-ca";
        L = "auto-generated";
        O = "NixOS";
        OU = "services.kubernetes.pki.caSpec";
      };

      description = "Certificate specification for the auto-generated CAcert.";
      type = attrs;
    };

    certs = mkOption {
      default = { };
      description = "List of certificate specs to feed to cert generator.";
      type = attrs;
    };

    cfsslAPIExtraSANs = mkOption {
      default = [ ];

      description = ''
        Extra x509 Subject Alternative Names to be added to the cfssl API webserver TLS cert.
      '';

      example = [ "subdomain.example.com" ];
      type = listOf str;
    };

    etcClusterAdminKubeconfig = mkOption {
      default = null;

      description = ''
        Symlink a kubeconfig with cluster-admin privileges to environment path
        (/etc/\<path\>).
      '';

      type = nullOr str;
    };

    genCfsslAPICerts = mkOption {
      default = true;

      description = ''
        Whether to automatically generate cfssl API webserver TLS cert and key,
        if they don't exist.
      '';

      type = bool;
    };

    genCfsslAPIToken = mkOption {
      default = true;

      description = ''
        Whether to automatically generate cfssl API-token secret,
        if they doesn't exist.
      '';

      type = bool;
    };

    genCfsslCACert = mkOption {
      default = true;

      description = ''
        Whether to automatically generate cfssl CA certificate and key,
        if they don't exist.
      '';

      type = bool;
    };

    pkiTrustOnBootstrap = mkOption {
      default = true;
      description = "Whether to always trust remote cfssl server upon initial PKI bootstrap.";
      type = bool;
    };

  };

  ###### implementation
  config = mkIf cfg.enable (
    let
      cfsslCertPathPrefix = "${config.services.cfssl.dataDir}/cfssl";
      cfsslCert = "${cfsslCertPathPrefix}.pem";
      cfsslKey = "${cfsslCertPathPrefix}-key.pem";
    in
    {

      environment.etc.${cfg.etcClusterAdminKubeconfig}.source = mkIf (
        cfg.etcClusterAdminKubeconfig != null
      ) clusterAdminKubeconfig;

      environment.systemPackages = mkIf (top.kubelet.enable || top.proxy.enable) [
        (pkgs.writeScriptBin "nixos-kubernetes-node-join" ''
          set -e
          exec 1>&2

          if [ $# -gt 0 ]; then
            echo "Usage: $(basename $0)"
            echo ""
            echo "No args. Apitoken must be provided on stdin."
            echo "To get the apitoken, execute: 'sudo cat ${certmgrAPITokenPath}' on the master node."
            exit 1
          fi

          if [ $(id -u) != 0 ]; then
            echo "Run as root please."
            exit 1
          fi

          read -r token
          if [ ''${#token} != ${toString cfsslAPITokenLength} ]; then
            echo "Token must be of length ${toString cfsslAPITokenLength}."
            exit 1
          fi

          install -m 0600 <(echo $token) ${certmgrAPITokenPath}

          echo "Restarting certmgr..." >&1
          systemctl restart certmgr

          echo "Waiting for certs to appear..." >&1

          ${optionalString top.kubelet.enable ''
            while [ ! -f ${cfg.certs.kubelet.cert} ]; do sleep 1; done
            echo "Restarting kubelet..." >&1
            systemctl restart kubelet
          ''}

          ${optionalString top.proxy.enable ''
            while [ ! -f ${cfg.certs.kubeProxyClient.cert} ]; do sleep 1; done
            echo "Restarting kube-proxy..." >&1
            systemctl restart kube-proxy
          ''}

          ${optionalString top.flannel.enable ''
            while [ ! -f ${cfg.certs.flannelClient.cert} ]; do sleep 1; done
            echo "Restarting flannel..." >&1
            systemctl restart flannel
          ''}

          echo "Node joined successfully"
        '')
      ];

      networking.extraHosts = mkIf (config.services.etcd.enable) ''
        127.0.0.1 etcd.${top.addons.dns.clusterDomain} etcd.local
      '';

      services.certmgr = {
        enable = true;
        package = pkgs.certmgr;

        specs =
          let
            mkSpec = _: cert: {
              inherit (cert) action;

              authority = {
                inherit remote;
                auth_key_file = certmgrAPITokenPath;
                profile = "default";
                root_ca = cert.caCert;
              };

              certificate = {
                path = cert.cert;
              };

              private_key = cert.privateKeyOptions;

              request = {
                inherit (cert) CN;
                hosts = [ cert.CN ] ++ cert.hosts;

                key = {
                  algo = "rsa";
                  size = 2048;
                };

                names = [ cert.fields ];
              };
            };
          in
          mapAttrs mkSpec cfg.certs;

        svcManager = "command";
      };

      services.cfssl = mkIf (top.apiserver.enable) {
        enable = true;
        address = "0.0.0.0";

        configFile = toString (
          pkgs.writeText "cfssl-config.json" (
            builtins.toJSON {
              auth_keys = {
                default = {
                  key = "file:${cfsslAPITokenPath}";
                  type = "standard";
                };
              };

              signing = {
                profiles = {
                  default = {
                    auth_key = "default";
                    expiry = "720h";
                    usages = [ "digital signature" ];
                  };
                };
              };
            }
          )
        );

        tlsCert = cfsslCert;
        tlsKey = cfsslKey;
      };

      # isolate etcd on loopback at the master node
      # easyCerts doesn't support multimaster clusters anyway atm.
      services.etcd = with cfg.certs.etcd; {
        advertiseClientUrls = [ "https://etcd.local:2379" ];
        certFile = mkDefault cert;
        initialAdvertisePeerUrls = [ "https://etcd.local:2380" ];
        initialCluster = [ "${top.masterAddress}=https://etcd.local:2380" ];
        keyFile = mkDefault key;
        listenClientUrls = [ "https://127.0.0.1:2379" ];
        listenPeerUrls = [ "https://127.0.0.1:2380" ];
        trustedCaFile = mkDefault caCert;
      };

      services.flannel = with cfg.certs.flannelClient; {
        kubeconfig = top.lib.mkKubeConfig "flannel" {
          certFile = cert;
          keyFile = key;
          server = top.apiserverAddress;
        };
      };

      services.kubernetes = {

        apiserver = mkIf top.apiserver.enable (
          with cfg.certs.apiServer;
          {
            clientCaFile = mkDefault caCert;

            etcd = with cfg.certs.apiserverEtcdClient; {
              caFile = mkDefault caCert;
              certFile = mkDefault cert;
              keyFile = mkDefault key;
              servers = [ "https://etcd.local:2379" ];
            };

            kubeletClientCaFile = mkDefault caCert;
            kubeletClientCertFile = mkDefault cfg.certs.apiserverKubeletClient.cert;
            kubeletClientKeyFile = mkDefault cfg.certs.apiserverKubeletClient.key;
            proxyClientCertFile = mkDefault cfg.certs.apiserverProxyClient.cert;
            proxyClientKeyFile = mkDefault cfg.certs.apiserverProxyClient.key;
            serviceAccountKeyFile = mkDefault cfg.certs.serviceAccount.cert;
            serviceAccountSigningKeyFile = mkDefault cfg.certs.serviceAccount.key;
            tlsCertFile = mkDefault cert;
            tlsKeyFile = mkDefault key;
          }
        );

        controllerManager = mkIf top.controllerManager.enable {
          kubeconfig = with cfg.certs.controllerManagerClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
          };

          rootCaFile = cfg.certs.controllerManagerClient.caCert;
          serviceAccountKeyFile = mkDefault cfg.certs.serviceAccount.key;
        };

        kubelet = mkIf top.kubelet.enable {
          clientCaFile = mkDefault cfg.certs.kubelet.caCert;

          kubeconfig = with cfg.certs.kubeletClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
          };

          tlsCertFile = mkDefault cfg.certs.kubelet.cert;
          tlsKeyFile = mkDefault cfg.certs.kubelet.key;
        };

        proxy = mkIf top.proxy.enable {
          kubeconfig = with cfg.certs.kubeProxyClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
          };
        };

        scheduler = mkIf top.scheduler.enable {
          kubeconfig = with cfg.certs.schedulerClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
          };
        };
      };

      systemd.services.cfssl.preStart =
        with pkgs;
        with config.services.cfssl;
        mkIf (top.apiserver.enable) (
          concatStringsSep "\n" [
            "set -e"
            (optionalString cfg.genCfsslCACert ''
              if [ ! -f "${cfg.caCertPathPrefix}.pem" ]; then
                ${cfssl}/bin/cfssl genkey -initca ${csrCA} | \
                  ${cfssl}/bin/cfssljson -bare ${cfg.caCertPathPrefix}
              fi
            '')
            (optionalString cfg.genCfsslAPICerts ''
              if [ ! -f "${dataDir}/cfssl.pem" ]; then
                ${cfssl}/bin/cfssl gencert -ca "${cfg.caCertPathPrefix}.pem" -ca-key "${cfg.caCertPathPrefix}-key.pem" ${csrCfssl} | \
                  ${cfssl}/bin/cfssljson -bare ${cfsslCertPathPrefix}
              fi
            '')
            (optionalString cfg.genCfsslAPIToken ''
              if [ ! -f "${cfsslAPITokenPath}" ]; then
                install -o cfssl -m 400 <(head -c ${
                  toString (cfsslAPITokenLength / 2)
                } /dev/urandom | od -An -t x | tr -d ' ') "${cfsslAPITokenPath}"
              fi
            '')
          ]
        );

      #TODO: Get rid of kube-addon-manager in the future for the following reasons
      # - it is basically just a shell script wrapped around kubectl
      # - it assumes that it is clusterAdmin or can gain clusterAdmin rights through serviceAccount
      # - it is designed to be used with k8s system components only
      # - it would be better with a more Nix-oriented way of managing addons
      systemd.services.kube-addon-manager = mkIf top.addonManager.enable (mkMerge [
        {
          environment.KUBECONFIG =
            with cfg.certs.addonManager;
            top.lib.mkKubeConfig "addon-manager" {
              certFile = cert;
              keyFile = key;
              server = top.apiserverAddress;
            };
        }

        (optionalAttrs (top.addonManager.bootstrapAddons != { }) {
          preStart =
            with pkgs;
            let
              files = mapAttrsToList (
                n: v: writeText "${n}.json" (builtins.toJSON v)
              ) top.addonManager.bootstrapAddons;
            in
            ''
              export KUBECONFIG=${clusterAdminKubeconfig}
              ${top.package}/bin/kubectl apply -f ${concatStringsSep " \\\n -f " files}
            '';

          serviceConfig.PermissionsStartOnly = true;
        })
      ]);

      systemd.services.kube-certmgr-bootstrap = {
        after = [ "cfssl.target" ];
        description = "Kubernetes certmgr bootstrapper";

        script = concatStringsSep "\n" [
          ''
            set -e

            # If there's a cfssl (cert issuer) running locally, then don't rely on user to
            # manually paste it in place. Just symlink.
            # otherwise, create the target file, ready for users to insert the token

            mkdir -p "$(dirname "${certmgrAPITokenPath}")"
            if [ -f "${cfsslAPITokenPath}" ]; then
              ln -fs "${cfsslAPITokenPath}" "${certmgrAPITokenPath}"
            elif [ ! -f "${certmgrAPITokenPath}" ]; then
              # Don't remove the token if it already exists
              install -m 600 /dev/null "${certmgrAPITokenPath}"
            fi
          ''
          (optionalString (cfg.pkiTrustOnBootstrap) ''
            if [ ! -f "${top.caFile}" ] || [ $(cat "${top.caFile}" | wc -c) -lt 1 ]; then
              ${pkgs.curl}/bin/curl --fail-early -f -kd '{}' ${remote}/api/v1/cfssl/info | \
                ${pkgs.cfssl}/bin/cfssljson -stdout >${top.caFile}
            fi
          '')
        ];

        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };

        wantedBy = [ "certmgr.service" ];
      };
    }
  );

  meta.buildDocsInSandbox = false;
}
