{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  blCfg = config.boot.loader;
  dtCfg = config.hardware.deviceTree;
  cfg = blCfg.generic-extlinux-compatible;

  timeoutStr = if blCfg.timeout == null then "-1" else toString blCfg.timeout;

  # The builder used to write during system activation
  builder = import ./extlinux-conf-builder.nix { inherit lib pkgs; };
  # The builder exposed in populateCmd, which runs on the build architecture
  populateBuilder = import ./extlinux-conf-builder.nix {
    inherit lib;
    pkgs = pkgs.buildPackages;
  };
in
{
  options = {
    boot.loader.generic-extlinux-compatible = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to generate an extlinux-compatible configuration file
          under `/boot/extlinux.conf`.  For instance,
          U-Boot's generic distro boot support uses this file format.

          See [U-boot's documentation](https://u-boot.readthedocs.io/en/latest/develop/distro.html)
          for more information.
        '';

        type = types.bool;
      };

      configurationLimit = mkOption {
        default = 20;

        description = ''
          Maximum number of configurations in the boot menu.
        '';

        example = 10;
        type = types.int;
      };

      mirroredBoots = mkOption {
        default = [ { path = "/boot"; } ];

        description = ''
          Mirror the boot configuration to multiple paths.
        '';

        example = [
          { path = "/boot1"; }
          { path = "/boot2"; }
        ];

        type =
          with types;
          listOf (submodule {
            options = {
              path = mkOption {
                description = ''
                  The path to the boot directory where the extlinux-compatible
                  configuration files will be written.
                '';

                example = "/boot1";
                type = types.str;
              };
            };
          });
      };

      populateCmd = mkOption {
        description = ''
          Contains the builder command used to populate an image,
          honoring all options except the `-c <path-to-default-configuration>`
          argument.
          Useful to have for sdImage.populateRootCommands
        '';

        readOnly = true;
        type = types.str;
      };

      useGenerationDeviceTree = mkOption {
        default = true;

        description = ''
          Whether to generate Device Tree-related directives in the
          extlinux configuration.

          When enabled, the bootloader will attempt to load the device
          tree binaries from the generation's kernel.

          Note that this affects all generations, regardless of the
          setting value used in their configurations.
        '';

        type = types.bool;
      };

    };
  };

  config =
    let
      builderArgs =
        "-g ${toString cfg.configurationLimit} -t ${timeoutStr}"
        + lib.optionalString (dtCfg.name != null) " -n ${dtCfg.name}"
        + lib.optionalString (!cfg.useGenerationDeviceTree) " -r";
      installBootLoader = pkgs.writeScript "install-extlinux-conf.sh" (
        ''
          #!${pkgs.runtimeShell}
          set -e
        ''
        + flip concatMapStrings cfg.mirroredBoots (args: ''
          ${builder} ${builderArgs} -d '${args.path}' -c "$@"
        '')
      );
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.mirroredBoots != [ ];

          message = ''
            You must not remove all elements from option 'boot.loader.generic-extlinux-compatible.mirroredBoots',
            otherwise the system will not be bootable.
          '';
        }
      ];

      boot.loader.generic-extlinux-compatible.populateCmd = "${populateBuilder} ${builderArgs}";
      system.boot.loader.id = "generic-extlinux-compatible";
      system.build.installBootLoader = installBootLoader;
    };
}
