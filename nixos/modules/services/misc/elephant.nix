{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.elephant;
in
{
  options.services.elephant = {
    enable = lib.mkEnableOption "Elephant application launcher backend";
    package = lib.mkPackageOption pkgs "elephant" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.elephant = {
      after = [ "graphical-session.target" ];
      description = "Elephant application launcher backend";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/elephant";
        Restart = "always";
        RestartSec = 10;
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    saadndm
  ];
}
