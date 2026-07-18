{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.playerctld;
in
{
  options.services.playerctld = {
    enable = lib.mkEnableOption "the playerctld daemon";
    package = lib.mkPackageOption pkgs "playerctl" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.playerctld = {
      description = "Playerctld daemon to track media player activity";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/playerctld";
        Type = "exec";
      };

      wantedBy = [ "default.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ aacebedo ];
}
