{
  config,
  lib,
  pkgs,
  ...
}:
let

  pkg = pkgs.cjdns;

  cfg = config.services.cjdns;

  connectToSubmodule =
    { ... }:
    {
      options = {
        hostname = lib.mkOption {
          default = "";
          description = "Optional hostname to add to /etc/hosts; prevents reverse lookup failures.";
          example = "foobar.hype";
          type = lib.types.str;
        };

        login = lib.mkOption {
          default = "";
          description = "(optional) name your peer has for you";
          type = lib.types.str;
        };

        password = lib.mkOption {
          description = "Authorized password to the opposite end of the tunnel.";
          type = lib.types.str;
        };

        peerName = lib.mkOption {
          default = "";
          description = "(optional) human-readable name for peer";
          type = lib.types.str;
        };

        publicKey = lib.mkOption {
          description = "Public key at the opposite end of the tunnel.";
          type = lib.types.str;
        };
      };
    };

  # Additional /etc/hosts entries for peers with an associated hostname
  cjdnsExtraHosts = pkgs.runCommand "cjdns-hosts" { } ''
    exec >$out
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        k: v:
        lib.optionalString (
          v.hostname != ""
        ) "echo $(${pkgs.cjdns}/bin/cjdnstool util key2ip6 ${v.publicKey}) ${v.hostname}"
      ) (cfg.ETHInterface.connectTo // cfg.UDPInterface.connectTo)
    )}
  '';

  parseModules =
    x:
    x
    // {
      connectTo = lib.mapAttrs (name: value: { inherit (value) password publicKey; }) x.connectTo;
    };

  cjdrouteConf = builtins.toJSON (
    lib.recursiveUpdate {
      admin = {
        bind = cfg.admin.bind;
        password = "@CJDNS_ADMIN_PASSWORD@";
      };

      authorizedPasswords = map (p: { password = p; }) cfg.authorizedPasswords;

      interfaces = {
        ETHInterface = if (cfg.ETHInterface.bind != "") then [ (parseModules cfg.ETHInterface) ] else [ ];
        UDPInterface = if (cfg.UDPInterface.bind != "") then [ (parseModules cfg.UDPInterface) ] else [ ];
      };

      privateKey = "@CJDNS_PRIVATE_KEY@";
      resetAfterInactivitySeconds = 100;

      router = {
        interface = {
          type = "TUNInterface";
        };

        ipTunnel = {
          allowedConnections = [ ];
          outgoingConnections = [ ];
        };
      };

      security = [
        {
          exemptAngel = 1;
          setuser = "nobody";
        }
      ];

    } cfg.extraConfig
  );

in

