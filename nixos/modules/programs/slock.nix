{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.slock;

in
{
  options = {
    programs.slock = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to install slock screen locker with setuid wrapper.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "slock" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.slock = {
      group = "root";
      owner = "root";
      setuid = true;
      source = lib.getExe cfg.package;
    };
  };
}
