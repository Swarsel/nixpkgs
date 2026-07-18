{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.services.https-dns-proxy;

  providers = {
    cloudflare = {
      ips = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      url = "https://cloudflare-dns.com/dns-query";
    };

    custom = {
      inherit (cfg.provider) ips url;
    };

    google = {
      ips = [
        "8.8.8.8"
        "8.8.4.4"
      ];

      url = "https://dns.google/dns-query";
    };

    opendns = {
      ips = [
        "208.67.222.222"
        "208.67.220.220"
      ];

      url = "https://doh.opendns.com/dns-query";
    };

    quad9 = {
      ips = [
        "9.9.9.9"
        "149.112.112.112"
      ];

      url = "https://dns.quad9.net/dns-query";
    };
  };

  defaultProvider = "quad9";

  providerCfg = concatStringsSep " " [
    "-b"
    (concatStringsSep "," providers."${cfg.provider.kind}".ips)
    "-r"
    providers."${cfg.provider.kind}".url
  ];

in
{
  ###### interface
  options.services.https-dns-proxy = {
    enable = mkEnableOption "https-dns-proxy daemon";

    address = mkOption {
      default = "127.0.0.1";
      description = "The address on which to listen";
      type = types.str;
    };

    extraArgs = mkOption {
      default = [ "-v" ];
      description = "Additional arguments to pass to the process.";
      type = types.listOf types.str;
    };

    port = mkOption {
      default = 5053;
      description = "The port on which to listen";
      type = types.port;
    };

    preferIPv4 = mkOption {
      default = true;

      description = ''
        https_dns_proxy will by default use IPv6 and fail if it is not available.
        To play it safe, we choose IPv4.
      '';

      type = types.bool;
    };

    provider = {
      ips = mkOption {
        description = "The custom provider IPs";
        type = types.listOf types.str;
      };

      kind = mkOption {
        default = defaultProvider;

        description = ''
          The upstream provider to use or custom in case you do not trust any of
          the predefined providers or just want to use your own.

          The default is ${defaultProvider} and there are privacy and security
          trade-offs when using any upstream provider. Please consider that
          before using any of them.

          Supported providers: ${concatStringsSep ", " (builtins.attrNames providers)}

          If you pick the custom provider, you will need to provide the
          bootstrap IP addresses as well as the resolver https URL.
        '';

        type = types.enum (builtins.attrNames providers);
      };

      url = mkOption {
        description = "The custom provider URL";
        type = types.str;
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    systemd.services.https-dns-proxy = {
      after = [ "network.target" ];
      before = [ "nss-lookup.target" ];
      description = "DNS to DNS over HTTPS (DoH) proxy";
      requires = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;

        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe pkgs.https-dns-proxy)
            "-a ${toString cfg.address}"
            "-p ${toString cfg.port}"
            "-l -"
            providerCfg
          ]
          ++ lib.optional cfg.preferIPv4 "-4"
          ++ cfg.extraArgs
        );

        ProtectHome = "tmpfs";
        Restart = "on-failure";
        Type = "exec";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "nss-lookup.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ peterhoeg ];
}
