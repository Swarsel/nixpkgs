{ config, lib, ... }:
let
  cfg = config.hardware.ksm;

in
{
  imports = [
    (lib.mkRenamedOptionModule [ "hardware" "enableKSM" ] [ "hardware" "ksm" "enable" ])
  ];

  options.hardware.ksm = {
    enable = lib.mkEnableOption "Linux kernel Same-Page Merging";

    sleep = lib.mkOption {
      default = null;

      description = ''
        How many milliseconds ksmd should sleep between scans.
        Setting it to `null` uses the kernel's default time.
      '';

      type = lib.types.nullOr lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.enable-ksm = {
      description = "Enable Kernel Same-Page Merging";

      script = ''
        echo 1 > /sys/kernel/mm/ksm/run
      ''
      + lib.optionalString (cfg.sleep != null) ''
        echo ${toString cfg.sleep} > /sys/kernel/mm/ksm/sleep_millisecs
      '';

      wantedBy = [ "multi-user.target" ];
    };
  };
}
