{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.unbound;

  toOption =
    indent: n: v:
    "${indent}${toString n}: ${v}";

  toConf =
    indent: n: v:
    if builtins.isFloat v then
      (toOption indent n (builtins.toJSON v))
    else if isInt v then
      (toOption indent n (toString v))
    else if isBool v then
      (toOption indent n (lib.boolToYesNo v))
    else if isString v then
      (toOption indent n v)
    else if isList v then
      (concatMapStringsSep "\n" (toConf indent n) v)
    else if isAttrs v then
      (concatStringsSep "\n" ([ "${indent}${n}:" ] ++ (mapAttrsToList (toConf "${indent}  ") v)))
    else
      throw (traceSeq v "services.unbound.settings: unexpected type");

  confNoServer = concatStringsSep "\n" (
    (mapAttrsToList (toConf "") (removeAttrs cfg.settings [ "server" ])) ++ [ "" ]
  );
  confServer = concatStringsSep "\n" (
    mapAttrsToList (toConf "  ") (removeAttrs cfg.settings.server [ "define-tag" ])
  );

  confFileUnchecked = pkgs.writeText "unbound.conf" ''
    server:
    ${optionalString (cfg.settings.server.define-tag != "") (
      toOption "  " "define-tag" cfg.settings.server.define-tag
    )}
    ${confServer}
    ${confNoServer}
  '';
  confFile =
    if cfg.checkconf then
      pkgs.runCommand "unbound-checkconf"
        {
          preferLocalBuild = true;
        }
        ''
          cp ${confFileUnchecked} unbound.conf

          # fake stateDir which is not accessible in the sandbox
          mkdir -p $PWD/state
          sed -i unbound.conf \
            -e '/auto-trust-anchor-file/d' \
            -e "s|${cfg.stateDir}|$PWD/state|"
          ${cfg.package}/bin/unbound-checkconf unbound.conf

          cp ${confFileUnchecked} $out
        ''
    else
      confFileUnchecked;

  rootTrustAnchorFile = "${cfg.stateDir}/root.key";

in
{

  imports = [
    (mkRenamedOptionModule
      [ "services" "unbound" "interfaces" ]
      [ "services" "unbound" "settings" "server" "interface" ]
    )
    (mkChangedOptionModule
      [ "services" "unbound" "allowedAccess" ]
      [ "services" "unbound" "settings" "server" "access-control" ]
      (
        config:
        map (value: "${value} allow") (getAttrFromPath [ "services" "unbound" "allowedAccess" ] config)
      )
    )
    (mkRemovedOptionModule [ "services" "unbound" "forwardAddresses" ] ''
      Add a new setting:
      services.unbound.settings.forward-zone = [{
        name = ".";
        forward-addr = [ # Your current services.unbound.forwardAddresses ];
      }];
      If any of those addresses are local addresses (127.0.0.1 or ::1), you must
      also set services.unbound.settings.server.do-not-query-localhost to false.
    '')
    (mkRemovedOptionModule [ "services" "unbound" "extraConfig" ] ''
      You can use services.unbound.settings to add any configuration you want.
    '')
  ];

  ###### interface
  options = {
    services.unbound = {

      enable = mkEnableOption "Unbound domain name server";
      package = mkPackageOption pkgs "unbound-with-systemd" { };

      checkconf = mkOption {
        default = !cfg.settings ? include && !cfg.settings ? remote-control;
        defaultText = "!services.unbound.settings ? include && !services.unbound.settings ? remote-control";

        description = ''
          Whether to check the resulting config file with unbound checkconf for syntax errors.

          If settings.include is used, this options is disabled, as the import can likely not be accessed at build time.
          If settings.remote-control is used, this option is disabled, too as the control-key-file, server-cert-file and server-key-file cannot be accessed at build time.
        '';

        type = types.bool;
      };

      enableRootTrustAnchor = mkOption {
        default = true;
        description = "Use and update root trust anchor for DNSSEC validation.";
        type = types.bool;
      };

      group = mkOption {
        default = "unbound";
        description = "Group under which unbound runs.";
        type = types.str;
      };

      localControlSocketPath = mkOption {
        default = null;

        description = ''
          When not set to `null` this option defines the path
          at which the unbound remote control socket should be created at. The
          socket will be owned by the unbound user (`unbound`)
          and group will be `nogroup`.

          Users that should be permitted to access the socket must be in the
          `config.services.unbound.group` group.

          If this option is `null` remote control will not be
          enabled. Unbounds default values apply.
        '';

        example = "/run/unbound/unbound.ctl";
        # FIXME: What is the proper type here so users can specify strings,
        # paths and null?
        # My guess would be `types.nullOr (types.either types.str types.path)`
        # but I haven't verified yet.
        type = types.nullOr types.str;
      };

      resolveLocalQueries = mkOption {
        default = true;

        description = ''
          Whether unbound should resolve local queries (i.e. add 127.0.0.1 to
          /etc/resolv.conf).
        '';

        type = types.bool;
      };

      settings = mkOption {
        default = { };

        description = ''
          Declarative Unbound configuration
          See the {manpage}`unbound.conf(5)` manpage for a list of
          available options.
        '';

        example = literalExpression ''
          {
            server = {
              interface = [ "127.0.0.1" ];
            };
            forward-zone = [
              {
                name = ".";
                forward-addr = "1.1.1.1@853#cloudflare-dns.com";
              }
              {
                name = "example.org.";
                forward-addr = [
                  "1.1.1.1@853#cloudflare-dns.com"
                  "1.0.0.1@853#cloudflare-dns.com"
                ];
              }
            ];
            remote-control.control-enable = true;
          };
        '';

        type =
          with types;
          submodule {

            options = {
              remote-control.control-enable = mkOption {
                default = false;
                internal = true;
                type = bool;
              };
            };

            freeformType =
              let
                validSettingsPrimitiveTypes = oneOf [
                  int
                  str
                  bool
                  float
                ];
                validSettingsTypes = oneOf [
                  validSettingsPrimitiveTypes
                  (listOf validSettingsPrimitiveTypes)
                ];
                settingsType = oneOf [
                  str
                  (attrsOf validSettingsTypes)
                ];
              in
              attrsOf (oneOf [
                settingsType
                (listOf settingsType)
              ])
              // {
                description = ''
                  unbound.conf configuration type. The format consist of an attribute
                  set of settings. Each settings can be either one value, a list of
                  values or an attribute set. The allowed values are integers,
                  strings, booleans or floats.
                '';
              };
          };
      };

      stateDir = mkOption {
        default = "/var/lib/unbound";
        description = "Directory holding all state for unbound to run.";
        type = types.path;
      };

      user = mkOption {
        default = "unbound";
        description = "User account under which unbound runs.";
        type = types.str;
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {

    environment.etc."unbound/unbound.conf".source = confFile;
    environment.systemPackages = [ cfg.package ];

    networking = mkIf cfg.resolveLocalQueries {
      resolvconf = {
        useLocalResolver = mkDefault true;
      };
    };

    services.unbound.settings = {
      remote-control = {
        control-cert-file = mkDefault "${cfg.stateDir}/unbound_control.pem";
        control-enable = mkDefault false;
        control-interface = mkDefault ([ "127.0.0.1" ] ++ (optional config.networking.enableIPv6 "::1"));
        control-key-file = mkDefault "${cfg.stateDir}/unbound_control.key";
        server-cert-file = mkDefault "${cfg.stateDir}/unbound_server.pem";
        server-key-file = mkDefault "${cfg.stateDir}/unbound_server.key";
      }
      // optionalAttrs (cfg.localControlSocketPath != null) {
        control-enable = true;
        control-interface = cfg.localControlSocketPath;
      };

      server = {
        access-control = mkDefault (
          [ "127.0.0.0/8 allow" ] ++ (optional config.networking.enableIPv6 "::1/128 allow")
        );

        auto-trust-anchor-file = mkIf cfg.enableRootTrustAnchor rootTrustAnchorFile;
        chroot = ''""'';
        define-tag = mkDefault "";
        directory = mkDefault cfg.stateDir;
        # when running under systemd there is no need to daemonize
        do-daemonize = false;
        interface = mkDefault ([ "127.0.0.1" ] ++ (optional config.networking.enableIPv6 "::1"));
        # prevent race conditions on system startup when interfaces are not yet
        # configured
        ip-freebind = mkDefault true;
        pidfile = ''""'';
        tls-cert-bundle = mkDefault config.security.pki.caBundle;
        username = ''""'';
      };
    };

    systemd.services.unbound = {
      after = [ "network.target" ];
      before = [ "nss-lookup.target" ];
      description = "Unbound recursive Domain Name Server";
      path = mkIf cfg.settings.remote-control.control-enable [ pkgs.openssl ];

      preStart = ''
        ${optionalString cfg.enableRootTrustAnchor ''
          ${cfg.package}/bin/unbound-anchor -a ${rootTrustAnchorFile} || echo "Root anchor updated!"
        ''}
        ${optionalString cfg.settings.remote-control.control-enable ''
          ${cfg.package}/bin/unbound-control-setup -d ${cfg.stateDir}
        ''}
      '';

      restartTriggers = [
        confFile
      ];

      serviceConfig = {
        AmbientCapabilities = [
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW" # needed if ip-transparent is set to true
        ];

        CapabilityBoundingSet = [
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
        ];

        ConfigurationDirectory = "unbound";
        ExecReload = "+/run/current-system/sw/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/unbound -p -d -c /etc/unbound/unbound.conf";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        NotifyAccess = "main";
        PrivateDevices = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.stateDir ];
        Restart = "on-failure";
        RestartSec = "5s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "unbound";
        StateDirectory = "unbound";
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        Type = "notify";
        User = cfg.user;
      };

      wantedBy = [
        "multi-user.target"
        "nss-lookup.target"
      ];
    };

    users.groups = mkIf (cfg.group == "unbound") {
      unbound = { };
    };

    users.users = mkIf (cfg.user == "unbound") {
      unbound = {
        description = "unbound daemon user";
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
