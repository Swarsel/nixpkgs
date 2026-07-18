{
  config,
  lib,
  pkgs,
  options,
  utils,
  ...
}:

let
  inherit (lib)
    concatStrings
    foldl'
    genAttrs
    literalExpression
    mapAttrs
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    flip
    attrNames
    xor
    ;

  cfg = config.services.prometheus.exporters;

  # each attribute in `exporterOpts` is expected to have specified:
  #   - port        (types.int):   port on which the exporter listens
  #   - serviceOpts (types.attrs): config that is merged with the
  #                                default definition of the exporter's
  #                                systemd service
  #   - extraOpts   (types.attrs): extra configuration options to
  #                                configure the exporter with, which
  #                                are appended to the default options
  #
  #  Note that `extraOpts` is optional, but a script for the exporter's
  #  systemd service must be provided by specifying either
  #  `serviceOpts.script` or `serviceOpts.serviceConfig.ExecStart`

  exporterOpts =
    (genAttrs
      [
        "apcupsd"
        "artifactory"
        "bind"
        "bird"
        "bitcoin"
        "blackbox"
        "borgmatic"
        "buildkite-agent"
        "ecoflow"
        "chrony"
        "collectd"
        "deluge"
        "dmarc"
        "dnsmasq"
        "dnssec"
        "domain"
        "dovecot"
        "ebpf"
        "elasticsearch"
        "fail2ban"
        "fastly"
        "flow"
        "fritz"
        "fritzbox"
        "frr"
        "graphite"
        "idrac"
        "imap-mailstat"
        "influxdb"
        "ipmi"
        "jitsi"
        "json"
        "junos-czerwonk"
        "kafka"
        "kea"
        "keylight"
        "klipper"
        "knot"
        "libvirt"
        "lnd"
        "mail"
        "mailman3"
        "mail-tlsa-check"
        "mikrotik"
        "modemmanager"
        "mongodb"
        "mqtt"
        "mysqld"
        "nats"
        "nextcloud"
        "nginx"
        "nginxlog"
        "node"
        "node-cert"
        "nut"
        "nvidia-gpu"
        "opnsense"
        "pgbouncer"
        "php-fpm"
        "pihole"
        "ping"
        "postfix"
        "postgres"
        "process"
        "pve"
        "py-air-control"
        "rasdaemon"
        "redis"
        "restic"
        "rtl_433"
        "sabnzbd"
        "script"
        "shelly"
        "smartctl"
        "smokeping"
        "snmp"
        "speedtest"
        "sql"
        "statsd"
        "storagebox"
        "surfboard"
        "systemd"
        "tailscale"
        "tibber"
        "unbound"
        "unpoller"
        "v2ray"
        "varnish"
        "wireguard"
        "xray"
        "zfs-siebenmann"
        "zfs"
      ]
      (
        name:
        import (./. + "/exporters/${name}.nix") {
          inherit
            config
            lib
            pkgs
            options
            utils
            ;
        }
      )
    )
    // (mapAttrs
      (
        name: params:
        import (./. + "/exporters/${params.name}.nix") {
          inherit
            config
            lib
            pkgs
            options
            utils
            ;

          type = params.type;
        }
      )
      {
        exportarr-bazarr = {
          name = "exportarr";
          type = "bazarr";
        };

        exportarr-lidarr = {
          name = "exportarr";
          type = "lidarr";
        };

        exportarr-prowlarr = {
          name = "exportarr";
          type = "prowlarr";
        };

        exportarr-radarr = {
          name = "exportarr";
          type = "radarr";
        };

        exportarr-readarr = {
          name = "exportarr";
          type = "readarr";
        };

        exportarr-sonarr = {
          name = "exportarr";
          type = "sonarr";
        };
      }
    );

  mkExporterOpts = (
    { name, port }:
    {
      enable = mkEnableOption "the prometheus ${name} exporter";

      extraFlags = mkOption {
        default = [ ];

        description = ''
          Extra commandline options to pass to the ${name} exporter.
        '';

        type = types.listOf types.str;
      };

      firewallFilter = mkOption {
        default = null;

        description = ''
          Specify a filter for iptables to use when
          {option}`services.prometheus.exporters.${name}.openFirewall`
          is true. It is used as `ip46tables -I nixos-fw firewallFilter -j nixos-fw-accept`.
        '';

        example = literalExpression ''
          "-i eth0 -p tcp -m tcp --dport ${toString port}"
        '';

        type = types.nullOr types.str;
      };

      firewallRules = mkOption {
        default = null;

        description = ''
          Specify rules for nftables to add to the input chain
          when {option}`services.prometheus.exporters.${name}.openFirewall` is true.
        '';

        example = literalExpression ''
          iifname "eth0" tcp dport ${toString port} counter accept
        '';

        type = types.nullOr types.lines;
      };

      group = mkOption {
        default = "${name}-exporter";

        description = ''
          Group under which the ${name} exporter shall be run.
        '';

        type = types.str;
      };

      listenAddress = mkOption {
        default = "0.0.0.0";

        description = ''
          Address to listen on.
        '';

        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open port in firewall for incoming connections.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = port;

        description = ''
          Port to listen on.
        '';

        type = types.port;
      };

      user = mkOption {
        default = "${name}-exporter";

        description = ''
          User name under which the ${name} exporter shall be run.
        '';

        type = types.str;
      };
    }
  );

  mkSubModule =
    {
      extraOpts,
      imports,
      name,
      port,
    }:
    {
      ${name} = mkOption {
        default = { };
        internal = true;

        type = types.submodule [
          {
            inherit imports;

            options = (
              mkExporterOpts {
                inherit name port;
              }
              // extraOpts
            );
          }
          (
            { config, ... }:
            mkIf config.openFirewall {
              firewallFilter = mkDefault "-p tcp -m tcp --dport ${toString config.port}";
              firewallRules = mkDefault ''tcp dport ${toString config.port} accept comment "${name}-exporter"'';
            }
          )
        ];
      };
    };

  mkSubModules = (
    foldl' (a: b: a // b) { } (
      mapAttrsToList (
        name: opts:
        mkSubModule {
          inherit name;
          inherit (opts) port;
          imports = opts.imports or [ ];
          extraOpts = opts.extraOpts or { };
        }
      ) exporterOpts
    )
  );

  mkExporterConf =
    {
      conf,
      name,
      serviceOpts,
    }:
    let
      enableDynamicUser = serviceOpts.serviceConfig.DynamicUser or true;
      nftables = config.networking.nftables.enable;
    in
    mkIf conf.enable {
      assertions = conf.assertions or [ ];

      networking.firewall.extraCommands = mkIf (conf.openFirewall && !nftables) (concatStrings [
        "ip46tables -A nixos-fw ${conf.firewallFilter} "
        "-m comment --comment ${name}-exporter -j nixos-fw-accept"
      ]);

      networking.firewall.extraInputRules = mkIf (conf.openFirewall && nftables) conf.firewallRules;

      services.udev.extraRules = mkIf (name == "smartctl") ''
        ACTION=="add", SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", RUN+="${pkgs.acl}/bin/setfacl -m g:smartctl-exporter-access:rw /dev/$kernel"
      '';

      systemd.services."prometheus-${name}-exporter" = mkMerge [
        {
          after = [ "network.target" ];
          # Hardening
          serviceConfig.CapabilityBoundingSet = mkDefault [ "" ];
          serviceConfig.DeviceAllow = [ "" ];
          serviceConfig.DynamicUser = mkDefault enableDynamicUser;
          serviceConfig.Group = conf.group;
          serviceConfig.LockPersonality = true;
          serviceConfig.MemoryDenyWriteExecute = true;
          serviceConfig.NoNewPrivileges = true;
          serviceConfig.PrivateDevices = mkDefault true;
          serviceConfig.PrivateTmp = mkDefault true;
          serviceConfig.ProtectClock = mkDefault true;
          serviceConfig.ProtectControlGroups = true;
          serviceConfig.ProtectHome = true;
          serviceConfig.ProtectHostname = true;
          serviceConfig.ProtectKernelLogs = true;
          serviceConfig.ProtectKernelModules = true;
          serviceConfig.ProtectKernelTunables = true;
          serviceConfig.ProtectSystem = mkDefault "strict";
          serviceConfig.RemoveIPC = true;
          serviceConfig.Restart = mkDefault "always";

          serviceConfig.RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          serviceConfig.RestrictNamespaces = true;
          serviceConfig.RestrictRealtime = true;
          serviceConfig.RestrictSUIDSGID = true;
          serviceConfig.SystemCallArchitectures = "native";
          serviceConfig.UMask = "0077";
          serviceConfig.User = mkDefault conf.user;
          serviceConfig.WorkingDirectory = mkDefault "/tmp";
          wantedBy = [ "multi-user.target" ];
        }
        serviceOpts
      ];

      systemd.services.prometheus-fail2ban-exporter-setup =
        mkIf (config.services.fail2ban.enable && name == "fail2ban")
          {
            after = [ "fail2ban.service" ];
            before = [ "prometheus-fail2ban-exporter.service" ];
            description = "Set fail2ban socket ACLs";

            path = [
              pkgs.acl
              pkgs.coreutils
            ];

            requires = [ "fail2ban.service" ];

            script = ''
              while [ ! -S ${conf.fail2banSocket} ]; do
                sleep 0.1
              done

              setfacl -m u:${conf.user}:x $(dirname ${conf.fail2banSocket})
              setfacl -m u:${conf.user}:rwx ${conf.fail2banSocket}
            '';

            serviceConfig = {
              Type = "oneshot";
              User = "root";
            };

            wantedBy = [ "prometheus-fail2ban-exporter.service" ];
          };

      users.groups = mkMerge [
        (mkIf (conf.group == "${name}-exporter" && !enableDynamicUser) {
          "${name}-exporter" = { };
        })
        (mkIf (name == "smartctl") {
          "smartctl-exporter-access" = { };
        })
      ];

      users.users."${name}-exporter" = (
        mkIf (conf.user == "${name}-exporter" && !enableDynamicUser) {
          inherit (conf) group;
          description = "Prometheus ${name} exporter service user";
          extraGroups = mkIf (name == "libvirt") [ "libvirtd" ];
          isSystemUser = true;
        }
      );

      warnings = conf.warnings or [ ];
    };
