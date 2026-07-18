{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib) mkIf mkOption types;

  randomEncryptionCoerce = enable: { inherit enable; };

  randomEncryptionOpts =
    { ... }:
    {

      options = {

        enable = mkOption {
          default = false;

          description = ''
            Encrypt swap device with a random key. This way you won't have a persistent swap device.

            WARNING: Don't try to hibernate when you have at least one swap partition with
            this option enabled! We have no way to set the partition into which hibernation image
            is saved, so if your image ends up on an encrypted one you would lose it!

            WARNING #2: Do not use /dev/disk/by-uuid/… or /dev/disk/by-label/… as your swap device
            when using randomEncryption as the UUIDs and labels will get erased on every boot when
            the partition is encrypted. Best to use /dev/disk/by-partuuid/…
          '';

          type = types.bool;
        };

        allowDiscards = mkOption {
          default = false;

          description = ''
            Whether to allow TRIM requests to the underlying device. This option
            has security implications; please read the LUKS documentation before
            activating it.
          '';

          type = types.bool;
        };

        cipher = mkOption {
          default = "aes-xts-plain64";

          description = ''
            Use specified cipher for randomEncryption.

            Hint: Run "cryptsetup benchmark" to see which one is fastest on your machine.
          '';

          example = "serpent-xts-plain64";
          type = types.str;
        };

        keySize = mkOption {
          default = null;

          description = ''
            Set the encryption key size for the plain device.

            If not specified, the amount of data to read from `source` will be
            determined by cryptsetup.

            See {manpage}`cryptsetup-open(8)` for details.
          '';

          example = "512";
          type = types.nullOr types.int;
        };

        sectorSize = mkOption {
          default = null;

          description = ''
            Set the sector size for the plain encrypted device type.

            If not specified, the default sector size is determined from the
            underlying block device.

            See {manpage}`cryptsetup-open(8)` for details.
          '';

          example = "4096";
          type = types.nullOr types.int;
        };

        source = mkOption {
          default = "/dev/urandom";

          description = ''
            Define the source of randomness to obtain a random key for encryption.
          '';

          example = "/dev/random";
          type = types.str;
        };
      };

    };

  swapCfg =
    { config, options, ... }:
    {

      options = {

        options = mkOption {
          default = [ "defaults" ];

          description = ''
            Options used to mount the swap.
          '';

          example = [ "nofail" ];
          type = types.listOf types.nonEmptyStr;
        };

        device = mkOption {
          description = "Path of the device or swap file.";
          example = "/dev/sda3";
          type = types.nonEmptyStr;
        };

        deviceName = mkOption {
          internal = true;
          type = types.str;
        };

        discardPolicy = mkOption {
          default = null;

          description = ''
            Specify the discard policy for the swap device. If "once", then the
            whole swap space is discarded at swapon invocation. If "pages",
            asynchronous discard on freed pages is performed, before returning to
            the available pages pool. With "both", both policies are activated.
            See {manpage}`swapon(8)` for more information.
          '';

          example = "once";

          type = types.nullOr (
            types.enum [
              "once"
              "pages"
              "both"
            ]
          );
        };

        isDevice = mkOption {
          default = lib.substring 0 5 config.device == "/dev/";
          internal = true;
        };

        label = mkOption {
          description = ''
            Label of the device.  Can be used instead of {var}`device`.
          '';

          example = "swap";
          type = types.str;
        };

        priority = mkOption {
          default = null;

          description = ''
            Specify the priority of the swap device. Priority is a value between 0 and 32767.
            Higher numbers indicate higher priority.
            null lets the kernel choose a priority, which will show up as a negative value.
          '';

          example = 2048;
          type = types.nullOr types.int;
        };

        randomEncryption = mkOption {
          default = false;

          description = ''
            Encrypt swap device with a random key. This way you won't have a persistent swap device.

            HINT: run "cryptsetup benchmark" to test cipher performance on your machine.

            WARNING: Don't try to hibernate when you have at least one swap partition with
            this option enabled! We have no way to set the partition into which hibernation image
            is saved, so if your image ends up on an encrypted one you would lose it!

            WARNING #2: Do not use /dev/disk/by-uuid/… or /dev/disk/by-label/… as your swap device
            when using randomEncryption as the UUIDs and labels will get erased on every boot when
            the partition is encrypted. Best to use /dev/disk/by-partuuid/…
          '';

          example = {
            enable = true;
            cipher = "serpent-xts-plain64";
            source = "/dev/random";
          };

          type = types.coercedTo types.bool randomEncryptionCoerce (types.submodule randomEncryptionOpts);
        };

        realDevice = mkOption {
          internal = true;
          type = types.path;
        };

        size = mkOption {
          default = null;

          description = ''
            If this option is set, ‘device’ is interpreted as the
            path of a swapfile that will be created automatically
            with the indicated size in MiB (1024×1024 bytes).
          '';

          example = 2048;
          type = types.nullOr types.int;
        };

      };

      config = {
        device = mkIf options.label.isDefined "/dev/disk/by-label/${config.label}";
        deviceName = lib.replaceStrings [ "\\" ] [ "" ] (utils.escapeSystemdPath config.device);

        realDevice =
          if config.randomEncryption.enable then "/dev/mapper/${config.deviceName}" else config.device;
      };

    };

in

