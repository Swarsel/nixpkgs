{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.bcc.enable = lib.mkEnableOption "bcc, tools for BPF-based Linux IO analysis, networking, monitoring, and more";

  config = lib.mkIf config.programs.bcc.enable {
    boot.extraModulePackages = [ pkgs.bcc ];
    environment.systemPackages = [ pkgs.bcc ];
  };
}
