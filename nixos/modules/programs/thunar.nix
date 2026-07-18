{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.thunar;

in
{
  options = {
    programs.thunar = {
      enable = lib.mkEnableOption "Thunar, the Xfce file manager";

      plugins = lib.mkOption {
        default = [ ];
        description = "List of thunar plugins to install.";
        example = lib.literalExpression "with pkgs; [ thunar-archive-plugin thunar-volman ]";
        type = lib.types.listOf lib.types.package;
      };

    };
  };

  config = lib.mkIf cfg.enable (
    let
      package = pkgs.thunar.override { thunarPlugins = cfg.plugins; };

    in
    {
      environment.systemPackages = [
        package
      ];

      programs.xfconf.enable = true;

      services.dbus.packages = [
        package
      ];

      systemd.packages = [
        package
      ];
    }
  );

  meta = {
    teams = [ lib.teams.xfce ];
  };
}
