{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    boolToString
    getExe
    hasSuffix
    hiPrio
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    optional
    optionalAttrs
    optionalString
    optionals
    singleton
    teams
    types
    ;
  inherit (types)
    addCheck
    bool
    enum
    float
    int
    ints
    lines
    listOf
    nullOr
    path
    str
    submodule
    ;

  cfg = config.virtualisation.xen;

  xenBootBuilder = pkgs.writeShellApplication {
    # We disable SC2016 because we don't want to expand the regexes in the sed commands.
    excludeShellChecks = [ "SC2016" ];
    name = "xenBootBuilder";
    runtimeEnv.efiMountPoint = config.boot.loader.efi.efiSysMountPoint;

    runtimeInputs =
      (with pkgs; [
        binutils
        coreutils
        findutils
        gawk
        gnugrep
        gnused
        jq
      ])
      ++ optionals (cfg.boot.builderVerbosity == "info") (
        with pkgs;
        [
          bat
          diffutils
        ]
      );

    text = builtins.readFile ./xen-boot-builder.sh;
  };
in

{
  imports = [
    (mkRemovedOptionModule
      [
        "virtualisation"
        "xen"
        "bridge"
        "name"
      ]
      "The Xen Network Bridge options are currently unavailable. Please set up your own bridge manually."
    )
    (mkRemovedOptionModule
      [
        "virtualisation"
        "xen"
        "bridge"
        "address"
      ]
      "The Xen Network Bridge options are currently unavailable. Please set up your own bridge manually."
    )
    (mkRemovedOptionModule
      [
        "virtualisation"
        "xen"
        "bridge"
        "prefixLength"
      ]
      "The Xen Network Bridge options are currently unavailable. Please set up your own bridge manually."
    )
    (mkRemovedOptionModule
      [
        "virtualisation"
        "xen"
        "bridge"
        "forwardDns"
      ]
      "The Xen Network Bridge options are currently unavailable. Please set up your own bridge manually."
    )
    (mkRenamedOptionModule
      [
        "virtualisation"
        "xen"
        "qemu-package"
      ]
      [
        "virtualisation"
        "xen"
        "qemu"
        "package"
      ]
    )
    (mkRenamedOptionModule
      [
        "virtualisation"
        "xen"
        "package-qemu"
      ]
      [
        "virtualisation"
        "xen"
        "qemu"
        "package"
      ]
    )
    (mkRenamedOptionModule
      [
        "virtualisation"
        "xen"
        "stored"
      ]
      [
        "virtualisation"
        "xen"
        "store"
        "path"
      ]
    )
    (mkRenamedOptionModule
      [
        "virtualisation"
        "xen"
        "efi"
        "bootBuilderVerbosity"
      ]
      [
        "virtualisation"
        "xen"
        "boot"
        "builderVerbosity"
      ]
    )
    (mkRenamedOptionModule
      [
        "virtualisation"
        "xen"
        "bootParams"
      ]
      [
        "virtualisation"
        "xen"
        "boot"
        "params"
      ]
    )
    (mkRenamedOptionModule
      [
        "virtualisation"
        "xen"
        "efi"
        "path"
      ]
      [
        "virtualisation"
        "xen"
        "boot"
        "efi"
        "path"
      ]
    )
  ];

  ## Interface ##

  options.virtualisation.xen = {

    enable = mkEnableOption "the Xen Project Hypervisor, a virtualisation technology defined as a *type-1 hypervisor*, which allows multiple virtual machines, known as *domains*, to run concurrently on the physical machine. NixOS runs as the privileged *Domain 0*. This option requires a reboot into a Xen kernel to take effect";
    package = mkPackageOption pkgs "Xen Hypervisor" { default = [ "xen" ]; };

    boot = {
      bios = {
        path = mkOption {
          default = "${cfg.package.boot}/${cfg.package.multiboot}";
          defaultText = literalExpression "\${config.virtualisation.xen.package.boot}/\${config.virtualisation.xen.package.multiboot}";

          description = ''
            Path to the Xen `multiboot` binary used for BIOS booting.
            Unless you're building your own Xen derivation, you should leave this
            option as the default value.
          '';

          example = literalExpression "\${config.virtualisation.xen.package}/boot/xen-\${config.virtualisation.xen.package.upstreamVersion}";
          type = path;
        };
      };

      builderVerbosity = mkOption {
        default = "default";

        description = ''
          The boot entry builder script should be called with exactly one of the following arguments in order to specify its verbosity:

          - `quiet` supresses all messages.

          - `default` adds a simple "Installing Xen Project Hypervisor boot entries...done." message to the script.

          - `info` is the same as `default`, but it also prints a diff with information on which generations were altered.
            - This option adds two extra dependencies to the script: `diffutils` and `bat`.

          - `debug` prints information messages for every single step of the script.

          This option does not alter the actual functionality of the script, just the number of messages printed when rebuilding the system.
        '';

        example = "info";

        type = enum [
          "default"
          "info"
          "debug"
          "quiet"
        ];
      };

      efi = {
        path = mkOption {
          default = "${cfg.package.boot}/${cfg.package.efi}";
          defaultText = literalExpression "\${config.virtualisation.xen.package.boot}/\${config.virtualisation.xen.package.efi}";

          description = ''
            Path to xen.efi. `pkgs.xen` is patched to install the xen.efi file
            on `$boot/boot/xen.efi`, but an unpatched Xen build may install it
            somewhere else, such as `$out/boot/efi/efi/nixos/xen.efi`. Unless
            you're building your own Xen derivation, you should leave this
            option as the default value.
          '';

          example = literalExpression "\${config.virtualisation.xen.package}/boot/efi/efi/nixos/xen-\${config.virtualisation.xen.package.upstreamVersion}.efi";
          type = path;
        };
      };

      params = mkOption {
        default = [ ];

        description = ''
          Xen Command Line parameters passed to Domain 0 at boot time.

          ::: {.note}
          Note: these are different from {option}`boot.kernelParams`. See
          the [Xen documentation](https://xenbits.xenproject.org/docs/unstable/misc/xen-command-line.html) for more information.
          :::
        '';

        example = literalExpression ''
          [
            "iommu=force:true,qinval:true,debug:true"
            "noreboot=true"
            "vga=ask"
          ]
        '';

        type = listOf str;
      };
    };

    debug = mkEnableOption "Xen debug features for Domain 0. This option enables some hidden debugging tests and features, and should not be used in production";

    dom0Resources = {
      maxMemory = mkOption {
        default = cfg.dom0Resources.memory;
        defaultText = literalExpression "config.virtualisation.xen.dom0Resources.memory";

        description = ''
          Maximum amount of memory (in MiB) that Domain 0 can
          dynamically allocate to itself. Does nothing if set
          to the same amount as virtualisation.xen.memory, or
          if that option is set to 0.
        '';

        example = 1024;
        type = ints.unsigned;
      };

      maxVCPUs = mkOption {
        default = 0;

        description = ''
          Amount of virtual CPU cores allocated to Domain 0 on boot.
          If set to 0, all cores are assigned to Domain 0, and
          unprivileged domains will compete with Domain 0 for CPU time.
        '';

        example = 4;
        type = ints.unsigned;
      };

      memory = mkOption {
        default = 0;

        description = ''
          Amount of memory (in MiB) allocated to Domain 0 on boot.
          If set to 0, all memory is assigned to Domain 0, and
          unprivileged domains will compete with Domain 0 for free RAM.
        '';

        example = 512;
        type = ints.unsigned;
      };
    };

    domains = {
      extraConfig = mkOption {
        default = "";

        description = ''
          Options defined here will override the defaults for xendomains.
          The default options can be seen in the file included from
          /etc/default/xendomains.
        '';

        example = literalExpression ''
          XENDOMAINS_SAVE=/persist/xen/save
          XENDOMAINS_RESTORE=false
          XENDOMAINS_CREATE_USLEEP=10000000
        '';

        type = lines;
      };
    };

    qemu = {
      package = mkPackageOption pkgs "QEMU (with Xen Hypervisor support)" {
        default = [ "qemu_xen" ];
      };

      pidFile = mkOption {
        default = "/run/xen/qemu-dom0.pid";
        description = "Path to the QEMU PID file.";
        example = "/var/run/xen/qemu-dom0.pid";
        type = path;
      };
    };

    store = {
      path = mkOption {
        default = "${cfg.package}/bin/oxenstored";
        defaultText = literalExpression "\${config.virtualisation.xen.package}/bin/oxenstored";

        description = ''
          Path to the Xen Store Daemon. This option is useful to
          switch between the legacy C-based Xen Store Daemon, and
          the newer OCaml-based Xen Store Daemon, `oxenstored`.
        '';

        example = literalExpression "\${config.virtualisation.xen.package}/bin/xenstored";
        type = path;
      };

      settings = mkOption {
        default = { };

        description = ''
          The OCaml-based Xen Store Daemon configuration. This
          option does nothing with the C-based `xenstored`.
        '';

        example = {
          conflict.burstLimit = 15.0;
          conflict.maxHistorySeconds = 0.12;
          enableMerge = false;
          quota.enable = true;
          quota.maxWatchEvents = 2048;
          xenstored.log.file = "/dev/null";
          xenstored.log.level = "info";
        };

        type = submodule {
          options = {
            conflict = {
              burstLimit = mkOption {
                default = 5.0;

                description = ''
                  Limits applied to domains whose writes cause other domains' transaction
                  commits to fail. Must include decimal point.

                  The burst limit is the number of conflicts a domain can cause to
                  fail in a short period; this value is used for both the initial and
                  the maximum value of each domain's conflict-credit, which falls by
                  one point for each conflict caused, and when it reaches zero the
                  domain's requests are ignored.
                '';

                example = 15.0;

                type = addCheck (
                  float
                  // {
                    description = "nonnegative floating point number, meaning >=0";
                    descriptionClass = "nonRestrictiveClause";
                    name = "nonnegativeFloat";
                  }
                ) (n: n >= 0);
              };

              maxHistorySeconds = mkOption {
                default = 5.0e-2;

                description = ''
                  Limits applied to domains whose writes cause other domains' transaction
                  commits to fail. Must include decimal point.

                  The conflict-credit is replenished over time:
                  one point is issued after each conflict.maxHistorySeconds, so this
                  is the minimum pause-time during which a domain will be ignored.
                '';

                example = 1.0;

                type = addCheck (float // { description = "nonnegative floating point number, meaning >=0"; }) (
                  n: n >= 0
                );
              };

              rateLimitIsAggregate = mkOption {
                default = true;

                description = ''
                  If the conflict.rateLimitIsAggregate option is `true`, then after each
                  tick one point of conflict-credit is given to just one domain: the
                  one at the front of the queue. If `false`, then after each tick each
                  domain gets a point of conflict-credit.

                  In environments where it is known that every transaction will
                  involve a set of nodes that is writable by at most one other domain,
                  then it is safe to set this aggregate limit flag to `false` for better
                  performance. (This can be determined by considering the layout of
                  the xenstore tree and permissions, together with the content of the
                  transactions that require protection.)

                  A transaction which involves a set of nodes which can be modified by
                  multiple other domains can suffer conflicts caused by any of those
                  domains, so the flag must be set to `true`.
                '';

                example = false;
                type = bool;
              };
            };

            enableMerge = mkOption {
              default = true;
              description = "Whether to enable transaction merge support.";
              example = false;
              type = bool;
            };

            perms = {
              enable = mkOption {
                default = true;
                description = "Whether to enable the node permission system.";
                example = false;
                type = bool;
              };

              enableWatch = mkOption {
                default = true;

                description = ''
                  Whether to enable the watch permission system.

                  When this is set to `true`, unprivileged guests can only get watch events
                  for xenstore entries that they would've been able to read.

                  When this is set to `false`, unprivileged guests may get watch events
                  for xenstore entries that they cannot read. The watch event contains
                  only the entry name, not the value.
                  This restores behaviour prior to [XSA-115](https://xenbits.xenproject.org/xsa/advisory-115.html).
                '';

                example = false;
                type = bool;
              };
            };

            persistent = mkOption {
              default = false;
              description = "Whether to activate the filed base backend.";
              example = true;
              type = bool;
            };

            pidFile = mkOption {
              default = "/run/xen/xenstored.pid";
              description = "Path to the Xen Store Daemon PID file.";
              example = "/var/run/xen/xenstored.pid";
              type = path;
            };

            quota = {
              enable = mkOption {
                default = true;
                description = "Whether to enable the quota system.";
                example = false;
                type = bool;
              };

              maxEntity = mkOption {
                default = 1000;
                description = "Entity limit for transactions.";
                example = 1024;
                type = ints.positive;
              };

              maxOutstanding = mkOption {
                default = 1024;
                description = "Maximum outstanding requests, i.e. in-flight requests / domain.";
                example = 1024;
                type = ints.positive;
              };

              maxPath = mkOption {
                default = 1024;
                description = "Path limit for the quota system.";
                example = 1024;
                type = ints.positive;
              };

              maxRequests = mkOption {
                default = 1024;
                description = "Maximum number of requests per transaction.";
                example = 1024;
                type = ints.positive;
              };

              maxSize = mkOption {
                default = 2048;
                description = "Size limit for transactions.";
                example = 4096;
                type = ints.positive;
              };

              maxWatch = mkOption {
                default = 100;
                description = "Maximum number of watches by the Xenstore Watchdog.";
                example = 256;
                type = ints.positive;
              };

              maxWatchEvents = mkOption {
                default = 1024;
                description = "Maximum number of outstanding watch events per watch.";
                example = 2048;
                type = ints.positive;
              };

              transaction = mkOption {
                default = 10;
                description = "Maximum number of transactions.";
                example = 50;
                type = ints.positive;
              };
            };

            ringScanInterval = mkOption {
              default = 20;

              description = ''
                Perodic scanning for all the rings as a safenet for lazy clients.
                Define the interval in seconds; set to a negative integer to disable.
              '';

              example = 30;

              type = addCheck (
                int
                // {
                  description = "nonzero signed integer, meaning !=0";
                  descriptionClass = "nonRestrictiveClause";
                  name = "nonzeroInt";
                }
              ) (n: n != 0);
            };

            testEAGAIN = mkOption {
              default = cfg.debug;
              defaultText = literalExpression "config.virtualisation.xen.debug";
              description = "Randomly fail a transaction with EAGAIN. This option is used for debugging purposes only.";
              example = true;
              type = bool;
              visible = false;
            };

            xenstored = {
              accessLog = {
                file = mkOption {
                  default = "/var/log/xen/xenstored-access.log";
                  description = "Path to the Xen Store access log file.";
                  example = "/var/log/security/xenstored-access.log";
                  type = path;
                };

                nbChars = mkOption {
                  default = 180;
                  description = "Set `acesss-log-nb-chars`.";
                  example = 256;
                  type = int;
                  visible = false;
                };

                nbLines = mkOption {
                  default = 13215;
                  description = "Set `access-log-nb-lines`.";
                  example = 16384;
                  type = int;
                  visible = false;
                };

                specialOps = mkOption {
                  default = false;
                  description = "Set `access-log-special-ops`.";
                  example = true;
                  type = bool;
                  visible = false;
                };
              };

              log = {
                file = mkOption {
                  default = "/var/log/xen/xenstored.log";
                  description = "Path to the Xen Store log file.";
                  example = "/dev/null";
                  type = path;
                };

                level = mkOption {
                  default = if cfg.trace then "debug" else null;
                  defaultText = literalExpression "if (config.virtualisation.xen.trace == true) then \"debug\" else null";
                  description = "Logging level for the Xen Store.";
                  example = "error";

                  type = nullOr (enum [
                    "debug"
                    "info"
                    "warn"
                    "error"
                  ]);
                };

                # The hidden options below have no upstream documentation whatsoever.
                # The nb* options appear to alter the log rotation behaviour, and
                # the specialOps option appears to affect the Xenbus logging logic.
                nbFiles = mkOption {
                  default = 10;
                  description = "Set `xenstored-log-nb-files`.";
                  example = 16;
                  type = int;
                  visible = false;
                };
              };

              xenfs = {
                kva = mkOption {
                  default = "/proc/xen/xsd_kva";

                  description = ''
                    Path to the Xen Store Daemon KVA location inside the XenFS pseudo-filesystem.
                    While it is possible to alter this value, some drivers may be hardcoded to follow the default paths.
                  '';

                  example = cfg.store.settings.xenstored.xenfs.kva;
                  type = path;
                  visible = false;
                };

                port = mkOption {
                  default = "/proc/xen/xsd_port";

                  description = ''
                    Path to the Xen Store Daemon userspace port inside the XenFS pseudo-filesystem.
                    While it is possible to alter this value, some drivers may be hardcoded to follow the default paths.
                  '';

                  example = cfg.store.settings.xenstored.xenfs.port;
                  type = path;
                  visible = false;
                };
              };
            };
          };
        };
      };

      type = mkOption {
        default = if (hasSuffix "oxenstored" cfg.store.path) then "ocaml" else "c";
        description = "Helper internal option that determines the type of the Xen Store Daemon based on cfg.store.path.";
        internal = true;
        readOnly = true;

        type = enum [
          "c"
          "ocaml"
        ];
      };
    };

    trace = mkOption {
      default = cfg.debug;
      defaultText = literalExpression "false";
      description = "Whether to enable Xen debug tracing and logging for Domain 0.";
      example = true;
      type = bool;
    };
  };

  ## Implementation ##

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isx86_64;
        message = "Xen is currently not supported on ${pkgs.stdenv.hostPlatform.system}.";
      }
      {
        assertion =
          config.boot.loader.systemd-boot.enable
          || (config.boot ? lanzaboote) && config.boot.lanzaboote.enable
          || config.boot.loader.limine.enable;

        message = "Xen only supports booting on systemd-boot, Lanzaboote or Limine.";
      }
      {
        assertion = config.boot.initrd.systemd.enable;

        message = ''
          Xen does not support the legacy script-based stage 1 initial ramdisk.
          Please set 'boot.initrd.systemd.enable' to 'true'.
        '';
      }
      {
        assertion = cfg.dom0Resources.maxMemory >= cfg.dom0Resources.memory;

        message = ''
          You have allocated more memory to dom0 than 'virtualisation.xen.dom0Resources.maxMemory'
          allows for. Please increase the maximum memory limit, or decrease the default memory allocation.
        '';
      }
      {
        assertion = cfg.debug -> cfg.trace;
        message = "Xen's debugging features are enabled, but logging is disabled. This is most likely not what you want.";
      }
      {
        assertion = cfg.store.settings.quota.maxWatchEvents >= cfg.store.settings.quota.maxOutstanding;

        message = ''
          Upstream Xen recommends that 'virtualisation.xen.store.settings.quota.maxWatchEvents'
          be equal to or greater than 'virtualisation.xen.store.settings.quota.maxOutstanding',
          in order to mitigate denial of service attacks from malicious frontends.
        '';
      }
    ];

    boot = {
      # Xen Bootspec extension. This extension allows NixOS bootloaders to
      # fetch the dom0 kernel paths and access the `cfg.boot.params` option.
      # Bootspec extension v2 includes more detail,
      # including supporting multiboot, and is the current supported
      # bootspec extension
      bootspec.extensions."org.xenproject.bootspec.v2" = {
        efiPath = cfg.boot.efi.path;
        multibootPath = cfg.boot.bios.path;
        params = cfg.boot.params;
        version = cfg.package.version;
      };

      # Increase the number of loopback devices from the default (8),
      # which is way too small because every VM virtual disk requires a
      # loopback device.
      extraModprobeConfig = ''
        options loop max_loop=64
      '';

      # The xenfs module is needed to mount /proc/xen.
      initrd.kernelModules = [ "xenfs" ];

      kernelModules = [
        "xen-evtchn"
        "xen-gntdev"
        "xen-gntalloc"
        "xen-blkback"
        "xen-netback"
        "xen-pciback"
        "tun"
        "netxen_nic"
        "xen_wdt"
        "xen-acpi-processor"
        "xen-privcmd"
        "xen-scsiback"
        "xenfs"
      ];

      # See the `xenBootBuilder` script in the main `let...in` statement of this file.
      loader.systemd-boot.extraInstallCommands = "${getExe xenBootBuilder} ${cfg.boot.builderVerbosity}";
    };

    environment = {
      etc =
        # Set up Xen Domain 0 configuration files.
        {
          "default/xencommons".text = ''
            source ${cfg.package}/etc/default/xencommons

            XENSTORED="${cfg.store.path}"
            QEMU_XEN="${cfg.qemu.package}/${cfg.qemu.package.qemu-system-i386}"
            ${optionalString cfg.trace ''
              XENSTORED_TRACE=yes
              XENCONSOLED_TRACE=all
            ''}
          '';

          "default/xendomains".text = ''
            source ${cfg.package}/etc/default/xendomains

            ${cfg.domains.extraConfig}
          '';

          "xen/scripts-xen" = {
            source = "${cfg.package}/etc/xen/scripts/*";
            target = "xen/scripts";
          };

          "xen/xl.conf".source = "${cfg.package}/etc/xen/xl.conf"; # TODO: Add options to configure xl.conf declaratively. It's worth considering making a new "xl value" type, as it could be reused to produce xl.cfg (domain definition) files.
        }
        # The OCaml-based Xen Store Daemon requires /etc/xen/oxenstored.conf to start.
        // optionalAttrs (cfg.store.type == "ocaml") {
          "xen/oxenstored.conf".text = ''
            pid-file = ${cfg.store.settings.pidFile}
            test-eagain = ${boolToString cfg.store.settings.testEAGAIN}
            merge-activate = ${toString cfg.store.settings.enableMerge}
            conflict-burst-limit = ${toString cfg.store.settings.conflict.burstLimit}
            conflict-max-history-seconds = ${toString cfg.store.settings.conflict.maxHistorySeconds}
            conflict-rate-limit-is-aggregate = ${toString cfg.store.settings.conflict.rateLimitIsAggregate}
            perms-activate = ${toString cfg.store.settings.perms.enable}
            perms-watch-activate = ${toString cfg.store.settings.perms.enableWatch}
            quota-activate = ${toString cfg.store.settings.quota.enable}
            quota-maxentity = ${toString cfg.store.settings.quota.maxEntity}
            quota-maxsize = ${toString cfg.store.settings.quota.maxSize}
            quota-maxwatch = ${toString cfg.store.settings.quota.maxWatch}
            quota-transaction = ${toString cfg.store.settings.quota.transaction}
            quota-maxrequests = ${toString cfg.store.settings.quota.maxRequests}
            quota-path-max = ${toString cfg.store.settings.quota.maxPath}
            quota-maxoutstanding = ${toString cfg.store.settings.quota.maxOutstanding}
            quota-maxwatchevents = ${toString cfg.store.settings.quota.maxWatchEvents}
            persistent = ${boolToString cfg.store.settings.persistent}
            xenstored-log-file = ${cfg.store.settings.xenstored.log.file}
            xenstored-log-level = ${
              if isNull cfg.store.settings.xenstored.log.level then
                "null"
              else
                cfg.store.settings.xenstored.log.level
            }
            xenstored-log-nb-files = ${toString cfg.store.settings.xenstored.log.nbFiles}
            access-log-file = ${cfg.store.settings.xenstored.accessLog.file}
            access-log-nb-lines = ${toString cfg.store.settings.xenstored.accessLog.nbLines}
            acesss-log-nb-chars = ${toString cfg.store.settings.xenstored.accessLog.nbChars}
            access-log-special-ops = ${boolToString cfg.store.settings.xenstored.accessLog.specialOps}
            ring-scan-interval = ${toString cfg.store.settings.ringScanInterval}
            xenstored-kva = ${cfg.store.settings.xenstored.xenfs.kva}
            xenstored-port = ${cfg.store.settings.xenstored.xenfs.port}
          '';
        };

      systemPackages = [
        cfg.package
        (hiPrio cfg.qemu.package)
      ];
    };

    # Xen provides udev rules.
    services.udev.packages = [ cfg.package ];

    # Domain 0 requires a pvops-enabled kernel.
    # All NixOS kernels come with this enabled by default; this is merely a sanity check.
    system.requiredKernelConfig = with config.lib.kernelConfig; [
      (isYes "XEN")
      (isYes "X86_IO_APIC")
      (isYes "ACPI")
      (isYes "XEN_DOM0")
      (isYes "PCI_XEN")
      (isYes "XEN_DEV_EVTCHN")
      (isYes "XENFS")
      (isYes "XEN_COMPAT_XENFS")
      (isYes "XEN_SYS_HYPERVISOR")
      (isYes "XEN_GNTDEV")
      (isYes "XEN_BACKEND")
      (isModule "XEN_NETDEV_BACKEND")
      (isModule "XEN_BLKDEV_BACKEND")
      (isModule "XEN_PCIDEV_BACKEND")
      (isYes "XEN_BALLOON")
      (isYes "XEN_SCRUB_PAGES")
    ];

    systemd = {
      mounts = singleton {
        description = "Mount /proc/xen files";
        type = "xenfs";

        unitConfig = {
          ConditionPathExists = "/proc/xen";
          RefuseManualStop = "true";
        };

        what = "xenfs";
        where = "/proc/xen";
      };

      # Xen provides systemd units.
      packages = [ cfg.package ];

      services = {
        xen-init-dom0 = {
          restartIfChanged = false;
          wantedBy = [ "multi-user.target" ];
        };

        xen-qemu-dom0-disk-backend = {
          serviceConfig = {
            ExecStart = [
              ""
              ''
                ${cfg.qemu.package}/${cfg.qemu.package.qemu-system-i386} \
                -xen-domid 0 -xen-attach -name dom0 -nographic -M xenpv \
                -daemonize -monitor /dev/null -serial /dev/null -parallel \
                /dev/null -nodefaults -no-user-config -pidfile \
                ${cfg.qemu.pidFile}
              ''
            ];

            PIDFile = cfg.qemu.pidFile;
            overrideStrategy = "asDropin";
          };

          wantedBy = [ "multi-user.target" ];
        };

        xen-watchdog = {
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "1";
          };

          wantedBy = [ "multi-user.target" ];
        };

        xenconsoled.wantedBy = [ "multi-user.target" ];

        xendomains = {
          path = [
            cfg.package
            cfg.qemu.package
          ];

          preStart = "mkdir -p /var/lock/subsys -m 755";
          restartIfChanged = false;
          wantedBy = [ "multi-user.target" ];
        };

        # While this service is installed by the `xen` package, it shouldn't be used in dom0.
        xendriverdomain.enable = false;

        xenstored = {
          preStart = ''
            export XENSTORED_ROOTDIR="/var/lib/xenstored"
            rm -f "$XENSTORED_ROOTDIR"/tdb* &>/dev/null
            mkdir -p /var/{run,log,lib}/xen
          '';

          wantedBy = [ "multi-user.target" ];
        };
      };
    };

    virtualisation.xen.boot.params =
      optionals cfg.trace [
        "loglvl=all"
        "guest_loglvl=all"
      ]
      ++
        optional (cfg.dom0Resources.memory != 0)
          "dom0_mem=${toString cfg.dom0Resources.memory}M${
            optionalString (
              cfg.dom0Resources.memory != cfg.dom0Resources.maxMemory
            ) ",max:${toString cfg.dom0Resources.maxMemory}M"
          }"
      ++ optional (
        cfg.dom0Resources.maxVCPUs != 0
      ) "dom0_max_vcpus=${toString cfg.dom0Resources.maxVCPUs}";

    warnings = lib.optional ((config.boot ? lanzaboote) && config.boot.lanzaboote.enable) ''
      Xen support has not yet been merged into Lanzaboote.
      Ensure that your Lanzaboote configuration includes PR #387:
      https://github.com/nix-community/lanzaboote/pull/387
    '';
  };

  meta = {
    doc = ./xen.md;
    teams = [ teams.xen ];
  };
}
