{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.noisetorch;
in
{
  options.programs.noisetorch = {
    enable = lib.mkEnableOption "noisetorch (+ setcap wrapper), a virtual microphone device with noise suppression";
    package = lib.mkPackageOption pkgs "noisetorch" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.noisetorch = {
      capabilities = "cap_sys_resource=+ep";
      group = "root";
      owner = "root";
      source = "${cfg.package}/bin/noisetorch";
    };
  };
}
