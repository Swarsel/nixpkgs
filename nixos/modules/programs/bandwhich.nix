{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.bandwhich;
in
{

  options = {
    programs.bandwhich = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to add bandwhich to the global environment and configure a
          setcap wrapper for it.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ bandwhich ];

    security.wrappers.bandwhich = {
      capabilities = "cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep";
      group = "root";
      owner = "root";
      source = "${pkgs.bandwhich}/bin/bandwhich";
    };
  };
}
