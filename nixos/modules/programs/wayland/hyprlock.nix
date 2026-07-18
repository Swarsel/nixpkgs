{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.hyprlock;
in
{
  options.programs.hyprlock = {
    enable = lib.mkEnableOption "hyprlock, Hyprland's GPU-accelerated screen locking utility";
    package = lib.mkPackageOption pkgs "hyprlock" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    # Hyprlock needs PAM access to authenticate, else it fallbacks to su
    security.pam.services.hyprlock = { };
    # Hyprlock needs Hypridle systemd service to be running to detect idle time
    services.hypridle.enable = true;
  };

  meta.teams = [ lib.teams.hyprland ];
}
