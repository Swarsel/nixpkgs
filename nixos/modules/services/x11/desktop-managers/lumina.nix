{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  xcfg = config.services.xserver;
  cfg = xcfg.desktopManager.lumina;

in

{
  options = {

    services.xserver.desktopManager.lumina.enable = mkOption {
      default = false;
      description = "Enable the Lumina desktop manager";
      type = types.bool;
    };

  };

  config = mkIf cfg.enable {

    # Link some extra directories in /run/current-system/software/share
    environment.pathsToLink = [
      "/share/lumina"
      # FIXME: modules should link subdirs of `/share` rather than relying on this
      "/share"
    ];

    environment.systemPackages = pkgs.lumina.preRequisitePackages ++ pkgs.lumina.corePackages;

    services.displayManager.sessionPackages = [
      pkgs.lumina.lumina
    ];

  };

  meta = {
    teams = [ teams.lumina ];
  };
}
