{ config, lib, ... }:
let
  cfg = config.boot.tmp;
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "boot" "cleanTmpDir" ] [ "boot" "tmp" "cleanOnBoot" ])
    (lib.mkRenamedOptionModule [ "boot" "tmpOnTmpfs" ] [ "boot" "tmp" "useTmpfs" ])
    (lib.mkRenamedOptionModule [ "boot" "tmpOnTmpfsSize" ] [ "boot" "tmp" "tmpfsSize" ])
  ];

  options = {
    boot.tmp = {
      cleanOnBoot = lib.mkOption {
        default = false;

        description = ''
          Whether to delete all files in {file}`/tmp` during boot.
        '';

        type = lib.types.bool;
      };

      tmpfsHugeMemoryPages = lib.mkOption {
        default = "never";

        description = ''
          - `never`        - Do not allocate huge memory pages. This is the default.
          - `always`       - Attempt to allocate huge memory page every time a new page is needed.
          - `within_size`  - Only allocate huge memory pages if it will be fully within i_size. Also respect madvise(2) hints. Recommended.
          - `advise`       - Only allocate huge memory pages if requested with madvise(2).
        '';

        example = "within_size";

        type = lib.types.enum [
          "never"
          "always"
          "within_size"
          "advise"
        ];
      };

      tmpfsSize = lib.mkOption {
        default = "50%";

        description = ''
          Size of tmpfs in percentage.
          Percentage is defined by systemd.
        '';

        type = lib.types.oneOf [
          lib.types.str
          lib.types.ints.positive
        ];
      };

      useTmpfs = lib.mkOption {
        default = false;

        description = ''
          Whether to mount a tmpfs on {file}`/tmp` during boot.

          ::: {.note}
          Large Nix builds can fail if the mounted tmpfs is not large enough.
          In such a case either increase the tmpfsSize or disable this option.
          :::
        '';

        type = lib.types.bool;
      };
    };
  };

  config = {
    # When changing remember to update /tmp mount in virtualisation/qemu-vm.nix
    systemd.mounts = lib.mkIf cfg.useTmpfs [
      {
        mountConfig.Options = lib.concatStringsSep "," [
          "mode=1777"
          "strictatime"
          "rw"
          "nosuid"
          "nodev"
          "size=${toString cfg.tmpfsSize}"
          "huge=${cfg.tmpfsHugeMemoryPages}"
        ];

        type = "tmpfs";
        what = "tmpfs";
        where = "/tmp";
      }
    ];

    systemd.tmpfiles.rules = lib.optional cfg.cleanOnBoot "D! /tmp 1777 root root";
  };
}
