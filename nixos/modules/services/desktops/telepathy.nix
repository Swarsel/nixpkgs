# Telepathy daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
{

  ###### interface
  options = {

    services.telepathy = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable Telepathy service, a communications framework
          that enables real-time communication via pluggable protocol backends.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation
  config = lib.mkIf config.services.telepathy.enable {

    environment.systemPackages = [ pkgs.telepathy-mission-control ];
    services.dbus.packages = [ pkgs.telepathy-mission-control ];
  };

  meta = {
    maintainers = [ ];
  };

}
