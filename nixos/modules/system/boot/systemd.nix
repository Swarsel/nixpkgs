{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with utils;
with systemdUtils.unitOptions;
with lib;

let

  cfg = config.systemd;

  inherit (systemdUtils.lib)
    generateUnits
    targetToUnit
    serviceToUnit
    socketToUnit
    timerToUnit
    pathToUnit
    mountToUnit
    automountToUnit
    sliceToUnit
    settingsToSections
    ;

  upstreamSystemUnits = [
    # Targets.
    "basic.target"
    "sysinit.target"
    "sockets.target"
    "exit.target"
    "graphical.target"
    "multi-user.target"
    "network.target"
    "network-pre.target"
    "network-online.target"
    "nss-lookup.target"
    "nss-user-lookup.target"
    "time-set.target"
    "time-sync.target"
    "first-boot-complete.target"
  ]
  ++ optionals cfg.package.withCryptsetup [
    "cryptsetup.target"
    "cryptsetup-pre.target"
    "remote-cryptsetup.target"
  ]
  ++ [
    "sigpwr.target"
    "timers.target"
    "paths.target"
    "rpcbind.target"

    # Rescue mode.
    "rescue.target"
    "rescue.service"

    # systemd-debug-generator
    "debug-shell.service"

    # Udev.
    "systemd-udevd-control.socket"
    "systemd-udevd-kernel.socket"
    "systemd-udevd-varlink.socket"
    "systemd-udevd.service"
  ]
  ++ (optional (!config.boot.isContainer) "systemd-udev-trigger.service")
  ++ [
    # hwdb.bin is managed by NixOS
    # "systemd-hwdb-update.service"

    # Hardware (started by udev when a relevant device is plugged in).
    "sound.target"
    "bluetooth.target"
    "printer.target"
    "smartcard.target"

    # Kernel module loading.
    "systemd-modules-load.service"
    "kmod-static-nodes.service"
    "modprobe@.service"

    # Filesystems.
    "systemd-fsck@.service"
    "systemd-fsck-root.service"
    "systemd-growfs@.service"
    "systemd-growfs-root.service"
    "systemd-remount-fs.service"
    "systemd-pstore.service"
    "local-fs.target"
    "local-fs-pre.target"
    "remote-fs.target"
    "remote-fs-pre.target"
    "swap.target"
    "dev-hugepages.mount"
    "dev-mqueue.mount"
    "sys-fs-fuse-connections.mount"
  ]
  ++ (optional (!config.boot.isContainer) "sys-kernel-config.mount")
  ++ [
    "sys-kernel-debug.mount"
    "sys-kernel-tracing.mount"

    # Maintaining state across reboots.
    "systemd-random-seed.service"
  ]
  ++ optionals cfg.package.withBootloader [
    "systemd-boot-random-seed.service"
    "systemd-bless-boot.service"
  ]
  ++ [
    "systemd-backlight@.service"
    "systemd-rfkill.service"
    "systemd-rfkill.socket"

    "boot-complete.target"

    # Hibernate / suspend.
    "hibernate.target"
    "suspend.target"
    "suspend-then-hibernate.target"
    "sleep.target"
    "hybrid-sleep.target"
    "systemd-hibernate.service"
  ]
  ++ (lib.optional cfg.package.withEfi "systemd-hibernate-clear.service")
  ++ [
    "systemd-hybrid-sleep.service"
    "systemd-suspend.service"
    "systemd-suspend-then-hibernate.service"

    # Reboot stuff.
    "reboot.target"
    "systemd-reboot.service"
    "poweroff.target"
    "systemd-poweroff.service"
    "halt.target"
    "systemd-halt.service"
    "shutdown.target"
    "umount.target"
    "final.target"
    "kexec.target"
    "systemd-kexec.service"
    "soft-reboot.target"
    "systemd-soft-reboot.service"
  ]
  ++ lib.optional cfg.package.withUtmp "systemd-update-utmp.service"
  ++ [

    # Password entry.
    "systemd-ask-password-console.path"
    "systemd-ask-password-console.service"
    "systemd-ask-password-wall.path"
    "systemd-ask-password-wall.service"

    # Varlink APIs
    "systemd-ask-password@.service"
    "systemd-ask-password.socket"
  ]
  ++ lib.optionals cfg.package.withBootloader [
    "systemd-bootctl@.service"
    "systemd-bootctl.socket"
  ]
  ++ [
    "systemd-creds@.service"
    "systemd-creds.socket"
  ]
  ++ lib.optionals cfg.package.withTpm2Units [
    "systemd-pcrlock@.service"
    "systemd-pcrlock.socket"
    "systemd-tpm2-clear.service"
  ]
  ++ [

    # Slices / containers.
    "slices.target"
  ]
  ++ optionals cfg.package.withImportd [
    "systemd-importd.service"
    "systemd-importd.socket"
  ]
  ++ optionals cfg.package.withMachined [
    "machine.slice"
    "machines.target"
    "systemd-machined.service"
    "systemd-machined.socket"
  ]
  ++ optionals cfg.package.withNspawn [
    "systemd-nspawn@.service"
  ]
  ++ [
    # Misc.
    "systemd-sysctl.service"
    "systemd-machine-id-commit.service"

    "systemd-mute-console@.service"
    "systemd-mute-console.socket"
  ]
  ++ optionals cfg.package.withTimedated [
    "dbus-org.freedesktop.timedate1.service"
    "systemd-timedated.service"
  ]
  ++ optionals cfg.package.withLocaled [
    "dbus-org.freedesktop.locale1.service"
    "systemd-localed.service"
  ]
  ++ optionals cfg.package.withHostnamed [
    "dbus-org.freedesktop.hostname1.service"
    "systemd-hostnamed.service"
    "systemd-hostnamed.socket"
  ]
  ++ optionals cfg.package.withPortabled [
    "dbus-org.freedesktop.portable1.service"
    "systemd-portabled.service"
  ]
  ++ optionals cfg.package.withRepart [
    # Varlink APIs
    "systemd-repart@.service"
    "systemd-repart.socket"
  ]
  ++ [
    "systemd-exit.service"
    "systemd-update-done.service"

    # Capsule support
    "capsule@.service"
    "capsule.slice"

    # Factory reset
    "factory-reset.target"
    "systemd-factory-reset-request.service"
    "systemd-factory-reset-reboot.service"
    "systemd-factory-reset@.service"
    "systemd-factory-reset.socket"
  ]
  ++ cfg.additionalUpstreamSystemUnits;

  upstreamSystemWants = [
    "sysinit.target.wants"
    "sockets.target.wants"
    "local-fs.target.wants"
    "multi-user.target.wants"
    "timers.target.wants"
    "factory-reset.target.wants"
  ];

  proxy_env = config.networking.proxy.envVars;

  json = pkgs.formats.json { };

in

{
  # FIXME: Remove these eventually.
  imports = [
    (mkRenamedOptionModule [ "boot" "systemd" "sockets" ] [ "systemd" "sockets" ])
    (mkRenamedOptionModule [ "boot" "systemd" "targets" ] [ "systemd" "targets" ])
    (mkRenamedOptionModule [ "boot" "systemd" "services" ] [ "systemd" "services" ])
    (mkRenamedOptionModule [ "jobs" ] [ "systemd" "services" ])
    (mkRemovedOptionModule [ "systemd" "generator-packages" ] "Use systemd.packages instead.")
    (mkRemovedOptionModule [ "systemd" "enableUnifiedCgroupHierarchy" ] ''
      In 256 support for cgroup v1 ('legacy' and 'hybrid' hierarchies) is now considered obsolete and systemd by default will refuse to boot under it.
      To forcibly reenable cgroup v1 support, you can set boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=0" "SYSTEMD_CGROUP_ENABLE_LEGACY_FORCE=1" ].
      NixOS does not officially support this configuration and might cause your system to be unbootable in future versions. You are on your own.
    '')
    (mkRemovedOptionModule [ "systemd" "extraConfig" ] "Use systemd.settings.Manager instead.")
    (mkRemovedOptionModule [
      "systemd"
      "sleep"
      "extraConfig"
    ] "Use systemd.sleep.settings.Sleep instead.")
    (lib.mkRenamedOptionModule
      [ "systemd" "watchdog" "device" ]
      [ "systemd" "settings" "Manager" "WatchdogDevice" ]
    )
    (lib.mkRenamedOptionModule
      [ "systemd" "watchdog" "runtimeTime" ]
      [ "systemd" "settings" "Manager" "RuntimeWatchdogSec" ]
    )
    (lib.mkRenamedOptionModule
      [ "systemd" "watchdog" "rebootTime" ]
      [ "systemd" "settings" "Manager" "RebootWatchdogSec" ]
    )
    (lib.mkRenamedOptionModule
      [ "systemd" "watchdog" "kexecTime" ]
      [ "systemd" "settings" "Manager" "KExecWatchdogSec" ]
    )
    (mkRemovedOptionModule [
      "systemd"
      "enableCgroupAccounting"
    ] "To disable cgroup accounting, disable systemd.settings.Manager.*Accounting directly.")
  ];

  ###### interface
  options.systemd = {

    package = mkPackageOption pkgs "systemd" { };

    additionalUpstreamSystemUnits = mkOption {
      default = [ ];

      description = ''
        Additional units shipped with systemd that shall be enabled.
      '';

      example = [
        "debug-shell.service"
        "systemd-quotacheck.service"
      ];

      type = types.listOf types.str;
    };

    automounts = mkOption {
      default = [ ];

      description = ''
        Definition of systemd automount units; see {manpage}`systemd.automount(5)`.

        This is a list instead of an attrSet, because systemd mandates
        the names to be derived from the `where` attribute.
      '';

      type = systemdUtils.types.automounts;
    };

    ctrlAltDelUnit = mkOption {
      default = "reboot.target";

      description = ''
        Target that should be started when Ctrl-Alt-Delete is pressed;
        see {manpage}`systemd.special(7)`.
      '';

      example = "poweroff.target";
      type = types.str;
    };

    defaultUnit = mkOption {
      default = "multi-user.target";

      description = ''
        Default unit started when the system boots; see {manpage}`systemd.special(7)`.
      '';

      type = types.str;
    };

    enableStrictShellChecks = mkEnableOption "" // {
      description = ''
        Whether to run `shellcheck` on the generated scripts for systemd
        units.

        When enabled, all systemd scripts generated by NixOS will be checked
        with `shellcheck` and any errors or warnings will cause the build to
        fail.

        This affects all scripts that have been created through the `script`,
        `reload`, `preStart`, `postStart`, `preStop` and `postStop` options for
        systemd services. This does not affect command lines passed directly
        to `ExecStart`, `ExecReload`, `ExecStartPre`, `ExecStartPost`,
        `ExecStop` or `ExecStopPost`.

        It therefore also does not affect systemd units that are coming from
        packages and that are not defined through the NixOS config. This option
        is disabled by default, and although some services have already been
        fixed, it is still likely that you will encounter build failures when
        enabling this.

        We encourage people to enable this option when they are willing and
        able to submit fixes for potential build failures to Nixpkgs. The
        option can also be enabled or disabled for individual services using
        the `enableStrictShellChecks` option on the service itself, which will
        take precedence over the global setting.
      '';
    };

    generatorEnvironment = mkOption {
      default = { };

      description = ''
        Environment variables for systemd generators.

        The `PATH` environment variable is populated via `systemd.generatorPath`.
      '';

      example = {
        MY_VAR = "my-value";
      };

      type = types.attrsOf types.str;
    };

    generatorPath = mkOption {
      default = [ ];

      description = ''
        Packages added to the `PATH` environment variable of all systemd generators.
      '';

      example = lib.literalExpression "[ pkgs.hello ]";
      type = types.listOf types.package;
    };

    generators = mkOption {
      default = { };

      description = ''
        Definition of systemd generators; see {manpage}`systemd.generator(5)`.

        For each `NAME = VALUE` pair of the attrSet, a link is generated from
        `/etc/systemd/system-generators/NAME` to `VALUE`.
      '';

      example = {
        systemd-gpt-auto-generator = "/dev/null";
      };

      type = types.attrsOf types.path;
    };

    globalEnvironment = mkOption {
      default = { };

      description = ''
        Environment variables passed to *all* systemd units.
      '';

      example = {
        TZ = "CET";
      };

      type =
        with types;
        attrsOf (
          nullOr (oneOf [
            str
            path
            package
          ])
        );
    };

    managerEnvironment = mkOption {
      default = { };

      description = ''
        Environment variables of PID 1. These variables are
        *not* passed to started units.
      '';

      example = {
        SYSTEMD_LOG_LEVEL = "debug";
      };

      type =
        with types;
        attrsOf (
          nullOr (oneOf [
            str
            path
            package
          ])
        );
    };

    mounts = mkOption {
      default = [ ];

      description = ''
        Definition of systemd mount units; see {manpage}`systemd.mount(5)`.

        This is a list instead of an attrSet, because systemd mandates
        the names to be derived from the `where` attribute.
      '';

      type = systemdUtils.types.mounts;
    };

    packages = mkOption {
      default = [ ];
      description = "Packages providing systemd units and hooks.";
      example = literalExpression "[ pkgs.systemd-cryptsetup-generator ]";
      type = types.listOf types.package;
    };

    paths = mkOption {
      default = { };
      description = "Definition of systemd path units; see {manpage}`systemd.path(5)`.";
      type = systemdUtils.types.paths;
    };

    services = mkOption {
      default = { };
      description = "Definition of systemd service units; see {manpage}`systemd.service(5)`.";
      type = systemdUtils.types.services;
    };

    settings.Manager = mkOption {
      default = { };

      defaultText = lib.literalExpression ''
        {
          DefaultIOAccounting = true;
          DefaultIPAccounting = true;
        }
      '';

      description = ''
        Options for the global systemd service manager. See {manpage}`systemd-system.conf(5)` man page
        for available options.
      '';

      example = {
        KExecWatchdogSec = "5min";
        RebootWatchdogSec = "10min";
        RuntimeWatchdogSec = "30s";
        WatchdogDevice = "/dev/watchdog";
      };

      type = lib.types.submodule {
        freeformType = types.attrsOf unitOption;
      };
    };

    shutdown = mkOption {
      default = { };

      description = ''
        Definition of systemd shutdown executables.
        For each `NAME = VALUE` pair of the attrSet, a link is generated from
        `/etc/systemd/system-shutdown/NAME` to `VALUE`.
      '';

      type = types.attrsOf types.path;
    };

    sleep.settings.Sleep = mkOption {
      default = { };

      description = ''
        Options for systemd sleep state logic. See {manpage}`sleep.conf.d(5)` man page
        for available options.
      '';

      example = {
        HibernateDelaySec = "1h";
      };

      type = lib.types.submodule {
        freeformType = types.attrsOf unitOption;
      };
    };

    slices = mkOption {
      default = { };
      description = "Definition of slice configurations; see {manpage}`systemd.slice(5)`.";
      type = systemdUtils.types.slices;
    };

    sockets = mkOption {
      default = { };
      description = "Definition of systemd socket units; see {manpage}`systemd.socket(5)`.";
      type = systemdUtils.types.sockets;
    };

    suppressedSystemUnits = mkOption {
      default = [ ];

      description = ''
        A list of units to skip when generating system systemd configuration directory. This has
        priority over upstream units, {option}`systemd.units`, and
        {option}`systemd.additionalUpstreamSystemUnits`. The main purpose of this is to
        prevent a upstream systemd unit from being added to the initrd with any modifications made to it
        by other NixOS modules.
      '';

      example = [ "systemd-backlight@.service" ];
      type = types.listOf types.str;
    };

    targets = mkOption {
      default = { };
      description = "Definition of systemd target units; see {manpage}`systemd.target(5)`";
      type = systemdUtils.types.targets;
    };

    timers = mkOption {
      default = { };
      description = "Definition of systemd timer units; see {manpage}`systemd.timer(5)`.";
      type = systemdUtils.types.timers;
    };

    units = mkOption {
      default = { };
      description = "Definition of systemd units; see {manpage}`systemd.unit(5)`.";
      type = systemdUtils.types.units;
    };
  };

  ###### implementation
  config = {

    assertions = concatLists (
      mapAttrsToList (
        name: service:
        map
          (message: {
            inherit message;
            assertion = false;
          })
          (concatLists [
            (optional
              (
                (builtins.elem "network-interfaces.target" service.after)
                || (builtins.elem "network-interfaces.target" service.wants)
              )
              "Service '${name}.service' is using the deprecated target network-interfaces.target, which no longer exists. Using network.target is recommended instead."
            )
          ])
      ) cfg.services
    );

    # Increase numeric PID range (set directly instead of copying a one-line file from systemd)
    # https://github.com/systemd/systemd/pull/12226
    boot.kernel.sysctl."kernel.pid_max" = mkIf pkgs.stdenv.hostPlatform.is64bit (lib.mkDefault 4194304);

    environment.etc =
      let
        # generate contents for /etc/systemd/${dir} from attrset of links and packages
        hooks =
          dir: links:
          pkgs.runCommand "${dir}"
            {
              packages = cfg.packages;
              preferLocalBuild = true;
            }
            ''
              set -e
              mkdir -p $out
              for package in $packages
              do
                for hook in $package/lib/systemd/${dir}/*
                do
                  ln -s $hook $out/
                done
              done
              ${concatStrings (mapAttrsToList (exec: target: "ln -s ${target} $out/${exec};\n") links)}
            '';

        enabledUpstreamSystemUnits = filter (n: !elem n cfg.suppressedSystemUnits) upstreamSystemUnits;
        enabledUnits = removeAttrs cfg.units cfg.suppressedSystemUnits;

      in
      {
        "sysctl.d/50-default.conf".source = "${cfg.package}/example/sysctl.d/50-default.conf";

        "systemd/generator-environment.json".source =
          json.generate "systemd-generator-environment.json" cfg.generatorEnvironment;

        "systemd/sleep.conf".text = settingsToSections cfg.sleep.settings;

        "systemd/system".source = generateUnits {
          type = "system";
          units = enabledUnits;
          upstreamUnits = enabledUpstreamSystemUnits;
          upstreamWants = upstreamSystemWants;
        };

        "systemd/system-environment-generators/env-generator".source =
          "${config.system.nixos-init.package}/bin/env-generator";

        "systemd/system-generators" = {
          source = hooks "system-generators" cfg.generators;
        };

        # Ignore all other preset files so systemd doesn't try to enable/disable
        # units during runtime.
        "systemd/system-preset/00-nixos.preset".text = ''
          ignore *
        '';

        "systemd/system-shutdown" = {
          source = hooks "system-shutdown" cfg.shutdown;
        };

        "systemd/system.conf".text = settingsToSections cfg.settings;

        "systemd/user-generators" = {
          source = hooks "user-generators" cfg.user.generators;
        };

        "systemd/user-preset/00-nixos.preset".text = ''
          ignore *
        '';
      };

    environment.systemPackages = [ cfg.package ];

    environment.variables = {
      SYSTEMD_XKB_DIRECTORY = "/etc/X11/xkb";
    };

    # run0 is supposed to authenticate the user via polkit and then run a command. Without this next
    # part, run0 would fail to run the command even if authentication is successful and the user has
    # permission to run the command. This next part is only enabled if polkit is enabled because the
    # error that we’re trying to avoid can’t possibly happen if polkit isn’t enabled. When polkit isn’t
    # enabled, run0 will fail before it even tries to run the command.
    security.pam.services = mkIf config.security.polkit.enable {
      systemd-run0 = {
        pamMount = false;
        # Upstream config: https://github.com/systemd/systemd/blob/main/src/run/systemd-run0.in
        setLoginUid = true;
      };
    };

    services.dbus.enable = true;

    services.logrotate.settings = {
      "/var/log/btmp" = mapAttrs (_: mkDefault) {
        create = "0660 root ${config.users.groups.utmp.name}";
        frequency = "monthly";
        minsize = "1M";
        rotate = 1;
      };

      "/var/log/wtmp" = mapAttrs (_: mkDefault) {
        create = "0664 root ${config.users.groups.utmp.name}";
        frequency = "monthly";
        minsize = "1M";
        rotate = 1;
      };
    };

    system.build.units = cfg.units;

    system.nssDatabases = {
      group = (
        mkMerge [
          (mkAfter [ "[success=merge] systemd" ]) # need merge so that NSS won't stop at file-based groups
        ]
      );

      hosts = (
        mkMerge [
          (mkOrder 400 [ "mymachines" ]) # 400 to ensure it comes before resolve (which is 501)
          (mkOrder 999 [ "myhostname" ]) # after files (which is 998), but before regular nss modules
        ]
      );

      passwd = (
        mkMerge [
          (mkAfter [ "systemd" ])
        ]
      );

      shadow = (
        mkMerge [
          (mkAfter [ "systemd" ])
        ]
      );
    };

    system.nssModules = [ cfg.package.out ];

    system.requiredKernelConfig = map config.lib.kernelConfig.isEnabled [
      "DEVTMPFS"
      "CGROUPS"
      "INOTIFY_USER"
      "SIGNALFD"
      "TIMERFD"
      "EPOLL"
      "NET"
      "SYSFS"
      "PROC_FS"
      "FHANDLE"
      "CRYPTO_USER_API_HASH"
      "CRYPTO_HMAC"
      "CRYPTO_SHA256"
      "DMIID"
      "AUTOFS_FS"
      "TMPFS_POSIX_ACL"
      "TMPFS_XATTR"
      "SECCOMP"
    ];

    systemd.generatorEnvironment = {
      PATH = lib.makeBinPath cfg.generatorPath;
    };

    # These are needed for systemd-fstab-generator to schedule systemd-fsck@
    # units.
    systemd.generatorPath = config.system.fsPackages ++ [
      cfg.package.util-linux
    ];

    # Environment of PID 1
    systemd.managerEnvironment = {
      LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";

      # Doesn't contain systemd itself - everything works so it seems to use the compiled-in value for its tools
      # util-linux is needed for the main fsck utility wrapping the fs-specific ones
      PATH = lib.makeBinPath (
        config.system.fsPackages
        ++ [ cfg.package.util-linux ]
        # systemd-ssh-generator needs sshd in PATH
        ++ lib.optional config.services.openssh.enable config.services.openssh.package
      );

      # If SYSTEMD_UNIT_PATH ends with an empty component (":"), the usual unit load path will be appended to the contents of the variable
      SYSTEMD_UNIT_PATH = lib.mkIf (
        config.boot.extraSystemdUnitPaths != [ ]
      ) "${builtins.concatStringsSep ":" config.boot.extraSystemdUnitPaths}:";

      TZDIR = "/etc/zoneinfo";
    };

    # NixOS has kernel modules in a different location, so override that here.
    systemd.services.kmod-static-nodes.unitConfig.ConditionFileNotEmpty = [
      "" # required to unset the previous value!
      "/run/booted-system/kernel-modules/lib/modules/%v/modules.devname"
    ];

    systemd.services."modprobe@" = {
      restartIfChanged = false;
      serviceConfig.ExecSearchPath = lib.makeBinPath [ pkgs.kmod ];
    };

    # the systemd vmspawn credential dropin executes sshd and expects ExecSearchPath to be set, see:
    # https://github.com/systemd/systemd/blob/v259.3/src/vmspawn/vmspawn.c#L2662
    # this service is used, for example, when NixOS is started via systemd-vmspawn
    systemd.services."sshd-vsock@" = mkIf config.services.openssh.enable {
      overrideStrategy = "asDropin";
      serviceConfig.ExecSearchPath = "${config.services.openssh.package}/bin";
    };

    # Some overrides to upstream units.
    systemd.services."systemd-backlight@".restartIfChanged = false;
    systemd.services."systemd-fsck@".path = [ pkgs.util-linux ] ++ config.system.fsPackages;
    systemd.services."systemd-fsck@".restartIfChanged = false;

    systemd.services."systemd-hostnamed".environment = lib.mkIf (!config.system.etc.overlay.enable) {
      SYSTEMD_ETC_HOSTNAME = "/etc/static/hostname";
      SYSTEMD_ETC_MACHINE_INFO = "/etc/static/machine-info";
    };

    systemd.services.systemd-importd = lib.mkIf cfg.package.withImportd {
      environment = proxy_env;
      path = [ pkgs.gnupgMinimal ];
    };

    # When using the classic /etc mechanism, we set certain paths in /etc to
    # /etc/static so that systemd cannot change them (as they are symlinks to
    # the read-only Nix Store). This is only done so that these services cannot
    # change the values. All other parts of systemd should read them from their
    # canonical locations.
    #
    # If you use the overlay mechanism to manage /etc, this is unnecessary
    # because either the overlay is mutable (and users can legitimately change
    # values without them being overridden) or it is immutable and systemd will
    # suggest to only make runtime changes.
    systemd.services."systemd-localed".environment =
      lib.mkIf (!config.system.etc.overlay.enable && !config.i18n.imperativeLocale)
        {
          SYSTEMD_ETC_LOCALE_CONF = "/etc/static/locale.conf";
          SYSTEMD_ETC_VCONSOLE_CONF = "/etc/static/vconsole.conf";
        };

    systemd.services."systemd-makefs@" = {
      # Since there is no /etc/systemd/system/systemd-makefs@.service
      # file, the units generated in /run/systemd/generator would
      # override anything we put here. But by forcing the use of a
      # drop-in in /etc, it does apply.
      overrideStrategy = "asDropin";
      path = [ pkgs.util-linux ] ++ config.system.fsPackages;
      restartIfChanged = false;
    };

    systemd.services."systemd-mkswap@" = {
      overrideStrategy = "asDropin";
      path = [ pkgs.util-linux ];
      restartIfChanged = false;
    };

    systemd.services.systemd-pstore.wantedBy = [ "sysinit.target" ]; # see #81138
    systemd.services.systemd-random-seed.restartIfChanged = false;
    systemd.services.systemd-remount-fs.restartIfChanged = false;
    # Don't bother with certain units in containers.
    systemd.services.systemd-remount-fs.unitConfig.ConditionVirtualization = "!container";

    systemd.services."systemd-timedated".environment =
      lib.mkIf (!config.system.etc.overlay.enable && config.time.timeZone != null)
        {
          SYSTEMD_ETC_ADJTIME = "/etc/static/adjtime";
          SYSTEMD_ETC_LOCALTIME = "/etc/static/localtime";
        };

    systemd.services.systemd-update-utmp.restartIfChanged = false;

    systemd.settings.Manager = {
      DefaultIOAccounting = lib.mkDefault true;
      DefaultIPAccounting = lib.mkDefault true;

      ManagerEnvironment = lib.concatStringsSep " " (
        lib.mapAttrsToList (n: v: "${n}=${lib.escapeShellArg v}") cfg.managerEnvironment
      );
    };

    # Fix paths in sshd-vsock.socket
    # https://github.com/systemd/systemd/blob/v259.3/src/ssh-generator/ssh-generator.c#L239
    # this socket is used, for example, when NixOS is started via systemd-vmspawn
    systemd.sockets.sshd-vsock = mkIf config.services.openssh.enable {
      overrideStrategy = "asDropin";

      socketConfig.ExecStartPost = [
        ""
        "${config.systemd.package}/lib/systemd/systemd-ssh-issue --make-vsock"
      ];

      socketConfig.ExecStopPre = [
        ""
        "${config.systemd.package}/lib/systemd/systemd-ssh-issue --rm-vsock"
      ];
    };

    systemd.targets.keys = {
      description = "Security Keys";
      unitConfig.X-StopOnReconfiguration = true;
    };

    systemd.targets.local-fs.unitConfig.X-StopOnReconfiguration = true;
    systemd.targets.remote-fs.unitConfig.X-StopOnReconfiguration = true;

    # This target only exists so that services ordered before sysinit.target
    # are restarted in the correct order, notably BEFORE the other services,
    # when switching configurations.
    systemd.targets.sysinit-reactivation = {
      description = "Reactivate sysinit units";
    };

    # Generate timer units for all services that have a ‘startAt’ value.
    systemd.timers = mapAttrs (name: service: {
      timerConfig.OnCalendar = service.startAt;
      wantedBy = [ "timers.target" ];
    }) (filterAttrs (name: service: service.enable && service.startAt != [ ]) cfg.services);

    systemd.units =
      let
        withName = cfgToUnit: cfg: lib.nameValuePair cfg.name (cfgToUnit cfg);
      in
      mapAttrs' (_: withName pathToUnit) cfg.paths
      // mapAttrs' (_: withName serviceToUnit) cfg.services
      // mapAttrs' (_: withName sliceToUnit) cfg.slices
      // mapAttrs' (_: withName socketToUnit) cfg.sockets
      // mapAttrs' (_: withName targetToUnit) cfg.targets
      // mapAttrs' (_: withName timerToUnit) cfg.timers
      // listToAttrs (map (withName mountToUnit) cfg.mounts)
      // listToAttrs (map (withName automountToUnit) cfg.automounts);

    # Target for ‘charon send-keys’ to hook into.
    users.groups.keys.gid = config.ids.gids.keys;
    users.groups.systemd-network.gid = config.ids.gids.systemd-network;
    users.groups.systemd-resolve.gid = config.ids.gids.systemd-resolve;

    users.users.systemd-network = {
      group = "systemd-network";
      uid = config.ids.uids.systemd-network;
    };

    users.users.systemd-resolve = {
      group = "systemd-resolve";
      uid = config.ids.uids.systemd-resolve;
    };

    warnings =
      let
        mkOneNetOnlineWarn =
          typeStr: name: def:
          lib.optional (
            lib.elem "network-online.target" def.after
            && !(lib.elem "network-online.target" (def.wants ++ def.requires ++ def.bindsTo))
          ) "${name}.${typeStr} is ordered after 'network-online.target' but doesn't depend on it";
        mkNetOnlineWarns =
          typeStr: defs: lib.concatLists (lib.mapAttrsToList (mkOneNetOnlineWarn typeStr) defs);
        mkMountNetOnlineWarns =
          typeStr: defs: lib.concatLists (map (m: mkOneNetOnlineWarn typeStr m.what m) defs);
      in
      concatLists (
        mapAttrsToList (
          name: service:
          let
            type = service.serviceConfig.Type or "";
            restart = service.serviceConfig.Restart or "no";
            hasDeprecated = builtins.hasAttr "StartLimitInterval" service.serviceConfig;
          in
          concatLists [
            (optional (type == "oneshot" && (restart == "always" || restart == "on-success"))
              "Service '${name}.service' with 'Type=oneshot' cannot have 'Restart=always' or 'Restart=on-success'"
            )
            (optional hasDeprecated "Service '${name}.service' uses the attribute 'StartLimitInterval' in the Service section, which is deprecated. See https://github.com/NixOS/nixpkgs/issues/45786.")
            (optional (service.reloadIfChanged && service.reloadTriggers != [ ])
              "Service '${name}.service' has both 'reloadIfChanged' and 'reloadTriggers' set. This is probably not what you want, because 'reloadTriggers' behave the same whay as 'restartTriggers' if 'reloadIfChanged' is set."
            )
          ]
        ) cfg.services
      )
      ++ (mkNetOnlineWarns "target" cfg.targets)
      ++ (mkNetOnlineWarns "service" cfg.services)
      ++ (mkNetOnlineWarns "socket" cfg.sockets)
      ++ (mkNetOnlineWarns "timer" cfg.timers)
      ++ (mkNetOnlineWarns "path" cfg.paths)
      ++ (mkMountNetOnlineWarns "mount" cfg.mounts)
      ++ (mkMountNetOnlineWarns "automount" cfg.automounts)
      ++ (mkNetOnlineWarns "slice" cfg.slices);
  };
}