in
{

  options.services.prometheus.exporters = mkOption {
    default = { };
    description = "Prometheus exporter configuration";

    example = literalExpression ''
      {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
        };
        varnish.enable = true;
      }
    '';

    type = types.submodule {
      imports = [
        ../../../misc/assertions.nix
        (lib.mkRenamedOptionModule [ "unifi-poller" ] [ "unpoller" ])
        (lib.mkRemovedOptionModule [ "minio" ] ''
          The Minio exporter has been removed, as it was broken and unmaintained.
          See the 24.11 release notes for more information.
        '')
        (lib.mkRemovedOptionModule [ "tor" ] ''
          The Tor exporter has been removed, as it was broken and unmaintained.
        '')
        (lib.mkRemovedOptionModule [ "rspamd" ] ''
          The Rspamd exporter has been removed. You can use the Rspamd /metrics endpoint directly instead:
          https://docs.rspamd.com/developers/protocol#controller-http-endpoints
        '')
      ];

      options = mkSubModules;
    };
  };

  config = mkMerge (
    [
      {
        assertions = [
          {
            assertion =
              cfg.ipmi.enable -> (cfg.ipmi.configFile != null) -> (!(lib.hasPrefix "/tmp/" cfg.ipmi.configFile));

            message = ''
              Config file specified in `services.prometheus.exporters.ipmi.configFile' must
                not reside within /tmp - it won't be visible to the systemd service.
            '';
          }
          {
            assertion =
              cfg.ipmi.enable
              -> (cfg.ipmi.webConfigFile != null)
              -> (!(lib.hasPrefix "/tmp/" cfg.ipmi.webConfigFile));

            message = ''
              Config file specified in `services.prometheus.exporters.ipmi.webConfigFile' must
                not reside within /tmp - it won't be visible to the systemd service.
            '';
          }
          {
            assertion =
              cfg.restic.enable -> ((cfg.restic.repository == null) != (cfg.restic.repositoryFile == null));

            message = ''
              Please specify either 'services.prometheus.exporters.restic.repository'
                or 'services.prometheus.exporters.restic.repositoryFile'.
            '';
          }
          {
            assertion =
              cfg.snmp.enable -> ((cfg.snmp.configurationPath == null) != (cfg.snmp.configuration == null));

            message = ''
              Please ensure you have either `services.prometheus.exporters.snmp.configuration'
                or `services.prometheus.exporters.snmp.configurationPath' set!
            '';
          }
          {
            assertion =
              cfg.mikrotik.enable -> ((cfg.mikrotik.configFile == null) != (cfg.mikrotik.configuration == null));

            message = ''
              Please specify either `services.prometheus.exporters.mikrotik.configuration'
                or `services.prometheus.exporters.mikrotik.configFile'.
            '';
          }
          {
            assertion = cfg.mail.enable -> ((cfg.mail.configFile == null) != (cfg.mail.configuration == null));

            message = ''
              Please specify either 'services.prometheus.exporters.mail.configuration'
                or 'services.prometheus.exporters.mail.configFile'.
            '';
          }
          {
            assertion = cfg.mysqld.runAsLocalSuperUser -> config.services.mysql.enable;

            message = ''
              The exporter is configured to run as 'services.mysql.user', but
                'services.mysql.enable' is set to false.
            '';
          }
          {
            assertion =
              cfg.nextcloud.enable -> ((cfg.nextcloud.passwordFile == null) != (cfg.nextcloud.tokenFile == null));

            message = ''
              Please specify either 'services.prometheus.exporters.nextcloud.passwordFile' or
                'services.prometheus.exporters.nextcloud.tokenFile'
            '';
          }
          {
            assertion = cfg.sql.enable -> ((cfg.sql.configFile == null) != (cfg.sql.configuration == null));

            message = ''
              Please specify either 'services.prometheus.exporters.sql.configuration' or
                'services.prometheus.exporters.sql.configFile'
            '';
          }
          {
            assertion =
              cfg.idrac.enable -> ((cfg.idrac.configurationPath == null) != (cfg.idrac.configuration == null));

            message = ''
              Please ensure you have either `services.prometheus.exporters.idrac.configuration'
                or `services.prometheus.exporters.idrac.configurationPath' set!
            '';
          }
          {
            assertion =
              cfg.deluge.enable
              -> ((cfg.deluge.delugePassword == null) != (cfg.deluge.delugePasswordFile == null));

            message = ''
              Please ensure you have either `services.prometheus.exporters.deluge.delugePassword'
                or `services.prometheus.exporters.deluge.delugePasswordFile' set!
            '';
          }
          {
            assertion =
              cfg.pgbouncer.enable
              -> (xor (cfg.pgbouncer.connectionEnvFile == null) (cfg.pgbouncer.connectionString == null));

            message = ''
              Options `services.prometheus.exporters.pgbouncer.connectionEnvFile` and
              `services.prometheus.exporters.pgbouncer.connectionString` are mutually exclusive!
            '';
          }
        ]
        ++ (flip map (attrNames exporterOpts) (exporter: {
          assertion = cfg.${exporter}.firewallFilter != null -> cfg.${exporter}.openFirewall;

          message = ''
            The `firewallFilter'-option of exporter ${exporter} doesn't have any effect unless
            `openFirewall' is set to `true'!
          '';
        }))
        ++ config.services.prometheus.exporters.assertions;

        warnings = [
          (mkIf
            (
              config.services.prometheus.exporters.idrac.enable
              && config.services.prometheus.exporters.idrac.configurationPath != null
            )
            ''
              Configuration file in `services.prometheus.exporters.idrac.configurationPath` may override
              `services.prometheus.exporters.idrac.listenAddress` and/or `services.prometheus.exporters.idrac.port`.
              Consider using `services.prometheus.exporters.idrac.configuration` instead.
            ''
          )
        ]
        ++ config.services.prometheus.exporters.warnings;
      }
    ]
    ++ [
      (mkIf config.services.prometheus.exporters.rtl_433.enable {
        hardware.rtl-sdr.enable = mkDefault true;
      })
    ]
    ++ [
      (mkIf config.services.postfix.enable {
        services.prometheus.exporters.postfix.group = mkDefault config.services.postfix.setgidGroup;
      })
    ]
    ++ (mapAttrsToList (
      name: conf:
      mkExporterConf {
        inherit name;
        inherit (conf) serviceOpts;
        conf = cfg.${name};
      }
    ) exporterOpts)
  );

  meta = {
    doc = ./exporters.md;
    maintainers = [ ];
  };
}
