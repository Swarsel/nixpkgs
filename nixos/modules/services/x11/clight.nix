{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.clight;

  toConf =
    v:
    if builtins.isFloat v then
      toString v
    else if isInt v then
      toString v
    else if isBool v then
      boolToString v
    else if isString v then
      ''"${escape [ ''"'' ] v}"''
    else if isList v then
      "[ " + concatMapStringsSep ", " toConf v + " ]"
    else if isAttrs v then
      "\n{\n" + convertAttrs v + "\n}"
    else
      abort "clight.toConf: unexpected type (v = ${v})";

  getSep = v: if isAttrs v then ":" else "=";

  convertAttrs =
    attrs:
    concatStringsSep "\n" (
      mapAttrsToList (name: value: "${toString name} ${getSep value} ${toConf value};") attrs
    );

  clightConf = pkgs.writeText "clight.conf" (
    convertAttrs (filterAttrs (_: value: value != null) cfg.settings)
  );
in
{
  options.services.clight = {
    enable = mkEnableOption "clight";

    settings =
      let
        validConfigTypes =
          with types;
          oneOf [
            int
            str
            bool
            float
          ];
        collectionTypes =
          with types;
          oneOf [
            validConfigTypes
            (listOf validConfigTypes)
          ];
      in
      mkOption {
        default = { };

        description = ''
          Additional configuration to extend clight.conf. See
          <https://github.com/FedeDP/Clight/blob/master/Extra/clight.conf> for a
          sample configuration file.
        '';

        example = {
          ac_capture_timeouts = [
            120
            300
            60
          ];

          captures = 20;
          gamma_long_transition = true;
        };

        type = with types; attrsOf (nullOr (either collectionTypes (attrsOf collectionTypes)));
      };

    temperature = {
      day = mkOption {
        default = 5500;

        description = ''
          Colour temperature to use during the day, between
          `1000` and `25000` K.
        '';

        type = types.int;
      };

      night = mkOption {
        default = 3700;

        description = ''
          Colour temperature to use at night, between
          `1000` and `25000` K.
        '';

        type = types.int;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      let
        inRange =
          v: l: r:
          v >= l && v <= r;
      in
      [
        {
          assertion =
            config.location.provider == "manual"
            -> inRange config.location.latitude (-90) 90 && inRange config.location.longitude (-180) 180;

          message = "You must specify a valid latitude and longitude if manually providing location";
        }
      ];

    boot.kernelModules = [ "i2c_dev" ];

    environment.systemPackages = with pkgs; [
      clight
      clightd
    ];

    services.clight.settings = {
      gamma.temp =
        with cfg.temperature;
        mkDefault [
          day
          night
        ];
    }
    // (optionalAttrs (config.location.provider == "manual") {
      daytime.latitude = mkDefault config.location.latitude;
      daytime.longitude = mkDefault config.location.longitude;
    });

    services.dbus.packages = with pkgs; [
      clight
      clightd
    ];

    services.geoclue2.appConfig.clightc = {
      isAllowed = true;
      isSystem = true;
    };

    services.upower.enable = true;

    systemd.services.clightd = {
      description = "Bus service to manage various screen related properties (gamma, dpms, backlight)";
      requires = [ "polkit.service" ];

      serviceConfig = {
        BusName = "org.clightd.clightd";

        ExecStart = ''
          ${pkgs.clightd}/bin/clightd
        '';

        Restart = "on-failure";
        RestartSec = 5;
        Type = "dbus";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.user.services.clight = {
      after = [
        "upower.service"
        "clightd.service"
      ];

      description = "C daemon to adjust screen brightness to match ambient brightness, as computed capturing frames from webcam";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.clight}/bin/clight --conf-file ${clightConf}
        '';

        Restart = "on-failure";
        RestartSec = 5;
      };

      wantedBy = [ "graphical-session.target" ];

      wants = [
        "upower.service"
        "clightd.service"
      ];
    };
  };
}
