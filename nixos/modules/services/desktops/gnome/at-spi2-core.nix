# at-spi2-core daemon.

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {

    services.gnome.at-spi2-core = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable at-spi2-core, a service for the Assistive Technologies
          available on the GNOME platform.

          Enable this if you get the error or warning
          `The name org.a11y.Bus was not provided by any .service files`.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation
  config = lib.mkMerge [
    (lib.mkIf config.services.gnome.at-spi2-core.enable {
      environment.systemPackages = [ pkgs.at-spi2-core ];
      services.dbus.packages = [ pkgs.at-spi2-core ];
      systemd.packages = [ pkgs.at-spi2-core ];
    })

    (lib.mkIf (!config.services.gnome.at-spi2-core.enable) {
      environment.sessionVariables = {
        GTK_A11Y = "none";
        NO_AT_BRIDGE = "1";
      };
    })
  ];

  meta = {
    teams = [ lib.teams.gnome ];
  };
}
