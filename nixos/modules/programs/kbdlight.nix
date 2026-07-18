{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.kbdlight;

in
{
  options.programs.kbdlight.enable = lib.mkEnableOption "kbdlight";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.kbdlight ];

    security.wrappers.kbdlight = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${pkgs.kbdlight.out}/bin/kbdlight";
    };
  };
}
