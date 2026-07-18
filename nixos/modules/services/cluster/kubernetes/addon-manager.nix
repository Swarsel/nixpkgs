{
  config,
  lib,
  pkgs,
  ...
}:
let
  top = config.services.kubernetes;
  cfg = top.addonManager;

  isRBACEnabled = lib.elem "RBAC" top.apiserver.authorizationMode;

  addons = pkgs.runCommand "kubernetes-addons" { } ''
    mkdir -p $out
    # since we are mounting the addons to the addon manager, they need to be copied
    ${lib.concatMapStringsSep ";" (a: "cp -v ${a}/* $out/") (
      lib.mapAttrsToList (name: addon: pkgs.writeTextDir "${name}.json" (builtins.toJSON addon)) (
        cfg.addons
      )
    )}
  '';
in
{
  ###### interface
  options.services.kubernetes.addonManager = with lib.types; {

    enable = lib.mkEnableOption "Kubernetes addon manager";

    addons = lib.mkOption {
      default = { };
      description = "Kubernetes addons (any kind of Kubernetes resource can be an addon).";

      example = lib.literalExpression ''
        {
          "my-service" = {
            "apiVersion" = "v1";
            "kind" = "Service";
            "metadata" = {
              "name" = "my-service";
              "namespace" = "default";
            };
            "spec" = { ... };
          };
        }
        // import <nixpkgs/nixos/modules/services/cluster/kubernetes/dns.nix> { cfg = config.services.kubernetes; };
      '';

      type = attrsOf (either attrs (listOf attrs));
    };

    bootstrapAddons = lib.mkOption {
      default = { };

      description = ''
        Bootstrap addons are like regular addons, but they are applied with cluster-admin rights.
        They are applied at addon-manager startup only.
      '';

      example = lib.literalExpression ''
        {
          "my-service" = {
            "apiVersion" = "v1";
            "kind" = "Service";
            "metadata" = {
              "name" = "my-service";
              "namespace" = "default";
            };
            "spec" = { ... };
          };
        }
      '';

      type = attrsOf attrs;
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    environment.etc."kubernetes/addons".source = "${addons}/";

    services.kubernetes.addonManager.bootstrapAddons = lib.mkIf isRBACEnabled (
      let
        name = "system:kube-addon-manager";
        namespace = "kube-system";
      in
      {

        kube-addon-manager-cluster-lister-cr = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRole";

          metadata = {
            name = "${name}:cluster-lister";
          };

          rules = [
            {
              apiGroups = [ "*" ];
              resources = [ "*" ];
              verbs = [ "list" ];
            }
          ];
        };

        kube-addon-manager-cluster-lister-crb = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRoleBinding";

          metadata = {
            name = "${name}:cluster-lister";
          };

          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            name = "${name}:cluster-lister";
          };

          subjects = [
            {
              inherit name;
              kind = "User";
            }
          ];
        };

        kube-addon-manager-r = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "Role";

          metadata = {
            inherit name namespace;
          };

          rules = [
            {
              apiGroups = [ "*" ];
              resources = [ "*" ];
              verbs = [ "*" ];
            }
          ];
        };

        kube-addon-manager-rb = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "RoleBinding";

          metadata = {
            inherit name namespace;
          };

          roleRef = {
            inherit name;
            apiGroup = "rbac.authorization.k8s.io";
            kind = "Role";
          };

          subjects = [
            {
              inherit name;
              apiGroup = "rbac.authorization.k8s.io";
              kind = "User";
            }
          ];
        };
      }
    );

    services.kubernetes.pki.certs = {
      addonManager = top.lib.mkCert {
        CN = "system:kube-addon-manager";
        action = "systemctl restart kube-addon-manager.service";
        name = "kube-addon-manager";
      };
    };

    systemd.services.kube-addon-manager = {
      after = [ "kube-apiserver.service" ];
      description = "Kubernetes addon manager";
      environment.ADDON_PATH = "/etc/kubernetes/addons/";
      path = [ pkgs.gawk ];

      serviceConfig = {
        ExecStart = "${top.package}/bin/kube-addons";
        Group = "kubernetes";
        Restart = "on-failure";
        RestartSec = 10;
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
