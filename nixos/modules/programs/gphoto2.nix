{
  config,
  lib,
  pkgs,
  ...
}:

{
  ###### interface
  options = {
    programs.gphoto2 = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to configure system to use gphoto2.
          To grant digital camera access to a user, the user must
          be part of the camera group:
          `users.users.alice.extraGroups = ["camera"];`
        '';

        type = lib.types.bool;
      };
    };
  };

  ###### implementation
  config = lib.mkIf config.programs.gphoto2.enable {
    environment.systemPackages = [ pkgs.gphoto2 ];
    services.udev.packages = [ pkgs.libgphoto2 ];
    users.groups.camera = { };
  };

  meta.maintainers = [ lib.maintainers.league ];
}
