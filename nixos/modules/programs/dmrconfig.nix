{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dmrconfig;

in
{
  ###### interface
  options = {
    programs.dmrconfig = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to configure system to enable use of dmrconfig. This
          enables the required udev rules and installs the program.
        '';

        relatedPackages = [ "dmrconfig" ];
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "dmrconfig" { };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
  };

  meta.maintainers = [ ];
}
