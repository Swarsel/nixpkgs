{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.tuxedo-rs;

in
{
  options = {
    hardware.tuxedo-rs = {
      enable = lib.mkEnableOption "Rust utilities for interacting with hardware from TUXEDO Computers";
      tailor-gui.enable = lib.mkEnableOption "tailor-gui, an alternative to TUXEDO Control Center, written in Rust";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ pkgs.tuxedo-rs ];
        hardware.tuxedo-drivers.enable = true;
        services.dbus.packages = [ pkgs.tuxedo-rs ];

        systemd = {
          services.tailord = {
            enable = true;
            after = [ "systemd-logind.service" ];
            description = "Tuxedo Tailor hardware control service";

            serviceConfig = {
              BusName = "com.tux.Tailor";
              Environment = "RUST_BACKTRACE=1";
              ExecStart = "${pkgs.tuxedo-rs}/bin/tailord";
              Restart = "on-failure";
              Type = "dbus";
            };

            wantedBy = [ "multi-user.target" ];
          };
        };
      }
      (lib.mkIf cfg.tailor-gui.enable {
        environment.systemPackages = [ pkgs.tailor-gui ];
      })
    ]
  );

  meta.maintainers = with lib.maintainers; [
    xaverdh
  ];
}
