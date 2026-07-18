{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.boot.loader.external;
in
{
  options.boot.loader.external = {
    enable = mkEnableOption "using an external tool to install your bootloader";

    installHook = mkOption {
      description = ''
        The full path to a program of your choosing which performs the bootloader installation process.

        The program will be called with an argument pointing to the output of the system's toplevel.
      '';

      type = with types; path;
    };
  };

  config = mkIf cfg.enable {
    boot.loader = {
      grub.enable = mkDefault false;
      supportsInitrdSecrets = mkDefault false;
      systemd-boot.enable = mkDefault false;
    };

    system.build.installBootLoader = cfg.installHook;
  };

  meta = {
    doc = ./external.md;

    maintainers = with maintainers; [
      cole-h
      raitobezarius
    ];
  };
}
