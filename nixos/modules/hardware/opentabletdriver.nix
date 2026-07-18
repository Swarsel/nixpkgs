{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.opentabletdriver;
in
{
  options = {
    hardware.opentabletdriver = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable OpenTabletDriver udev rules, user service and blacklist kernel
          modules known to conflict with OpenTabletDriver.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "opentabletdriver" { };

      blacklistedKernelModules = lib.mkOption {
        default = [
          "hid-uclogic"
          "wacom"
        ];

        description = ''
          Blacklist of kernel modules known to conflict with OpenTabletDriver.
        '';

        type = lib.types.listOf lib.types.str;
      };

      daemon = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Whether to start OpenTabletDriver daemon as a systemd user service.
          '';

          type = lib.types.bool;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.blacklistedKernelModules = cfg.blacklistedKernelModules;
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];

    systemd.user.services.opentabletdriver = lib.mkIf cfg.daemon.enable {
      description = "Open source, cross-platform, user-mode tablet driver";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = lib.getExe' cfg.package "otd-daemon";

        # workaround for https://github.com/NixOS/nixpkgs/issues/469340
        ExecStartPre = pkgs.writeShellScript "disable-for-gdm-greeter" ''
          if [[ "$USER" = "gdm-greeter"* ]]; then
            exit 1
          fi
        '';

        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    gepbird
    thiagokokada
  ];
}
