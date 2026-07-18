{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.kea;

  format = pkgs.formats.json { };

  chooseNotNull = x: y: if x != null then x else y;

  dhcp4Config = chooseNotNull cfg.dhcp4.configFile (
    format.generate "kea-dhcp4.conf" {
      Dhcp4 = cfg.dhcp4.settings;
    }
  );

  dhcp6Config = chooseNotNull cfg.dhcp6.configFile (
    format.generate "kea-dhcp6.conf" {
      Dhcp6 = cfg.dhcp6.settings;
    }
  );

  dhcpDdnsConfig = chooseNotNull cfg.dhcp-ddns.configFile (
    format.generate "kea-dhcp-ddns.conf" {
      DhcpDdns = cfg.dhcp-ddns.settings;
    }
  );
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "kea" "ctrl-agent" ] ''
      https://kb.isc.org/docs/things-to-be-aware-of-when-upgrading-to-kea-3-2#the-kea-control-agent-ca
    '')
  ];

  options.services.kea = with lib.types; {
    package = lib.mkPackageOption pkgs "kea" { };

    dhcp-ddns = lib.mkOption {
      default = { };

      description = ''
        Kea DHCP-DDNS configuration
      '';

      type = submodule {
        options = {
          enable = lib.mkEnableOption "Kea DDNS server";

          configFile = lib.mkOption {
            default = null;

            description = ''
              Kea DHCP-DDNS configuration as a path, see <https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/ddns.html>.

              Takes preference over [settings](#opt-services.kea.dhcp-ddns.settings).
              Most users should prefer using [settings](#opt-services.kea.dhcp-ddns.settings) instead.
            '';

            type = nullOr path;
          };

          extraArgs = lib.mkOption {
            default = [ ];

            description = ''
              List of additional arguments to pass to the daemon.
            '';

            type = listOf str;
          };

          settings = lib.mkOption {
            default = null;

            description = ''
              Kea DHCP-DDNS configuration as an attribute set, see <https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/ddns.html>.
            '';

            example = {
              dns-server-timeout = 100;

              forward-ddns = {
                ddns-domains = [ ];
              };

              ip-address = "127.0.0.1";
              ncr-format = "JSON";
              ncr-protocol = "UDP";
              port = 53001;

              reverse-ddns = {
                ddns-domains = [ ];
              };

              tsig-keys = [ ];
            };

            type = format.type;
          };
        };
      };
    };

    dhcp4 = lib.mkOption {
      default = { };

      description = ''
        DHCP4 Server configuration
      '';

      type = submodule {
        options = {
          enable = lib.mkEnableOption "Kea DHCP4 server";

          configFile = lib.mkOption {
            default = null;

            description = ''
              Kea DHCP4 configuration as a path, see <https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/dhcp4-srv.html>.

              Takes preference over [settings](#opt-services.kea.dhcp4.settings).
              Most users should prefer using [settings](#opt-services.kea.dhcp4.settings) instead.
            '';

            type = nullOr path;
          };

          extraArgs = lib.mkOption {
            default = [ ];

            description = ''
              List of additional arguments to pass to the daemon.
            '';

            type = listOf str;
          };

          settings = lib.mkOption {
            default = null;

            description = ''
              Kea DHCP4 configuration as an attribute set, see <https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/dhcp4-srv.html>.
            '';

            example = {
              interfaces-config = {
                interfaces = [
                  "eth0"
                ];
              };

              lease-database = {
                name = "/var/lib/kea/dhcp4.leases";
                persist = true;
                type = "memfile";
              };

              rebind-timer = 2000;
              renew-timer = 1000;

              subnet4 = [
                {
                  id = 1;

                  pools = [
                    {
                      pool = "192.0.2.100 - 192.0.2.240";
                    }
                  ];

                  subnet = "192.0.2.0/24";
                }
              ];

              valid-lifetime = 4000;
            };

            type = format.type;
          };
        };
      };
    };

    dhcp6 = lib.mkOption {
      default = { };

      description = ''
        DHCP6 Server configuration
      '';

      type = submodule {
        options = {
          enable = lib.mkEnableOption "Kea DHCP6 server";

          configFile = lib.mkOption {
            default = null;

            description = ''
              Kea DHCP6 configuration as a path, see <https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/dhcp6-srv.html>.

              Takes preference over [settings](#opt-services.kea.dhcp6.settings).
              Most users should prefer using [settings](#opt-services.kea.dhcp6.settings) instead.
            '';

            type = nullOr path;
          };

          extraArgs = lib.mkOption {
            default = [ ];

            description = ''
              List of additional arguments to pass to the daemon.
            '';

            type = listOf str;
          };

          settings = lib.mkOption {
            default = null;

            description = ''
              Kea DHCP6 configuration as an attribute set, see <https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/dhcp6-srv.html>.
            '';

            example = {
              interfaces-config = {
                interfaces = [
                  "eth0"
                ];
              };

              lease-database = {
                name = "/var/lib/kea/dhcp6.leases";
                persist = true;
                type = "memfile";
              };

              preferred-lifetime = 3000;
              rebind-timer = 2000;
              renew-timer = 1000;

              subnet6 = [
                {
                  id = 1;

                  pools = [
                    {
                      pool = "2001:db8:1::1-2001:db8:1::ffff";
                    }
                  ];

                  subnet = "2001:db8:1::/64";
                }
              ];

              valid-lifetime = 4000;
            };

            type = format.type;
          };
        };
      };
    };
  };

  config =
    let
      commonEnvironment = {
        # Allow hooks to originate from the configured package
        KEA_HOOKS_PATH = lib.mkDefault "${cfg.package}/lib/kea/hooks";
        # Allow hook scripts only when they originate from the system configuration
        KEA_HOOK_SCRIPTS_PATH = lib.mkDefault "/nix/store";
      };

      commonServiceConfig = {
        ConfigurationDirectory = "kea";
        DynamicUser = true;

        ExecReload = toString [
          (lib.getExe' pkgs.coreutils "kill")
          "-HUP"
          "$MAINPID"
        ];

        Restart = "on-failure";
        RuntimeDirectory = "kea";
        RuntimeDirectoryMode = "0750";
        RuntimeDirectoryPreserve = true;
        StateDirectory = "kea";
        UMask = "0077";
        User = "kea";
      };
    in
    lib.mkIf (cfg.dhcp4.enable || cfg.dhcp6.enable || cfg.dhcp-ddns.enable) (
      lib.mkMerge [
        {
          environment.systemPackages = [ cfg.package ];
          users.groups.kea = { };

          users.users.kea = {
            group = "kea";
            isSystemUser = true;
          };
        }

        (lib.mkIf cfg.dhcp4.enable {
          assertions = [
            {
              assertion = lib.xor (cfg.dhcp4.settings == null) (cfg.dhcp4.configFile == null);
              message = "Either services.kea.dhcp4.settings or services.kea.dhcp4.configFile must be set to a non-null value.";
            }
          ];

          environment.etc."kea/dhcp4-server.conf".source = dhcp4Config;

          systemd.services.kea-dhcp4-server = {
            after = [
              "network-online.target"
              "time-sync.target"
            ];

            description = "Kea DHCP4 Server";

            documentation = [
              "man:kea-dhcp4(8)"
              "https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/dhcp4-srv.html"
            ];

            environment = commonEnvironment;

            restartTriggers = [
              dhcp4Config
            ];

            serviceConfig = {
              # Kea does not request capabilities by itself
              AmbientCapabilities = [
                "CAP_NET_BIND_SERVICE"
                "CAP_NET_RAW"
              ];

              CapabilityBoundingSet = [
                "CAP_NET_BIND_SERVICE"
                "CAP_NET_RAW"
              ];

              ExecStart = utils.escapeSystemdExecArgs (
                [
                  (lib.getExe' cfg.package "kea-dhcp4")
                  "-c"
                  "/etc/kea/dhcp4-server.conf"
                ]
                ++ cfg.dhcp4.extraArgs
              );
            }
            // commonServiceConfig;

            wantedBy = [
              "multi-user.target"
            ];

            wants = [
              "network-online.target"
            ];
          };
        })

        (lib.mkIf cfg.dhcp6.enable {
          assertions = [
            {
              assertion = lib.xor (cfg.dhcp6.settings == null) (cfg.dhcp6.configFile == null);
              message = "Either services.kea.dhcp6.settings or services.kea.dhcp6.configFile must be set to a non-null value.";
            }
          ];

          environment.etc."kea/dhcp6-server.conf".source = dhcp6Config;

          systemd.services.kea-dhcp6-server = {
            after = [
              "network-online.target"
              "time-sync.target"
            ];

            description = "Kea DHCP6 Server";

            documentation = [
              "man:kea-dhcp6(8)"
              "https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/dhcp6-srv.html"
            ];

            environment = commonEnvironment;

            restartTriggers = [
              dhcp6Config
            ];

            serviceConfig = {
              # Kea does not request capabilities by itself
              AmbientCapabilities = [
                "CAP_NET_BIND_SERVICE"
              ];

              CapabilityBoundingSet = [
                "CAP_NET_BIND_SERVICE"
              ];

              ExecStart = utils.escapeSystemdExecArgs (
                [
                  (lib.getExe' cfg.package "kea-dhcp6")
                  "-c"
                  "/etc/kea/dhcp6-server.conf"
                ]
                ++ cfg.dhcp6.extraArgs
              );
            }
            // commonServiceConfig;

            wantedBy = [
              "multi-user.target"
            ];

            wants = [
              "network-online.target"
            ];
          };
        })

        (lib.mkIf cfg.dhcp-ddns.enable {
          assertions = [
            {
              assertion = lib.xor (cfg.dhcp-ddns.settings == null) (cfg.dhcp-ddns.configFile == null);
              message = "Either services.kea.dhcp-ddns.settings or services.kea.dhcp-ddns.configFile must be set to a non-null value.";
            }
          ];

          environment.etc."kea/dhcp-ddns.conf".source = dhcpDdnsConfig;

          systemd.services.kea-dhcp-ddns-server = {
            after = [
              "network-online.target"
              "time-sync.target"
            ];

            description = "Kea DHCP-DDNS Server";

            documentation = [
              "man:kea-dhcp-ddns(8)"
              "https://kea.readthedocs.io/en/kea-${cfg.package.version}/arm/ddns.html"
            ];

            environment = commonEnvironment;

            restartTriggers = [
              dhcpDdnsConfig
            ];

            serviceConfig = {
              AmbientCapabilities = [
                "CAP_NET_BIND_SERVICE"
              ];

              CapabilityBoundingSet = [
                "CAP_NET_BIND_SERVICE"
              ];

              ExecStart = utils.escapeSystemdExecArgs (
                [
                  (lib.getExe' cfg.package "kea-dhcp-ddns")
                  "-c"
                  "/etc/kea/dhcp-ddns.conf"
                ]
                ++ cfg.dhcp-ddns.extraArgs
              );
            }
            // commonServiceConfig;

            wantedBy = [
              "multi-user.target"
            ];

            wants = [ "network-online.target" ];
          };
        })

      ]
    );

  # uses attributes of the linked package
  meta.buildDocsInSandbox = false;
  meta.maintainers = with lib.maintainers; [ hexa ];
}
