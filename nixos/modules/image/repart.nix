# This module exposes options to build a disk image with a GUID Partition Table
# (GPT). It uses systemd-repart to build the image.

{
  config,
  lib,
  pkgs,
  options,
  utils,
  ...
}:

let
  cfg = config.image.repart;

  inherit (utils.systemdUtils.lib) GPTMaxLabelLength;

  partitionOptions =
    { config, ... }:
    {
      options = {
        contents = lib.mkOption {
          default = { };
          description = "The contents to end up in the filesystem image.";

          example = lib.literalExpression ''
            {
              "/EFI/BOOT/BOOTX64.EFI".source =
                "''${pkgs.systemd}/lib/systemd/boot/efi/systemd-bootx64.efi";

              "/loader/entries/nixos.conf".source = systemdBootEntry;
            }
          '';

          type =
            with lib.types;
            attrsOf (submodule {
              options = {
                source = lib.mkOption {
                  description = "Path of the source file.";
                  type = types.path;
                };
              };
            });
        };

        nixStorePrefix = lib.mkOption {
          default = "/nix/store";

          description = ''
            The prefix to use for store paths. Defaults to `/nix/store`. This is
            useful when you want to build a partition that only contains store
            paths and is mounted under `/nix/store` or if you want to create the
            store paths below a parent path (e.g., `/@nix/nix/store`).
          '';

          type = lib.types.path;
        };

        repartConfig = lib.mkOption {
          description = ''
            Specify the repart options for a partition as a structural setting.
            See {manpage}`repart.d(5)`
            for all available options.
          '';

          example = {
            SizeMaxBytes = "2G";
            SizeMinBytes = "512M";
            Type = "home";
          };

          type =
            with lib.types;
            attrsOf (oneOf [
              str
              int
              bool
              (listOf str)
            ]);
        };

        storePaths = lib.mkOption {
          default = [ ];
          description = "The store paths to include in the partition.";
          type = with lib.types; listOf path;
        };

        # Superseded by `nixStorePrefix`. Unfortunately, `mkChangedOptionModule`
        # does not support submodules.
        stripNixStorePrefix = lib.mkOption {
          default = "_mkMergedOptionModule";
          visible = false;
        };
      };

      config = lib.mkIf (config.stripNixStorePrefix == true) {
        nixStorePrefix = "/";
      };
    };

  mkfsOptionsToEnv =
    opts:
    lib.mapAttrs' (fsType: options: {
      name = "SYSTEMD_REPART_MKFS_OPTIONS_${lib.toUpper fsType}";
      value = builtins.concatStringsSep " " options;
    }) opts;
