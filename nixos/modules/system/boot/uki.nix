{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.boot.uki;

  inherit (pkgs.stdenv.hostPlatform) efiArch;

  format = pkgs.formats.ini { };
in

{
  options = {

    boot.uki = {
      configFile = lib.mkOption {
        description = ''
          The configuration file passed to {manpage}`ukify(1)` to create the UKI.

          By default this configuration file is created from {option}`boot.uki.settings`.
        '';

        type = lib.types.path;
      };

      name = lib.mkOption {
        description = "Name of the UKI";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        description = ''
          The configuration settings for ukify. These control what the UKI
          contains and how it is built.
        '';

        type = format.type;
      };

      tries = lib.mkOption {
        default = null;

        description = ''
          Number of boot attempts before this UKI is considered bad.

          If no tries are specified (the default) automatic boot assessment remains inactive.

          See documentation on [Automatic Boot Assessment](https://systemd.io/AUTOMATIC_BOOT_ASSESSMENT/) and
          [boot counting](https://uapi-group.org/specifications/specs/boot_loader_specification/#boot-counting)
          for more information.
        '';

        type = lib.types.nullOr lib.types.ints.unsigned;
      };

      version = lib.mkOption {
        default = config.system.image.version;
        defaultText = lib.literalExpression "config.system.image.version";
        description = "Version of the image or generation the UKI belongs to";
        type = lib.types.nullOr lib.types.str;
      };
    };

    system.boot.loader.ukiFile = lib.mkOption {
      description = "Name of the UKI file";
      internal = true;
      type = lib.types.str;
    };

  };

  config = {

    boot.uki.configFile = lib.mkOptionDefault (format.generate "ukify.conf" cfg.settings);

    boot.uki.name = lib.mkOptionDefault (
      if config.system.image.id != null then config.system.image.id else "nixos"
    );

    boot.uki.settings = {
      UKI = {
        Cmdline = lib.mkOptionDefault "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}";
        # This is needed for cross compiling.
        EFIArch = lib.mkOptionDefault efiArch;
        Initrd = lib.mkOptionDefault "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
        Linux = lib.mkOptionDefault "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";
        OSRelease = lib.mkOptionDefault "@${config.system.build.etc}/etc/os-release";
        Stub = lib.mkOptionDefault "${config.systemd.package}/lib/systemd/boot/efi/linux${efiArch}.efi.stub";
        Uname = lib.mkOptionDefault "${config.boot.kernelPackages.kernel.modDirVersion}";
      }
      //
        lib.optionalAttrs (config.hardware.deviceTree.enable && config.hardware.deviceTree.name != null)
          {
            DeviceTree = lib.mkOptionDefault "${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name}";
          };
    };

    system.boot.loader.ukiFile =
      let
        name = config.boot.uki.name;
        version = config.boot.uki.version;
        versionInfix = if version != null then "_${version}" else "";
        triesInfix = if cfg.tries != null then "+${toString cfg.tries}" else "";
      in
      name + versionInfix + triesInfix + ".efi";

    system.build.uki = pkgs.runCommand config.system.boot.loader.ukiFile { } ''
      mkdir -p $out
      ${pkgs.buildPackages.systemdUkify}/lib/systemd/ukify build \
        --config=${cfg.configFile} \
        --output="$out/${config.system.boot.loader.ukiFile}"
    '';
  };

  meta.maintainers = with lib.maintainers; [ nikstur ];
}
