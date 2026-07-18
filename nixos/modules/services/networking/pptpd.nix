{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options = {
    services.pptpd = {
      enable = mkEnableOption "pptpd, the Point-to-Point Tunneling Protocol daemon";

      clientIpRange = mkOption {
        default = "10.124.124.2-11";
        description = "The range from which client IPs are drawn.";
        type = types.str;
      };

      extraPppdOptions = mkOption {
        default = "";
        description = "Adds extra lines to the pppd options file.";

        example = ''
          ms-dns 8.8.8.8
          ms-dns 8.8.4.4
        '';

        type = types.lines;
      };

      extraPptpdOptions = mkOption {
        default = "";
        description = "Adds extra lines to the pptpd configuration file.";
        type = types.lines;
      };

      maxClients = mkOption {
        default = 10;
        description = "The maximum number of simultaneous connections.";
        type = types.int;
      };

      serverIp = mkOption {
        default = "10.124.124.1";
        description = "The server-side IP address.";
        type = types.str;
      };
    };
  };

  config = mkIf config.services.pptpd.enable {
    systemd.services.pptpd =
      let
        cfg = config.services.pptpd;

        pptpd-conf = pkgs.writeText "pptpd.conf" ''
          # Inspired from pptpd-1.4.0/samples/pptpd.conf
          ppp ${ppp-pptpd-wrapped}/bin/pppd
          option ${pppd-options}
          pidfile /run/pptpd.pid
          localip ${cfg.serverIp}
          remoteip ${cfg.clientIpRange}
          connections ${toString cfg.maxClients} # (Will get harmless warning if inconsistent with IP range)

          # Extra
          ${cfg.extraPptpdOptions}
        '';

        pppd-options = pkgs.writeText "ppp-options-pptpd.conf" ''
          # From: cat pptpd-1.4.0/samples/options.pptpd | grep -v ^# | grep -v ^$
          name pptpd
          refuse-pap
          refuse-chap
          refuse-mschap
          require-mschap-v2
          require-mppe-128
          proxyarp
          lock
          nobsdcomp
          novj
          novjccomp
          nologfd

          # Extra:
          ${cfg.extraPppdOptions}
        '';

        ppp-pptpd-wrapped = pkgs.stdenv.mkDerivation {
          buildCommand = ''
            mkdir -p $out/bin
            makeWrapper ${pkgs.ppp}/bin/pppd $out/bin/pppd \
              --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
              --set NIX_REDIRECTS "/etc/ppp=/etc/ppp-pptpd"
          '';

          name = "ppp-pptpd-wrapped";
          nativeBuildInputs = with pkgs; [ makeWrapper ];
        };
      in
      {
        description = "pptpd server";

        preStart = ''
          mkdir -p -m 700 /etc/ppp-pptpd

          secrets="/etc/ppp-pptpd/chap-secrets"

          [ -f "$secrets" ] || install -m 600 -o root -g root /dev/stdin "$secrets" << EOF
          # From: pptpd-1.4.0/samples/chap-secrets
          # Secrets for authentication using CHAP
          # client	server	secret		IP addresses
          #username	pptpd	password	*
          EOF
        '';

        requires = [ "network-online.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.pptpd}/bin/pptpd --conf ${pptpd-conf}";
          KillMode = "process";
          PIDFile = "/run/pptpd.pid";
          Restart = "on-success";
          Type = "forking";
        };

        wantedBy = [ "multi-user.target" ];
      };
  };
}
