{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.traceroute;
in
{
  options = {
    programs.traceroute = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to configure a setcap wrapper for traceroute.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.traceroute = {
      capabilities = "cap_net_raw+p";
      group = "root";
      owner = "root";
      source = lib.getExe pkgs.traceroute;
    };
  };
}
