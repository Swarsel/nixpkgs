{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xbanish;

in
{
  options.services.xbanish = {

    enable = mkEnableOption "xbanish";

    arguments = mkOption {
      default = "";
      description = "Arguments to pass to xbanish command";
      example = "-d -i shift";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.xbanish = {
      description = "xbanish hides the mouse pointer";
      partOf = [ "graphical-session.target" ];

      serviceConfig.ExecStart = ''
        ${pkgs.xbanish}/bin/xbanish ${cfg.arguments}
      '';

      serviceConfig.Restart = "always";
      wantedBy = [ "graphical-session.target" ];
    };
  };
}
