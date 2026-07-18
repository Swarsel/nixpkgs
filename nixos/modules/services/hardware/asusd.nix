{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.asusd;
in
{
  imports = [
    (lib.mkRemovedOptionModule
      [
        "services"
        "asusd"
        "auraConfig"
      ]
      ''
        This option has been replaced by `services.asusd.auraConfigs' because asusd
        supports multiple aura devices since version 6.0.0.
      ''
    )
    (lib.mkRemovedOptionModule [
      "services"
      "asusd"
      "enableUserService"
    ] "The asusd user service is no longer required.")
  ];

  options = {
    services.asusd =
      with lib.types;
      let
        configType = submodule (
          { source, text, ... }:
          {
            options = {
              source = lib.mkOption {
                default = null;
                description = "Path of the source file.";
                type = nullOr path;
              };

              text = lib.mkOption {
                default = null;
                description = "Text of the file.";
                type = nullOr lines;
              };
            };
          }
        );
      in
      {
        enable = lib.mkEnableOption "the asusd service for ASUS ROG laptops";
        package = lib.mkPackageOption pkgs "asusctl" { };

        animeConfig = lib.mkOption {
          default = null;

          description = ''
            The content of /etc/asusd/anime.ron.
            See <https://asus-linux.org/manual/asusctl-manual/#anime-control>.
          '';

          type = nullOr configType;
        };

        asusdConfig = lib.mkOption {
          default = null;

          description = ''
            The content of /etc/asusd/asusd.ron.
            See <https://asus-linux.org/manual/asusctl-manual/>.
          '';

          type = nullOr configType;
        };

        auraConfigs = lib.mkOption {
          default = { };

          description = ''
            The content of /etc/asusd/aura_<name>.ron.
            See <https://asus-linux.org/manual/asusctl-manual/#led-keyboard-control>.
          '';

          type = attrsOf configType;
        };

        fanCurvesConfig = lib.mkOption {
          default = null;

          description = ''
            The content of /etc/asusd/fan_curves.ron.
            See <https://asus-linux.org/manual/asusctl-manual/#fan-curves>.
          '';

          type = nullOr configType;
        };

        profileConfig = lib.mkOption {
          default = null;

          description = ''
            The content of /etc/asusd/profile.ron.
            See <https://asus-linux.org/manual/asusctl-manual/#profiles>.
          '';

          type = nullOr configType;
        };

        userLedModesConfig = lib.mkOption {
          default = null;

          description = ''
            The content of /etc/asusd/asusd-user-ledmodes.ron.
            See <https://asus-linux.org/manual/asusctl-manual/#led-keyboard-control>.
          '';

          type = nullOr configType;
        };
      };
  };

  config = lib.mkIf cfg.enable {
    environment.etc =
      let
        maybeConfig =
          name: cfg:
          lib.mkIf (cfg != null) (
            (if (cfg.source != null) then { source = cfg.source; } else { text = cfg.text; })
            // {
              mode = "0644";
            }
          );
      in
      {
        "asusd/anime.ron" = maybeConfig "anime.ron" cfg.animeConfig;
        "asusd/asusd.ron" = maybeConfig "asusd.ron" cfg.asusdConfig;
        "asusd/asusd_user_ledmodes.ron" = maybeConfig "asusd_user_ledmodes.ron" cfg.userLedModesConfig;
        "asusd/fan_curves.ron" = maybeConfig "fan_curves.ron" cfg.fanCurvesConfig;
        "asusd/profile.ron" = maybeConfig "profile.ron" cfg.profileConfig;
      }
      // lib.attrsets.concatMapAttrs (prod_id: value: {
        "asusd/aura_${prod_id}.ron" = maybeConfig "aura_${prod_id}.ron" value;
      }) cfg.auraConfigs;

    environment.systemPackages = [ cfg.package ];
    services.dbus.enable = true;
    services.dbus.packages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
  };

  meta.maintainers = pkgs.asusctl.meta.maintainers;
}