in
{
  imports = [
    ./repart-verity-store.nix
    ./file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "image"
        "repart"
        "imageFileBasename"
      ];

      sinceRelease = 2411;

      to = [
        "image"
        "baseName"
      ];
    })
    (lib.mkRenamedOptionModuleWith {
      from = [
        "image"
        "repart"
        "imageFile"
      ];

      sinceRelease = 2411;

      to = [
        "image"
        "fileName"
      ];
    })
  ];

  options.image.repart = {

    package = lib.mkPackageOption pkgs "systemd-repart" {
      # We use buildPackages so that repart images are built with the build
      # platform's systemd, allowing for cross-compiled systems to work.
      default = [
        "buildPackages"
        "systemd"
      ];

      example = "pkgs.buildPackages.systemdMinimal.override { withCryptsetup = true; }";
    };

    assertions = lib.mkOption {
      default = [ ];

      description = ''
        Assertions only evaluated by the repart image, not by the system toplevel.
      '';

      internal = true;
      type = options.assertions.type;
      visible = false;
    };

    compression = {
      enable = lib.mkEnableOption "Image compression";

      algorithm = lib.mkOption {
        default = "zstd";
        description = "Compression algorithm";

        type = lib.types.enum [
          "zstd"
          "xz"
          "zstd-seekable"
        ];
      };

      level = lib.mkOption {
        description = ''
          Compression level. The available range depends on the used algorithm.
        '';

        type = lib.types.int;
      };
    };

    finalPartitions = lib.mkOption {
      description = ''
        Convenience option to access partitions with added closures.
      '';

      internal = true;
      readOnly = true;
      type = lib.types.attrs;
    };

    image = lib.mkOption {
      description = ''
        The image built by this module. Used as the default for `system.build.image`.
      '';

      internal = true;
      readOnly = true;
      type = lib.types.package;
    };

    imageSize = lib.mkOption {
      default = "auto";

      description = "Size of the produced image in bytes with optional K, M, G, T suffix,
        or 'auto' to determine the minimal size automatically";

      example = "512G";
      type = lib.types.strMatching "^([0-9]+[KMGTP]?|auto)$";
    };

    mkfsOptions = lib.mkOption {
      default = { };

      description = ''
        Specify extra options for created file systems. The specified options
        are converted to individual environment variables of the format
        `SYSTEMD_REPART_MKFS_OPTIONS_<FSTYPE>`.

        See [upstream systemd documentation](https://github.com/systemd/systemd/blob/v255/docs/ENVIRONMENT.md?plain=1#L575-L577)
        for information about the usage of these environment variables.

        The example would produce the following environment variable:
        ```
        SYSTEMD_REPART_MKFS_OPTIONS_VFAT="-S 512 -c"
        ```
      '';

      example = lib.literalExpression ''
        {
          vfat = [ "-S 512" "-c" ];
        }
      '';

      type = with lib.types; attrsOf (listOf str);
    };

    name = lib.mkOption {
      description = ''
          Name of the image.

        If this option is unset but config.system.image.id is set,
        config.system.image.id is used as the default value.
      '';

      type = lib.types.str;
    };

    partitions = lib.mkOption {
      default = { };

      description = ''
        Specify partitions as a set of the names of the partitions with their
        configuration as the key.
      '';

      example = lib.literalExpression ''
        {
          "10-esp" = {
            contents = {
              "/EFI/BOOT/BOOTX64.EFI".source =
                "''${pkgs.systemd}/lib/systemd/boot/efi/systemd-bootx64.efi";
            };
            repartConfig = {
              Type = "esp";
              Format = "vfat";
            };
          };
          "20-root" = {
            storePaths = [ config.system.build.toplevel ];
            repartConfig = {
              Type = "root";
              Format = "ext4";
              Minimize = "guess";
            };
          };
        };
      '';

      type = with lib.types; attrsOf (submodule partitionOptions);
    };

    sectorSize = lib.mkOption {
      default = 512;

      description = ''
        The sector size of the disk image produced by systemd-repart. This
        value must be a power of 2 between 512 and 4096.
      '';

      example = lib.literalExpression "4096";
      type = with lib.types; nullOr int;
    };

    seed = lib.mkOption {
      # Generated with `uuidgen`. Random but fixed to improve reproducibility.
      default = "0867da16-f251-457d-a9e8-c31f9a3c220b";

      description = ''
        A UUID to use as a seed. You can set this to `random` to explicitly
        randomize the partition UUIDs.
        See {manpage}`systemd-repart(8)` for more information.
      '';

      type = with lib.types; nullOr str;
    };

    split = lib.mkOption {
      default = false;

      description = ''
        Enables generation of split artifacts from partitions. If enabled, for
        each partition with SplitName= set, a separate output file containing
        just the contents of that partition is generated.
      '';

      type = lib.types.bool;
    };

    version = lib.mkOption {
      default = config.system.image.version;
      defaultText = lib.literalExpression "config.system.image.version";
      description = "Version of the image";
      type = lib.types.nullOr lib.types.str;
    };

    warnings = lib.mkOption {
      default = [ ];

      description = ''
        Warnings only evaluated by the repart image, not by the system toplevel.
      '';

      internal = true;
      type = options.warnings.type;
      visible = false;
    };

  };

  config = {
    image.baseName =
      let
        version = config.image.repart.version;
        versionInfix = if version != null then "_${version}" else "";
      in
      cfg.name + versionInfix;

    image.extension =
      let
        compressionSuffix =
          lib.optionalString cfg.compression.enable
            {
              "xz" = ".xz";
              "zstd" = ".zst";
              "zstd-seekable" = ".zst";
            }
            ."${cfg.compression.algorithm}";

      in
      "raw" + compressionSuffix;

    image.repart =
      let
        makeClosure = paths: pkgs.closureInfo { rootPaths = paths; };

        # Add the closure of the provided Nix store paths to cfg.partitions so
        # that amend-repart-definitions.py can read it.
        addClosure =
          _name: partitionConfig:
          partitionConfig
          // (lib.optionalAttrs (partitionConfig.storePaths or [ ] != [ ]) {
            closure = "${makeClosure partitionConfig.storePaths}/store-paths";
          });
      in
      {
        assertions = lib.mapAttrsToList (
          fileName: partitionConfig:
          let
            inherit (partitionConfig) repartConfig;
            labelLength = builtins.stringLength repartConfig.Label;
          in
          {
            assertion = repartConfig ? Label -> GPTMaxLabelLength >= labelLength;

            message = ''
              The partition label '${repartConfig.Label}'
              defined for '${fileName}' is ${toString labelLength} characters long,
              but the maximum label length supported by UEFI is ${toString GPTMaxLabelLength}.
            '';
          }
        ) cfg.partitions;

        compression = {
          # Generally default to slightly faster than default compression
          # levels under the assumption that most of the building will be done
          # for development and release builds will be customized.
          level =
            lib.mkOptionDefault
              {
                "xz" = 3;
                "zstd" = 3;
                "zstd-seekable" = 3;
              }
              ."${cfg.compression.algorithm}";
        };

        finalPartitions = lib.mapAttrs addClosure cfg.partitions;

        image =
          let
            fileSystems = lib.filter (f: f != null) (
              lib.mapAttrsToList (_n: v: v.repartConfig.Format or null) cfg.partitions
            );

            format = pkgs.formats.ini { listsAsDuplicateKeys = true; };

            definitionsDirectory = utils.systemdUtils.lib.definitions "repart.d" format (
              lib.mapAttrs (_n: v: { Partition = v.repartConfig; }) cfg.finalPartitions
            );

            mkfsEnv = mkfsOptionsToEnv cfg.mkfsOptions;
            val = pkgs.callPackage ./repart-image.nix {
              inherit (config.image) baseName;

              inherit (cfg)
                name
                version
                compression
                split
                seed
                imageSize
                sectorSize
                finalPartitions
                ;

              inherit fileSystems definitionsDirectory mkfsEnv;
              systemd = cfg.package;
            };
          in
          lib.asserts.checkAssertWarn cfg.assertions cfg.warnings val;

        name = lib.mkIf (config.system.image.id != null) (lib.mkOptionDefault config.system.image.id);

        warnings = lib.flatten (
          lib.mapAttrsToList (
            fileName: partitionConfig:
            let
              inherit (partitionConfig) repartConfig;
              suggestedMaxLabelLength = GPTMaxLabelLength - 2;
              labelLength = builtins.stringLength repartConfig.Label;
            in
            lib.optional (repartConfig ? Label && labelLength >= suggestedMaxLabelLength) ''
              The partition label '${repartConfig.Label}'
              defined for '${fileName}' is ${toString labelLength} characters long.
              The suggested maximum label length is ${toString suggestedMaxLabelLength}.

              If you use systemd-sysupdate style A/B updates, this might
              not leave enough space to increment the version number included in
              the label in a future release. For example, if your label is
              ${toString GPTMaxLabelLength} characters long (the maximum enforced by UEFI) and
              you're at version 9, you cannot increment this to 10.
            ''
            ++ lib.optional (partitionConfig.stripNixStorePrefix != "_mkMergedOptionModule") ''
              The option definition `image.repart.partitions.${fileName}.stripNixStorePrefix`
              has changed to `image.repart.partitions.${fileName}.nixStorePrefix` and now
              accepts the path to use as prefix directly. Use `nixStorePrefix = "/"` to
              achieve the same effect as setting `stripNixStorePrefix = true`.
            ''
          ) cfg.partitions
        );
      };

    system.build.image = cfg.image;
  };

  meta.maintainers = with lib.maintainers; [
    nikstur
    willibutz
  ];
}
