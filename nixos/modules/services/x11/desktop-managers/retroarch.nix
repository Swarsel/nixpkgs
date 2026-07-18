{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.desktopManager.retroarch;

in
{
  options.services.xserver.desktopManager.retroarch = {
    enable = mkEnableOption "RetroArch";

    package = mkPackageOption pkgs "retroarch" {
      example = "retroarch-full";
    };

    extraArgs = mkOption {
      default = [ ];
      description = "Extra arguments to pass to RetroArch.";

      example = [
        "--verbose"
        "--host"
      ];

      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.xserver.desktopManager.session = [
      {
        name = "RetroArch";

        start = ''
          ${cfg.package}/bin/retroarch -f ${escapeShellArgs cfg.extraArgs} &
          waitPID=$!
        '';
      }
    ];
  };

  meta.maintainers = with maintainers; [ j0hax ];
}
