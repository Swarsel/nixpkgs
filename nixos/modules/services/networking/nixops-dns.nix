{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  pkg = pkgs.nixops-dns;
  cfg = config.services.nixops-dns;
in

{
  options = {
    services.nixops-dns = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to enable the nixops-dns resolution
          of NixOps virtual machines via dnsmasq and fake domain name.
        '';

        type = types.bool;
      };

      dnsmasq = mkOption {
        default = true;

        description = ''
          Enable dnsmasq forwarding to nixops-dns. This allows to use
          nixops-dns for `services.nixops-dns.domain` resolution
          while forwarding the rest of the queries to original resolvers.
        '';

        type = types.bool;
      };

      domain = mkOption {
        default = "ops";

        description = ''
          Fake domain name to resolve to NixOps virtual machines.

          For example "ops" will resolve "vm.ops".
        '';

        type = types.str;
      };

      user = mkOption {
        description = ''
          The user the nixops-dns daemon should run as.
          This should be the user, which is also used for nixops and
          have the .nixops directory in its home.
        '';

        type = types.str;
      };

    };
  };

  config = mkIf cfg.enable {
    services.dnsmasq = mkIf cfg.dnsmasq {
      enable = true;
      resolveLocalQueries = true;

      servers = [
        "/${cfg.domain}/127.0.0.1#5300"
      ];

      settings = {
        bind-interfaces = true;
        listen-address = "127.0.0.1";
      };
    };

    systemd.services.nixops-dns = {
      description = "nixops-dns: DNS server for resolving NixOps machines";

      serviceConfig = {
        ExecStart = "${pkg}/bin/nixops-dns --domain=.${cfg.domain}";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

  };
}
