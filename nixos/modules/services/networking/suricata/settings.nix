{
  config,
  lib,
  yaml,
  ...
}:
let
  cfg = config.services.suricata;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    ;
  mkDisableOption =
    name:
    mkEnableOption name
    // {
      default = true;
      example = false;
    };
in
{
  options = {
    "af-packet" = mkOption {
      default = null;

      description = ''
        Linux high speed capture support.
      '';

      type =
        with types;
        nullOr (
          listOf (submodule {
            options = {
              interface = mkOption {
                default = null;

                description = ''
                  af-packet capture interface, see [upstream docs reagrding tuning](https://docs.suricata.io/en/latest/performance/tuning-considerations.html#af-packet).
                '';

                type = types.str;
              };
            };

            freeformType = yaml.type;
          })
        );
    };

    "af-xdp" = mkOption {
      default = null;

      description = ''
        Linux high speed af-xdp capture support, see
        [docs/capture-hardware/af-xdp](https://docs.suricata.io/en/suricata-7.0.3/capture-hardware/af-xdp.html).
      '';

      type =
        with types;
        nullOr (
          listOf (submodule {
            options = {
              interface = mkOption {
                default = null;

                description = ''
                  af-xdp capture interface, see [upstream docs](https://docs.suricata.io/en/latest/capture-hardware/af-xdp.html).
                '';

                type = types.str;
              };
            };

            freeformType = yaml.type;
          })
        );
    };

    "app-layer" = mkOption {
      default = null; # do not add to config unless specified

      description = ''
        app-layer configuration, see [upstream docs](https://docs.suricata.io/en/latest/rules/app-layer.html).
      '';

      type =
        with types;
        nullOr (submodule {
          options = {
            "error-policy" = mkOption {
              default = "ignore";

              description = ''
                The error-policy setting applies to all app-layer parsers. Values can be
                "drop-flow", "pass-flow", "bypass", "drop-packet", "pass-packet", "reject" or
                "ignore" (the default).
              '';

              type = types.enum [
                "drop-flow"
                "pass-flow"
                "bypass"
                "drop-packet"
                "pass-packet"
                "reject"
                "ignore"
              ];
            };

            protocols = mkOption {
              default = null;

              description = ''
                app-layer protocols, see [upstream docs](https://docs.suricata.io/en/latest/rules/app-layer.html).
              '';

              type =
                with types;
                nullOr (
                  attrsOf (submodule {
                    options = {
                      enabled = mkOption {
                        default = "no";

                        description = ''
                          The option "enabled" takes 3 values - "yes", "no", "detection-only".
                          "yes" enables both detection and the parser, "no" disables both, and
                          "detection-only" enables protocol detection only (parser disabled).
                        '';

                        type = types.enum [
                          "yes"
                          "no"
                          "detection-only"
                        ];
                      };
                    };

                    freeformType = yaml.type;
                  })
                );
            };
          };
        });
    };

    "classification-file" = mkOption {
      default = "/var/lib/suricata/rules/classification.config";
      description = "Suricata classification configuration file.";
      type = types.str;
    };

    "default-log-dir" = mkOption {
      default = "/var/log/suricata";

      description = ''
        The default logging directory. Any log or output file will be placed here if it's
        not specified with a full path name. This can be overridden with the -l command
        line parameter.
      '';

      type = types.str;
    };

    "default-rule-path" = mkOption {
      default = "/var/lib/suricata/rules";
      description = "Path in which suricata-update managed rules are stored by default.";
      type = types.path;
    };

    "dpdk" = mkOption {
      default = null;

      description = ''
        Data Plane Development Kit is a framework for fast packet processing in data plane applications running on a wide variety of CPU architectures. DPDK's Environment Abstraction Layer (EAL) provides a generic interface to low-level resources. It is a unique way how DPDK libraries access NICs. EAL creates an API for an application to access NIC resources from the userspace level. In DPDK, packets are not retrieved via interrupt handling. Instead, the application polls the NIC for newly received packets.

        DPDK allows the user space application to directly access memory where the NIC stores the packets. As a result, neither DPDK nor the application copies the packets for the inspection. The application directly processes packets via passed packet descriptors.
        See [docs/capture-hardware/dpdk](https://docs.suricata.io/en/suricata-7.0.7/capture-hardware/dpdk.html) and [docs/configuration/suricata-yaml.html#data-plane-development-kit-dpdk](https://docs.suricata.io/en/suricata-7.0.7/configuration/suricata-yaml.html#data-plane-development-kit-dpdk).
      '';

      type =
        with types;
        nullOr (submodule {
          options = {
            eal-params.proc-type = mkOption {
              default = null;

              description = ''
                dpdk eal-params.proc-type, see [data plane development kit docs](https://doc.dpdk.org/guides/linux_gsg/linux_eal_parameters.html#multiprocessing-related-options).
              '';

              type = with types; nullOr str;
            };

            interfaces = mkOption {
              default = null;

              description = ''
                See upstream docs: [docs/capture-hardware/dpdk](https://docs.suricata.io/en/suricata-7.0.7/capture-hardware/dpdk.html) and [docs/configuration/suricata-yaml.html#data-plane-development-kit-dpdk](https://docs.suricata.io/en/suricata-7.0.7/configuration/suricata-yaml.html#data-plane-development-kit-dpdk).
              '';

              type =
                with types;
                nullOr (
                  listOf (submodule {
                    options = {
                      interface = mkOption {
                        default = null;

                        description = ''
                          See upstream docs: [docs/capture-hardware/dpdk](https://docs.suricata.io/en/suricata-7.0.7/capture-hardware/dpdk.html) and [docs/configuration/suricata-yaml.html#data-plane-development-kit-dpdk](https://docs.suricata.io/en/suricata-7.0.7/configuration/suricata-yaml.html#data-plane-development-kit-dpdk).
                        '';

                        type = types.str;
                      };
                    };

                    freeformType = yaml.type;
                  })
                );
            };
          };
        });
    };

    "exception-policy" = mkOption {
      default = "auto";

      description = ''
        Define a common behavior for all exception policies.
        In IPS mode, the default is drop-flow. For cases when that's not possible, the
        engine will fall to drop-packet. To fallback to old behavior (setting each of
        them individually, or ignoring all), set this to ignore.
        All values available for exception policies can be used, and there is one
        extra option: auto - which means drop-flow or drop-packet (as explained above)
        in IPS mode, and ignore in IDS mode. Exception policy values are: drop-packet,
        drop-flow, reject, bypass, pass-packet, pass-flow, ignore (disable).
      '';

      type = types.enum [
        "auto"
        "drop-packet"
        "drop-flow"
        "reject"
        "bypass"
        "pass-packet"
        "pass-flow"
        "ignore"
      ];
    };

    "host-mode" = mkOption {
      default = "auto";

      description = ''
        If the Suricata box is a router for the sniffed networks, set it to 'router'. If
        it is a pure sniffing setup, set it to 'sniffer-only'. If set to auto, the variable
        is internally switched to 'router' in IPS mode and 'sniffer-only' in IDS mode.
        This feature is currently only used by the reject* keywords.
      '';

      type = types.enum [
        "router"
        "sniffer-only"
        "auto"
      ];
    };

    includes = mkOption {
      default = null;

      description = ''
        Files to include in the suricata configuration. See
        [docs/configuration/suricata-yaml](https://docs.suricata.io/en/suricata-7.0.3/configuration/suricata-yaml.html)
        for available options.
      '';

      type = with types; nullOr (listOf path);
    };

    logging = {
      "default-log-format" = mkOption {
        default = null;

        description = ''
          The default output format. Optional parameter, should default to
          something reasonable if not provided. Can be overridden in an
          output section.  You can leave this out to get the default.
        '';

        type = types.nullOr types.str;
      };

      "default-log-level" = mkOption {
        default = "notice";

        description = ''
          The default log level: can be overridden in an output section.
          Note that debug level logging will only be emitted if Suricata was
          compiled with the --enable-debug configure option.
        '';

        type = types.enum [
          "error"
          "warning"
          "notice"
          "info"
          "perf"
          "config"
          "debug"
        ];
      };

      "default-output-filter" = mkOption {
        default = null;

        description = ''
          A regex to filter output.  Can be overridden in an output section.
          Defaults to empty (no filter).
        '';

        type = types.nullOr types.str;
      };

      outputs = {
        console = {
          enable = mkDisableOption "logging to console";
        };

        file = {
          enable = mkDisableOption "logging to file";

          filename = mkOption {
            default = "suricata.log";

            description = ''
              Filename of the logfile.
            '';

            type = types.str;
          };

          format = mkOption {
            default = null;

            description = ''
              Logformat for logs written to the logfile.
            '';

            type = types.nullOr types.str;
          };

          level = mkOption {
            default = "info";

            description = ''
              Loglevel for logs written to the logfile.
            '';

            type = types.enum [
              "error"
              "warning"
              "notice"
              "info"
              "perf"
              "config"
              "debug"
            ];
          };

          type = mkOption {
            default = null;

            description = ''
              Type of logfile.
            '';

            type = types.nullOr types.str;
          };
        };

        syslog = {
          enable = mkEnableOption "logging to syslog";

          facility = mkOption {
            default = "local5";

            description = ''
              Facility to log to.
            '';

            type = types.str;
          };

          format = mkOption {
            default = null;

            description = ''
              Logformat for logs send to syslog.
            '';

            type = types.nullOr types.str;
          };

          type = mkOption {
            default = null;

            description = ''
              Type of logs send to syslog.
            '';

            type = types.nullOr types.str;
          };
        };
      };

      "stacktrace-on-signal" = mkOption {
        default = null;

        description = ''
          Requires libunwind to be available when Suricata is configured and built.
          If a signal unexpectedly terminates Suricata, displays a brief diagnostic
          message with the offending stacktrace if enabled.
        '';

        type = types.nullOr types.str;
      };
    };

    outputs = mkOption {
      default = null;

      description = ''
        Configure the type of alert (and other) logging you would like.

        Valid values for <NAME> are e. g. `fast`, `eve-log`, `syslog`, `file-store`, ...
        - `fast`: a line based alerts log similar to Snort's fast.log
        - `eve-log`: Extensible Event Format (nicknamed EVE) event log in JSON format

        For more details regarding the configuration, checkout the shipped suricata.yaml
        ```shell
        nix-shell -p suricata yq coreutils-full --command 'yq < $(dirname $(which suricata))/../etc/suricata/suricata.yaml'
        ```
        and the [suricata documentation](https://docs.suricata.io/en/latest/output/index.html).
      '';

      example = literalExpression ''
        [
          {
            fast = {
              enabled = "yes";
              filename = "fast.log";
              append = "yes";
            };
          }
          {
            eve-log = {
              enabled = "yes";
              filetype = "regular";
              filename = "eve.json";
              community-id = true;
              types = [
                {
                  alert.tagged-packets = "yes";
                }
              ];
            };
          }
        ];
      '';

      type =
        with types;
        nullOr (
          listOf (
            attrsOf (submodule {
              options = {
                enabled = mkEnableOption "<NAME>";
              };

              freeformType = yaml.type;
            })
          )
        );
    };

    "pcap" = mkOption {
      default = null;

      description = ''
        Cross platform libpcap capture support.
      '';

      type =
        with types;
        nullOr (
          listOf (submodule {
            options = {
              interface = mkOption {
                default = null;

                description = ''
                  pcap capture interface, see [upstream docs](https://docs.suricata.io/en/latest/manpages/suricata.html).
                '';

                type = types.str;
              };
            };

            freeformType = yaml.type;
          })
        );
    };

    "pcap-file".checksum-checks = mkOption {
      default = "auto";

      description = ''
        Possible values are:
        - yes: checksum validation is forced
        - no: checksum validation is disabled
        - auto: Suricata uses a statistical approach to detect when
        checksum off-loading is used. (default)
        Warning: 'checksum-validation' must be set to yes to have checksum tested.
      '';

      type = types.enum [
        "yes"
        "no"
        "auto"
      ];
    };

    plugins = mkOption {
      default = null;

      description = ''
        Plugins -- Experimental -- specify the filename for each plugin shared object.
      '';

      type = with types; nullOr (listOf path);
    };

    "reference-config-file" = mkOption {
      default = "${cfg.package}/etc/suricata/reference.config";
      defaultText = "\${config.services.suricata.package}/etc/suricata/reference.config";
      description = "Suricata reference configuration file.";
      type = types.str;
    };

    "rule-files" = mkOption {
      default = [ "suricata.rules" ];
      description = "Files to load suricata-update managed rules, relative to 'default-rule-path'.";
      type = types.listOf types.str;
    };

    "run-as" = {
      group = mkOption {
        default = "suricata";
        description = "Run Suricata with a specific group-id.";
        type = types.str;
      };

      user = mkOption {
        default = "suricata";
        description = "Run Suricata with a specific user-id.";
        type = types.str;
      };
    };

    stats = mkOption {
      default = null; # do not add to config unless specified

      description = ''
        Engine statistics such as packet counters, memory use counters and others can be logged in several ways. A separate text log 'stats.log' and an EVE record type 'stats' are enabled by default.
      '';

      type =
        with types;
        nullOr (submodule {
          options = {
            enable = mkEnableOption "suricata global stats";

            decoder-events = mkOption {
              default = true;

              description = ''
                Add decode events to stats
              '';

              type = types.bool;
            };

            decoder-events-prefix = mkOption {
              default = "decoder.event";

              description = ''
                Decoder event prefix in stats. Has been 'decoder' before, but that leads
                to missing events in the eve.stats records.
              '';

              type = types.str;
            };

            interval = mkOption {
              default = "8";

              description = ''
                The interval field (in seconds) controls the interval at
                which stats are updated in the log.
              '';

              type = types.str;
            };

            stream-events = mkOption {
              default = false;

              description = ''
                Add stream events as stats.
              '';

              type = types.bool;
            };
          };
        });
    };

    "threshold-file" = mkOption {
      default = "${cfg.package}/etc/suricata/threshold.config";
      defaultText = "\${config.services.suricata.package}/etc/suricata/threshold.config";
      description = "Suricata threshold configuration file.";
      type = types.str;
    };

    "unix-command" = mkOption {
      default = { };

      description = ''
        Unix command socket that can be used to pass commands to Suricata.
        An external tool can then connect to get information from Suricata
        or trigger some modifications of the engine. Set enabled to yes
        to activate the feature. In auto mode, the feature will only be
        activated in live capture mode. You can use the filename variable to set
        the file name of the socket.
      '';

      type =
        with types;
        nullOr (submodule {
          options = {
            enabled = mkOption {
              default = "auto";

              description = ''
                Enable unix-command socket.
              '';

              type = types.either types.bool (types.enum [ "auto" ]);
            };

            filename = mkOption {
              default = "/run/suricata/suricata-command.socket";

              description = ''
                Filename for unix-command socket.
              '';

              type = types.path;
            };
          };
        });
    };

    vars = mkOption {
      default = { }; # add default values to config

      description = ''
        Variables to be used within the suricata rules.
      '';

      type = types.nullOr (
        types.submodule {
          options = {
            address-groups = mkOption {
              default = { };

              description = ''
                The address group variables for suricata, if not defined the
                default value of suricata (see example) will be used.
                Your settings will extend the predefined values in example.
              '';

              example = {
                AIM_SERVERS = "$EXTERNAL_NET";
                DC_SERVERS = "$HOME_NET";
                DNP3_CLIENT = "$HOME_NET";
                DNP3_SERVER = "$HOME_NET";
                DNS_SERVERS = "$HOME_NET";
                ENIP_CLIENT = "$HOME_NET";
                ENIP_SERVER = "$HOME_NET";
                EXTERNAL_NET = "!$HOME_NET";
                HOME_NET = "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]";
                HTTP_SERVERS = "$HOME_NET";
                MODBUS_CLIENT = "$HOME_NET";
                MODBUS_SERVER = "$HOME_NET";
                SMTP_SERVERS = "$HOME_NET";
                SQL_SERVERS = "$HOME_NET";
                TELNET_SERVERS = "$HOME_NET";
              };

              type = (
                types.submodule {
                  options = {
                    AIM_SERVERS = mkOption {
                      default = "$EXTERNAL_NET";

                      description = ''
                        AIM_SERVERS variable.
                      '';
                    };

                    DC_SERVERS = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        DC_SERVERS variable.
                      '';
                    };

                    DNP3_CLIENT = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        DNP3_CLIENT variable.
                      '';
                    };

                    DNP3_SERVER = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        DNP3_SERVER variable.
                      '';
                    };

                    DNS_SERVERS = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        DNS_SERVERS variable.
                      '';
                    };

                    ENIP_CLIENT = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        ENIP_CLIENT variable.
                      '';
                    };

                    ENIP_SERVER = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        ENIP_SERVER variable.
                      '';
                    };

                    EXTERNAL_NET = mkOption {
                      default = "!$HOME_NET";

                      description = ''
                        EXTERNAL_NET variable.
                      '';
                    };

                    HOME_NET = mkOption {
                      default = "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]";

                      description = ''
                        HOME_NET variable.
                      '';
                    };

                    HTTP_SERVERS = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        HTTP_SERVERS variable.
                      '';
                    };

                    MODBUS_CLIENT = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        MODBUS_CLIENT variable
                      '';
                    };

                    MODBUS_SERVER = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        MODBUS_SERVER variable.
                      '';
                    };

                    SMTP_SERVERS = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        SMTP_SERVERS variable.
                      '';
                    };

                    SQL_SERVERS = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        SQL_SERVERS variable.
                      '';
                    };

                    TELNET_SERVERS = mkOption {
                      default = "$HOME_NET";

                      description = ''
                        TELNET_SERVERS variable.
                      '';
                    };
                  };
                }
              );
            };

            port-groups = mkOption {
              default = {
                DNP3_PORTS = "20000";
                FILE_DATA_PORTS = "[$HTTP_PORTS,110,143]";
                FTP_PORTS = "21";
                GENEVE_PORTS = "6081";
                HTTP_PORTS = "80";
                MODBUS_PORTS = "502";
                ORACLE_PORTS = "1521";
                SHELLCODE_PORTS = "!80";
                SSH_PORTS = "22";
                TEREDO_PORTS = "3544";
                VXLAN_PORTS = "4789";
              };

              description = ''
                The port group variables for suricata.
              '';

              type = with types; nullOr (attrsOf str);
            };
          };
        }
      );
    };
  };

  freeformType = yaml.type;
}
