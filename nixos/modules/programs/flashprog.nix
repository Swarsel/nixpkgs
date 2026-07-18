{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.flashprog;
in
{
  options.programs.flashprog = {
    enable = lib.mkEnableOption ''
      configuring flashprog udev rules and
      installing flashprog as system package
    '';

    package = lib.mkPackageOption pkgs "flashprog" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    hardware.libftdi.enable = true;
    hardware.libjaylink.enable = true;
    services.udev.packages = [ cfg.package ];
  };

  meta.maintainers = with lib.maintainers; [ felixsinger ];
}
