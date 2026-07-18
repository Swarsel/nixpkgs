{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.mtr;

in
{
  options = {
    programs.mtr = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to add mtr to the global environment and configure a
          setcap wrapper for it.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "mtr" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.mtr-packet = {
      capabilities = "cap_net_raw+p";
      group = "root";
      owner = "root";
      source = "${cfg.package}/bin/mtr-packet";
    };
  };
}
