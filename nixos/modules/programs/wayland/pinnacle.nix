{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pinnacle;
  inherit (lib.options) mkEnableOption mkPackageOption;
in
{
  options.programs.pinnacle = {
    enable = mkEnableOption "pinnacle";

    package = mkPackageOption pkgs "pinnacle" {
      default = "pinnacle";
      example = "pkgs.pinnacle";
      extraDescription = "package containing the pinnacle server binary";
    };

    withUWSM = mkEnableOption ''
      manage the pinnacle session with [UWSM](https://github.com/Vladimir-csp/uwsm) instead
      of independent systemd services and targets.
    '';

    xdg-portals.enable = mkEnableOption "enable xdg-portals for pinnacle";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.pathsToLink = [
          # For /run/current-system/sw/share/pinnacle protobuf files - for
          # pinnacle to be able to launch with a non-default config out of the
          # box.
          "/share/pinnacle"
        ];

        environment.systemPackages = [
          cfg.package
          pkgs.protobuf
          cfg.package.lua-client-api
        ];

        xdg.portal = lib.mkIf cfg.xdg-portals.enable {
          enable = true;
          configPackages = [ cfg.package ];

          extraPortals = [
            pkgs.xdg-desktop-portal-wlr
            pkgs.xdg-desktop-portal-gtk
            pkgs.gnome-keyring
          ];

          wlr.enable = true;
        };
      }
      (lib.mkIf (cfg.withUWSM) {
        programs.uwsm.enable = true;

        # Configure UWSM to launch Pinnacle from a display manager like SDDM
        programs.uwsm.waylandCompositors = {
          pinnacle = {
            binPath = "/run/current-system/sw/bin/pinnacle";
            comment = "Pinnacle compositor managed by UWSM";
            extraArgs = [ "--session" ];
            prettyName = "Pinnacle";
          };
        };
      })
      (lib.mkIf (!cfg.withUWSM) {
        services.displayManager.sessionPackages = [ cfg.package ];
      })
    ]
  );

  meta.maintainers = with lib.maintainers; [ cassandracomar ];
}
