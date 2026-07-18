{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.plotinus;
in
{
  ###### interface
  options = {
    programs.plotinus = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Plotinus GTK 3 plugin. Plotinus provides a
          popup (triggered by Ctrl-Shift-P) to search the menus of a
          compatible application.
        '';

        type = lib.types.bool;
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    environment.sessionVariables.XDG_DATA_DIRS = [
      "${pkgs.plotinus}/share/gsettings-schemas/${pkgs.plotinus.name}"
    ];

    environment.variables.GTK3_MODULES = [ "${pkgs.plotinus}/lib/libplotinus.so" ];
  };

  meta = {
    doc = ./plotinus.md;
    maintainers = pkgs.plotinus.meta.maintainers;
  };
}
