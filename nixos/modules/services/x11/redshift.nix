{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.redshift;
  lcfg = config.location;

in
{

  imports = [
    (mkChangedOptionModule [ "services" "redshift" "latitude" ] [ "location" "latitude" ] (
      config:
      let
        value = getAttrFromPath [ "services" "redshift" "latitude" ] config;
      in
      if value == null then
        throw "services.redshift.latitude is set to null, you can remove this"
      else
        builtins.fromJSON value
    ))
    (mkChangedOptionModule [ "services" "redshift" "longitude" ] [ "location" "longitude" ] (
      config:
      let
        value = getAttrFromPath [ "services" "redshift" "longitude" ] config;
      in
      if value == null then
        throw "services.redshift.longitude is set to null, you can remove this"
      else
        builtins.fromJSON value
    ))
    (mkRenamedOptionModule [ "services" "redshift" "provider" ] [ "location" "provider" ])
  ];

  options.services.redshift = {
    enable = mkOption {
      default = false;

      description = ''
        Enable Redshift to change your screen's colour temperature depending on
        the time of day.
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "redshift" { };

    brightness = {
      day = mkOption {
        default = "1";

        description = ''
          Screen brightness to apply during the day,
          between `0.1` and `1.0`.
        '';

        type = types.str;
      };

      night = mkOption {
        default = "1";

        description = ''
          Screen brightness to apply during the night,
          between `0.1` and `1.0`.
        '';

        type = types.str;
      };
    };

    executable = mkOption {
      default = "/bin/redshift";

      description = ''
        Redshift executable to use within the package.
      '';

      example = "/bin/redshift-gtk";
      type = types.str;
    };

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Additional command-line arguments to pass to
        {command}`redshift`.
      '';

      example = [
        "-v"
        "-m randr"
      ];

      type = types.listOf types.str;
    };

    temperature = {
      day = mkOption {
        default = 5500;

        description = ''
          Colour temperature to use during the day, between
          `1000` and `25000` K.
        '';

        type = types.ints.between 1000 25000;
      };

      night = mkOption {
        default = 3700;

        description = ''
          Colour temperature to use at night, between
          `1000` and `25000` K.
        '';

        type = types.ints.between 1000 25000;
      };
    };
  };

  config = mkIf cfg.enable {
    # needed so that .desktop files are installed, which geoclue cares about
    environment.systemPackages = [ cfg.package ];

    services.geoclue2.appConfig.redshift = {
      isAllowed = true;
      isSystem = true;
    };

    systemd.user.services.redshift =
      let
        providerString =
          if lcfg.provider == "manual" then
            "${toString lcfg.latitude}:${toString lcfg.longitude}"
          else
            lcfg.provider;
      in
      {
        description = "Redshift colour temperature adjuster";
        partOf = [ "graphical-session.target" ];

        serviceConfig = {
          ExecStart = ''
            ${cfg.package}${cfg.executable} \
              -l ${providerString} \
              -t ${toString cfg.temperature.day}:${toString cfg.temperature.night} \
              -b ${toString cfg.brightness.day}:${toString cfg.brightness.night} \
              ${lib.strings.concatStringsSep " " cfg.extraOptions}
          '';

          Restart = "always";
          RestartSec = 3;
        };

        wantedBy = [ "graphical-session.target" ];
      };
  };

}
