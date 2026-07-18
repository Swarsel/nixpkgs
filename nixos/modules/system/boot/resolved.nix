{
  config,
  lib,
  utils,
  ...
}:
let
  inherit (utils.systemdUtils.lib) settingsToSections;
  inherit (utils.systemdUtils.unitOptions) unitOption;

  inherit (lib)
    concatStringsSep
    elem
    isList
    literalExpression
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    mkOption
    mkOrder
    mkRenamedOptionModule
    mkRemovedOptionModule
    nameValuePair
    optionalAttrs
    types
    ;

  cfg = config.services.resolved;

  dnsmasqResolve = config.services.dnsmasq.enable && config.services.dnsmasq.resolveLocalQueries;

  transformSettings =
    settings:
    lib.mapAttrs (
      key: value:
      # concat lists for options that should result in space-separated values
      if
        elem key [
          "DNS"
          "Domains"
          "FallbackDNS"
        ]
        && isList value
      then
        concatStringsSep " " value
      else
        value
    ) settings;

  resolvedConf = settingsToSections (transformSettings cfg.settings);
in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "resolved" "fallbackDns" ]
      [ "services" "resolved" "settings" "Resolve" "FallbackDNS" ]
    )
    (mkRenamedOptionModule
      [ "services" "resolved" "domains" ]
      [ "services" "resolved" "settings" "Resolve" "Domains" ]
    )
    (mkRenamedOptionModule
      [ "services" "resolved" "llmnr" ]
      [ "services" "resolved" "settings" "Resolve" "LLMNR" ]
    )
    (mkRenamedOptionModule
      [ "services" "resolved" "dnssec" ]
      [ "services" "resolved" "settings" "Resolve" "DNSSEC" ]
    )
    (mkRenamedOptionModule
      [ "services" "resolved" "dnsovertls" ]
      [ "services" "resolved" "settings" "Resolve" "DNSOverTLS" ]
    )
    (mkRemovedOptionModule [
      "services"
      "resolved"
      "extraConfig"
    ] "Use services.resolved.settings instead")
  ];

  options = {
    boot.initrd.services.resolved.enable = mkOption {
      default = config.boot.initrd.systemd.network.enable;
      defaultText = "config.boot.initrd.systemd.network.enable";

      description = ''
        Whether to enable resolved for stage 1 networking.
        Uses the toplevel 'services.resolved' options for 'resolved.conf'
      '';
    };

    services.resolved = {
      enable = lib.mkEnableOption "the Systemd DNS resolver daemon (systemd-resolved)";

      dnsDelegates = mkOption {
        default = { };

        description = ''
          dns-delegate files to be created.
          See {manpage}`systemd.dns-delegate(5)` for more info.
        '';

        type = types.attrsOf (
          types.submodule {
            options.Delegate = mkOption {
              description = ''
                Settings option for systemd dns-delegate files.
                See {manpage}`systemd.dns-delegate(5)` for all available options.
              '';

              type = types.submodule {
                freeformType = types.attrsOf unitOption;
              };
            };
          }
        );
      };

      settings.Resolve = mkOption {
        default = { };

        description = ''
          Settings option for systemd-resolved.
          See {manpage}`resolved.conf(5)` for all available options.
        '';

        type = types.submodule {
          options = {
            DNS = mkOption {
              default = config.networking.nameservers;
              defaultText = literalExpression "config.networking.nameservers";

              description = ''
                List of IP addresses to query as recursive DNS resolvers.
              '';

              type = unitOption;
            };

            DNSOverTLS = mkOption {
              default = false;

              description = ''
                Whether to use TLS encryption for DNS queries. Requires
                nameservers that support DNS-over-TLS.
              '';

              type = unitOption;
            };

            DNSSEC = mkOption {
              default = false;

              description = ''
                Whether to validate DNSSEC for DNS lookups.
              '';

              type = unitOption;
            };

            Domains = mkOption {
              default = config.networking.search;
              defaultText = literalExpression "config.networking.search";

              description = ''
                List of search domains used to complete unqualified name lookups.
              '';

              example = [
                "scope.example.com"
                "example.com"
              ];

              type = unitOption;
            };
          };

          freeformType = types.attrsOf unitOption;
        };
      };

    };

  };

  config = mkMerge [
    (mkIf cfg.enable {

      assertions = [
        {
          assertion = !config.networking.useHostResolvConf;
          message = "Using host resolv.conf is not supported with systemd-resolved";
        }
      ];

      environment.etc = {
        # symlink the dynamic stub resolver of resolv.conf as recommended by upstream:
        # https://www.freedesktop.org/software/systemd/man/systemd-resolved.html#/etc/resolv.conf
        "resolv.conf".source = "/run/systemd/resolve/stub-resolv.conf";
        "systemd/resolved.conf".text = resolvedConf;
      }
      // optionalAttrs dnsmasqResolve {
        "dnsmasq-resolv.conf".source = "/run/systemd/resolve/resolv.conf";
      }
      // mapAttrs' (
        name: value:
        nameValuePair "systemd/dns-delegate.d/${name}.dns-delegate" {
          text = settingsToSections (transformSettings value);
        }
      ) cfg.dnsDelegates;

      # If networkmanager is enabled, ask it to interface with resolved.
      networking.networkmanager.dns = "systemd-resolved";
      # Since we explicitly provide a resolv.conf, disable resolvconf
      networking.resolvconf.enable = false;
      # ... but we still set the package for correct compatibility.
      networking.resolvconf.package = config.systemd.package;

      nix.firewall.extraNftablesRules = [
        "ip daddr { 127.0.0.53, 127.0.0.54 } udp dport 53 accept comment \"systemd-resolved listening IPs\""
      ];

      # add resolve to nss hosts database if enabled and nscd enabled
      # system.nssModules is configured in nixos/modules/system/boot/systemd.nix
      # added with order 501 to allow modules to go before with mkBefore
      system.nssDatabases.hosts = (mkOrder 501 [ "resolve [!UNAVAIL=return]" ]);

      systemd.additionalUpstreamSystemUnits = [
        "systemd-resolved.service"
        "systemd-resolved-monitor.socket"
        "systemd-resolved-varlink.socket"
      ];

      systemd.services.systemd-resolved = {
        aliases = [ "dbus-org.freedesktop.resolve1.service" ];

        reloadTriggers = [
          config.environment.etc."systemd/resolved.conf".source
        ]
        ++ mapAttrsToList (
          name: _: config.environment.etc."systemd/dns-delegate.d/${name}.dns-delegate".source
        ) cfg.dnsDelegates;

        stopIfChanged = false;
        wantedBy = [ "sysinit.target" ];
      };

      users.users.systemd-resolve.group = "systemd-resolve";

    })

    (mkIf config.boot.initrd.services.resolved.enable {

      assertions = [
        {
          assertion = config.boot.initrd.systemd.enable;
          message = "'boot.initrd.services.resolved.enable' can only be enabled with systemd stage 1.";
        }
      ];

      boot.initrd.systemd = {
        additionalUpstreamUnits = [
          "systemd-resolved.service"
          "systemd-resolved-monitor.socket"
          "systemd-resolved-varlink.socket"
        ];

        contents = {
          "/etc/systemd/resolved.conf".text = resolvedConf;
        };

        groups.systemd-resolve = { };

        services.systemd-resolved = {
          aliases = [ "dbus-org.freedesktop.resolve1.service" ];
          wantedBy = [ "sysinit.target" ];
        };

        storePaths = [ "${config.boot.initrd.systemd.package}/lib/systemd/systemd-resolved" ];

        tmpfiles.settings.systemd-resolved-stub."/etc/resolv.conf".L.argument =
          "/run/systemd/resolve/stub-resolv.conf";

        users.systemd-resolve = { };
      };

    })
  ];

}
