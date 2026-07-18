{
  config,
  lib,
  pkgs,
  ...
}:
let

  tzdir = "${pkgs.tzdata}/share/zoneinfo";
  nospace = str: lib.filter (c: c == " ") (lib.stringToCharacters str) == [ ];
  timezone = lib.types.nullOr (lib.types.addCheck lib.types.str nospace) // {
    description = "null or string without spaces";
  };

  lcfg = config.location;

in

{
  options = {

    location = {

      latitude = lib.mkOption {
        description = ''
          Your current latitude, between
          `-90.0` and `90.0`. Must be provided
          along with longitude.
        '';

        type = lib.types.float;
      };

      longitude = lib.mkOption {
        description = ''
          Your current longitude, between
          between `-180.0` and `180.0`. Must be
          provided along with latitude.
        '';

        type = lib.types.float;
      };

      provider = lib.mkOption {
        default = "manual";

        description = ''
          The location provider to use for determining your location. If set to
          `manual` you must also provide latitude/longitude.
        '';

        type = lib.types.enum [
          "manual"
          "geoclue2"
        ];
      };

    };

    time = {

      hardwareClockInLocalTime = lib.mkOption {
        default = false;
        description = "If set, keep the hardware clock in local time instead of UTC.";
        type = lib.types.bool;
      };

      timeZone = lib.mkOption {
        default = null;

        description = ''
          The time zone used when displaying times and dates. See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
          for a comprehensive list of possible values for this setting.

          If null, the timezone will default to UTC and can be set imperatively
          using timedatectl.
        '';

        example = "America/New_York";
        type = timezone;
      };

    };
  };

  config = {

    environment.etc = {
      zoneinfo.source = tzdir;
    }
    // lib.optionalAttrs (config.time.timeZone != null) {
      localtime.mode = "direct-symlink";
      localtime.source = "/etc/zoneinfo/${config.time.timeZone}";
    }
    // lib.optionalAttrs config.time.hardwareClockInLocalTime {
      # Mirrors timedated
      # https://github.com/systemd/systemd/blob/afaca649ad678031a46182b0cce667cbbbf47a6d/src/timedate/timedated.c#L325-L396
      adjtime.text = ''
        0.0 0 0
        0
        LOCAL
      '';
    };

    environment.sessionVariables.TZDIR = "/etc/zoneinfo";
    services.geoclue2.enable = lib.mkIf (lcfg.provider == "geoclue2") true;
    # This way services are restarted when tzdata changes.
    systemd.globalEnvironment.TZDIR = tzdir;
  };

}
