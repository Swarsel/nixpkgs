{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.a2boot;
in
{
  options.services.a2boot = {
    enable = lib.mkEnableOption "the a2boot daemon";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.a2boot = {
      after = [
        "network.target"
        "netatalk.service"
      ];

      description = "a2boot daemon";
      path = [ pkgs.netatalk ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.netatalk}/bin/a2boot";
        Restart = "always";
        RuntimeDirectory = "a2boot";
        Type = "forking";
      };

      unitConfig.Documentation = "man:a2boot(8)";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.netatalk.partOf = [ "a2boot.service" ];
  };

  meta.maintainers = with lib.maintainers; [ matthewcroughan ];
}
