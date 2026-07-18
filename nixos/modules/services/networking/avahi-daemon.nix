{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.avahi;

  avahiDaemonConf =
    with cfg;
    pkgs.writeText "avahi-daemon.conf" ''
      [server]
      ${
        # Users can set `networking.hostName' to the empty string, when getting
        # a host name from DHCP.  In that case, let Avahi take whatever the
        # current host name is; setting `host-name' to the empty string in
        # `avahi-daemon.conf' would be invalid.
        lib.optionalString (hostName != "") "host-name=${hostName}"
      }
      browse-domains=${lib.concatStringsSep ", " browseDomains}
      use-ipv4=${lib.boolToYesNo ipv4}
      use-ipv6=${lib.boolToYesNo ipv6}
      ${lib.optionalString (
        allowInterfaces != null
      ) "allow-interfaces=${lib.concatStringsSep "," allowInterfaces}"}
      ${lib.optionalString (
        denyInterfaces != null
      ) "deny-interfaces=${lib.concatStringsSep "," denyInterfaces}"}
      ${lib.optionalString (domainName != null) "domain-name=${domainName}"}
      allow-point-to-point=${lib.boolToYesNo allowPointToPoint}
      ${lib.optionalString (cacheEntriesMax != null) "cache-entries-max=${toString cacheEntriesMax}"}

      [wide-area]
      enable-wide-area=${lib.boolToYesNo wideArea}

      [publish]
      disable-publishing=${lib.boolToYesNo (!publish.enable)}
      disable-user-service-publishing=${lib.boolToYesNo (!publish.userServices)}
      publish-addresses=${lib.boolToYesNo (publish.userServices || publish.addresses)}
      publish-hinfo=${lib.boolToYesNo publish.hinfo}
      publish-workstation=${lib.boolToYesNo publish.workstation}
      publish-domain=${lib.boolToYesNo publish.domain}

      [reflector]
      enable-reflector=${lib.boolToYesNo reflector}
      ${extraConfig}
    '';
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "avahi" "interfaces" ]
      [ "services" "avahi" "allowInterfaces" ]
    )
    (lib.mkRenamedOptionModule [ "services" "avahi" "nssmdns" ] [ "services" "avahi" "nssmdns4" ])
  ];

  options.services.avahi = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to run the Avahi daemon, which allows Avahi clients
        to use Avahi's service discovery facilities and also allows
        the local machine to advertise its presence and services
        (through the mDNS responder implemented by `avahi-daemon`).
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "avahi" { };

    allowInterfaces = lib.mkOption {
      default = null;

      description = ''
        List of network interfaces that should be used by the {command}`avahi-daemon`.
        Other interfaces will be ignored. If `null`, all local interfaces
        except loopback and point-to-point will be used.
      '';

      type = lib.types.nullOr (lib.types.listOf lib.types.str);
    };

    allowPointToPoint = lib.mkOption {
      default = false;

      description = ''
        Whether to use POINTTOPOINT interfaces. Might make mDNS unreliable due to usually large
        latencies with such links and opens a potential security hole by allowing mDNS access from Internet
        connections.
      '';

      type = lib.types.bool;
    };

    browseDomains = lib.mkOption {
      default = [ ];

      description = ''
        List of non-local DNS domains to be browsed.
      '';

      example = [
        "0pointer.de"
        "zeroconf.org"
      ];

      type = lib.types.listOf lib.types.str;
    };

    cacheEntriesMax = lib.mkOption {
      default = null;

      description = ''
        Number of resource records to be cached per interface. Use 0 to
        disable caching. Avahi daemon defaults to 4096 if not set.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    debug = lib.mkEnableOption "debug logging";

    denyInterfaces = lib.mkOption {
      default = null;

      description = ''
        List of network interfaces that should be ignored by the
        {command}`avahi-daemon`. Other unspecified interfaces will be used,
        unless {option}`allowInterfaces` is set. This option takes precedence
        over {option}`allowInterfaces`.
      '';

      type = lib.types.nullOr (lib.types.listOf lib.types.str);
    };

    domainName = lib.mkOption {
      default = "local";

      description = ''
        Domain name for all advertisements.
      '';

      type = lib.types.str;
    };

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra config to append to avahi-daemon.conf.
      '';

      type = lib.types.lines;
    };

    extraServiceFiles = lib.mkOption {
      default = { };

      description = ''
        Specify custom service definitions which are placed in the avahi service directory.
        See the {manpage}`avahi.service(5)` manpage for detailed information.
      '';

      example = lib.literalExpression ''
        {
          ssh = "''${pkgs.avahi}/etc/avahi/services/ssh.service";
          smb = '''
            <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">%h</name>
              <service>
                <type>_smb._tcp</type>
                <port>445</port>
              </service>
            </service-group>
          ''';
        }
      '';

      type = with lib.types; attrsOf (either str path);
    };

    hostName = lib.mkOption {
      default = config.networking.hostName;
      defaultText = lib.literalExpression "config.networking.hostName";

      description = ''
        Host name advertised on the LAN. If not set, avahi will use the value
        of {option}`config.networking.hostName`.
      '';

      type = lib.types.str;
    };

    ipv4 = lib.mkOption {
      default = true;
      description = "Whether to use IPv4.";
      type = lib.types.bool;
    };

    ipv6 = lib.mkOption {
      default = config.networking.enableIPv6;
      defaultText = lib.literalExpression "config.networking.enableIPv6";
      description = "Whether to use IPv6.";
      type = lib.types.bool;
    };

    nssmdns4 = lib.mkOption {
      default = false;

      description = ''
        Whether to enable the mDNS NSS (Name Service Switch) plug-in for IPv4.
        Enabling it allows applications to resolve names in the `.local`
        domain by transparently querying the Avahi daemon.
      '';

      type = lib.types.bool;
    };

    nssmdns6 = lib.mkOption {
      default = false;

      description = ''
        Whether to enable the mDNS NSS (Name Service Switch) plug-in for IPv6.
        Enabling it allows applications to resolve names in the `.local`
        domain by transparently querying the Avahi daemon.

        ::: {.note}
        Due to the fact that most mDNS responders only register local IPv4 addresses,
        most user want to leave this option disabled to avoid long timeouts when applications first resolve the none existing IPv6 address.
        :::
      '';

      type = lib.types.bool;
    };

    nssmdnsFull = lib.mkOption {
      default = false;

      description = ''
        Whether to enable the full mDNS NSS (Name Service Switch) plug-in.

        By default, only the minimal module is enabled. The minimal module
        will only resolve `.local` domains and only perform reverse hostname
        lookups for `169.254.0.0/16`. The full module will use mDNS to resolve any
        domain allowed by [`/etc/mdns.allow`][1] and will perform reverse hostname
        lookups for any IP address.

        [1]: https://github.com/avahi/nss-mdns/tree/master#etcmdnsallow

        ::: {.note}
        Enabling this option will introduce a 5 second delay to failed reverse
        hostname lookups. For example, this will often add a 5 second delay to
        ping.
        :::
      '';

      type = lib.types.bool;
    };

    openFirewall = lib.mkOption {
      default = true;

      description = ''
        Whether to open the firewall for UDP port 5353.
        Disabling this setting also disables discovering of network devices.
      '';

      type = lib.types.bool;
    };

    publish = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to allow publishing in general.";
        type = lib.types.bool;
      };

      addresses = lib.mkOption {
        default = false;
        description = "Whether to register mDNS address records for all local IP addresses.";
        type = lib.types.bool;
      };

      domain = lib.mkOption {
        default = false;
        description = "Whether to announce the locally used domain name for browsing by other hosts.";
        type = lib.types.bool;
      };

      hinfo = lib.mkOption {
        default = false;

        description = ''
          Whether to register a mDNS HINFO record which contains information about the
          local operating system and CPU.
        '';

        type = lib.types.bool;
      };

      userServices = lib.mkOption {
        default = false;
        description = "Whether to publish user services. Will set `addresses=true`.";
        type = lib.types.bool;
      };

      workstation = lib.mkOption {
        default = false;

        description = ''
          Whether to register a service of type "_workstation._tcp" on the local LAN.
        '';

        type = lib.types.bool;
      };
    };

    reflector = lib.mkOption {
      default = false;
      description = "Reflect incoming mDNS requests to all allowed network interfaces.";
      type = lib.types.bool;
    };

    wideArea = lib.mkOption {
      default = false;

      description = ''
        Whether to enable wide-area service discovery.

        It is recommended to keep this options disabled as it exposes the system to `CVE-2024-52615`/`GHSA-x6vp-f33h-h32g`.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.nssmdnsFull -> (cfg.nssmdns4 || cfg.nssmdns6);

        message = ''
          `services.avahi.nssmdnsFull` requires one or both of `services.avahi.nssmdns4` and/or `services.avahi.nssmdns6` to be enabled.
        '';
      }
    ];

    environment.etc = (
      lib.mapAttrs' (
        n: v:
        lib.nameValuePair "avahi/services/${n}.service" {
          ${if lib.types.path.check v then "source" else "text"} = v;
        }
      ) cfg.extraServiceFiles
    );

    environment.systemPackages = [ cfg.package ];
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ 5353 ];
    services.dbus.enable = true;
    services.dbus.packages = [ cfg.package ];

    system.nssDatabases.hosts =
      let
        mdns =
          if (cfg.nssmdns4 && cfg.nssmdns6) then
            "mdns"
          else if (!cfg.nssmdns4 && cfg.nssmdns6) then
            "mdns6"
          else if (cfg.nssmdns4 && !cfg.nssmdns6) then
            "mdns4"
          else
            "";
      in
      lib.optionals (cfg.nssmdns4 || cfg.nssmdns6) (
        lib.mkMerge [
          (lib.mkBefore [ "${mdns}_minimal [NOTFOUND=return]" ]) # before resolve
          (lib.mkAfter (lib.optional cfg.nssmdnsFull "${mdns}")) # after dns
        ]
      );

    system.nssModules = lib.optional (cfg.nssmdns4 || cfg.nssmdns6) pkgs.nssmdns;

    systemd.services.avahi-daemon = {
      description = "Avahi mDNS/DNS-SD Stack";

      documentation = [
        "man:avahi-daemon(8)"
        "man:avahi-daemon.conf(5)"
        "man:avahi.hosts(5)"
        "man:avahi.service(5)"
      ];

      # Make NSS modules visible so that `avahi_nss_support ()' can
      # return a sensible value.
      environment.LD_LIBRARY_PATH = config.system.nssModules.path;

      path = [
        pkgs.coreutils
        cfg.package
      ];

      requires = [ "avahi-daemon.socket" ];

      serviceConfig = {
        BusName = "org.freedesktop.Avahi";

        # Hardening
        CapabilityBoundingSet = [
          # https://github.com/avahi/avahi/blob/v0.9-rc1/avahi-daemon/caps.c#L38
          "CAP_SYS_CHROOT"
          "CAP_SETUID"
          "CAP_SETGID"
        ];

        ConfigurationDirectory = "avahi/services";
        DevicePolicy = "closed";
        ExecStart = "${cfg.package}/sbin/avahi-daemon --syslog -f ${avahiDaemonConf} ${lib.optionalString cfg.debug "--debug"}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        NotifyAccess = "main";
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = false;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "@chown setgroups setresuid"
        ];

        Type = "dbus";
        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.sockets.avahi-daemon = {
      after = [
        # Ensure that `/run/avahi-daemon` owned by `avahi` is created by `systemd.tmpfiles.rules` before the `avahi-daemon.socket`,
        # otherwise `avahi-daemon.socket` will automatically create it owned by `root`, which will cause `avahi-daemon.service` to fail.
        "systemd-tmpfiles-setup.service"
      ];

      description = "Avahi mDNS/DNS-SD Stack Activation Socket";
      listenStreams = [ "/run/avahi-daemon/socket" ];
      wantedBy = [ "sockets.target" ];
    };

    systemd.tmpfiles.rules = [ "d /run/avahi-daemon - avahi avahi -" ];
    users.groups.avahi = { };

    users.users.avahi = {
      description = "avahi-daemon privilege separation user";
      group = "avahi";
      home = "/var/empty";
      isSystemUser = true;
    };

    warnings = [
      (lib.mkIf cfg.wideArea "Enabling `services.avahi.wideArea` exposes this system to `CVE-2024-52615`.")
    ];
  };
}