{

  ###### interface

  options = {

    swapDevices = mkOption {
      default = [ ];

      description = ''
        The swap devices and swap files.  These must have been
        initialised using {command}`mkswap`.  Each element
        should be an attribute set specifying either the path of the
        swap device or file (`device`) or the label
        of the swap device (`label`, see
        {command}`mkswap -L`).  Using a label is
        recommended.
      '';

      example = [
        { device = "/dev/hda7"; }
        { device = "/var/swapfile"; }
        { label = "bigswap"; }
      ];

      type = types.listOf (types.submodule swapCfg);
    };

  };

  config = mkIf ((lib.length config.swapDevices) != 0) {
    assertions = lib.map (sw: {
      assertion =
        sw.randomEncryption.enable -> builtins.match "/dev/disk/by-(uuid|label)/.*" sw.device == null;

      message = ''
        You cannot use swap device "${sw.device}" with randomEncryption enabled.
        The UUIDs and labels will get erased on every boot when the partition is encrypted.
        Use /dev/disk/by-partuuid/… instead.
      '';
    }) config.swapDevices;

    system.requiredKernelConfig = [
      (config.lib.kernelConfig.isYes "SWAP")
    ];

    # Create missing swapfiles.
    systemd.services =
      let
        createSwapDevice =
          sw:
          let
            realDevice' = utils.escapeSystemdPath sw.realDevice;
            btrfsInSystem = config.boot.supportedFilesystems.btrfs or false;
          in
          lib.nameValuePair "mkswap-${sw.deviceName}" {
            # The mkswap service fails for file-backed swap devices if the
            # loop module has not been loaded before the service runs.
            # We add an ordering constraint to run after systemd-modules-load to
            # avoid this race condition.
            after = [ "systemd-modules-load.service" ];

            before = [
              "${realDevice'}.swap"
              "shutdown.target"
            ];

            conflicts = [ "shutdown.target" ];
            description = "Initialisation of swap device ${sw.device}";
            enableStrictShellChecks = true;
            environment.DEVICE = sw.device;

            path = [
              pkgs.util-linux
              pkgs.e2fsprogs
            ]
            ++ lib.optional btrfsInSystem pkgs.btrfs-progs
            ++ lib.optional sw.randomEncryption.enable pkgs.cryptsetup;

            requiredBy = lib.optionals sw.randomEncryption.enable [ "${realDevice'}.swap" ];
            restartIfChanged = false;

            script = ''
              ${lib.optionalString (sw.size != null) ''
                currentSize=$(( $(stat -c "%s" "$DEVICE" 2>/dev/null || echo 0) / 1024 / 1024 ))
                if [[ ! -b "$DEVICE" && "${toString sw.size}" != "$currentSize" ]]; then
                  if [[ "$(stat -f -c %T "$(dirname "$DEVICE")")" == "btrfs" ]]; then
                    # Use btrfs mkswapfile to speed up the creation of swapfile.
                    rm -f "$DEVICE"
                    btrfs filesystem mkswapfile --size "${toString sw.size}M" --uuid clear "$DEVICE"
                  else
                    # Disable CoW for CoW based filesystems.
                    truncate --size 0 "$DEVICE"
                    chattr +C "$DEVICE" 2>/dev/null || true

                    echo "Creating swap file using dd and mkswap."
                    mkdir -p "$(dirname "$DEVICE")"
                    dd if=/dev/zero of="$DEVICE" bs=1M count=${toString sw.size} status=progress
                    ${lib.optionalString (!sw.randomEncryption.enable) "mkswap \"${sw.realDevice}\""}
                  fi
                fi
              ''}
              ${lib.optionalString sw.randomEncryption.enable ''
                cryptsetup plainOpen -c ${sw.randomEncryption.cipher} -d ${sw.randomEncryption.source} \
                ${
                  lib.concatStringsSep " \\\n" (
                    lib.flatten [
                      (lib.optional (
                        sw.randomEncryption.sectorSize != null
                      ) "--sector-size=${toString sw.randomEncryption.sectorSize}")
                      (lib.optional (
                        sw.randomEncryption.keySize != null
                      ) "--key-size=${toString sw.randomEncryption.keySize}")
                      (lib.optional sw.randomEncryption.allowDiscards "--allow-discards")
                    ]
                  )
                } ${sw.device} ${sw.deviceName}
                mkswap ${sw.realDevice}
                ${lib.optionalString sw.isDevice "udevadm trigger ${sw.realDevice}"}
              ''}
            '';

            serviceConfig = {
              ExecStop = lib.optionalString sw.randomEncryption.enable "${pkgs.cryptsetup}/bin/cryptsetup luksClose ${sw.deviceName}";
              RemainAfterExit = sw.randomEncryption.enable;
              Type = "oneshot";
              UMask = "0177";
            };

            unitConfig.DefaultDependencies = false; # needed to prevent a cycle
            unitConfig.RequiresMountsFor = [ "${dirOf sw.device}" ];
            wantedBy = [ "${realDevice'}.swap" ];
          };

      in
      lib.listToAttrs (
        lib.map createSwapDevice (
          lib.filter (sw: sw.size != null || sw.randomEncryption.enable) config.swapDevices
        )
      );

    warnings = lib.concatMap (
      sw:
      if sw.size != null && lib.hasPrefix "/dev/" sw.device then
        [ "Setting the swap size of block device ${sw.device} has no effect" ]
      else
        [ ]
    ) config.swapDevices;

  };

}
