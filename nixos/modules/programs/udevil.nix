{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.udevil;

in
{
  options.programs.udevil.enable = lib.mkEnableOption "udevil, to mount filesystems without password";

  config = lib.mkIf cfg.enable {
    security.wrappers.udevil = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${lib.getBin pkgs.udevil}/bin/udevil";
    };
  };
}
