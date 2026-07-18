{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.incus;

  acmeHostDir = config.security.acme.certs."${cfg.useACMEHost}".directory;

  preseedFormat = pkgs.formats.yaml { };

  nvidiaEnabled = (lib.elem "nvidia" config.services.xserver.videoDrivers);

  path =
    with pkgs;
    [
      cfg.package
      "/run/wrappers"

      # some qemu helpers not in bin
      (linkFarm "incus-qemu-libexec" [
        {
          name = "bin";
          path = "${qemu_kvm}/libexec";
        }
      ])

      acl
      attr
      bash
      btrfs-progs
      bzip2
      cdrkit
      coreutils
      criu
      dnsmasq
      e2fsprogs
      findutils
      gawk
      getent
      gnugrep
      gnused
      gnutar
      gptfdisk
      gzip
      iproute2
      iptables
      iw
      kmod
      lego
      libxfs
      lvm2
      lxcfs
      lz4
      nftables
      qemu-utils
      qemu_kvm
      rsync
      skopeo
      squashfs-tools-ng
      squashfsTools
      sshfs
      swtpm
      systemd
      thin-provisioning-tools
      umoci
      util-linux
      virtiofsd
      xdelta
      xz
      zstd
    ]
    ++ lib.optionals config.security.apparmor.enable [
      apparmor-bin-utils

      (writeShellScriptBin "apparmor_parser" ''
        exec '${apparmor-parser}/bin/apparmor_parser' -I '${apparmor-profiles}/etc/apparmor.d' "$@"
      '')
    ]
    ++ lib.optionals config.services.ceph.client.enable [ ceph-client ]
    ++ lib.optionals config.virtualisation.vswitch.enable [ config.virtualisation.vswitch.package ]
    ++ lib.optionals config.boot.zfs.enabled [
      config.boot.zfs.package
      (linkFarm "incus-zfs-udev" [
        {
          name = "bin";
          path = "${config.boot.zfs.package}/lib/udev";
        }
      ])
    ]
    ++ lib.optionals nvidiaEnabled [
      libnvidia-container
    ]
    ++ lib.optionals cfg.storage.truenas.enable [
      truenas-incus-ctl
    ];

  # https://github.com/lxc/incus/blob/cff35a29ee3d7a2af1f937cbb6cf23776941854b/internal/server/instance/drivers/driver_qemu.go#L123
  OVMF2MB = pkgs.OVMF.override {
    fdSize2MB = true;
    secureBoot = true;
  };
  ovmf-prefix = if pkgs.stdenv.hostPlatform.isAarch64 then "AAVMF" else "OVMF";
  ovmf = pkgs.linkFarm "incus-ovmf" (
    [
      # 2MB must remain the default or existing VMs will fail to boot. New VMs will prefer 4MB
      {
        name = "OVMF_CODE.fd";
        path = "${OVMF2MB.fd}/FV/${ovmf-prefix}_CODE.fd";
      }
      {
        name = "OVMF_VARS.fd";
        path = "${OVMF2MB.fd}/FV/${ovmf-prefix}_VARS.fd";
      }
      {
        name = "OVMF_VARS.ms.fd";
        path = "${OVMF2MB.fd}/FV/${ovmf-prefix}_VARS.fd";
      }

      {
        name = "OVMF_CODE.4MB.fd";
        path = "${pkgs.OVMFFull.fd}/FV/${ovmf-prefix}_CODE.fd";
      }
      {
        name = "OVMF_VARS.4MB.fd";
        path = "${pkgs.OVMFFull.fd}/FV/${ovmf-prefix}_VARS.fd";
      }
      {
        name = "OVMF_VARS.4MB.ms.fd";
        path = "${pkgs.OVMFFull.fd}/FV/${ovmf-prefix}_VARS.fd";
      }
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
      {
        name = "seabios.bin";
        path = "${pkgs.seabios-qemu}/share/seabios/bios.bin";
      }
    ]
  );

  environment = lib.mkMerge [
    {
      INCUS_AGENT_PATH = "${cfg.package}/share/agent";
      INCUS_DOCUMENTATION = "${cfg.package.doc}/html";
      INCUS_EDK2_PATH = ovmf;
      INCUS_LXC_HOOK = "${cfg.lxcPackage}/share/lxc/hooks";
      INCUS_LXC_TEMPLATE_CONFIG = "${pkgs.lxcfs}/share/lxc/config";
      INCUS_USBIDS_PATH = "${pkgs.hwdata}/share/hwdata/usb.ids";
    }
    (lib.mkIf (cfg.ui.enable) { "INCUS_UI" = cfg.ui.package; })
  ];

  incus-startup = pkgs.writeShellScript "incus-startup" ''
    case "$1" in
        start)
          systemctl is-active incus.service -q && exit 0
          exec incusd activateifneeded
        ;;

        stop)
          systemctl is-active incus.service -q || exit 0
          exec incusd shutdown
        ;;

        *)
          echo "unknown argument \`$1'" >&2
          exit 1
        ;;
    esac

    exit 0
  '';
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "virtualisation" "incus" "bucketSupport" ] ''
      The option was only a temporary workaround to gate the insecure minio dependency until it could be dropped.
    '')
  ];

  options = {
    virtualisation.incus = {
      enable = lib.mkEnableOption ''
        incusd, a daemon that manages containers and virtual machines.

        Users in the "incus-admin" group can interact with
        the daemon (e.g. to start or stop containers) using the
        {command}`incus` command line tool, among others.
        Users in the "incus" group can also interact with
        the daemon, but with lower permissions
        (i.e. administrative operations are forbidden).
      '';

      package = lib.mkPackageOption pkgs "incus-lts" { };

      clientPackage = lib.mkOption {
        default = cfg.package.client;
        defaultText = lib.literalExpression "config.virtualisation.incus.package.client";
        description = "The incus client package to use. This package is added to PATH.";
        type = lib.types.package;
      };

      lxcPackage = lib.mkOption {
        default = config.virtualisation.lxc.package;
        defaultText = lib.literalExpression "config.virtualisation.lxc.package";
        description = "The lxc package to use.";
        type = lib.types.package;
      };

      preseed = lib.mkOption {
        default = null;

        description = ''
          Configuration for Incus preseed, see
          <https://linuxcontainers.org/incus/docs/main/howto/initialize/#non-interactive-configuration>
          for supported values.

          Changes to this will be re-applied to Incus which will overwrite existing entities or create missing ones,
          but entities will *not* be removed by preseed.
        '';

        example = {
          networks = [
            {
              config = {
                "ipv4.address" = "10.0.100.1/24";
                "ipv4.nat" = "true";
              };

              name = "incusbr0";
              type = "bridge";
            }
          ];

          profiles = [
            {
              devices = {
                eth0 = {
                  name = "eth0";
                  network = "incusbr0";
                  type = "nic";
                };

                root = {
                  path = "/";
                  pool = "default";
                  size = "35GiB";
                  type = "disk";
                };
              };

              name = "default";
            }
          ];

          storage_pools = [
            {
              config = {
                source = "/var/lib/incus/storage-pools/default";
              };

              driver = "dir";
              name = "default";
            }
          ];
        };

        type = lib.types.nullOr (lib.types.submodule { freeformType = preseedFormat.type; });
      };

      socketActivation = lib.mkEnableOption ''
        socket-activation for starting incus.service. Enabling this option
        will stop incus.service from starting automatically on boot.
      '';

      softDaemonRestart = lib.mkOption {
        default = true;

        description = ''
          Allow for incus.service to be stopped without affecting running instances.
        '';

        type = lib.types.bool;
      };

      startTimeout = lib.mkOption {
        apply = toString;
        default = 600;

        description = ''
          Time to wait (in seconds) for incusd to become ready to process requests.
          If incusd does not reply within the configured time, `incus.service` will be
          considered failed and systemd will attempt to restart it.
        '';

        type = lib.types.ints.unsigned;
      };

      storage.truenas.enable = lib.mkEnableOption "TrueNAS storage driver support";

      ui = {
        enable = lib.mkEnableOption "Incus Web UI";
        package = lib.mkPackageOption pkgs [ "incus-ui-canonical" ] { };
      };

      useACMEHost = lib.mkOption {
        default = null;

        description = ''
          Host of an existing Let's Encrypt certificate to use for TLS.
          *Note that this option does not create any certificates and it
          doesn't add subdomains to existing ones – you will need to create
          them manually using {option}`security.acme.certs`.*
        '';

        example = "incus.example.com";
        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(
            config.networking.firewall.enable
            && !(config.networking.nftables.enable || config.networking.firewall.backend == "nftables")
            && config.virtualisation.incus.enable
          );

        message = "Incus on NixOS is unsupported using iptables. Set `networking.nftables.enable = true;`";
      }
      {
        assertion = cfg.storage.truenas.enable -> config.services.openiscsi.enable;
        messages = "`virtualisation.incus.storage.truenas.enable` requires `services.openiscsi.enable`";
      }
    ];

    # https://github.com/lxc/incus/blob/f145309929f849b9951658ad2ba3b8f10cbe69d1/doc/reference/server_settings.md
    boot.kernel.sysctl = {
      "fs.aio-max-nr" = lib.mkDefault 524288;
      "fs.inotify.max_queued_events" = lib.mkDefault 1048576;
      "fs.inotify.max_user_instances" = lib.mkOverride 1050 1048576; # override in case conflict nixos/modules/services/x11/xserver.nix
      "fs.inotify.max_user_watches" = lib.mkOverride 1050 1048576; # override in case conflict nixos/modules/services/x11/xserver.nix
      "kernel.dmesg_restrict" = lib.mkDefault 1;
      "kernel.keys.maxbytes" = lib.mkDefault 2000000;
      "kernel.keys.maxkeys" = lib.mkDefault 2000;
      "net.core.bpf_jit_limit" = lib.mkDefault 1000000000;
      "net.ipv4.neigh.default.gc_thresh3" = lib.mkDefault 8192;
      "net.ipv6.neigh.default.gc_thresh3" = lib.mkDefault 8192;
      # vm.max_map_count is set higher in nixos/modules/config/sysctl.nix
    };

    boot.kernelModules = [
      "br_netfilter"
      "veth"
      "xt_comment"
      "xt_CHECKSUM"
      "xt_MASQUERADE"
      "vhost_vsock"
    ]
    ++ lib.optionals nvidiaEnabled [ "nvidia_uvm" ];

    environment.systemPackages = [
      cfg.clientPackage

      # gui console support
      pkgs.spice-gtk
    ]
    ++ lib.optionals cfg.storage.truenas.enable [
      pkgs.truenas-incus-ctl
    ];

    security.acme.certs = lib.mkIf (cfg.useACMEHost != null) {
      "${cfg.useACMEHost}".reloadServices = [ "incus.service" ];
    };

    security.apparmor = {
      includes."abstractions/base" = ''
        # Allow incusd's various AA profiles to load dynamic libraries from Nix store
        # https://discuss.linuxcontainers.org/t/creating-new-containers-vms-blocked-by-apparmor-on-nixos/21908/6
        mr /nix/store/*/lib/*.so*,
        r ${pkgs.stdenv.cc.libc}/lib/gconv/gconv-modules,
        r ${pkgs.stdenv.cc.libc}/lib/gconv/gconv-modules.d/,
        r ${pkgs.stdenv.cc.libc}/lib/gconv/gconv-modules.d/gconv-modules-extra.conf,

        # Support use of VM instance
        mrix ${pkgs.qemu_kvm}/bin/*,
        k ${OVMF2MB.fd}/FV/*.fd,
        k ${pkgs.OVMFFull.fd}/FV/*.fd,
      ''
      + lib.optionalString pkgs.stdenv.hostPlatform.isx86_64 ''
        k ${pkgs.seabios-qemu}/share/seabios/bios.bin,
      '';

      packages = [ cfg.lxcPackage ];

      policies = {
        "bin.lxc-start".profile = ''
          include ${cfg.lxcPackage}/etc/apparmor.d/usr.bin.lxc-start
        '';

        "incusd".profile = ''
          # incusd is deliberatly left unconfined, with NO named profile attached to the binary.
          # Incus checks its own confinement at startup by reading /proc/self/attr/current
          # (https://github.com/lxc/incus/blob/92b0cbbc5728ed45578fdeeec634606af8826404/internal/server/sys/apparmor.go).
          # Anything other than "unconfined" makes Incus believe that the host process is
          # itself confined, which sends every container down the "reuse my own profile" branch in
          # https://github.com/lxc/incus/blob/92b0cbbc5728ed45578fdeeec634606af8826404/internal/server/instance/drivers/driver_lxc.go
          # instead of generating a "proper" per-container profile. Furthermore,
          # that branch only strips " (enforce)" suffix before handing the string to lxc.apparmor.profile
          # (https://github.com/lxc/incus/blob/92b0cbbc5728ed45578fdeeec634606af8826404/internal/server/instance/drivers/driver_lxc.go#L96),
          # so the named profile with flags=(unconfined) produces a literal string
          # "incusd (unconfined)", which the kernel rejects at change_profile() time
          # with "label not found", failing every `incus start` when AppArmor is enabled.
          # This was not caught before as AppArmor was stifled by bpf.

          # We keep this policy to pull in the per-container /
          # per-archive profiles incusd generates at runtime so
          # apparmor_parser loads them.

          abi <abi/4.0>,
          include <tunables/global>

          include if exists "/var/lib/incus/security/apparmor/profiles"
        '';

        "lxc-containers".profile = ''
          include ${cfg.lxcPackage}/etc/apparmor.d/lxc-containers
        '';
      };
    };

    systemd.services.incus = {
      inherit environment path;

      after = [
        "network-online.target"
        "lxcfs.service"
        "incus.socket"
      ]
      ++ lib.optionals config.virtualisation.vswitch.enable [ "ovs-vswitchd.service" ]
      ++ lib.optionals (cfg.useACMEHost != null) [ "acme-${cfg.useACMEHost}.service" ];

      description = "Incus Container and Virtual Machine Management Daemon";

      requires = [
        "lxcfs.service"
        "incus.socket"
      ]
      ++ lib.optionals config.virtualisation.vswitch.enable [ "ovs-vswitchd.service" ];

      serviceConfig = {
        BindReadOnlyPaths = lib.mkIf (cfg.useACMEHost != null) [
          "${acmeHostDir}/fullchain.pem:/var/lib/incus/server.crt"
          "${acmeHostDir}/key.pem:/var/lib/incus/server.key"
        ];

        Delegate = "yes";
        ExecStart = "${cfg.package}/bin/incusd --group incus-admin";
        ExecStartPost = "${cfg.package}/bin/incusd waitready --timeout=${cfg.startTimeout}";
        ExecStop = lib.optionalString (!cfg.softDaemonRestart) "${cfg.package}/bin/incus admin shutdown";
        KillMode = "process"; # when stopping, leave the containers alone
        LimitMEMLOCK = "infinity";
        LimitNOFILE = "1048576";
        LimitNPROC = "infinity";
        Restart = "on-failure";
        TasksMax = "infinity";
        TimeoutStartSec = "${cfg.startTimeout}s";
        TimeoutStopSec = "30s";
      };

      stopIfChanged = lib.mkIf cfg.softDaemonRestart false;
      wantedBy = lib.mkIf (!cfg.socketActivation) [ "multi-user.target" ];

      wants = [
        "network-online.target"
      ]
      ++ lib.optionals (cfg.useACMEHost != null) [ "acme-${cfg.useACMEHost}.service" ];
    };

    systemd.services.incus-preseed = lib.mkIf (cfg.preseed != null) {
      after = [ "incus.service" ];
      bindsTo = [ "incus.service" ];
      description = "Incus initialization with preseed file";
      partOf = [ "incus.service" ];

      script = ''
        ${cfg.package}/bin/incus admin init --preseed <${preseedFormat.generate "incus-preseed.yaml" cfg.preseed}
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "incus.service" ];
    };

    systemd.services.incus-startup = lib.mkIf cfg.softDaemonRestart {
      inherit environment path;

      after = [
        "incus.service"
        "incus.socket"
      ];

      description = "Incus Instances Startup/Shutdown";
      requires = [ "incus.socket" ];
      # restarting this service will affect instances
      restartIfChanged = false;

      serviceConfig = {
        ExecStart = "${incus-startup} start";
        ExecStop = "${incus-startup} stop";
        RemainAfterExit = true;
        TimeoutStartSec = "600s";
        TimeoutStopSec = "600s";
        Type = "oneshot";
      };

      stopIfChanged = false;
      wantedBy = config.systemd.services.incus.wantedBy;
    };

    systemd.services.incus-user = {
      inherit environment path;

      after = [
        "incus.service"
        "incus-user.socket"
      ];

      description = "Incus Container and Virtual Machine Management User Daemon";

      requires = [
        "incus-user.socket"
      ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/incus-user --group incus";
        Restart = "on-failure";
      };
    };

    systemd.sockets.incus = {
      description = "Incus UNIX socket";

      socketConfig = {
        ListenStream = "/var/lib/incus/unix.socket";
        SocketGroup = "incus-admin";
        SocketMode = "0660";
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.sockets.incus-user = {
      description = "Incus user UNIX socket";

      socketConfig = {
        ListenStream = "/var/lib/incus/unix.socket.user";
        SocketGroup = "incus";
        SocketMode = "0660";
      };

      wantedBy = [ "sockets.target" ];
    };

    # Note: the following options are also declared in virtualisation.lxc, but
    # the latter can't be simply enabled to reuse the formers, because it
    # does a bunch of unrelated things.
    systemd.tmpfiles.rules = [ "d /var/lib/lxc/rootfs 0755 root root -" ];
    users.groups.incus = { };
    users.groups.incus-admin = { };

    users.users.root = {
      subGidRanges = [
        {
          count = 1000000000;
          startGid = 1000000;
        }
      ];

      # match documented default ranges https://linuxcontainers.org/incus/docs/main/userns-idmap/#allowed-ranges
      subUidRanges = [
        {
          count = 1000000000;
          startUid = 1000000;
        }
      ];
    };

    virtualisation.lxc.lxcfs.enable = true;
  };

  meta = {
    teams = [ lib.teams.lxc ];
  };
}
