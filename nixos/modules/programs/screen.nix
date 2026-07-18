{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.screen;
in

{
  options = {
    programs.screen = {
      enable = lib.mkEnableOption "screen, a basic terminal multiplexer";
      package = lib.mkPackageOption pkgs "screen" { };

      screenrc = lib.mkOption {
        default = "";
        description = "The contents of {file}`/etc/screenrc` file";

        example = ''
          defscrollback 10000
          startup_message off
        '';

        type = lib.types.lines;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.etc.screenrc = {
        text = cfg.screenrc;
      };

      environment.systemPackages = [ cfg.package ];
      security.pam.services.screen = { };
    })
  ];
}
