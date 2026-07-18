{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hardware.openrgb;
in
{
  options.services.hardware.openrgb = {
    enable = lib.mkEnableOption "OpenRGB server, for RGB lighting control";
    package = lib.mkPackageOption pkgs "openrgb" { };

    motherboard = lib.mkOption {
      default =
        if config.hardware.cpu.intel.updateMicrocode then
          "intel"
        else if config.hardware.cpu.amd.updateMicrocode then
          "amd"
        else
          null;

      defaultText = lib.literalMD ''
        if config.hardware.cpu.intel.updateMicrocode then "intel"
        else if config.hardware.cpu.amd.updateMicrocode then "amd"
        else null;
      '';

      description = "CPU family of motherboard. Allows for addition motherboard i2c support.";

      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
        ]
      );
    };

    server.port = lib.mkOption {
      default = 6742;
      description = "Set server port of openrgb.";
      type = lib.types.port;
    };

    startupProfile = lib.mkOption {
      default = null;
      description = "The profile file to load from \"/var/lib/OpenRGB\" at startup.";
      type = lib.types.nullOr (lib.types.str);
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [
      "i2c-dev"
    ]
    ++ lib.optionals (cfg.motherboard == "amd") [ "i2c-piix4" ]
    ++ lib.optionals (cfg.motherboard == "intel") [ "i2c-i801" ];

    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];

    systemd.services.openrgb = {
      after = [
        "network.target"
        "lm_sensors.service"
      ];

      description = "OpenRGB SDK Server";

      serviceConfig = {
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "--server"
            "--server-port"
            cfg.server.port
          ]
          ++ lib.optionals (lib.isString cfg.startupProfile) [
            "--profile"
            cfg.startupProfile
          ]
        );

        Restart = "always";
        StateDirectory = "OpenRGB";
        WorkingDirectory = "/var/lib/OpenRGB";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "dev-usb.device" ];
    };
  };

  meta.maintainers = [ ];
}
