{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.wmderland;
in

{
  options.services.xserver.windowManager.wmderland = {
    enable = mkEnableOption "wmderland";

    extraPackages = mkOption {
      default = with pkgs; [
        rofi
        dunst
        light
        hsetroot
        feh
        rxvt-unicode
      ];

      defaultText = literalExpression ''
        with pkgs; [
          rofi
          dunst
          light
          hsetroot
          feh
          rxvt-unicode
        ]
      '';

      description = ''
        Extra packages to be installed system wide.
      '';

      type = with types; listOf package;
    };

    extraSessionCommands = mkOption {
      default = "";

      description = ''
        Shell commands executed just before wmderland is started.
      '';

      type = types.lines;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wmderland
      pkgs.wmderlandc
    ]
    ++ cfg.extraPackages;

    services.xserver.windowManager.session = singleton {
      name = "wmderland";

      start = ''
        ${cfg.extraSessionCommands}

        ${pkgs.wmderland}/bin/wmderland &
        waitPID=$!
      '';
    };
  };
}
