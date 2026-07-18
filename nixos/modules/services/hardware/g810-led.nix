{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.g810-led;
in
{
  options = {
    services.g810-led = {
      enable = lib.mkEnableOption "g810-led, a Linux LED controller for some Logitech G Keyboards";
      package = lib.mkPackageOption pkgs "g810-led" { };
      earlySetup = lib.mkEnableOption "g810-led in early stage initrd";

      profile = lib.mkOption {
        default = null;

        description = ''
          Keyboard profile to apply at boot time.

          The upstream repository provides [example configurations](https://github.com/MatMoul/g810-led/tree/master/sample_profiles).
        '';

        example = ''
          # G810-LED Profile (turn all keys on)

          # Set all keys on
          a ffffff

          # Commit changes
          c
        '';

        type = lib.types.nullOr lib.types.lines;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd = lib.mkIf (cfg.earlySetup && cfg.profile != null) {
      services.udev.binPackages = [ cfg.package ];
      services.udev.packages = [ cfg.package ];

      systemd.contents = {
        "/etc/g810-led/profile".text = cfg.profile;
      };
    };

    environment.etc."g810-led/profile".text = lib.mkIf (cfg.profile != null) cfg.profile;
    services.udev.packages = [ cfg.package ];
  };

  meta.maintainers = with lib.maintainers; [ GaetanLepage ];
}
