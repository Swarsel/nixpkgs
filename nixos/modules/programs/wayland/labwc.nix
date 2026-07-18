{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.labwc;
in
{
  options.programs.labwc = {
    enable = lib.mkEnableOption "labwc";
    package = lib.mkPackageOption pkgs "labwc" { };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ cfg.package ];
        # To make a labwc session available for certain DMs like SDDM
        services.displayManager.sessionPackages = [ cfg.package ];

        xdg.portal.config.wlroots.default = lib.mkDefault [
          "wlr"
          "gtk"
        ];
      }
      (import ./wayland-session.nix { inherit lib pkgs; })
    ]
  );

  meta.maintainers = [ ];
}
