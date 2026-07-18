{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.virtualisation.libvirtd;
  vswitch = config.virtualisation.vswitch;
  configFile = pkgs.writeText "libvirtd.conf" ''
    auth_unix_ro = "polkit"
    auth_unix_rw = "polkit"
    ${cfg.extraConfig}
  '';
  qemuConfigFile = pkgs.writeText "qemu.conf" ''
    ${optionalString (!cfg.qemu.runAsRoot) ''
      user = "qemu-libvirtd"
      group = "qemu-libvirtd"
    ''}
    ${cfg.qemu.verbatimConfig}
  '';
  networkConfigFile = pkgs.writeText "network.conf" ''
    firewall_backend = "${cfg.firewallBackend}"
  '';

  dirName = "libvirt";
  subDirs = list: [ dirName ] ++ map (e: "${dirName}/${e}") list;

  swtpmModule = types.submodule {
    options = {
      enable = mkOption {
        default = false;

        description = ''
          Allows libvirtd to use swtpm to create an emulated TPM.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "swtpm" { };
    };
  };

  qemuModule = types.submodule {
    options = {
      package = mkPackageOption pkgs "qemu" {
        extraDescription = ''
          `pkgs.qemu` can emulate alien architectures (e.g. aarch64 on x86)
          `pkgs.qemu_kvm` saves disk space allowing to emulate only host architectures.
        '';
      };

      ovmf = mkOption {
        default = { };
        description = "This submodule is deprecated and has been removed";
        internal = true;

        type = types.submodule {
          options = {
            enable = mkOption {
              default = null;
              internal = true;
              type = types.nullOr types.bool;
            };

            package = mkOption {
              default = null;
              internal = true;
              type = types.nullOr types.package;
            };

            packages = mkOption {
              default = null;
              internal = true;
              type = types.nullOr (types.listOf types.package);
            };
          };
        };
      };

      runAsRoot = mkOption {
        default = true;

        description = ''
          If true,  libvirtd runs qemu as root.
          If false, libvirtd runs qemu as unprivileged user qemu-libvirtd.
          Changing this option to false may cause file permission issues
          for existing guests. To fix these, manually change ownership
          of affected files in /var/lib/libvirt/qemu to qemu-libvirtd.
        '';

        type = types.bool;
      };

      swtpm = mkOption {
        default = { };

        description = ''
          QEMU's swtpm options.
        '';

        type = swtpmModule;
      };

      verbatimConfig = mkOption {
        default = ''
          namespaces = []
        '';

        description = ''
          Contents written to the qemu configuration file, qemu.conf.
          Make sure to include a proper namespace configuration when
          supplying custom configuration.
        '';

        type = types.lines;
      };

      vhostUserPackages = mkOption {
        default = [ ];

        description = ''
          Packages containing out-of-tree vhost-user drivers.
        '';

        example = lib.literalExpression "[ pkgs.virtiofsd ]";
        type = types.listOf types.package;
      };
    };
  };

  hooksModule = types.submodule {
    options = {
      daemon = mkOption {
        default = { };

        description = ''
          Hooks that will be placed under /var/lib/libvirt/hooks/daemon.d/
          and called for daemon start/shutdown/SIGHUP events.
          Please see <https://libvirt.org/hooks.html> for documentation.
        '';

        type = types.attrsOf types.path;
      };

      libxl = mkOption {
        default = { };

        description = ''
          Hooks that will be placed under /var/lib/libvirt/hooks/libxl.d/
          and called for libxl-handled xen domains begin/end events.
          Please see <https://libvirt.org/hooks.html> for documentation.
        '';

        type = types.attrsOf types.path;
      };

      lxc = mkOption {
        default = { };

        description = ''
          Hooks that will be placed under /var/lib/libvirt/hooks/lxc.d/
          and called for lxc domains begin/end events.
          Please see <https://libvirt.org/hooks.html> for documentation.
        '';

        type = types.attrsOf types.path;
      };

      network = mkOption {
        default = { };

        description = ''
          Hooks that will be placed under /var/lib/libvirt/hooks/network.d/
          and called for networks begin/end events.
          Please see <https://libvirt.org/hooks.html> for documentation.
        '';

        type = types.attrsOf types.path;
      };

      qemu = mkOption {
        default = { };

        description = ''
          Hooks that will be placed under /var/lib/libvirt/hooks/qemu.d/
          and called for qemu domains begin/end/migrate events.
          Please see <https://libvirt.org/hooks.html> for documentation.
        '';

        type = types.attrsOf types.path;
      };
    };
  };

  nssModule = types.submodule {
    options = {
      enable = mkOption {
        default = false;

        description = ''
          This option enables the older libvirt NSS module. This method uses
          DHCP server records, therefore is dependent on the hostname provided
          by the guest.
          Please see <https://libvirt.org/nss.html> for more information.
        '';

        type = types.bool;
      };

      enableGuest = mkOption {
        default = false;

        description = ''
          This option enables the newer libvirt_guest NSS module. This module
          uses the libvirt guest name instead of the hostname of the guest.
          Please see <https://libvirt.org/nss.html> for more information.
        '';

        type = types.bool;
      };
    };
  };

  qemuOvmfMetadata = pkgs.stdenv.mkDerivation {
    dontBuild = true;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out
      cp ${cfg.qemu.package}/share/qemu/firmware/*.json $out
      substituteInPlace $out/*.json \
        --replace-fail "${cfg.qemu.package}/share/qemu/" "/run/${dirName}/nix-ovmf/"
    '';

    name = "qemu-ovmf-metadata";
    nativeBuildInputs = [ cfg.qemu.package ];
    version = cfg.qemu.package.version;
  };

in
{

  imports = [
    (mkRemovedOptionModule [
      "virtualisation"
      "libvirtd"
      "enableKVM"
    ] "Set the option `virtualisation.libvirtd.qemu.package' instead.")
    (mkRenamedOptionModule
      [ "virtualisation" "libvirtd" "qemuPackage" ]
      [ "virtualisation" "libvirtd" "qemu" "package" ]
    )
    (mkRenamedOptionModule
      [ "virtualisation" "libvirtd" "qemuRunAsRoot" ]
      [ "virtualisation" "libvirtd" "qemu" "runAsRoot" ]
    )
    (mkRenamedOptionModule
      [ "virtualisation" "libvirtd" "qemuVerbatimConfig" ]
      [ "virtualisation" "libvirtd" "qemu" "verbatimConfig" ]
    )
    (mkRenamedOptionModule
      [ "virtualisation" "libvirtd" "qemuSwtpm" ]
      [ "virtualisation" "libvirtd" "qemu" "swtpm" "enable" ]
    )
    (mkRemovedOptionModule [ "virtualisation" "libvirtd" "qemuOvmf" ]
      "The 'virtualisation.libvirtd.qemuOvmf' option has been removed. All OVMF images distributed with QEMU are now available by default."
    )
    (mkRemovedOptionModule [ "virtualisation" "libvirtd" "qemuOvmfPackage" ]
      "The 'virtualisation.libvirtd.qemuOvmfPackage' option has been removed. All OVMF images distributed with QEMU are now available by default."
    )
  ];

  ###### interface

  options.virtualisation.libvirtd = {

    enable = mkOption {
      default = false;

      description = ''
        This option enables libvirtd, a daemon that manages
        virtual machines. Users in the "libvirtd" group can interact with
        the daemon (e.g. to start or stop VMs) using the
        {command}`virsh` command line tool, among others.
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "libvirt" { };

    allowedBridges = mkOption {
      default = [ "virbr0" ];

      description = ''
        List of bridge devices that can be used by qemu:///session
      '';

      type = types.listOf types.str;
    };

    dbus = {
      enable = mkEnableOption "exposing libvirtd APIs over D-Bus";
      package = mkPackageOption pkgs "libvirt-dbus" { };
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Extra contents appended to the libvirtd configuration file,
        libvirtd.conf.
      '';

      type = types.lines;
    };

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Extra command line arguments passed to libvirtd on startup.
      '';

      example = [ "--verbose" ];
      type = types.listOf types.str;
    };

    firewallBackend = mkOption {
      default = if config.networking.nftables.enable then "nftables" else "iptables";
      defaultText = lib.literalExpression "if config.networking.nftables.enable then \"nftables\" else \"iptables\"";

      description = ''
        The backend used to setup virtual network firewall rules.
      '';

      type = types.enum [
        "iptables"
        "nftables"
      ];
    };

    hooks = mkOption {
      default = { };

      description = ''
        Hooks related options.
      '';

      type = hooksModule;
    };

    nss = mkOption {
      default = { };

      description = ''
        libvirt NSS module options.
      '';

      type = nssModule;
    };

    onBoot = mkOption {
      default = "start";

      description = ''
        Specifies the action to be done to / on the guests when the host boots.
        The "start" option starts all guests that were running prior to shutdown
        regardless of their autostart settings. The "ignore" option will not
        start the formerly running guest on boot. However, any guest marked as
        autostart will still be automatically started by libvirtd.
      '';

      type = types.enum [
        "start"
        "ignore"
      ];
    };

    onShutdown = mkOption {
      default = "suspend";

      description = ''
        When shutting down / restarting the host what method should
        be used to gracefully halt the guests. Setting to "shutdown"
        will cause an ACPI shutdown of each guest. "suspend" will
        attempt to save the state of the guests ready to restore on boot.
      '';

      type = types.enum [
        "shutdown"
        "suspend"
      ];
    };

    parallelShutdown = mkOption {
      default = 0;

      description = ''
        Number of guests that will be shutdown concurrently, taking effect when onShutdown
        is set to "shutdown". If set to 0, guests will be shutdown one after another.
        Number of guests on shutdown at any time will not exceed number set in this
        variable.
      '';

      type = types.ints.unsigned;
    };

    qemu = mkOption {
      default = { };

      description = ''
        QEMU related options.
      '';

      type = qemuModule;
    };

    shutdownTimeout = mkOption {
      default = 300;

      description = ''
        Number of seconds we're willing to wait for a guest to shut down.
        If parallel shutdown is enabled, this timeout applies as a timeout
        for shutting down all guests on a single URI defined in the variable URIS.
        If this is 0, then there is no time out (use with caution, as guests might not
        respond to a shutdown request).
      '';

      type = types.ints.unsigned;
    };

    sshProxy = mkOption {
      default = true;

      description = ''
        Whether to configure OpenSSH to use the [SSH Proxy](https://libvirt.org/ssh-proxy.html).
      '';

      type = types.bool;
    };

    startDelay = mkOption {
      default = 0;

      description = ''
        Number of seconds to wait between each guest start.
        If set to 0, all guests will start up in parallel.
      '';

      type = types.ints.unsigned;
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = config.security.polkit.enable;
        message = "The libvirtd module currently requires Polkit to be enabled ('security.polkit.enable = true').";
      }

      {
        assertion = ((lib.filterAttrs (n: v: v != null) cfg.qemu.ovmf) == { });
        message = "The 'virtualisation.libvirtd.qemu.ovmf' submodule has been removed. All OVMF images distributed with QEMU are now available by default.";
      }
    ];

    boot.kernelModules = [ "tun" ];

    environment = {
      etc.ethertypes.source = "${pkgs.iptables}/etc/ethertypes";
      # this file is expected in /etc/qemu and not sysconfdir (/var/lib)
      etc."qemu/bridge.conf".text = lib.concatMapStringsSep "\n" (e: "allow ${e}") cfg.allowedBridges;

      systemPackages = with pkgs; [
        netcat
        config.networking.firewall.package
        cfg.package
        cfg.qemu.package
      ];
    };

    programs.ssh.extraConfig = mkIf cfg.sshProxy ''
      Include ${cfg.package}/etc/ssh/ssh_config.d/30-libvirt-ssh-proxy.conf
    '';

    security.polkit = {
      enable = true;

      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.libvirt.unix.manage" &&
            subject.isInGroup("libvirtd")) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    security.wrappers.qemu-bridge-helper = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${cfg.qemu.package}/libexec/qemu-bridge-helper";
    };

    services.dbus.packages = lib.optional cfg.dbus.enable cfg.dbus.package;
    services.firewalld.packages = [ cfg.package ];

    system.nssDatabases.hosts = mkMerge [
      # ensure that the NSS modules come between mymachines (which is 400) and resolve (which is 501)
      (mkIf cfg.nss.enable (mkOrder 430 [ "libvirt" ]))
      (mkIf cfg.nss.enableGuest (mkOrder 432 [ "libvirt_guest" ]))
    ];

    system.nssModules = optional (cfg.nss.enable || cfg.nss.enableGuest) cfg.package;
    systemd.packages = [ cfg.package ] ++ lib.optional cfg.dbus.enable cfg.dbus.package;

    systemd.services.libvirt-guests = {
      after = [ "libvirtd.service" ];
      environment.ON_BOOT = "${cfg.onBoot}";
      environment.ON_SHUTDOWN = "${cfg.onShutdown}";
      environment.PARALLEL_SHUTDOWN = "${toString cfg.parallelShutdown}";
      environment.SHUTDOWN_TIMEOUT = "${toString cfg.shutdownTimeout}";
      environment.START_DELAY = "${toString cfg.startDelay}";

      path = with pkgs; [
        coreutils
        gawk
        cfg.package
      ];

      restartIfChanged = false;
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.libvirtd = {
      after = [ "libvirtd-config.service" ] ++ optional vswitch.enable "ovs-vswitchd.service";
      enableStrictShellChecks = true;

      environment.LIBVIRTD_ARGS = escapeShellArgs (
        [
          "--config"
          configFile
          "--timeout"
          "120" # from ${libvirt}/var/lib/sysconfig/libvirtd
        ]
        ++ cfg.extraOptions
      );

      path = [
        cfg.qemu.package
        pkgs.netcat
      ] # libvirtd requires qemu-img to manage disk images
      ++ optional vswitch.enable vswitch.package
      ++ optional cfg.qemu.swtpm.enable cfg.qemu.swtpm.package;

      requires = [ "libvirtd-config.service" ];
      restartIfChanged = false;

      serviceConfig = {
        KillMode = "process"; # when stopping, leave the VMs alone
        OOMScoreAdjust = "-999";
        Restart = "no";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.libvirtd-config = {
      description = "Libvirt Virtual Machine Management Daemon - configuration";

      script = ''
        # Copy default libvirt network config .xml files to /var/lib
        # Files modified by the user will not be overwritten
        for i in $(cd ${cfg.package}/var/lib && echo \
            libvirt/qemu/networks/*.xml \
            libvirt/nwfilter/*.xml );
        do
            # Intended behavior
            # shellcheck disable=SC2174
            mkdir -p "/var/lib/$(dirname "$i")" -m 755
            if [ ! -e "/var/lib/$i" ]; then
              cp -pd "${cfg.package}/var/lib/$i" "/var/lib/$i"
            fi
        done

        # Copy generated qemu config to libvirt directory
        cp -f ${qemuConfigFile} /var/lib/${dirName}/qemu.conf

        # Copy generated network config to libvirt directory
        cp -f ${networkConfigFile} /var/lib/${dirName}/network.conf

        # stable (not GC'able as in /nix/store) paths for using in <emulator> section of xml configs
        for emulator in ${cfg.package}/libexec/libvirt_lxc ${cfg.qemu.package}/bin/qemu-kvm ${cfg.qemu.package}/bin/qemu-system-*; do
          ln -s --force "$emulator" /run/${dirName}/nix-emulators/
        done

        ln -s --force ${cfg.qemu.package}/bin/qemu-pr-helper /run/${dirName}/nix-helpers/

        # Symlink to OVMF firmware code and variable template images distributed with QEMU
        readarray -t firmware_files < <(
          ${pkgs.jq}/bin/jq -rs \
            '[.[] | .mapping.executable.filename, .mapping."nvram-template".filename] | unique | .[]' \
          ${cfg.qemu.package}/share/qemu/firmware/*
        )
        cp -sfv "''${firmware_files[@]}" /run/${dirName}/nix-ovmf

        # Symlink hooks to /var/lib/libvirt
        ${concatStringsSep "\n" (
          map (driver: ''
            mkdir -p /var/lib/${dirName}/hooks/${driver}.d
            rm -rf /var/lib/${dirName}/hooks/${driver}.d/*
            ${concatStringsSep "\n" (
              mapAttrsToList (
                name: value: "ln -s --force ${value} /var/lib/${dirName}/hooks/${driver}.d/${name}"
              ) cfg.hooks.${driver}
            )}
          '') (attrNames cfg.hooks)
        )}
      '';

      serviceConfig = {
        LogsDirectory = subDirs [ "qemu" ];

        RuntimeDirectory = subDirs [
          "nix-emulators"
          "nix-helpers"
          "nix-ovmf"
        ];

        RuntimeDirectoryPreserve = "yes";

        StateDirectory = subDirs [
          "dnsmasq"
          "secrets"
        ];

        Type = "oneshot";
      };
    };

    systemd.services.virtchd = {
      path = [ pkgs.cloud-hypervisor ];
    };

    systemd.services.virtlockd = {
      description = "Virtual machine lock manager";
      restartIfChanged = false;
      serviceConfig.ExecStart = "@${cfg.package}/sbin/virtlockd virtlockd";
    };

    systemd.services.virtlogd = {
      description = "Virtual machine log manager";
      restartIfChanged = false;
      serviceConfig.ExecStart = "@${cfg.package}/sbin/virtlogd virtlogd";
    };

    # https://libvirt.org/daemons.html#monolithic-systemd-integration
    systemd.sockets.libvirtd.wantedBy = [ "sockets.target" ];

    systemd.sockets.virtlockd = {
      description = "Virtual machine lock manager socket";
      listenStreams = [ "/run/${dirName}/virtlockd-sock" ];
      wantedBy = [ "sockets.target" ];
    };

    systemd.sockets.virtlogd = {
      description = "Virtual machine log manager socket";
      listenStreams = [ "/run/${dirName}/virtlogd-sock" ];
      wantedBy = [ "sockets.target" ];
    };

    systemd.tmpfiles.rules =
      let
        vhostUserCollection = pkgs.buildEnv {
          name = "vhost-user";
          paths = cfg.qemu.vhostUserPackages;
          pathsToLink = [ "/share/qemu/vhost-user" ];
        };
      in
      [
        "L+ /var/lib/qemu/vhost-user - - - - ${vhostUserCollection}/share/qemu/vhost-user"
        "L+ /var/lib/qemu/firmware - - - - ${qemuOvmfMetadata}"
      ];

    users = lib.mkMerge [
      {
        groups = {
          libvirtd.gid = config.ids.gids.libvirtd;
          qemu-libvirtd.gid = config.ids.gids.qemu-libvirtd;
        };

        # libvirtd runs qemu as this user and group by default
        users.qemu-libvirtd = {
          group = "qemu-libvirtd";
          isNormalUser = false;
          uid = config.ids.uids.qemu-libvirtd;
        };
      }
      (lib.mkIf cfg.dbus.enable {
        groups.libvirtdbus = { };

        users.libvirtdbus = {
          description = "Libvirt D-Bus bridge";
          group = "libvirtdbus";
          isSystemUser = true;
        };
      })
    ];
  };
}
