{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkOption
    mkDefault
    mkEnableOption
    types
    optional
    optionals
    ;
  inherit (lib.types)
    nullOr
    bool
    listOf
    str
    attrsOf
    submodule
    ;

  cfg = config.services.i2pd;

  homeDir = "/var/lib/i2pd";

  strOpt = k: v: k + " = " + v;
  boolOpt = k: v: k + " = " + lib.boolToString v;
  intOpt = k: v: k + " = " + toString v;
  lstOpt = k: xs: k + " = " + lib.concatStringsSep "," xs;
  optionalNullString = o: s: optional (s != null) (strOpt o s);
  optionalNullBool = o: b: optional (b != null) (boolOpt o b);
  optionalNullInt = o: i: optional (i != null) (intOpt o i);
  optionalEmptyList = o: l: optional ([ ] != l) (lstOpt o l);

  mkEnableTrueOption = name: mkEnableOption name // { default = true; };

  mkEndpointOpt = name: addr: port: {
    enable = mkEnableOption name;

    address = mkOption {
      default = addr;
      description = "Bind address for ${name} endpoint.";
      type = types.str;
    };

    name = mkOption {
      default = name;
      description = "The endpoint name.";
      type = types.str;
    };

    port = mkOption {
      default = port;
      description = "Bind port for ${name} endpoint.";
      type = types.port;
    };
  };

  i2cpOpts = name: {
    length = mkOption {
      default = 3;
      description = "Guaranteed minimum hops for ${name} tunnels.";
      type = types.int;
    };

    quantity = mkOption {
      default = 5;
      description = "Number of simultaneous ${name} tunnels.";
      type = types.int;
    };
  };

  mkKeyedEndpointOpt =
    name: addr: port: keyloc:
    (mkEndpointOpt name addr port)
    // {
      inbound = i2cpOpts name;

      keys = mkOption {
        default = keyloc;

        description = ''
          File to persist ${lib.toUpper name} keys.
        '';

        type = nullOr str;
      };

      latency.max = mkOption {
        default = null;
        description = "Max latency for tunnels.";
        type = with types; nullOr int;
      };

      latency.min = mkOption {
        default = null;
        description = "Min latency for tunnels.";
        type = with types; nullOr int;
      };

      outbound = i2cpOpts name;
    };

  commonTunOpts =
    name:
    {
      crypto.tagsToSend = mkOption {
        default = 40;
        description = "Number of ElGamal/AES tags to send.";
        type = types.int;
      };

      inbound = i2cpOpts name;

      keys = mkOption {
        default = name + "-keys.dat";
        description = "Keyset used for tunnel identity.";
        type = types.str;
      };

      outbound = i2cpOpts name;
    }
    // mkEndpointOpt name "127.0.0.1" 0;

  sec = name: "\n[" + name + "]";
  notice = "# DO NOT EDIT -- this file has been generated automatically.";
  i2pdConf =
    let
      opts = [
        notice
        (strOpt "loglevel" cfg.logLevel)
        (boolOpt "logclftime" cfg.logCLFTime)
        (boolOpt "ipv4" cfg.enableIPv4)
        (boolOpt "ipv6" cfg.enableIPv6)
        (boolOpt "notransit" cfg.notransit)
        (boolOpt "floodfill" cfg.floodfill)
        (intOpt "netid" cfg.netid)
      ]
      ++ (optionalNullInt "bandwidth" cfg.bandwidth)
      ++ (optionalNullInt "port" cfg.port)
      ++ (optionalNullString "family" cfg.family)
      ++ (optionalNullString "datadir" cfg.dataDir)
      ++ (optionalNullInt "share" cfg.share)
      ++ (optionalNullBool "ssu" cfg.ssu)
      ++ (optionalNullBool "ntcp" cfg.ntcp)
      ++ (optionalNullString "ntcpproxy" cfg.ntcpProxy)
      ++ (optionalNullString "ifname" cfg.ifname)
      ++ (optionalNullString "ifname4" cfg.ifname4)
      ++ (optionalNullString "ifname6" cfg.ifname6)
      ++ [
        (sec "limits")
        (intOpt "transittunnels" cfg.limits.transittunnels)
        (intOpt "coresize" cfg.limits.coreSize)
        (intOpt "openfiles" cfg.limits.openFiles)
        (intOpt "ntcphard" cfg.limits.ntcpHard)
        (intOpt "ntcpsoft" cfg.limits.ntcpSoft)
        (intOpt "ntcpthreads" cfg.limits.ntcpThreads)
        (sec "upnp")
        (boolOpt "enabled" cfg.upnp.enable)
        (sec "precomputation")
        (boolOpt "elgamal" cfg.precomputation.elgamal)
        (sec "reseed")
        (boolOpt "verify" cfg.reseed.verify)
      ]
      ++ (optionalNullString "file" cfg.reseed.file)
      ++ (optionalEmptyList "urls" cfg.reseed.urls)
      ++ (optionalNullString "floodfill" cfg.reseed.floodfill)
      ++ (optionalNullString "zipfile" cfg.reseed.zipfile)
      ++ (optionalNullString "proxy" cfg.reseed.proxy)
      ++ [
        (sec "trust")
        (boolOpt "enabled" cfg.trust.enable)
        (boolOpt "hidden" cfg.trust.hidden)
      ]
      ++ (optionalEmptyList "routers" cfg.trust.routers)
      ++ (optionalNullString "family" cfg.trust.family)
      ++ [
        (sec "websockets")
        (boolOpt "enabled" cfg.websocket.enable)
        (strOpt "address" cfg.websocket.address)
        (intOpt "port" cfg.websocket.port)
        (sec "exploratory")
        (intOpt "inbound.length" cfg.exploratory.inbound.length)
        (intOpt "inbound.quantity" cfg.exploratory.inbound.quantity)
        (intOpt "outbound.length" cfg.exploratory.outbound.length)
        (intOpt "outbound.quantity" cfg.exploratory.outbound.quantity)
        (sec "ntcp2")
        (boolOpt "enabled" cfg.ntcp2.enable)
        (boolOpt "published" cfg.ntcp2.published)
        (intOpt "port" cfg.ntcp2.port)
        (sec "ssu2")
        (boolOpt "enabled" cfg.ssu2.enable)
        (boolOpt "published" cfg.ssu2.published)
        (intOpt "port" cfg.ssu2.port)
        (sec "addressbook")
        (strOpt "defaulturl" cfg.addressbook.defaulturl)
      ]
      ++ (optionalEmptyList "subscriptions" cfg.addressbook.subscriptions)
      ++ [
        (sec "meshnets")
        (boolOpt "yggdrasil" cfg.yggdrasil.enable)
      ]
      ++ (optionalNullString "yggaddress" cfg.yggdrasil.address)
      ++ (lib.flip map (lib.collect (proto: proto ? port && proto ? address) cfg.proto) (
        proto:
        let
          protoOpts = [
            (sec proto.name)
            (boolOpt "enabled" proto.enable)
            (strOpt "address" proto.address)
            (intOpt "port" proto.port)
          ]
          ++ (optionals (proto ? keys) (optionalNullString "keys" proto.keys))
          ++ (optionals (proto ? auth) (optionalNullBool "auth" proto.auth))
          ++ (optionals (proto ? user) (optionalNullString "user" proto.user))
          ++ (optionals (proto ? pass) (optionalNullString "pass" proto.pass))
          ++ (optionals (proto ? strictHeaders) (optionalNullBool "strictheaders" proto.strictHeaders))
          ++ (optionals (proto ? hostname) (optionalNullString "hostname" proto.hostname))
          ++ (optionals (proto ? outproxy) (optionalNullString "outproxy" proto.outproxy))
          ++ (optionals (proto ? outproxyPort) (optionalNullInt "outproxyport" proto.outproxyPort))
          ++ (optionals (proto ? outproxyEnable) (optionalNullBool "outproxy.enabled" proto.outproxyEnable));
        in
        (lib.concatStringsSep "\n" protoOpts)
      ));
    in
    pkgs.writeText "i2pd.conf" (lib.concatStringsSep "\n" opts);

  tunnelConf =
    let
      mkOutTunnel =
        tun:
        let
          outTunOpts = [
            (sec tun.name)
            (intOpt "type" tun.type)
            (intOpt "port" tun.port)
            (strOpt "destination" tun.destination)
          ]
          ++ (optionals (tun ? destinationPort) (optionalNullInt "destinationport" tun.destinationPort))
          ++ (optionals (tun ? keys) (optionalNullString "keys" tun.keys))
          ++ (optionals (tun ? address) (optionalNullString "address" tun.address))
          ++ (optionals (tun ? inbound.length) (optionalNullInt "inbound.length" tun.inbound.length))
          ++ (optionals (tun ? inbound.quantity) (optionalNullInt "inbound.quantity" tun.inbound.quantity))
          ++ (optionals (tun ? outbound.length) (optionalNullInt "outbound.length" tun.outbound.length))
          ++ (optionals (tun ? outbound.quantity) (optionalNullInt "outbound.quantity" tun.outbound.quantity))
          ++ (optionals (tun ? crypto.tagsToSend) (
            optionalNullInt "crypto.tagstosend" tun.crypto.tagsToSend
          ));
        in
        lib.concatStringsSep "\n" outTunOpts;

      mkInTunnel =
        tun:
        let
          inTunOpts = [
            (sec tun.name)
            (intOpt "type" tun.type)
            (intOpt "port" tun.port)
            (strOpt "host" tun.address)
          ]
          ++ (optionals (tun ? keys) (optionalNullString "keys" tun.keys))
          ++ (optionals (tun ? inPort) (optionalNullInt "inport" tun.inPort))
          ++ (optionals (tun ? accessList) (optionalEmptyList "accesslist" tun.accessList))
          ++ (optionals (tun ? inbound.length) (optionalNullInt "inbound.length" tun.inbound.length))
          ++ (optionals (tun ? inbound.quantity) (optionalNullInt "inbound.quantity" tun.inbound.quantity))
          ++ (optionals (tun ? outbound.length) (optionalNullInt "outbound.length" tun.outbound.length))
          ++ (optionals (tun ? outbound.quantity) (optionalNullInt "outbound.quantity" tun.outbound.quantity))
          ++ (optionals (tun ? crypto.tagsToSend) (
            optionalNullInt "crypto.tagstosend" tun.crypto.tagsToSend
          ));
        in
        lib.concatStringsSep "\n" inTunOpts;

      allOutTunnels = lib.collect (tun: tun ? port && tun ? destination) cfg.outTunnels;
      allInTunnels = lib.collect (tun: tun ? port && tun ? address) cfg.inTunnels;

      opts = [ notice ] ++ (map mkOutTunnel allOutTunnels) ++ (map mkInTunnel allInTunnels);
    in
    pkgs.writeText "i2pd-tunnels.conf" (lib.concatStringsSep "\n" opts);

  i2pdFlags = lib.concatStringsSep " " (
    optional (cfg.address != null) ("--host=" + cfg.address)
    ++ [
      "--service"
      ("--conf=" + i2pdConf)
      ("--tunconf=" + tunnelConf)
    ]
  );

