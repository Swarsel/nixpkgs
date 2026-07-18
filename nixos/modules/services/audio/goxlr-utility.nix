{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.goxlr-utility;
in
{

  options = {
    services.goxlr-utility = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable goxlr-utility for controlling your TC-Helicon GoXLR or GoXLR Mini
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "goxlr-utility" { };

      autoStart.xdg = lib.mkOption {
        default = true;

        description = ''
          Start the daemon automatically using XDG autostart.
          Sets `xdg.autostart.enable = true` if not already enabled.
        '';

        type = with lib.types; bool;
      };
    };
  };

  config =
    let
      goxlr-autostart = pkgs.stdenv.mkDerivation {
        buildCommand = ''
          mkdir -p $out/etc/xdg/autostart
          cp ${cfg.package}/share/applications/goxlr-utility.desktop $out/etc/xdg/autostart/goxlr-daemon.desktop
          chmod +w $out/etc/xdg/autostart/goxlr-daemon.desktop
          echo "X-KDE-autostart-phase=2" >> $out/etc/xdg/autostart/goxlr-daemon.desktop
          substituteInPlace $out/etc/xdg/autostart/goxlr-daemon.desktop \
            --replace-fail goxlr-launcher goxlr-daemon
        '';

        name = "autostart-goxlr-daemon";
        priority = 5;
      };
    in
    lib.mkIf config.services.goxlr-utility.enable {
      environment.systemPackages = lib.mkIf cfg.autoStart.xdg [
        cfg.package
        goxlr-autostart
      ];

      services.udev.packages = [ cfg.package ];
      xdg.autostart.enable = lib.mkIf cfg.autoStart.xdg true;
    };

  meta.maintainers = with lib.maintainers; [ errnoh ];
}
