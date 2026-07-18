{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.k40-whisperer;
  pkg = cfg.package.override {
    udevGroup = cfg.group;
  };
in
{
  options.programs.k40-whisperer = {
    enable = lib.mkEnableOption "K40-Whisperer";
    package = lib.mkPackageOption pkgs "k40-whisperer" { };

    group = lib.mkOption {
      default = "k40";

      description = ''
        Group assigned to the device when connected.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkg ];
    services.udev.packages = [ pkg ];
    users.groups.${cfg.group} = { };
  };
}