in

{

  imports = [
    (lib.mkRenamedOptionModule [ "services" "i2pd" "extIp" ] [ "services" "i2pd" "address" ])
  ];

  ###### interface

  options = {

    services.i2pd = {

      enable = mkEnableOption "I2Pd daemon" // {
        description = ''
          Enables I2Pd as a running service upon activation.
          Please read <https://i2pd.readthedocs.io/en/latest/> for further
          configuration help.
        '';
      };

      package = lib.mkPackageOption pkgs "i2pd" { };

      address = mkOption {
        default = null;

        description = ''
          Your external IP or hostname.
        '';

        type = nullOr str;
      };

      addressbook.defaulturl = mkOption {
        default = "http://joajgazyztfssty4w2on5oaqksz6tqoxbduy553y34mf4byv6gpq.b32.i2p/export/alive-hosts.txt";

        description = ''
          AddressBook subscription URL for initial setup
        '';

        type = types.str;
      };

      addressbook.subscriptions = mkOption {
        default = [
          "http://inr.i2p/export/alive-hosts.txt"
          "http://i2p-projekt.i2p/hosts.txt"
          "http://stats.i2p/cgi-bin/newhosts.txt"
        ];

        description = ''
          AddressBook subscription URLs
        '';

        type = listOf str;
      };

      bandwidth = mkOption {
        default = null;

        description = ''
          Set a router bandwidth limit integer in KBps.
          If not set, {command}`i2pd` defaults to 32KBps.
        '';

        type = with types; nullOr int;
      };

      dataDir = mkOption {
        default = null;

        description = ''
          Alternative path to storage of i2pd data (RI, keys, peer profiles, ...)
        '';

        type = nullOr str;
      };

      enableIPv4 = mkEnableTrueOption "IPv4 connectivity";
      enableIPv6 = mkEnableOption "IPv6 connectivity";
      exploratory.inbound = i2cpOpts "exploratory";
      exploratory.outbound = i2cpOpts "exploratory";

      family = mkOption {
        default = null;

        description = ''
          Specify a family the router belongs to.
        '';

        type = nullOr str;
      };

      floodfill = mkEnableOption "floodfill" // {
        description = ''
          Makes your router a floodfill, that means what other routers will
          publish and get LeaseSets and RouterInfos on your router.
        '';
      };

      ifname = mkOption {
        default = null;

        description = ''
          Network interface to bind to.
        '';

        type = nullOr str;
      };

      ifname4 = mkOption {
        default = null;

        description = ''
          IPv4 interface to bind to.
        '';

        type = nullOr str;
      };

      ifname6 = mkOption {
        default = null;

        description = ''
          IPv6 interface to bind to.
        '';

        type = nullOr str;
      };

      inTunnels = mkOption {
        default = { };

        description = ''
          Serve something on I2P network at port and delegate requests to address inPort.
        '';

        type = attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                accessList = mkOption {
                  default = [ ];
                  description = "I2P nodes that are allowed to connect to this service.";
                  type = listOf str;
                };

                inPort = mkOption {
                  default = 0;
                  description = "Service port. Default to the tunnel's listen port.";
                  type = types.port;
                };

                type = mkOption {
                  default = "server";
                  description = "Tunnel type.";

                  type = types.enum [
                    "server"
                    "http"
                    "irc"
                    "udpserver"
                  ];
                };
              }
              // commonTunOpts name;

              config = {
                name = mkDefault name;
              };
            }
          )
        );
      };

      limits.coreSize = mkOption {
        default = 0;

        description = ''
          Maximum size of corefile in Kb (0 - use system limit).
        '';

        type = types.int;
      };

      limits.ntcpHard = mkOption {
        default = 0;

        description = ''
          Maximum number of active transit sessions.
        '';

        type = types.int;
      };

      limits.ntcpSoft = mkOption {
        default = 0;

        description = ''
          Threshold to start probabalistic backoff with ntcp sessions (default: use system limit).
        '';

        type = types.int;
      };

      limits.ntcpThreads = mkOption {
        default = 1;

        description = ''
          Maximum number of threads used by NTCP DH worker.
        '';

        type = types.int;
      };

      limits.openFiles = mkOption {
        default = 0;

        description = ''
          Maximum number of open files (0 - use system default).
        '';

        type = types.int;
      };

      limits.transittunnels = mkOption {
        default = 2500;

        description = ''
          Maximum number of active transit sessions.
        '';

        type = types.int;
      };

      logCLFTime = mkEnableOption "full CLF-formatted date and time to log";

      logLevel = mkOption {
        default = "error";

        description = ''
          The log level. {command}`i2pd` defaults to "info"
          but that generates copious amounts of log messages.

          We default to "error" which is similar to the default log
          level of {command}`tor`.
        '';

        type = types.enum [
          "debug"
          "info"
          "warn"
          "error"
        ];
      };

      nat = mkEnableTrueOption "NAT bypass";

      netid = mkOption {
        default = 2;

        description = ''
          I2P overlay netid.
        '';

        type = types.int;
      };

      notransit = mkEnableOption "notransit" // {
        description = ''
          Tells the router to not accept transit tunnels during startup.
        '';
      };

      ntcp = mkEnableTrueOption "ntcp";
      ntcp2.enable = mkEnableTrueOption "NTCP2";

      ntcp2.port = mkOption {
        default = 0;

        description = ''
          Port to listen for incoming NTCP2 connections (0=auto).
        '';

        type = types.port;
      };

      ntcp2.published = mkEnableOption "NTCP2 publication";

      ntcpProxy = mkOption {
        default = null;

        description = ''
          Proxy URL for NTCP transport.
        '';

        type = nullOr str;
      };

      outTunnels = mkOption {
        default = { };

        description = ''
          Connect to someone as a client and establish a local accept endpoint
        '';

        type = attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                destination = mkOption {
                  description = "Remote endpoint, I2P hostname or b32.i2p address.";
                  type = types.str;
                };

                destinationPort = mkOption {
                  default = null;
                  description = "Connect to particular port at destination.";
                  type = with types; nullOr port;
                };

                type = mkOption {
                  default = "client";
                  description = "Tunnel type.";

                  type = types.enum [
                    "client"
                    "udpclient"
                  ];
                };
              }
              // commonTunOpts name;

              config = {
                name = mkDefault name;
              };
            }
          )
        );
      };

      port = mkOption {
        default = null;

        description = ''
          I2P listen port. If no one is given the router will pick between 9111 and 30777.
        '';

        type = with types; nullOr port;
      };

      precomputation.elgamal = mkEnableTrueOption "Precomputed ElGamal tables" // {
        description = ''
          Whenever to use precomputated tables for ElGamal.
          {command}`i2pd` defaults to `false`
          to save 64M of memory (and looses some performance).

          We default to `true` as that is what most
          users want anyway.
        '';
      };

      proto.bob = mkEndpointOpt "bob" "127.0.0.1" 2827;

      proto.http = (mkEndpointOpt "http" "127.0.0.1" 7070) // {

        auth = mkEnableOption "webconsole authentication";

        hostname = mkOption {
          default = null;

          description = ''
            Expected hostname for WebUI.
          '';

          type = nullOr str;
        };

        pass = mkOption {
          default = "i2pd";

          description = ''
            Password for webconsole access.
          '';

          type = types.str;
        };

        strictHeaders = mkOption {
          default = null;

          description = ''
            Enable strict host checking on WebUI.
          '';

          type = nullOr bool;
        };

        user = mkOption {
          default = "i2pd";

          description = ''
            Username for webconsole access
          '';

          type = types.str;
        };
      };

      proto.httpProxy = (mkKeyedEndpointOpt "httpproxy" "127.0.0.1" 4444 "httpproxy-keys.dat") // {
        outproxy = mkOption {
          default = null;
          description = "Upstream outproxy bind address.";
          type = nullOr str;
        };
      };

      proto.i2cp = mkEndpointOpt "i2cp" "127.0.0.1" 7654;
      proto.i2pControl = mkEndpointOpt "i2pcontrol" "127.0.0.1" 7650;
      proto.sam = mkEndpointOpt "sam" "127.0.0.1" 7656;

      proto.socksProxy = (mkKeyedEndpointOpt "socksproxy" "127.0.0.1" 4447 "socksproxy-keys.dat") // {
        outproxy = mkOption {
          default = "127.0.0.1";
          description = "Upstream outproxy bind address.";
          type = types.str;
        };

        outproxyEnable = mkEnableOption "SOCKS outproxy";

        outproxyPort = mkOption {
          default = 4444;
          description = "Upstream outproxy bind port.";
          type = types.port;
        };
      };

      reseed.file = mkOption {
        default = null;

        description = ''
          Full path to SU3 file to reseed from.
        '';

        type = nullOr str;
      };

      reseed.floodfill = mkOption {
        default = null;

        description = ''
          Path to router info of floodfill to reseed from.
        '';

        type = nullOr str;
      };

      reseed.proxy = mkOption {
        default = null;

        description = ''
          URL for reseed proxy, supports http/socks.
        '';

        type = nullOr str;
      };

      reseed.urls = mkOption {
        default = [ ];

        description = ''
          Reseed URLs.
        '';

        type = listOf str;
      };

      reseed.verify = mkEnableOption "SU3 signature verification";

      reseed.zipfile = mkOption {
        default = null;

        description = ''
          Path to local .zip file to reseed from.
        '';

        type = nullOr str;
      };

      share = mkOption {
        default = 100;

        description = ''
          Limit of transit traffic from max bandwidth in percents.
        '';

        type = types.int;
      };

      ssu = mkEnableTrueOption "ssu";

      ssu2 = {
        enable = mkEnableTrueOption "SSU2";

        port = mkOption {
          default = 0;

          description = ''
            Port to listen for incoming SSU2 connections (0=auto).
          '';

          type = types.port;
        };

        published = mkEnableOption "SSU2 publication";
      };

      trust.enable = mkEnableOption "explicit trust options";

      trust.family = mkOption {
        default = null;

        description = ''
          Router Family to trust for first hops.
        '';

        type = nullOr str;
      };

      trust.hidden = mkEnableOption "router concealment";

      trust.routers = mkOption {
        default = [ ];

        description = ''
          Only connect to the listed routers.
        '';

        type = listOf str;
      };

      upnp.enable = mkEnableOption "UPnP service discovery";

      upnp.name = mkOption {
        default = "I2Pd";

        description = ''
          Name i2pd appears in UPnP forwardings list.
        '';

        type = types.str;
      };

      websocket = mkEndpointOpt "websockets" "127.0.0.1" 7666;

      yggdrasil.address = mkOption {
        default = null;

        description = ''
          Your local yggdrasil address. Specify it if you want to bind your router to a
          particular address.
        '';

        type = nullOr str;
      };

      yggdrasil.enable = mkEnableOption "Yggdrasil";
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.i2pd = {
      after = [ "network.target" ];
      description = "Minimal I2P router";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/i2pd ${i2pdFlags}";
        Restart = "on-abort";
        User = "i2pd";
        WorkingDirectory = homeDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.i2pd.gid = config.ids.gids.i2pd;

    users.users.i2pd = {
      createHome = true;
      description = "I2Pd User";
      group = "i2pd";
      home = homeDir;
      uid = config.ids.uids.i2pd;
    };
  };
}
