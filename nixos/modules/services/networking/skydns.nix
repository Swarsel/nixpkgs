{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.skydns;

in
{
  options.services.skydns = {
    enable = mkEnableOption "skydns service";
    package = mkPackageOption pkgs "skydns" { };

    address = mkOption {
      default = "0.0.0.0:53";
      description = "Skydns address to bind to.";
      type = types.str;
    };

    domain = mkOption {
      default = "skydns.local.";
      description = "Skydns default domain if not specified by etcd config.";
      type = types.str;
    };

    etcd = {
      caCert = mkOption {
        default = null;
        description = "Skydns path of TLS certificate authority public key.";
        type = types.nullOr types.path;
      };

      machines = mkOption {
        default = [ "http://127.0.0.1:2379" ];
        description = "Skydns list of etcd endpoints to connect to.";
        type = types.listOf types.str;
      };

      tlsKey = mkOption {
        default = null;
        description = "Skydns path of TLS client certificate - private key.";
        type = types.nullOr types.path;
      };

      tlsPem = mkOption {
        default = null;
        description = "Skydns path of TLS client certificate - public key.";
        type = types.nullOr types.path;
      };
    };

    extraConfig = mkOption {
      default = { };
      description = "Skydns attribute set of extra config options passed as environment variables.";
      type = types.attrsOf types.str;
    };

    nameservers = mkOption {
      default = map (n: n + ":53") config.networking.nameservers;
      defaultText = literalExpression ''map (n: n + ":53") config.networking.nameservers'';
      description = "Skydns list of nameservers to forward DNS requests to when not authoritative for a domain.";

      example = [
        "8.8.8.8:53"
        "8.8.4.4:53"
      ];

      type = types.listOf types.str;
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    systemd.services.skydns = {
      after = [
        "network.target"
        "etcd.service"
      ];

      description = "Skydns Service";

      environment = {
        ETCD_CACERT = cfg.etcd.caCert;
        ETCD_MACHINES = concatStringsSep "," cfg.etcd.machines;
        ETCD_TLSKEY = cfg.etcd.tlsKey;
        ETCD_TLSPEM = cfg.etcd.tlsPem;
        SKYDNS_ADDR = cfg.address;
        SKYDNS_DOMAIN = cfg.domain;
        SKYDNS_NAMESERVERS = concatStringsSep "," cfg.nameservers;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/skydns";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
