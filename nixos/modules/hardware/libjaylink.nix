{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.libjaylink;
in
{
  options.hardware.libjaylink = {
    enable = lib.mkEnableOption ''
      udev rules for devices supported by libjaylink.
      Add users to the `jlink` group in order to grant
      them access
    '';

    package = lib.mkPackageOption pkgs "libjaylink" { };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ cfg.package ];
    users.groups.jlink = { };
  };

  meta.maintainers = with lib.maintainers; [ felixsinger ];
}
