{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    recursiveUpdate
    optionalAttrs
    ;

  cfg = config.networking.wireless.iwd;
  ini = pkgs.formats.ini { };
  defaults =
    with config.networking.networkmanager;
    optionalAttrs (enable && (wifi.backend == "iwd")) {
      # without DefaultInterface, sometimes wlan0 simply goes AWOL with NetworkManager
      # https://iwd.wiki.kernel.org/interface_lifecycle#interface_management_in_iwd
      DriverQuirks.DefaultInterface = "?*";
    };
  configFile = ini.generate "main.conf" (recursiveUpdate defaults cfg.settings);

in
{
  options.networking.wireless.iwd = {
    enable = mkEnableOption "iwd";
    package = mkPackageOption pkgs "iwd" { };

    settings = mkOption {
      default = { };

      description = ''
        Options passed to iwd.
        See {manpage}`iwd.config(5)` for supported options.
      '';

      example = {
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };

        Settings.AutoConnect = true;
      };

      type = ini.type;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.networking.wireless.enable;

        message = ''
          Only one wireless daemon is allowed at the time: networking.wireless.enable and networking.wireless.iwd.enable are mutually exclusive.
        '';
      }
      {
        assertion = !(cfg.settings ? General && cfg.settings.General ? UseDefaultInterface);

        message = ''
          `networking.wireless.iwd.settings.General.UseDefaultInterface` has been deprecated. Use `networking.wireless.iwd.settings.DriverQuirks.DefaultInterface` instead.
        '';
      }
    ];

    environment.etc."iwd/${configFile.name}".source = configFile;
    # for iwctl
    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];

    systemd.network.links."80-iwd" = {
      linkConfig.NamePolicy = "keep kernel";
      matchConfig.Type = "wlan";
    };

    systemd.packages = [ cfg.package ];

    systemd.services.iwd = {
      path = [ config.networking.resolvconf.package ];
      restartTriggers = [ configFile ];
      serviceConfig.ReadWritePaths = "-/etc/resolv.conf";
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
