{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nethoscope;
in
{
  options = {
    programs.nethoscope = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to add nethoscope to the global environment and configure a
          setcap wrapper for it.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ nethoscope ];

    security.wrappers.nethoscope = {
      capabilities = "cap_net_raw,cap_net_admin=eip";
      source = "${pkgs.nethoscope}/bin/nethoscope";
    };
  };

  meta.maintainers = with lib.maintainers; [ _0x4A6F ];
}
