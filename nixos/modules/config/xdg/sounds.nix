{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    xdg.sounds.enable = lib.mkOption {
      default = true;

      description = ''
        Whether to install files to support the
        [XDG Sound Theme specification](https://www.freedesktop.org/wiki/Specifications/sound-theme-spec/).
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.xdg.sounds.enable {
    environment.pathsToLink = [
      "/share/sounds"
    ];

    environment.systemPackages = [
      pkgs.sound-theme-freedesktop
    ];
  };

  meta = {
    teams = [ lib.teams.freedesktop ];
  };

}
