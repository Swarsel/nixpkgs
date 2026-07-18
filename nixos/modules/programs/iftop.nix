{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.iftop;
in
{
  options = {
    programs.iftop.enable = lib.mkEnableOption "iftop and setcap wrapper for it";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.iftop ];

    security.wrappers.iftop = {
      capabilities = "cap_net_raw+p";
      group = "root";
      owner = "root";
      source = lib.getExe pkgs.iftop;
    };
  };
}
