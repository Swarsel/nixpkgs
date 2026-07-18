{
  config,
  lib,
  pkgs,
  ...
}:

with {
  inherit (lib)
    elemAt
    getExe
    hasAttrByPath
    mkEnableOption
    mkIf
    mkOption
    strings
    types
    ;
};

let
  mkDefaults = lib.mapAttrsRecursive (n: v: lib.mkDefault v);

  cfg = config.services.pihole-ftl;

  piholeScript = pkgs.writeScriptBin "pihole" ''
    sudo=exec
    if [[ "$USER" != '${cfg.user}' ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${cfg.user}'
    fi
    $sudo ${getExe cfg.piholePackage} "$@"
  '';

  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "pihole.toml" cfg.settings;
in
{
  options.services.pihole-ftl = {
    enable = mkEnableOption "Pi-hole FTL";
    package = lib.mkPackageOption pkgs "pihole-ftl" { };

    configDirectory = mkOption {
      default = "/etc/pihole";

      description = ''
        Path for pihole configuration.
        pihole does not currently support any path other than /etc/pihole.
      '';

      internal = true;
      readOnly = true;
      type = types.path;
    };

    group = mkOption {
      default = "pihole";
      description = "Group to run the service as.";
      type = types.str;
    };

    lists =
      let
        adlistType = types.submodule {
          options = {
            description = mkOption {
              default = "";
              description = "Description of the list";
              type = types.str;
            };

            enabled = mkOption {
              default = true;
              description = "Whether this list is enabled";
              type = types.bool;
            };

            type = mkOption {
              default = "block";
              description = "Whether domains on this list should be explicitly allowed, or blocked";

              type = types.enum [
                "allow"
                "block"
              ];
            };

            url = mkOption {
              description = "URL of the domain list";
              type = types.str;
            };
          };
        };
      in
      mkOption {
        default = [ ];
        description = "Deny (or allow) domain lists to use";

        example = [
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          }
        ];

        type = with types; listOf adlistType;
      };

    logDirectory = mkOption {
      default = "/var/log/pihole";
      description = "Path for Pi-hole log files";
      type = types.path;
    };

    macvendorURL = mkOption {
      default = "https://ftl.pi-hole.net/macvendor.db";

      description = ''
        URL from which to download the macvendor.db file.
      '';

      type = types.str;
    };

    openFirewallDHCP = mkOption {
      default = false;
      description = "Open ports in the firewall for pihole-FTL's DHCP server.";
      type = types.bool;
    };

    openFirewallDNS = mkOption {
      default = false;
      description = "Open ports in the firewall for pihole-FTL's DNS server.";
      type = types.bool;
    };

    openFirewallWebserver = mkOption {
      default = false;

      description = ''
        Open ports in the firewall for pihole-FTL's webserver, as configured in `settings.webserver.port`.
      '';

      type = types.bool;
    };

    pihole = mkOption {
      default = piholeScript;
      description = "Pi-hole admin script";
      internal = true;
      type = types.package;
    };

    piholePackage = lib.mkPackageOption pkgs "pihole" { };

    privacyLevel = mkOption {
      default = 0;

      description = ''
        Level of detail in generated statistics. 0 enables full statistics, 3
        shows only anonymous statistics.

        See [the documentation](https://docs.pi-hole.net/ftldns/privacylevels).

        Also see services.dnsmasq.settings.log-queries to completely disable
        query logging.
      '';

      example = 3;
      type = types.numbers.between 0 3;
    };

    queryLogDeleter = {
      enable = mkEnableOption "Pi-hole FTL DNS query log deleter";

      age = mkOption {
        default = 90;

        description = ''
          Delete DNS query logs older than this many days, if
          [](#opt-services.pihole-ftl.queryLogDeleter.enable) is on.
        '';

        type = types.int;
      };

      interval = mkOption {
        default = "weekly";

        description = ''
          How often the query log deleter is run. See systemd.time(7) for more
          information about the format.
        '';

        type = types.str;
      };
    };

    settings = mkOption {
      description = ''
        Configuration options for pihole.toml.
        See the upstream [documentation](https://docs.pi-hole.net/ftldns/configfile).
      '';

      type = settingsFormat.type;
    };

    stateDirectory = mkOption {
      default = "/var/lib/pihole";

      description = ''
        Path for pihole state files.
      '';

      type = types.path;
    };

    useDnsmasqConfig = mkOption {
      default = false;

      description = ''
        Import options defined in [](#opt-services.dnsmasq.settings) via
        misc.dnsmasq_lines in Pi-hole's config.
      '';

      type = types.bool;
    };

    user = mkOption {
      default = "pihole";
      description = "User to run the service as.";
      type = types.str;
    };

    webserverEnabled = mkOption {
      default = (
        (hasAttrByPath [ "webserver" "port" ] cfg.settings)
        && !builtins.elem cfg.settings.webserver.port [
          ""
          null
        ]
      );

      description = "Whether the webserver is enabled.";
      internal = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.dnsmasq.enable;
        message = "pihole-ftl conflicts with dnsmasq. Please disable one of them.";
      }

      {
        assertion = builtins.length cfg.lists == 0 || cfg.webserverEnabled;

        message = ''
          The Pi-hole webserver must be enabled for lists set in services.pihole-ftl.lists to be automatically loaded on startup via the web API.
          services.pihole-ftl.settings.port must be defined, e.g. by enabling services.pihole-web.enable and defining services.pihole-web.port.
        '';
      }

      {
        assertion =
          builtins.length cfg.lists == 0
          || !(hasAttrByPath [ "webserver" "api" "cli_pw" ] cfg.settings)
          || cfg.settings.webserver.api.cli_pw == true;

        message = ''
          services.pihole-ftl.settings.webserver.api.cli_pw must be true for lists set in services.pihole-ftl.lists to be automatically loaded on startup.
          This enables an ephemeral password used by the pihole command.
        '';
      }
    ];

    environment.etc = {
      "pihole/pihole.toml" = {
        group = cfg.group;
        mode = "400";
        source = settingsFile;
        user = cfg.user;
      };

      "pihole/versions".text = ''
        CORE_VERSION=${cfg.piholePackage.src.src.tag}
        FTL_VERSION=${cfg.package.src.tag}
      '';
    };

    environment.systemPackages = [ cfg.pihole ];

    networking.firewall = lib.mkMerge [
      (mkIf cfg.openFirewallDNS {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      })

      (mkIf cfg.openFirewallDHCP {
        allowedUDPPorts = [ 67 ];
      })

      (mkIf cfg.openFirewallWebserver {
        allowedTCPPorts = lib.pipe cfg.settings.webserver.port [
          (lib.splitString ",")
          (map (
            port:
            lib.pipe port [
              (builtins.split "[[:alpha:]]+")
              builtins.head
              lib.toInt
            ]
          ))
        ];
      })
    ];

    services.logrotate.settings.pihole-ftl = {
      enable = true;
      files = [ "${cfg.logDirectory}/FTL.log" ];
    };

    services.pihole-ftl.settings = lib.mkMerge [
      # Defaults
      (mkDefaults {
        misc.privacylevel = cfg.privacyLevel;
        misc.readOnly = true; # Prevent config changes via API or CLI by default
        webserver.port = ""; # Disable the webserver by default
      })

      # Move state files to cfg.stateDirectory
      {
        files = {
          database = "${cfg.stateDirectory}/pihole-FTL.db";
          gravity = "${cfg.stateDirectory}/gravity.db";
          log.dnsmasq = "${cfg.logDirectory}/pihole.log";
          log.ftl = "${cfg.logDirectory}/FTL.log";
          log.webserver = "${cfg.logDirectory}/webserver.log";
          macvendor = "${cfg.stateDirectory}/macvendor.db";
        };

        # TODO: Pi-hole currently hardcodes dhcp-leasefile this in its
        # generated dnsmasq.conf, and we can't override it
        misc.dnsmasq_lines = [
          # "dhcp-leasefile=${cfg.stateDirectory}/dhcp.leases"
          # "hostsdir=${cfg.stateDirectory}/hosts"
        ];

        webserver.tls.cert = "${cfg.stateDirectory}/tls.pem";
      }

      (lib.optionalAttrs cfg.useDnsmasqConfig {
        misc.dnsmasq_lines = lib.pipe config.services.dnsmasq.configFile [
          builtins.readFile
          (lib.strings.splitString "\n")
          (builtins.filter (s: s != ""))
        ];
      })
    ];

    systemd.services = {
      pihole-ftl =
        let
          setupService = config.systemd.services.pihole-ftl-setup.name;
        in
        {
          after = [ "network.target" ];
          before = [ setupService ];
          description = "Pi-hole FTL";

          environment = {
            # pihole is executed by the /actions/gravity API endpoint
            PATH = lib.mkForce (
              lib.makeBinPath [
                cfg.piholePackage
              ]
            );

            # Currently unused, but allows the service to be reloaded
            # automatically when the config is changed.
            PIHOLE_CONFIG = settingsFile;
          };

          serviceConfig = {
            AmbientCapabilities = [
              "CAP_NET_BIND_SERVICE"
              "CAP_NET_RAW"
              "CAP_NET_ADMIN"
              "CAP_SYS_NICE"
              "CAP_IPC_LOCK"
              "CAP_CHOWN"
              "CAP_SYS_TIME"
            ];

            DevicePolicy = "closed";
            ExecStart = "${getExe cfg.package} no-daemon";
            Group = cfg.group;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            # Hardening
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectControlGroups = true;
            ProtectHome = "read-only";
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectSystem = "strict";

            ReadWritePaths = [
              cfg.configDirectory
              cfg.stateDirectory
              cfg.logDirectory
            ];

            Restart = "on-failure";
            RestartSec = 1;
            RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            Type = "simple";
            User = cfg.user;
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ setupService ];
        };

      pihole-ftl-log-deleter = mkIf cfg.queryLogDeleter.enable {
        description = "Pi-hole FTL DNS query log deleter";

        script =
          let
            days = toString cfg.queryLogDeleter.age;
            database = cfg.settings.files.database;
          in
          ''
            set -euo pipefail

            # Avoid creating an empty database file if it doesn't yet exist
            if [ ! -f "${database}" ]; then
              exit 0;
            fi

            echo "Deleting query logs older than ${days} days"
            ${getExe cfg.package} sqlite3 "${database}" "DELETE FROM query_storage WHERE timestamp <= CAST(strftime('%s', date('now', '-${days} day')) AS INT); select changes() from query_storage limit 1"
          '';

        serviceConfig = {
          DevicePolicy = "closed";
          Group = cfg.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          # Hardening
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = "read-only";
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ cfg.stateDirectory ];
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          Type = "oneshot";
          User = cfg.user;
        };
      };

      pihole-ftl-setup = {
        enable = builtins.length cfg.lists > 0;
        # Wait for network so lists can be downloaded
        after = [ "network-online.target" ];
        description = "Pi-hole FTL setup";
        requires = [ "network-online.target" ];

        script = import ./pihole-ftl-setup-script.nix {
          inherit
            cfg
            config
            lib
            pkgs
            ;
        };

        serviceConfig = {
          DevicePolicy = "closed";
          Group = cfg.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          # Hardening
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = "read-only";
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";

          ReadWritePaths = [
            cfg.configDirectory
            cfg.stateDirectory
            cfg.logDirectory
          ];

          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          Type = "oneshot";
          User = cfg.user;
        };
      };
    };

    systemd.timers.pihole-ftl-log-deleter = mkIf cfg.queryLogDeleter.enable {
      before = [
        config.systemd.services.pihole-ftl.name
        config.systemd.services.pihole-ftl-setup.name
      ];

      description = "Pi-hole FTL DNS query log deleter";

      timerConfig = {
        OnCalendar = cfg.queryLogDeleter.interval;
        Unit = "pihole-ftl-log-deleter.service";
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.configDirectory} 0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.stateDirectory} 0700 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.logDirectory} 0700 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta = {
    doc = ./pihole-ftl.md;
    maintainers = with lib.maintainers; [ averyvigolo ];
  };
}
