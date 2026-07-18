{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (lib.mkRenamedOptionModule
      [
        "services"
        "gnome"
        "tracker-miners"
        "enable"
      ]
      [
        "services"
        "gnome"
        "localsearch"
        "enable"
      ]
    )
  ];

  options = {
    services.gnome.localsearch = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable LocalSearch, indexing services for TinySPARQL
          search engine and metadata storage system.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf config.services.gnome.localsearch.enable {
    environment.systemPackages = [ pkgs.localsearch ];
    services.dbus.packages = [ pkgs.localsearch ];
    systemd.packages = [ pkgs.localsearch ];
  };

  meta = {
    teams = [ lib.teams.gnome ];
  };
}
