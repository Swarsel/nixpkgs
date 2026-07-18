{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.programs.proxychains;

  configFile = ''
    ${cfg.chain.type}_chain
    ${lib.optionalString (cfg.chain.type == "random") "chain_len = ${toString cfg.chain.length}"}
    ${lib.optionalString cfg.proxyDNS "proxy_dns"}
    ${lib.optionalString cfg.quietMode "quiet_mode"}
    remote_dns_subnet ${toString cfg.remoteDNSSubnet}
    tcp_read_time_out ${toString cfg.tcpReadTimeOut}
    tcp_connect_time_out ${toString cfg.tcpConnectTimeOut}
    localnet ${cfg.localnet}
    [ProxyList]
    ${builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (k: v: "${v.type} ${v.host} ${toString v.port}") (
        lib.filterAttrs (k: v: v.enable) cfg.proxies
      )
    )}
  '';

  proxyOptions = {
    options = {
      enable = lib.mkEnableOption "this proxy";

      host = lib.mkOption {
        description = "Proxy host or IP address.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        description = "Proxy port";
        type = lib.types.port;
      };

      type = lib.mkOption {
        description = "Proxy type.";

        type = lib.types.enum [
          "http"
          "socks4"
          "socks5"
        ];
      };
    };
  };

in
{

  ###### interface
  options = {

    programs.proxychains = {

      enable = lib.mkEnableOption "proxychains configuration";

      package = lib.mkPackageOption pkgs "proxychains" {
        example = "proxychains-ng";
      };

      chain = {
        length = lib.mkOption {
          default = null;

          description = ''
            Chain length for random chain.
          '';

          type = lib.types.nullOr lib.types.int;
        };

        type = lib.mkOption {
          default = "strict";

          description = ''
            `dynamic` - Each connection will be done via chained proxies
            all proxies chained in the order as they appear in the list
            at least one proxy must be online to play in chain
            (dead proxies are skipped)
            otherwise `EINTR` is returned to the app.

            `strict` - Each connection will be done via chained proxies
            all proxies chained in the order as they appear in the list
            all proxies must be online to play in chain
            otherwise `EINTR` is returned to the app.

            `random` - Each connection will be done via random proxy
            (or proxy chain, see {option}`programs.proxychains.chain.length`) from the list.
          '';

          type = lib.types.enum [
            "dynamic"
            "strict"
            "random"
          ];
        };
      };

      localnet = lib.mkOption {
        default = "127.0.0.0/255.0.0.0";
        description = "By default enable localnet for loopback address ranges.";
        type = lib.types.str;
      };

      proxies = lib.mkOption {
        description = ''
          Proxies to be used by proxychains.
        '';

        example = lib.literalExpression ''
          { myproxy =
            { type = "socks4";
              host = "127.0.0.1";
              port = 1337;
            };
          }
        '';

        type = lib.types.attrsOf (lib.types.submodule proxyOptions);
      };

      proxyDNS = lib.mkOption {
        default = true;
        description = "Proxy DNS requests - no leak for DNS data.";
        type = lib.types.bool;
      };

      quietMode = lib.mkEnableOption "Quiet mode (no output from the library)";

      remoteDNSSubnet = lib.mkOption {
        default = 224;

        description = ''
          Set the class A subnet number to use for the internal remote DNS mapping, uses the reserved 224.x.x.x range by default.
        '';

        type = lib.types.enum [
          10
          127
          224
        ];
      };

      tcpConnectTimeOut = lib.mkOption {
        default = 8000;
        description = "Connection time-out in milliseconds.";
        type = lib.types.int;
      };

      tcpReadTimeOut = lib.mkOption {
        default = 15000;
        description = "Connection read time-out in milliseconds.";
        type = lib.types.int;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    assertions = lib.singleton {
      assertion = cfg.chain.type != "random" && cfg.chain.length == null;

      message = ''
        Option `programs.proxychains.chain.length`
        only makes sense with `programs.proxychains.chain.type` = "random".
      '';
    };

    environment.etc."proxychains.conf".text = configFile;
    environment.systemPackages = [ cfg.package ];

    programs.proxychains.proxies = lib.mkIf config.services.tor.client.enable {
      torproxy = lib.mkDefault {
        enable = true;
        host = "127.0.0.1";
        port = 9050;
        type = "socks4";
      };
    };
  };

  ###### implementation
  meta.maintainers = with lib.maintainers; [ sorki ];

}
