{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) literalExpression types;
in
{
  options = {
    openstack = {
      efi = lib.mkOption {
        default = pkgs.stdenv.hostPlatform.isAarch64;
        defaultText = literalExpression "pkgs.stdenv.hostPlatform.isAarch64";

        description = ''
          Whether the instance is using EFI.
        '';

        internal = true;
      };

      zfs = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Whether the OpenStack instance uses a ZFS root.
          '';

          internal = true;
        };

        datasets = lib.mkOption {
          default = { };

          description = ''
            Datasets to create under the `tank` and `boot` zpools.

            **NOTE:** This option is used only at image creation time, and
            does not attempt to declaratively create or manage datasets
            on an existing system.
          '';

          type = types.attrsOf (
            types.submodule {
              options = {
                mount = lib.mkOption {
                  default = null;
                  description = "Where to mount this dataset.";
                  type = types.nullOr types.str;
                };

                properties = lib.mkOption {
                  default = { };
                  description = "Properties to set on this dataset.";
                  type = types.attrsOf types.str;
                };
              };
            }
          );
        };
      };
    };
  };

  config = lib.mkIf config.openstack.zfs.enable {
    fileSystems =
      let
        mountable = lib.filterAttrs (
          _: value: ((value.mount or null) != null)
        ) config.openstack.zfs.datasets;
      in
      lib.mapAttrs' (
        dataset: opts:
        lib.nameValuePair opts.mount {
          device = dataset;
          fsType = "zfs";
        }
      ) mountable;

    networking.hostId = lib.mkDefault "00000000";
  };
}
