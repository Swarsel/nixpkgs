{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.handheld-daemon;
in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "handheld-daemon"
      "adjustor"
      "package"
    ] "Adjustor is now part of handheld-daemon package, so it can't be overriden")
  ];

  options.services.handheld-daemon = {
    enable = mkEnableOption "Handheld Daemon";
    package = mkPackageOption pkgs "handheld-daemon" { };

    adjustor = {
      enable = mkEnableOption "Handheld Daemon TDP control plugin";

      loadAcpiCallModule = mkOption {
        description = ''
          Whether to load the acpi_call kernel module.
          Required for TDP control by adjustor on most devices.
        '';

        type = types.bool;
      };
    };

    ui = {
      enable = mkEnableOption "Handheld Daemon UI";
      package = mkPackageOption pkgs "handheld-daemon-ui" { };
    };

    user = mkOption {
      description = ''
        The user to run Handheld Daemon with.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = mkIf cfg.adjustor.loadAcpiCallModule [
      config.boot.kernelPackages.acpi_call
    ];

    boot.kernelModules = mkIf cfg.adjustor.loadAcpiCallModule [ "acpi_call" ];

    environment.systemPackages = [
      cfg.package
    ]
    ++ lib.optional cfg.ui.enable cfg.ui.package;

    services.handheld-daemon.adjustor.loadAcpiCallModule = mkDefault cfg.adjustor.enable;
    services.handheld-daemon.ui.enable = mkDefault true;
    services.udev.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.handheld-daemon = {
      description = "Handheld Daemon";

      environment = {
        HHD_ADJ_DISABLE = mkIf (!cfg.adjustor.enable) "1";
      };

      path = mkIf cfg.ui.enable [
        cfg.ui.package
        pkgs.lsof
      ];

      restartIfChanged = true;

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --user ${cfg.user}";
        Nice = "-12";
        Restart = "on-failure";
        RestartSec = "10";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ maintainers.toast ];
}
