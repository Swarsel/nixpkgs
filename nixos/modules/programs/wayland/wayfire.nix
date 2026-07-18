{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wayfire;
in
{
  options.programs.wayfire = {
    enable = lib.mkEnableOption "Wayfire, a wayland compositor based on wlroots";
    package = lib.mkPackageOption pkgs "wayfire" { };

    plugins = lib.mkOption {
      default = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
      ];

      defaultText = lib.literalExpression "with pkgs.wayfirePlugins; [ wcm wf-shell ]";

      description = ''
        Additional plugins to use with the wayfire window manager.
      '';

      example = lib.literalExpression ''
        with pkgs.wayfirePlugins; [
          wcm
          wf-shell
          wayfire-plugins-extra
        ];
      '';

      type = lib.types.listOf lib.types.package;
    };

    xwayland.enable = lib.mkEnableOption "XWayland" // {
      default = true;
    };
  };

  config =
    let
      finalPackage = pkgs.wayfire-with-plugins.override {
        plugins = cfg.plugins;
        wayfire = cfg.package;
      };
    in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          environment.systemPackages = [ finalPackage ];
          services.displayManager.sessionPackages = [ finalPackage ];

          xdg.portal = {
            # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1050914
            config.wayfire.default = lib.mkDefault [
              "wlr"
              "gtk"
            ];

            enable = lib.mkDefault true;
            wlr.enable = lib.mkDefault true;
          };
        }
        (import ./wayland-session.nix {
          inherit lib pkgs;
          enableXWayland = cfg.xwayland.enable;
        })
      ]
    );

  meta.maintainers = with lib.maintainers; [ wineee ];
}
