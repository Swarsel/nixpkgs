{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.pdns-recursor;

  oneOrMore = type: with types; either type (listOf type);
  valueType =
    with types;
    oneOf [
      int
      str
      bool
      path
    ];
  configType = with types; attrsOf (nullOr (oneOrMore valueType));

  serialize =
    val:
    with types;
    if str.check val then
      val
    else if int.check val then
      toString val
    else if path.check val then
      toString val
    else if bool.check val then
      boolToYesNo val
    else if builtins.isList val then
      (concatMapStringsSep "," serialize val)
    else
      "";

  settingsFormat = pkgs.formats.yaml { };

  mkDefaultAttrs = mapAttrs (n: v: mkDefault v);

  mkForwardZone = mapAttrsToList (
    zone: uri: {
      inherit zone;
      forwarders = [ uri ];
    }
  );

in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "pdns-recursor"
      "extraConfig"
    ] "To change extra Recursor settings use services.pdns-recursor.settings instead.")

    (mkRenamedOptionModule
      [
        "services"
        "pdns-recursor"
        "yaml-settings"
      ]
      [
        "services"
        "pdns-recursor"
        "settings"
      ]
    )

    (mkRemovedOptionModule
      [
        "services"
        "pdns-recursor"
        "old-settings"
      ]
      ''
        pdns-recursor has changed its configuration file format from pdns-recursor.conf
        (mapped to `services.pdns-recursor.old-settings`) to the newer pdns-recursor.yml
        (mapped to `services.pdns-recursor.settings`).

        Support for the older format has been removed, please migrate your settings over.
        See <https://doc.powerdns.com/recursor/yamlsettings.html>.
      ''
    )
  ];

  options.services.pdns-recursor = {
    enable = mkEnableOption "PowerDNS Recursor, a recursive DNS server";

    api.address = mkOption {
      default = "0.0.0.0";

      description = ''
        IP address Recursor REST API server will bind to.
      '';

      type = types.str;
    };

    api.allowFrom = mkOption {
      default = [
        "127.0.0.1"
        "::1"
      ];

      description = ''
        IP address ranges of clients allowed to make API requests.
      '';

      example = [
        "0.0.0.0/0"
        "::/0"
      ];

      type = types.listOf types.str;
    };

    api.port = mkOption {
      default = 8082;

      description = ''
        Port number Recursor REST API server will bind to.
      '';

      type = types.port;
    };

    dns.address = mkOption {
      default = [
        "::"
        "0.0.0.0"
      ];

      description = ''
        IP addresses Recursor DNS server will bind to.
      '';

      type = oneOrMore types.str;
    };

    dns.allowFrom = mkOption {
      default = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "100.64.0.0/10"
        "169.254.0.0/16"
        "192.168.0.0/16"
        "172.16.0.0/12"
        "::1/128"
        "fc00::/7"
        "fe80::/10"
      ];

      description = ''
        IP address ranges of clients allowed to make DNS queries.
      '';

      example = [
        "0.0.0.0/0"
        "::/0"
      ];

      type = types.listOf types.str;
    };

    dns.port = mkOption {
      default = 53;

      description = ''
        Port number Recursor DNS server will bind to.
      '';

      type = types.port;
    };

    dnssecValidation = mkOption {
      default = "validate";

      description = ''
        Controls the level of DNSSEC processing done by the PowerDNS Recursor.
        See <https://doc.powerdns.com/md/recursor/dnssec/> for a detailed explanation.
      '';

      type = types.enum [
        "off"
        "process-no-validate"
        "process"
        "log-fail"
        "validate"
      ];
    };

    exportHosts = mkOption {
      default = false;

      description = ''
        Whether to export names and IP addresses defined in /etc/hosts.
      '';

      type = types.bool;
    };

    forwardZones = mkOption {
      default = { };

      description = ''
        DNS zones to be forwarded to other authoritative servers.
      '';

      type = types.attrs;
    };

    forwardZonesRecurse = mkOption {
      default = { };

      description = ''
        DNS zones to be forwarded to other recursive servers.
      '';

      example = {
        eth = "[::1]:5353";
      };

      type = types.attrs;
    };

    luaConfig = mkOption {
      default = "";

      description = ''
        The content Lua configuration file for PowerDNS Recursor. See
        <https://doc.powerdns.com/recursor/lua-config/index.html>.
      '';

      type = types.lines;
    };

    serveRFC1918 = mkOption {
      default = true;

      description = ''
        Whether to directly resolve the RFC1918 reverse-mapping domains:
        `10.in-addr.arpa`,
        `168.192.in-addr.arpa`,
        `16-31.172.in-addr.arpa`
        This saves load on the AS112 servers.
      '';

      type = types.bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        PowerDNS Recursor settings. Use this option to configure Recursor
        settings not exposed in a NixOS option or to bypass one.
        See the full documentation at
        <https://doc.powerdns.com/recursor/yamlsettings.html>
        for the available options.
      '';

      example = literalExpression ''
        {
          loglevel = 8;
          log-common-errors = true;
        }
      '';

      type = settingsFormat.type;
    };
  };

  config = mkIf cfg.enable {

    environment.etc."/pdns-recursor/recursor.yml".source =
      settingsFormat.generate "recursor.yml" cfg.settings;

    networking.resolvconf.useLocalResolver = lib.mkDefault true;

    services.pdns-recursor.settings = {
      dnssec = mkDefaultAttrs {
        validation = cfg.dnssecValidation;
      };

      incoming = mkDefaultAttrs {
        allow_from = cfg.dns.allowFrom;
        listen = cfg.dns.address;
        port = cfg.dns.port;
      };

      logging = mkDefaultAttrs {
        disable_syslog = true;
        timestamp = false;
      };

      recursor = mkDefaultAttrs {
        daemon = false;
        export_etc_hosts = cfg.exportHosts;
        forward_zones = mkForwardZone cfg.forwardZones;
        forward_zones_recurse = mkForwardZone cfg.forwardZonesRecurse;
        lua_config_file = pkgs.writeText "recursor.lua" cfg.luaConfig;
        serve_rfc1918 = cfg.serveRFC1918;
        write_pid = false;
      };

      webservice = mkDefaultAttrs {
        address = cfg.api.address;
        allow_from = cfg.api.allowFrom;
        port = cfg.api.port;
      };
    };

    systemd.packages = [ pkgs.pdns-recursor ];

    systemd.services.pdns-recursor = {
      restartTriggers = [ config.environment.etc."/pdns-recursor/recursor.yml".source ];
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.pdns-recursor = { };

    users.users.pdns-recursor = {
      description = "PowerDNS Recursor daemon user";
      group = "pdns-recursor";
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
