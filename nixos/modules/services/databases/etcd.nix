{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.etcd;
  opt = options.services.etcd;

in
{

  options.services.etcd = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable etcd.";
      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "etcd" { };

    advertiseClientUrls = lib.mkOption {
      default = cfg.listenClientUrls;
      defaultText = lib.literalExpression "config.${opt.listenClientUrls}";
      description = "Etcd list of this member's client URLs to advertise to the rest of the cluster.";
      type = lib.types.listOf lib.types.str;
    };

    certFile = lib.mkOption {
      default = null;
      description = "Cert file to use for clients";
      type = lib.types.nullOr lib.types.path;
    };

    clientCertAuth = lib.mkOption {
      default = false;
      description = "Whether to use certs for client authentication";
      type = lib.types.bool;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/etcd";
      description = "Etcd data directory.";
      type = lib.types.path;
    };

    discovery = lib.mkOption {
      default = "";
      description = "Etcd discovery url";
      type = lib.types.str;
    };

    extraConf = lib.mkOption {
      default = { };

      description = ''
        Etcd extra configuration. See
        <https://github.com/coreos/etcd/blob/master/Documentation/op-guide/configuration.md#configuration-flags>
      '';

      example = lib.literalExpression ''
        {
          "CORS" = "*";
          "NAME" = "default-name";
          "MAX_RESULT_BUFFER" = "1024";
          "MAX_CLUSTER_SIZE" = "9";
          "MAX_RETRY_ATTEMPTS" = "3";
        }
      '';

      type = lib.types.attrsOf lib.types.str;
    };

    initialAdvertisePeerUrls = lib.mkOption {
      default = cfg.listenPeerUrls;
      defaultText = lib.literalExpression "config.${opt.listenPeerUrls}";
      description = "Etcd list of this member's peer URLs to advertise to rest of the cluster.";
      type = lib.types.listOf lib.types.str;
    };

    initialCluster = lib.mkOption {
      default = [ "${cfg.name}=http://127.0.0.1:2380" ];
      defaultText = lib.literalExpression ''["''${config.${opt.name}}=http://127.0.0.1:2380"]'';
      description = "Etcd initial cluster configuration for bootstrapping.";
      type = lib.types.listOf lib.types.str;
    };

    initialClusterState = lib.mkOption {
      default = "new";
      description = "Etcd initial cluster configuration for bootstrapping.";

      type = lib.types.enum [
        "new"
        "existing"
      ];
    };

    initialClusterToken = lib.mkOption {
      default = "etcd-cluster";
      description = "Etcd initial cluster token for etcd cluster during bootstrap.";
      type = lib.types.str;
    };

    keyFile = lib.mkOption {
      default = null;
      description = "Key file to use for clients";
      type = lib.types.nullOr lib.types.path;
    };

    listenClientUrls = lib.mkOption {
      default = [ "http://127.0.0.1:2379" ];
      description = "Etcd list of URLs to listen on for client traffic.";
      type = lib.types.listOf lib.types.str;
    };

    listenPeerUrls = lib.mkOption {
      default = [ "http://127.0.0.1:2380" ];
      description = "Etcd list of URLs to listen on for peer traffic.";
      type = lib.types.listOf lib.types.str;
    };

    name = lib.mkOption {
      default = config.networking.hostName;
      defaultText = lib.literalExpression "config.networking.hostName";
      description = "Etcd unique node name.";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open etcd ports in the firewall.
        Ports opened:
        - 2379/tcp for client requests
        - 2380/tcp for peer communication
      '';

      type = lib.types.bool;
    };

    peerCertFile = lib.mkOption {
      default = cfg.certFile;
      defaultText = lib.literalExpression "config.${opt.certFile}";
      description = "Cert file to use for peer to peer communication";
      type = lib.types.nullOr lib.types.path;
    };

    peerClientCertAuth = lib.mkOption {
      default = false;
      description = "Whether to check all incoming peer requests from the cluster for valid client certificates signed by the supplied CA";
      type = lib.types.bool;
    };

    peerKeyFile = lib.mkOption {
      default = cfg.keyFile;
      defaultText = lib.literalExpression "config.${opt.keyFile}";
      description = "Key file to use for peer to peer communication";
      type = lib.types.nullOr lib.types.path;
    };

    peerTrustedCaFile = lib.mkOption {
      default = cfg.trustedCaFile;
      defaultText = lib.literalExpression "config.${opt.trustedCaFile}";
      description = "Certificate authority file to use for peer to peer communication";
      type = lib.types.nullOr lib.types.path;
    };

    trustedCaFile = lib.mkOption {
      default = null;
      description = "Certificate authority file to use for clients";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        2379 # for client requests
        2380 # for peer communication
      ];
    };

    systemd.services.etcd = {
      after = [
        "network-online.target"
      ]
      ++ lib.optional config.networking.firewall.enable "firewall.service";

      description = "etcd key-value store";

      environment =
        (lib.filterAttrs (n: v: v != null) {
          ETCD_ADVERTISE_CLIENT_URLS = lib.concatStringsSep "," cfg.advertiseClientUrls;
          ETCD_CERT_FILE = cfg.certFile;
          ETCD_CLIENT_CERT_AUTH = toString cfg.clientCertAuth;
          ETCD_DATA_DIR = cfg.dataDir;
          ETCD_DISCOVERY = cfg.discovery;
          ETCD_INITIAL_ADVERTISE_PEER_URLS = lib.concatStringsSep "," cfg.initialAdvertisePeerUrls;
          ETCD_KEY_FILE = cfg.keyFile;
          ETCD_LISTEN_CLIENT_URLS = lib.concatStringsSep "," cfg.listenClientUrls;
          ETCD_LISTEN_PEER_URLS = lib.concatStringsSep "," cfg.listenPeerUrls;
          ETCD_NAME = cfg.name;
          ETCD_PEER_CERT_FILE = cfg.peerCertFile;
          ETCD_PEER_CLIENT_CERT_AUTH = toString cfg.peerClientCertAuth;
          ETCD_PEER_KEY_FILE = cfg.peerKeyFile;
          ETCD_PEER_TRUSTED_CA_FILE = cfg.peerTrustedCaFile;
          ETCD_TRUSTED_CA_FILE = cfg.trustedCaFile;
        })
        // (lib.optionalAttrs (cfg.discovery == "") {
          ETCD_INITIAL_CLUSTER = lib.concatStringsSep "," cfg.initialCluster;
          ETCD_INITIAL_CLUSTER_STATE = cfg.initialClusterState;
          ETCD_INITIAL_CLUSTER_TOKEN = cfg.initialClusterToken;
        })
        // (lib.mapAttrs' (n: v: lib.nameValuePair "ETCD_${n}" v) cfg.extraConf);

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/etcd";
        LimitNOFILE = 40000;
        Restart = "always";
        RestartSec = "30s";
        Type = "notify";
        User = "etcd";
      };

      unitConfig = {
        Documentation = "https://github.com/coreos/etcd";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
      ]
      ++ lib.optional config.networking.firewall.enable "firewall.service";
    };

    systemd.tmpfiles.settings."10-etcd".${cfg.dataDir}.d = {
      mode = "0700";
      user = "etcd";
    };

    users.groups.etcd = { };

    users.users.etcd = {
      description = "Etcd daemon user";
      group = "etcd";
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };

  meta.maintainers = pkgs.etcd.meta.maintainers;

}
