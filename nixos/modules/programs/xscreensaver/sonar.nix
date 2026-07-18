{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.xscreensaver.sonar;
  globalCfg = config.programs.xscreensaver;
in
{
  options.programs.xscreensaver.sonar = {
    enable = lib.mkEnableOption "xscreensaver";
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.sonar = {
      capabilities = "cap_net_raw+ep";
      group = "root";
      owner = "root";

      source = pkgs.writeShellScript "sonar-fakeroot" ''
        exec ${lib.getExe pkgs.fakeroot} ${globalCfg.package}/libexec/xscreensaver/sonar "$@"
      '';
    };
  };
}
