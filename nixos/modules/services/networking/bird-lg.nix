{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bird-lg;

  stringOrConcat = sep: v: if builtins.isString v then v else lib.concatStringsSep sep v;

  frontend_args =
    let
      fe = cfg.frontend;
    in
    {
      "--bgpmap-info" = lib.concatStringsSep "," cfg.frontend.bgpMapInfo;
      "--dns-interface" = fe.dnsInterface;
      "--domain" = fe.domain;
      "--listen" = stringOrConcat "," fe.listenAddresses;
      "--navbar-all-servers" = fe.navbar.allServers;
      "--navbar-all-url" = fe.navbar.allServersURL;
      "--navbar-brand" = fe.navbar.brand;
      "--navbar-brand-url" = fe.navbar.brandURL;
      "--net-specific-mode" = fe.netSpecificMode;
      "--protocol-filter" = lib.concatStringsSep "," cfg.frontend.protocolFilter;
      "--proxy-port" = fe.proxyPort;
      "--servers" = lib.concatStringsSep "," fe.servers;
      "--title-brand" = fe.titleBrand;
      "--whois" = fe.whois;
    };

  proxy_args =
    let
      px = cfg.proxy;
    in
    {
      "--allowed" = lib.concatStringsSep "," px.allowedIPs;
      "--bird" = px.birdSocket;
      "--listen" = stringOrConcat "," px.listenAddresses;
      "--traceroute_bin" = px.traceroute.binary;
      "--traceroute_flags" = lib.concatStringsSep " " px.traceroute.flags;
      "--traceroute_raw" = px.traceroute.rawOutput;
    };

  mkArgValue =
    value:
    if lib.isString value then
      lib.escapeShellArg value
    else if lib.isBool value then
      lib.boolToString value
    else
      toString value;

  filterNull = lib.filterAttrs (_: v: v != "" && v != null && v != [ ]);

  argsAttrToList =
    args: lib.mapAttrsToList (name: value: "${name} " + mkArgValue value) (filterNull args);
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "bird-lg" "frontend" "listenAddress" ]
      [ "services" "bird-lg" "frontend" "listenAddresses" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "bird-lg" "proxy" "listenAddress" ]
      [ "services" "bird-lg" "proxy" "listenAddresses" ]
    )
  ];

  options = {
    services.bird-lg = {
      package = lib.mkPackageOption pkgs "bird-lg" { };

      frontend = {
        enable = lib.mkEnableOption "Bird Looking Glass Frontend Webserver";

        bgpMapInfo = lib.mkOption {
          default = [
            "asn"
            "as-name"
            "ASName"
            "descr"
          ];

          description = "Information displayed in bgpmap.";
          type = lib.types.listOf lib.types.str;
        };

        dnsInterface = lib.mkOption {
          default = "asn.cymru.com";
          description = "DNS zone to query ASN information.";
          type = lib.types.str;
        };

        domain = lib.mkOption {
          description = "Server name domain suffixes.";
          example = "dn42.lantian.pub";
          type = lib.types.str;
        };

        extraArgs = lib.mkOption {
          default = [ ];

          description = ''
            Extra parameters documented [here](https://github.com/xddxdd/bird-lg-go#frontend).

            :::{.note}
            Passing lines (plain strings) is deprecated in favour of passing lists of strings.
            :::
          '';

          type = with lib.types; listOf str;
        };

        listenAddresses = lib.mkOption {
          default = "127.0.0.1:5000";
          description = "Address to listen on.";
          type = with lib.types; either str (listOf str);
        };

        nameFilter = lib.mkOption {
          default = "";
          description = "Protocol names to hide in summary tables (RE2 syntax),";
          example = "^ospf";
          type = lib.types.str;
        };

        navbar = {
          allServers = lib.mkOption {
            default = "ALL Servers";
            description = "Text of 'All server' button in the navigation bar.";
            type = lib.types.str;
          };

          allServersURL = lib.mkOption {
            default = "all";
            description = "URL of 'All servers' button.";
            type = lib.types.str;
          };

          brand = lib.mkOption {
            default = "Bird-lg Go";
            description = "Brand to show in the navigation bar .";
            type = lib.types.str;
          };

          brandURL = lib.mkOption {
            default = "/";
            description = "URL of the brand to show in the navigation bar.";
            type = lib.types.str;
          };
        };

        netSpecificMode = lib.mkOption {
          default = "";
          description = "Apply network-specific changes for some networks.";
          example = "dn42";
          type = lib.types.str;
        };

        protocolFilter = lib.mkOption {
          default = [ ];
          description = "Information displayed in bgpmap.";
          example = [ "ospf" ];
          type = lib.types.listOf lib.types.str;
        };

        proxyPort = lib.mkOption {
          default = 8000;
          description = "Port bird-lg-proxy is running on.";
          type = lib.types.port;
        };

        servers = lib.mkOption {
          description = "Server name prefixes.";

          example = [
            "gigsgigscloud"
            "hostdare"
          ];

          type = lib.types.listOf lib.types.str;
        };

        timeout = lib.mkOption {
          default = 120;
          description = "Time before request timed out, in seconds.";
          type = lib.types.int;
        };

        titleBrand = lib.mkOption {
          default = "Bird-lg Go";
          description = "Prefix of page titles in browser tabs.";
          type = lib.types.str;
        };

        whois = lib.mkOption {
          default = "whois.verisign-grs.com";
          description = "Whois server for queries.";
          type = lib.types.str;
        };
      };

      group = lib.mkOption {
        default = "bird-lg";
        description = "Group to run the service.";
        type = lib.types.str;
      };

      proxy = {
        enable = lib.mkEnableOption "Bird Looking Glass Proxy";

        allowedIPs = lib.mkOption {
          default = [ ];
          description = "List of IPs or networks to allow (default all allowed).";

          example = [
            "192.168.25.52"
            "192.168.25.53"
            "192.168.0.0/24"
          ];

          type = lib.types.listOf lib.types.str;
        };

        birdSocket = lib.mkOption {
          default = "/var/run/bird/bird.ctl";
          description = "Bird control socket path.";
          type = lib.types.str;
        };

        extraArgs = lib.mkOption {
          default = [ ];

          description = ''
            Extra parameters documented [here](https://github.com/xddxdd/bird-lg-go#proxy).
          '';

          type = with lib.types; listOf str;
        };

        listenAddresses = lib.mkOption {
          default = "127.0.0.1:8000";
          description = "Address to listen on.";
          type = with lib.types; either str (listOf str);
        };

        traceroute = {
          binary = lib.mkOption {
            default = "${pkgs.traceroute}/bin/traceroute";
            defaultText = lib.literalExpression ''"''${pkgs.traceroute}/bin/traceroute"'';
            description = "Traceroute's binary path.";
            type = lib.types.str;
          };

          flags = lib.mkOption {
            default = [ ];
            description = "Flags for traceroute process";
            type = with lib.types; listOf str;
          };

          rawOutput = lib.mkOption {
            default = false;
            description = "Display traceroute output in raw format.";
            type = lib.types.bool;
          };
        };
      };

      user = lib.mkOption {
        default = "bird-lg";
        description = "User to run the service.";
        type = lib.types.str;
      };
    };
  };

  ###### implementation

  config = {
    systemd.services = {
      bird-lg-frontend = lib.mkIf cfg.frontend.enable {
        enable = true;
        after = [ "network.target" ];
        description = "Bird Looking Glass Frontend Webserver";

        script = ''
          ${cfg.package}/bin/frontend \
            ${lib.concatStringsSep " \\\n  " (argsAttrToList frontend_args)} \
            ${stringOrConcat " " cfg.frontend.extraArgs}
        '';

        serviceConfig = {
          Group = cfg.group;
          MemoryDenyWriteExecute = "yes";
          ProtectHome = "yes";
          ProtectSystem = "full";
          Restart = "on-failure";
          Type = "simple";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };

      bird-lg-proxy = lib.mkIf cfg.proxy.enable {
        enable = true;
        after = [ "network.target" ];
        description = "Bird Looking Glass Proxy";

        script = ''
          ${cfg.package}/bin/proxy \
            ${lib.concatStringsSep " \\\n  " (argsAttrToList proxy_args)} \
            ${stringOrConcat " " cfg.proxy.extraArgs}
        '';

        serviceConfig = {
          Group = cfg.group;
          MemoryDenyWriteExecute = "yes";
          ProtectHome = "yes";
          ProtectSystem = "full";
          Restart = "on-failure";
          Type = "simple";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

    users = lib.mkIf (cfg.frontend.enable || cfg.proxy.enable) {
      groups."bird-lg" = lib.mkIf (cfg.group == "bird-lg") { };

      users."bird-lg" = lib.mkIf (cfg.user == "bird-lg") {
        description = "Bird Looking Glass user";
        extraGroups = lib.optionals (config.services.bird.enable) [ "bird" ];
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    e1mo
    tchekda
  ];
}
