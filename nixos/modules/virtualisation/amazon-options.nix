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
    ec2 = {
      efi = lib.mkOption {
        default = pkgs.stdenv.hostPlatform.isAarch64;
        defaultText = literalExpression "pkgs.stdenv.hostPlatform.isAarch64";

        description = ''
          Whether the EC2 instance is using EFI.
        '';

        internal = true;
      };

      hvm = lib.mkOption {
        default = true;
        description = "Unused legacy option. While support for non-hvm has been dropped, we keep this option around so that NixOps remains compatible with a somewhat recent `nixpkgs` and machines with an old `stateVersion`.";
        internal = true;
        readOnly = true;
      };

      zfs = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Whether the EC2 instance uses a ZFS root.
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

  config = lib.mkIf config.ec2.zfs.enable {
    fileSystems =
      let
        mountable = lib.filterAttrs (_: value: ((value.mount or null) != null)) config.ec2.zfs.datasets;
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
