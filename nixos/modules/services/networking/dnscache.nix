{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dnscache;

  dnscache-root = pkgs.runCommand "dnscache-root" { preferLocalBuild = true; } ''
    mkdir -p $out/{servers,ip}

    ${lib.concatMapStrings (ip: ''
      touch "$out/ip/"${lib.escapeShellArg ip}
    '') cfg.clientIps}

    ${lib.concatStrings (
      lib.mapAttrsToList (host: ips: ''
        ${lib.concatMapStrings (ip: ''
          echo ${lib.escapeShellArg ip} >> "$out/servers/"${lib.escapeShellArg host}
        '') ips}
      '') cfg.domainServers
    )}

    # if a list of root servers was not provided in config, copy it
    # over. (this is also done by dnscache-conf, but we 'rm -rf
    # /var/lib/dnscache/root' below & replace it wholesale with this,
    # so we have to ensure servers/@ exists ourselves.)
    if [ ! -e $out/servers/@ ]; then
      # symlink does not work here, due chroot
      cp ${pkgs.djbdns}/etc/dnsroots.global $out/servers/@;
    fi
  '';

in
{

  ###### interface

  options = {
    services.dnscache = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to run the dnscache caching dns server.";
        type = lib.types.bool;
      };

      clientIps = lib.mkOption {
        default = [ "127.0.0.1" ];
        description = "Client IP addresses (or prefixes) from which to accept connections.";

        example = [
          "192.168"
          "172.23.75.82"
        ];

        type = lib.types.listOf lib.types.str;
      };

      domainServers = lib.mkOption {
        default = { };

        description = ''
          Table of {hostname: server} pairs to use as authoritative servers for hosts (and subhosts).
          If entry for @ is not specified predefined list of root servers is used.
        '';

        example = lib.literalExpression ''
          {
            "@" = ["8.8.8.8" "8.8.4.4"];
            "example.com" = ["192.168.100.100"];
          }
        '';

        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      };

      forwardOnly = lib.mkOption {
        default = false;

        description = ''
          Whether to treat root servers (for @) as caching
          servers, requesting addresses the same way a client does. This is
          needed if you want to use e.g. Google DNS as your upstream DNS.
        '';

        type = lib.types.bool;
      };

      ip = lib.mkOption {
        default = "0.0.0.0";
        description = "IP address on which to listen for connections.";
        type = lib.types.str;
      };

    };
  };

  ###### implementation

  config = lib.mkIf config.services.dnscache.enable {
    environment.systemPackages = [ pkgs.djbdns ];

    systemd.services.dnscache = {
      description = "djbdns dnscache server";

      path = with pkgs; [
        bash
        daemontools
        djbdns
      ];

      preStart = ''
        rm -rf /var/lib/dnscache
        dnscache-conf dnscache dnscache /var/lib/dnscache ${config.services.dnscache.ip}
        rm -rf /var/lib/dnscache/root
        ln -sf ${dnscache-root} /var/lib/dnscache/root
      '';

      script = ''
        cd /var/lib/dnscache/
        ${lib.optionalString cfg.forwardOnly "export FORWARDONLY=1"}
        exec ./run
      '';

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.dnscache = { };

    users.users.dnscache = {
      group = "dnscache";
      isSystemUser = true;
    };
  };
}
