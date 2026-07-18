{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.arp-scan;
in
{
  options = {
    programs.arp-scan = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to configure a setcap wrapper for arp-scan.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.arp-scan = {
      capabilities = "cap_net_raw+p";
      group = "root";
      owner = "root";
      source = lib.getExe pkgs.arp-scan;
    };
  };
}
