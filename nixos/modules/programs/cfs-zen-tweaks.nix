# CFS Zen Tweaks

{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.programs.cfs-zen-tweaks;

in

{

  options = {
    programs.cfs-zen-tweaks.enable = lib.mkEnableOption "CFS Zen Tweaks";
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ pkgs.cfs-zen-tweaks ];

    systemd.services.set-cfs-tweaks.wantedBy = [
      "multi-user.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
  };

  meta = {
    maintainers = with lib.maintainers; [ mkg20001 ];
  };
}
