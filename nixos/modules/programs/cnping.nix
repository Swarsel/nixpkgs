{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cnping;
in
{
  options = {
    programs.cnping = {
      enable = lib.mkEnableOption "a setcap wrapper for cnping";
    };
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.cnping = {
      capabilities = "cap_net_raw+ep";
      group = "root";
      owner = "root";
      source = "${pkgs.cnping}/bin/cnping";
    };
  };
}