{
  options = {

    services.cjdns = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the cjdns network encryption
          and routing engine. A file at /etc/cjdns.keys will
          be created if it does not exist to contain a random
          secret key that your IPv6 address will be derived from.
        '';

        type = lib.types.bool;
      };

      ETHInterface = {
        beacon = lib.mkOption {
          default = 2;

          description = ''
            Auto-connect to other cjdns nodes on the same network.
            Options:
              0: Disabled.
              1: Accept beacons, this will cause cjdns to accept incoming
                 beacon messages and try connecting to the sender.
              2: Accept and send beacons, this will cause cjdns to broadcast
                 messages on the local network which contain a randomly
                 generated per-session password, other nodes which have this
                 set to 1 or 2 will hear the beacon messages and connect
                 automatically.
          '';

          type = lib.types.int;
        };

        bind = lib.mkOption {
          default = "";

          description = ''
            Bind to this device for native ethernet operation.
            `all` is a pseudo-name which will try to connect to all devices.
          '';

          example = "eth0";
          type = lib.types.str;
        };

        connectTo = lib.mkOption {
          default = { };

          description = ''
            Credentials for connecting look similar to UDP credientials
            except they begin with the mac address.
          '';

          example = lib.literalExpression ''
            {
              "01:02:03:04:05:06" = {
                hostname = "homer.hype";
                password = "5kG15EfpdcKNX3f2GSQ0H1HC7yIfxoCoImnO5FHM";
                publicKey = "371zpkgs8ss387tmr81q04mp0hg1skb51hw34vk1cq644mjqhup0.k";
              };
            }
          '';

          type = lib.types.attrsOf (lib.types.submodule connectToSubmodule);
        };
      };

      UDPInterface = {
        bind = lib.mkOption {
          default = "";

          description = ''
            Address and port to bind UDP tunnels to.
          '';

          example = "192.168.1.32:43211";
          type = lib.types.str;
        };

        connectTo = lib.mkOption {
          default = { };

          description = ''
            Credentials for making UDP tunnels.
          '';

          example = lib.literalExpression ''
            {
              "192.168.1.1:27313" = {
                hostname = "homer.hype";
                password = "5kG15EfpdcKNX3f2GSQ0H1HC7yIfxoCoImnO5FHM";
                publicKey = "371zpkgs8ss387tmr81q04mp0hg1skb51hw34vk1cq644mjqhup0.k";
              };
            }
          '';

          type = lib.types.attrsOf (lib.types.submodule connectToSubmodule);
        };
      };

      addExtraHosts = lib.mkOption {
        default = false;

        description = ''
          Whether to add cjdns peers with an associated hostname to
          {file}`/etc/hosts`.  Beware that enabling this
          incurs heavy eval-time costs.
        '';

        type = lib.types.bool;
      };

      admin = {
        bind = lib.mkOption {
          default = "127.0.0.1:11234";

          description = ''
            Bind the administration port to this address and port.
          '';

          type = lib.types.str;
        };
      };

      authorizedPasswords = lib.mkOption {
        default = [ ];

        description = ''
          Any remote cjdns nodes that offer these passwords on
          connection will be allowed to route through this node.
        '';

        example = [
          "snyrfgkqsc98qh1y4s5hbu0j57xw5s0"
          "z9md3t4p45mfrjzdjurxn4wuj0d8swv"
          "49275fut6tmzu354pq70sr5b95qq0vj"
        ];

        type = lib.types.listOf lib.types.str;
      };

      confFile = lib.mkOption {
        default = null;

        description = ''
          Ignore all other cjdns options and load configuration from this file.
        '';

        example = "/etc/cjdroute.conf";
        type = lib.types.nullOr lib.types.path;
      };

      extraConfig = lib.mkOption {
        default = { };

        description = ''
          Extra configuration, given as attrs, that will be merged recursively
          with the rest of the JSON generated by this module, at the root node.
        '';

        example = {
          router.interface.tunDevice = "tun10";
        };

        type = lib.types.attrs;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = (cfg.ETHInterface.bind != "" || cfg.UDPInterface.bind != "" || cfg.confFile != null);
        message = "Neither cjdns.ETHInterface.bind nor cjdns.UDPInterface.bind defined.";
      }
      {
        assertion = config.networking.enableIPv6;
        message = "networking.enableIPv6 must be enabled for CJDNS to work";
      }
    ];

    boot.kernelModules = [ "tun" ];
    networking.hostFiles = lib.mkIf cfg.addExtraHosts [ cjdnsExtraHosts ];

    # networking.firewall.allowedUDPPorts = ...
    systemd.services.cjdns = {
      after = [ "network-online.target" ];
      bindsTo = [ "network-online.target" ];
      description = "cjdns: routing engine designed for security, scalability, speed and ease of use";

      preStart = lib.optionalString (cfg.confFile == null) ''
        [ -e /etc/cjdns.keys ] && source /etc/cjdns.keys

        if [ -z "$CJDNS_PRIVATE_KEY" ]; then
            shopt -s lastpipe
            ${pkg}/bin/cjdnstool util keygen | { read private ipv6 public; }

            install -m 600 <(echo "CJDNS_PRIVATE_KEY=$private") /etc/cjdns.keys
            install -m 444 <(echo -e "CJDNS_IPV6=$ipv6\nCJDNS_PUBLIC_KEY=$public") /etc/cjdns.public
        fi

        if [ -z "$CJDNS_ADMIN_PASSWORD" ]; then
            echo "CJDNS_ADMIN_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)" \
                >> /etc/cjdns.keys
        fi
      '';

      script = (
        if cfg.confFile != null then
          "${pkg}/bin/cjdroute < ${cfg.confFile}"
        else
          ''
            source /etc/cjdns.keys
            (cat <<'EOF'
            ${cjdrouteConf}
            EOF
            ) | sed \
                -e "s/@CJDNS_ADMIN_PASSWORD@/$CJDNS_ADMIN_PASSWORD/g" \
                -e "s/@CJDNS_PRIVATE_KEY@/$CJDNS_PRIVATE_KEY/g" \
                | ${pkg}/bin/cjdroute
          ''
      );

      serviceConfig = {
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW CAP_SETUID";
        # Doesn't work on i686, causing service to fail
        MemoryDenyWriteExecute = !pkgs.stdenv.hostPlatform.isi686;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = true;
        Restart = "always";
        RestartSec = 1;
        Type = "forking";
      };

      startLimitIntervalSec = 0;

      wantedBy = [
        "multi-user.target"
        "sleep.target"
      ];
    };

  };

}
