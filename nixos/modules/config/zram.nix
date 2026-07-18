{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.zramSwap;
  devices = map (nr: "zram${toString nr}") (lib.range 0 (cfg.swapDevices - 1));

in

{

  imports = [
    (lib.mkRemovedOptionModule [
      "zramSwap"
      "numDevices"
    ] "Using ZRAM devices as general purpose ephemeral block devices is no longer supported")
  ];

  ###### interface

  options = {

    zramSwap = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable in-memory compressed devices and swap space provided by the zram
          kernel module.
          See [
            https://www.kernel.org/doc/Documentation/blockdev/zram.txt
          ](https://www.kernel.org/doc/Documentation/blockdev/zram.txt).
        '';

        type = lib.types.bool;
      };

      algorithm = lib.mkOption {
        default = "zstd";

        description = ''
          Compression algorithm. `lzo` has good compression,
          but is slow. `lz4` has bad compression, but is fast.
          `zstd` is both good compression and fast, but requires newer kernel.
          You can check what other algorithms are supported by your zram device with
          {command}`cat /sys/class/block/zram*/comp_algorithm`
        '';

        example = "lz4";

        type =
          with lib.types;
          either (enum [
            "842"
            "lzo"
            "lzo-rle"
            "lz4"
            "lz4hc"
            "zstd"
          ]) str;
      };

      memoryMax = lib.mkOption {
        default = null;

        description = ''
          Maximum total amount of memory (in bytes) that can be stored in the zram
          swap devices. If set, the smaller one of this option and memoryPercent would
          be used.
          This doesn't define how much memory will be used by the zram swap devices.
        '';

        type = with lib.types; nullOr int;
      };

      memoryPercent = lib.mkOption {
        default = 50;

        description = ''
          Maximum total amount of memory that can be stored in the zram swap devices
          (as a percentage of your total memory). Defaults to 1/2 of your total
          RAM. Run `zramctl` to check how good memory is compressed.
          This doesn't define how much memory will be used by the zram swap devices.
        '';

        type = lib.types.ints.positive;
      };

      priority = lib.mkOption {
        default = 5;

        description = ''
          Priority of the zram swap devices. It should be a number higher than
          the priority of your disk-based swap devices (so that the system will
          fill the zram swap devices before falling back to disk swap).
        '';

        type = lib.types.int;
      };

      swapDevices = lib.mkOption {
        default = 1;

        description = ''
          Number of zram devices to be used as swap, recommended is 1.
        '';

        type = lib.types.int;
      };

      writebackDevice = lib.mkOption {
        default = null;

        description = ''
          Write incompressible pages to this device,
          as there's no gain from keeping them in RAM.
        '';

        example = "/dev/zvol/tarta-zoot/swap-writeback";
        type = lib.types.nullOr lib.types.path;
      };
    };

  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.writebackDevice == null || cfg.swapDevices <= 1;
        message = "A single writeback device cannot be shared among multiple zram devices";
      }
    ];

    services.zram-generator.enable = true;

    services.zram-generator.settings = lib.listToAttrs (
      map (dev: {
        name = dev;

        value =
          let
            size = "${toString cfg.memoryPercent} / 100 * ram";
          in
          {
            compression-algorithm = cfg.algorithm;
            swap-priority = cfg.priority;

            zram-size =
              if cfg.memoryMax != null then "min(${size}, ${toString cfg.memoryMax} / 1024 / 1024)" else size;
          }
          // lib.optionalAttrs (cfg.writebackDevice != null) {
            writeback-device = cfg.writebackDevice;
          };
      }) devices
    );

  };

}
