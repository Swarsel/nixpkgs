{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "dleyna-server" ] [ "services" "dleyna" ])
    (lib.mkRenamedOptionModule [ "services" "dleyna-renderer" ] [ "services" "dleyna" ])
  ];

  ###### interface
  options = {
    services.dleyna = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable dleyna-renderer and dleyna-server service,
          a DBus service for handling DLNA servers and renderers.
        '';

        type = lib.types.bool;
      };
    };
  };

  ###### implementation
  config = lib.mkIf config.services.dleyna.enable {
    environment.systemPackages = [ pkgs.dleyna ];
    services.dbus.packages = [ pkgs.dleyna ];
  };
}
