{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.wavemon;
in
{
  options = {
    programs.wavemon = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to add wavemon to the global environment and configure a
          setcap wrapper for it.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ wavemon ];

    security.wrappers.wavemon = {
      capabilities = "cap_net_admin+ep";
      group = "root";
      owner = "root";
      source = "${pkgs.wavemon}/bin/wavemon";
    };
  };
}
