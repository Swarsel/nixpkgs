# Evolution Data Server daemon.

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface
  options = {

    programs.evolution = {
      enable = lib.mkEnableOption "Evolution, a Personal information management application that provides integrated mail, calendaring and address book functionality";

      plugins = lib.mkOption {
        default = [ ];
        description = "Plugins for Evolution.";
        example = lib.literalExpression "[ pkgs.evolution-ews ]";
        type = lib.types.listOf lib.types.package;
      };

    };

    services.gnome.evolution-data-server = {
      enable = lib.mkEnableOption "Evolution Data Server, a collection of services for storing addressbooks and calendars";

      plugins = lib.mkOption {
        default = [ ];
        description = "Plugins for Evolution Data Server.";
        type = lib.types.listOf lib.types.package;
      };
    };
  };

  ###### implementation
  config =
    let
      bundle = pkgs.evolutionWithPlugins.override {
        inherit (config.services.gnome.evolution-data-server) plugins;
      };
    in
    lib.mkMerge [
      (lib.mkIf config.services.gnome.evolution-data-server.enable {
        environment.systemPackages = [ bundle ];
        services.dbus.packages = [ bundle ];
        systemd.packages = [ bundle ];
      })
      (lib.mkIf config.programs.evolution.enable {
        services.gnome.evolution-data-server = {
          enable = true;
          plugins = [ pkgs.evolution ] ++ config.programs.evolution.plugins;
        };

        services.gnome.gnome-keyring.enable = true;
      })
    ];

  meta = {
    teams = [ lib.teams.gnome ];
  };
}
