{
  config,
  lib,
  pkgs,
  ...
}:
let

  udev = config.systemd.package;

  cfg = config.services.udev;

  initrdUdevRules = pkgs.runCommand "initrd-udev-rules" { } ''
    mkdir -p $out/etc/udev/rules.d
    for f in 60-cdrom_id 60-persistent-storage 75-net-description 80-drivers 80-net-setup-link; do
      ln -s ${config.boot.initrd.systemd.package}/lib/udev/rules.d/$f.rules $out/etc/udev/rules.d
    done
  '';

  extraUdevRules = pkgs.writeTextFile {
    destination = "/etc/udev/rules.d/99-local.rules";
    name = "extra-udev-rules";
    text = cfg.extraRules;
  };

  extraHwdbFile = pkgs.writeTextFile {
    destination = "/etc/udev/hwdb.d/99-local.hwdb";
    name = "extra-hwdb-file";
    text = cfg.extraHwdb;
  };

  nixosRules = ''
    # Needed for gpm.
    SUBSYSTEM=="input", KERNEL=="mice", TAG+="systemd"
  '';

  nixosInitrdRules = ''
    # Mark dm devices as db_persist so that they are kept active after switching root
    SUBSYSTEM=="block", KERNEL=="dm-[0-9]*", ACTION=="add|change", OPTIONS+="db_persist"
  '';

  # Perform substitutions in all udev rules files.
  udevRulesFor =
    {
      binPackages,
      name,
      systemd,
      udev,
      udevPackages,
      udevPath,
      initrdBin ? null,
    }:
    pkgs.runCommand name
      {
        allowSubstitutes = false;

        nativeBuildInputs = [
          # We only include the out output here to avoid needing to include all
          # other outputs in the installer tests as well
          # We only need the udevadm command anyway
          pkgs.buildPackages.systemdMinimal.out
        ];

        packages = lib.unique (map toString udevPackages);
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out
        shopt -s nullglob
        set +o pipefail

        # Set a reasonable $PATH for programs called by udev rules.
        echo 'ENV{PATH}="${udevPath}/bin:${udevPath}/sbin"' > $out/00-path.rules

        # Add the udev rules from other packages.
        for i in $packages; do
          echo "Adding rules for package $i"
          for j in $i/{etc,lib}/udev/rules.d/*; do
            echo "Copying $j to $out/$(basename $j)"
            cat $j > $out/$(basename $j)
          done
        done

        # Fix some paths in the standard udev rules.  Hacky.
        for i in $out/*.rules; do
          substituteInPlace $i \
            --replace-quiet \"/sbin/modprobe \"${pkgs.kmod}/bin/modprobe \
            --replace-quiet \"/sbin/mdadm \"${pkgs.mdadm}/sbin/mdadm \
            --replace-quiet \"/sbin/blkid \"${pkgs.util-linux}/sbin/blkid \
            --replace-quiet \"/bin/mount \"${pkgs.util-linux}/bin/mount \
            --replace-quiet /usr/bin/readlink ${pkgs.coreutils}/bin/readlink \
            --replace-quiet /usr/bin/cat ${pkgs.coreutils}/bin/cat \
            --replace-quiet /usr/bin/basename ${pkgs.coreutils}/bin/basename 2>/dev/null
        ${lib.optionalString (initrdBin != null) ''
          substituteInPlace $i --replace-quiet '/run/current-system/systemd' "${lib.removeSuffix "/bin" initrdBin}"
        ''}
        done

        echo -n "Checking that all programs called by relative paths in udev rules exist in ${udev}/lib/udev... "
        import_progs=$(grep 'IMPORT{program}="[^/$]' $out/* |
          sed -e 's/.*IMPORT{program}="\([^ "]*\)[ "].*/\1/' | uniq)
        run_progs=$(grep -v '^[[:space:]]*#' $out/* | grep 'RUN+="[^/$]' |
          sed -e 's/.*RUN+="\([^ "]*\)[ "].*/\1/' | uniq)
        for i in $import_progs $run_progs; do
          if [[ ! -x ${udev}/lib/udev/$i && ! $i =~ socket:.* ]]; then
            echo "FAIL"
            echo "$i is called in udev rules but not installed by udev"
            exit 1
          fi
        done
        echo "OK"

        echo -n "Checking that all programs called by absolute paths in udev rules exist... "
        import_progs=$(grep 'IMPORT{program}="/' $out/* |
          sed -e 's/.*IMPORT{program}="\([^ "]*\)[ "].*/\1/' | uniq)
        run_progs=$(grep -v '^[[:space:]]*#' $out/* | grep 'RUN+="/' |
          sed -e 's/.*RUN+="\([^ "]*\)[ "].*/\1/' | uniq)
        for i in $import_progs $run_progs; do
          # if the path refers to /run/current-system/systemd, replace with config.systemd.package
          if [[ $i == /run/current-system/systemd* ]]; then
            i="${systemd}/''${i#/run/current-system/systemd/}"
          fi

          if [[ ! -x $i ]]; then
            echo "FAIL"
            echo "$i is called in udev rules but is not executable or does not exist"
            exit 1
          fi
        done
        echo "OK"

        filesToFixup="$(for i in "$out"/*; do
          # list all files referring to (/usr)/bin paths, but allow references to /bin/sh.
          grep -P -l '\B(?!\/bin\/sh\b)(\/usr)?\/bin(?:\/.*)?' "$i" || :
        done)"

        if [ -n "$filesToFixup" ]; then
          echo "Consider fixing the following udev rules:"
          echo "$filesToFixup" | while read localFile; do
            remoteFile="origin unknown"
            for i in ${toString binPackages}; do
              for j in "$i"/*/udev/rules.d/*; do
                [ -e "$out/$(basename "$j")" ] || continue
                [ "$(basename "$j")" = "$(basename "$localFile")" ] || continue
                remoteFile="originally from $j"
                break 2
              done
            done
            refs="$(
              grep -o '\B\(/usr\)\?/s\?bin/[^ "]\+' "$localFile" \
                | sed -e ':r;N;''${s/\n/ and /;br};s/\n/, /g;br'
            )"
            echo "$localFile ($remoteFile) contains references to $refs."
          done
          exit 1
        fi

        # Verify all the udev rules
        echo "Verifying udev rules using udevadm verify..."
        udevadm verify --resolve-names=late --no-style $out
        echo "OK"

        # If auto-configuration is disabled, then remove
        # udev's 80-drivers.rules file, which contains rules for
        # automatically calling modprobe.
        ${lib.optionalString (!config.boot.hardwareScan) ''
          ln -s /dev/null $out/80-drivers.rules
        ''}
      '';

  hwdbBin =
    pkgs.runCommand "hwdb.bin"
      {
        allowSubstitutes = false;
        packages = lib.unique (map toString ([ udev ] ++ cfg.packages));
        preferLocalBuild = true;
      }
      ''
        mkdir -p etc/udev/hwdb.d
        for i in $packages; do
          echo "Adding hwdb files for package $i"
          for j in $i/{etc,lib}/udev/hwdb.d/*; do
            # This must be a copy, not a symlink, because --root below will chase links within the root argument.
            cp $j etc/udev/hwdb.d/$(basename $j)
          done
        done

        echo "Generating hwdb database..."
        # hwdb --update doesn't return error code even on errors!
        res="$(${pkgs.buildPackages.systemd}/bin/systemd-hwdb --root=$(pwd) update 2>&1)"
        echo "$res"
        [ -z "$(echo "$res" | egrep '^Error')" ]
        mv etc/udev/hwdb.bin $out
      '';

  compressFirmware =
    firmware:
    if
      config.hardware.firmwareCompression == "none" || (firmware.compressFirmware or true) == false
    then
      firmware
    else if config.hardware.firmwareCompression == "zstd" then
      pkgs.compressFirmwareZstd firmware
    else
      pkgs.compressFirmwareXz firmware;

  # Udev has a 512-character limit for ENV{PATH}, so create a symlink
  # tree to work around this.
  udevPath = pkgs.buildEnv {
    ignoreCollisions = true;
    name = "udev-path";
    paths = cfg.path;

    pathsToLink = [
      "/bin"
      "/sbin"
    ];
  };

in

{

  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "udev" "initrdRules" ]
      [ "boot" "initrd" "services" "udev" "rules" ]
    )
  ];

  ###### interface
  options = {
    boot.hardwareScan = lib.mkOption {
      default = true;

      description = ''
        Whether to try to load kernel modules for all detected hardware.
        Usually this does a good job of providing you with the modules
        you need, but sometimes it can crash the system or cause other
        nasty effects.
      '';

      type = lib.types.bool;
    };

    boot.initrd.services.udev = {

      binPackages = lib.mkOption {
        apply = map lib.getBin;
        default = [ ];

        description = ''
          *This will only be used when systemd is used in stage 1.*

          Packages to search for binaries that are referenced by the udev rules in stage 1.
          This list always contains /bin of the initrd.
        '';

        type = lib.types.listOf lib.types.path;
      };

      packages = lib.mkOption {
        default = [ ];

        description = ''
          *This will only be used when systemd is used in stage 1.*

          List of packages containing {command}`udev` rules that will be copied to stage 1.
          All files found in
          {file}`«pkg»/etc/udev/rules.d` and
          {file}`«pkg»/lib/udev/rules.d`
          will be included.
        '';

        type = lib.types.listOf lib.types.path;
      };

      rules = lib.mkOption {
        default = "";

        description = ''
          {command}`udev` rules to include in the initrd
          *only*. They'll be written into file
          {file}`99-local.rules`. Thus they are read and applied
          after the essential initrd rules.
        '';

        example = ''
          SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:1D:60:B9:6D:4F", KERNEL=="eth*", NAME="my_fast_network_card"
        '';

        type = lib.types.lines;
      };

    };

    hardware.firmware = lib.mkOption {
      apply =
        list:
        pkgs.buildEnv {
          ignoreCollisions = true;
          name = "firmware";
          paths = map compressFirmware list;
          pathsToLink = [ "/lib/firmware" ];
        };

      default = [ ];

      description = ''
        List of packages containing firmware files.  Such files
        will be loaded automatically if the kernel asks for them
        (i.e., when it has detected specific hardware that requires
        firmware to function).  If multiple packages contain firmware
        files with the same name, the first package in the list takes
        precedence.  Note that you must rebuild your system if you add
        files to any of these directories.
      '';

      type = lib.types.listOf lib.types.package;
    };

    hardware.firmwareCompression = lib.mkOption {
      default =
        if config.boot.kernelPackages.kernelAtLeast "5.19" then
          "zstd"
        else if config.boot.kernelPackages.kernelAtLeast "5.3" then
          "xz"
        else
          "none";

      defaultText = "auto";

      description = ''
        Whether to compress firmware files.
        Defaults depend on the kernel version.
        For kernels older than 5.3, firmware files are not compressed.
        For kernels 5.3 and newer, firmware files are compressed with xz.
        For kernels 5.19 and newer, firmware files are compressed with zstd.
      '';

      type = lib.types.enum [
        "xz"
        "zstd"
        "none"
      ];
    };

    networking.usePredictableInterfaceNames = lib.mkOption {
      default = true;

      description = ''
        Whether to assign [predictable names to network interfaces](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/).
        If enabled, interfaces
        are assigned names that contain topology information
        (e.g. `wlp3s0`) and thus should be stable
        across reboots.  If disabled, names depend on the order in
        which interfaces are discovered by the kernel, which may
        change randomly across reboots; for instance, you may find
        `eth0` and `eth1` flipping
        unpredictably.
      '';

      type = lib.types.bool;
    };

    services.udev = {
      enable = lib.mkEnableOption "udev, a device manager for the Linux kernel" // {
        default = true;
      };

      extraHwdb = lib.mkOption {
        default = "";

        description = ''
          Additional {command}`hwdb` files. They'll be written
          into file {file}`99-local.hwdb`. Thus they are
          read after all other files.
        '';

        example = ''
          evdev:input:b0003v05AFp8277*
            KEYBOARD_KEY_70039=leftalt
            KEYBOARD_KEY_700e2=leftctrl
        '';

        type = lib.types.lines;
      };

      extraRules = lib.mkOption {
        default = "";

        description = ''
          Additional {command}`udev` rules. They'll be written
          into file {file}`99-local.rules`. Thus they are
          read and applied after all other rules.
        '';

        example = ''
          ENV{ID_VENDOR_ID}=="046d", ENV{ID_MODEL_ID}=="0825", ENV{PULSE_IGNORE}="1"
        '';

        type = lib.types.lines;
      };

      packages = lib.mkOption {
        apply = map lib.getBin;
        default = [ ];

        description = ''
          List of packages containing {command}`udev` rules.
          All files found in
          {file}`«pkg»/etc/udev/rules.d` and
          {file}`«pkg»/lib/udev/rules.d`
          will be included.
        '';

        type = lib.types.listOf lib.types.path;
      };

      path = lib.mkOption {
        default = [ ];

        description = ''
          Packages added to the {env}`PATH` environment variable when
          executing programs from Udev rules.

          coreutils, gnu{sed,grep}, util-linux and config.systemd.package are
          automatically included.
        '';

        type = lib.types.listOf lib.types.path;
      };

    };

  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion =
          config.hardware.firmwareCompression == "zstd" -> config.boot.kernelPackages.kernelAtLeast "5.19";

        message = ''
          The firmware compression method is set to zstd, but the kernel version is too old.
          The kernel version must be at least 5.19 to use zstd compression.
        '';
      }
      {
        assertion =
          config.hardware.firmwareCompression == "xz" -> config.boot.kernelPackages.kernelAtLeast "5.3";

        message = ''
          The firmware compression method is set to xz, but the kernel version is too old.
          The kernel version must be at least 5.3 to use xz compression.
        '';
      }
    ];

    boot.initrd.extraUdevRulesCommands =
      lib.mkIf (!config.boot.initrd.systemd.enable && config.boot.initrd.services.udev.rules != "")
        ''
          cat <<'EOF' > $out/99-local.rules
          ${config.boot.initrd.services.udev.rules}
          EOF
        '';

    # Insert initrd rules
    boot.initrd.services.udev.packages = [
      initrdUdevRules
      (lib.mkIf (config.boot.initrd.services.udev.rules != "") (
        pkgs.writeTextFile {
          destination = "/etc/udev/rules.d/99-local.rules";
          name = "initrd-udev-rules";
          text = config.boot.initrd.services.udev.rules;
        }
      ))
    ];

    boot.initrd.services.udev.rules = nixosInitrdRules;

    boot.initrd.systemd.additionalUpstreamUnits = [
      "initrd-udevadm-cleanup-db.service"
      "systemd-udevd-control.socket"
      "systemd-udevd-kernel.socket"
      "systemd-udevd.service"
      "systemd-udev-trigger.service"
    ];

    # Generate the udev rules for the initrd
    boot.initrd.systemd.contents = {
      "/etc/udev/rules.d".source = udevRulesFor {
        binPackages = config.boot.initrd.services.udev.binPackages ++ [
          config.boot.initrd.systemd.contents."/bin".source
        ];

        initrdBin = config.boot.initrd.systemd.contents."/bin".source;
        name = "initrd-udev-rules";
        systemd = config.boot.initrd.systemd.package;
        udev = config.boot.initrd.systemd.package;
        udevPackages = config.boot.initrd.services.udev.packages;
        udevPath = config.boot.initrd.systemd.contents."/bin".source;
      };
    };

    boot.initrd.systemd.storePaths = [
      "${config.boot.initrd.systemd.package}/lib/systemd/systemd-udevd"
      "${config.boot.initrd.systemd.package}/lib/udev/ata_id"
      "${config.boot.initrd.systemd.package}/lib/udev/cdrom_id"
      "${config.boot.initrd.systemd.package}/lib/udev/scsi_id"
      "${config.boot.initrd.systemd.package}/lib/udev/rules.d"
    ]
    ++ lib.optional (
      # https://github.com/systemd/systemd/blob/v259/meson.build#L1529-L1530
      pkgs.stdenv.hostPlatform.isx86
      || pkgs.stdenv.hostPlatform.isAarch
      || pkgs.stdenv.hostPlatform.isLoongArch64
      || pkgs.stdenv.hostPlatform.isMips
      || pkgs.stdenv.hostPlatform.isRiscV64
    ) "${config.boot.initrd.systemd.package}/lib/udev/dmi_memory_id"
    ++ map (x: "${x}/bin") config.boot.initrd.services.udev.binPackages;

    boot.kernelParams = lib.mkIf (!config.networking.usePredictableInterfaceNames) [ "net.ifnames=0" ];

    environment.etc = {
      "udev/hwdb.bin".source = hwdbBin;

      "udev/rules.d".source = udevRulesFor {
        inherit udevPath udev;
        binPackages = cfg.packages;
        name = "udev-rules";
        systemd = config.systemd.package;
        udevPackages = cfg.packages;
      };
    }
    // lib.optionalAttrs config.boot.modprobeConfig.enable {
      # We don't place this into `extraModprobeConfig` so that stage-1 ramdisk doesn't bloat.
      "modprobe.d/firmware.conf".text =
        "options firmware_class path=${config.hardware.firmware}/lib/firmware";
    };

    services.udev.extraRules = nixosRules;

    services.udev.packages = [
      extraUdevRules
      extraHwdbFile
    ];

    services.udev.path = [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gnugrep
      pkgs.util-linux
      udev
    ];

    system.activationScripts.udevd = lib.mkIf config.boot.kernel.enable ''
      # The deprecated hotplug uevent helper is not used anymore
      if [ -e /proc/sys/kernel/hotplug ]; then
        echo "" > /proc/sys/kernel/hotplug
      fi

      # Allow the kernel to find our firmware.
      if [ -e /sys/module/firmware_class/parameters/path ]; then
        echo -n "${config.hardware.firmware}/lib/firmware" > /sys/module/firmware_class/parameters/path
      fi
    '';

    system.requiredKernelConfig = with config.lib.kernelConfig; [
      (isEnabled "UNIX")
      (isYes "INOTIFY_USER")
      (isYes "NET")
    ];

    systemd.services.systemd-udevd = {
      notSocketActivated = true;
      restartTriggers = [ config.environment.etc."udev/rules.d".source ];
      stopIfChanged = false;
    };
  };
}
