{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hardware.argonone;
in
{
  options.services.hardware.argonone = {
    enable = lib.mkEnableOption "the driver for Argon One Raspberry Pi case fan and power button";
    package = lib.mkPackageOption pkgs "argononed" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    hardware.deviceTree.overlays = [
      {
        dtboFile = "${cfg.package}/boot/overlays/argonone.dtbo";
        name = "argononed";
      }
      {
        dtsText = ''
          /dts-v1/;
          /plugin/;
          / {
            compatible = "brcm,bcm2711";
            fragment@0 {
              target = <&i2c1>;
              __overlay__ {
                status = "okay";
              };
            };
          };
        '';

        name = "i2c1-okay-overlay";
      }
    ];

    hardware.i2c.enable = true;

    systemd.services.argononed = {
      description = "Argon One Raspberry Pi case Daemon Service";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/argononed";
        PIDFile = "/run/argononed.pid";
        Restart = "on-failure";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ misterio77 ];

}
