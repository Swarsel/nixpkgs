{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.extra-container;
in
{
  options = {
    programs.extra-container.enable = lib.mkEnableOption ''
      extra-container, a tool for running declarative NixOS containers
      without host system rebuilds
    '';
  };

  config = lib.mkIf cfg.enable {
    boot.extraSystemdUnitPaths = [ "/etc/systemd-mutable/system" ];
    environment.systemPackages = [ pkgs.extra-container ];
  };
}
