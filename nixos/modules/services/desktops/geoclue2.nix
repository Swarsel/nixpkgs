# GeoClue 2 daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.geoclue2;

  appConfigModule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        desktopID = lib.mkOption {
          description = "Desktop ID of the application.";
          type = lib.types.str;
        };

        isAllowed = lib.mkOption {
          description = ''
            Whether the application will be allowed access to location information.
          '';

          type = lib.types.bool;
        };

        isSystem = lib.mkOption {
          description = ''
            Whether the application is a system component or not.
          '';

          type = lib.types.bool;
        };

        users = lib.mkOption {
          default = [ ];

          description = ''
            List of UIDs of all users for which this application is allowed location
            info access, Defaults to an empty string to allow it for all users.
          '';

          type = lib.types.listOf lib.types.str;
        };
      };

      config.desktopID = lib.mkDefault name;
    }
  );

  appConfigToINICompatible =
    _:
    {
      desktopID,
      isAllowed,
      isSystem,
      users,
      ...
    }:
    {
      name = desktopID;

      value = {
        allowed = isAllowed;
        system = isSystem;
        users = lib.concatStringsSep ";" users;
      };
    };

in
{

  ###### interface

  options = {

    services.geoclue2 = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable GeoClue 2 daemon, a DBus service
          that provides location information for accessing.
        '';

        type = lib.types.bool;
      };

      package = lib.mkOption {
        apply =
          pkg:
          pkg.override {
            # the demo agent isn't built by default, but we need it here
            withDemoAgent = cfg.enableDemoAgent;
          };

        default = pkgs.geoclue2;
        defaultText = lib.literalExpression "pkgs.geoclue2";
        description = "The geoclue2 package to use";
        type = lib.types.package;
      };

      appConfig = lib.mkOption {
        default = { };

        description = ''
          Specify extra settings per application.
        '';

        example = lib.literalExpression ''
          "com.github.app" = {
            isAllowed = true;
            isSystem = true;
            users = [ "300" ];
          };
        '';

        type = lib.types.attrsOf appConfigModule;
      };

      enable3G = lib.mkOption {
        default = true;

        description = ''
          Whether to enable 3G source.
        '';

        type = lib.types.bool;
      };

      enableCDMA = lib.mkOption {
        default = true;

        description = ''
          Whether to enable CDMA source.
        '';

        type = lib.types.bool;
      };

      enableDemoAgent = lib.mkOption {
        default = true;

        description = ''
          Whether to use the GeoClue demo agent. This should be
          overridden by desktop environments that provide their own
          agent.
        '';

        type = lib.types.bool;
      };

      enableModemGPS = lib.mkOption {
        default = true;

        description = ''
          Whether to enable Modem-GPS source.
        '';

        type = lib.types.bool;
      };

      enableNmea = lib.mkOption {
        default = true;

        description = ''
          Whether to fetch location from NMEA sources on local network.
        '';

        type = lib.types.bool;
      };

      enableStatic = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the static source. This source defines a fixed
          location using the `staticLatitude`, `staticLongitude`,
          `staticAltitude`, and `staticAccuracy` options.

          Setting `enableStatic` to true will disable all other sources, to
          prevent conflicts. Use `lib.mkForce true` when enabling other sources
          if for some reason you want to override this.
        '';

        type = lib.types.bool;
      };

      enableWifi = lib.mkOption {
        default = true;

        description = ''
          Whether to enable WiFi source.
        '';

        type = lib.types.bool;
      };

      geoProviderUrl = lib.mkOption {
        default = "https://api.beacondb.net/v1/geolocate";

        description = ''
          The url to the wifi GeoLocation Service.
        '';

        example = "https://www.googleapis.com/geolocation/v1/geolocate?key=YOUR_KEY";
        type = lib.types.str;
      };

      staticAccuracy = lib.mkOption {
        description = ''
          Accuracy radius in meters to use for the static source.
        '';

        type = lib.types.numbers.positive;
      };

      staticAltitude = lib.mkOption {
        description = ''
          Altitude in meters to use for the static source.
        '';

        type = lib.types.number;
      };

      staticLatitude = lib.mkOption {
        description = ''
          Latitude to use for the static source. Defaults to `location.latitude`.
        '';

        type = lib.types.numbers.between (-90) 90;
      };

      staticLongitude = lib.mkOption {
        description = ''
          Longitude to use for the static source. Defaults to `location.longitude`.
        '';

        type = lib.types.numbers.between (-180) 180;
      };

      submissionNick = lib.mkOption {
        default = "geoclue";

        description = ''
          A nickname to submit network data with.
          Must be 2-32 characters long.
        '';

        type = lib.types.str;
      };

      submissionUrl = lib.mkOption {
        default = "https://api.beacondb.net/v2/geosubmit";

        description = ''
          The url to submit data to a GeoLocation Service.
        '';

        type = lib.types.str;
      };

      submitData = lib.mkOption {
        default = false;

        description = ''
          Whether to submit data to a GeoLocation Service.
        '';

        type = lib.types.bool;
      };

      whitelistedAgents = lib.mkOption {
        default = [
          "gnome-shell"
          "io.elementary.desktop.agent-geoclue2"
        ];

        description = ''
          Desktop IDs (without the .desktop extension) of whitelisted agents.
        '';

        type = lib.types.listOf lib.types.str;
      };

    };

  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    environment.etc."geoclue/geoclue.conf".text = lib.generators.toINI { } (
      {
        "3g" = {
          enable = cfg.enable3G;
        };

        agent = {
          whitelist = lib.concatStringsSep ";" (
            lib.lists.unique (
              cfg.whitelistedAgents
              ++ lib.optionals config.services.geoclue2.enableDemoAgent [ "geoclue-demo-agent" ]
            )
          );
        };

        cdma = {
          enable = cfg.enableCDMA;
        };

        modem-gps = {
          enable = cfg.enableModemGPS;
        };

        network-nmea = {
          enable = cfg.enableNmea;
        };

        static-source = {
          enable = cfg.enableStatic;
        };

        wifi = {
          enable = cfg.enableWifi;
        }
        // lib.optionalAttrs cfg.enableWifi {
          submission-nick = cfg.submissionNick;
          submission-url = cfg.submissionUrl;
          submit-data = lib.boolToString cfg.submitData;
          url = cfg.geoProviderUrl;
        };
      }
      // lib.mapAttrs' appConfigToINICompatible cfg.appConfig
    );

    environment.etc.geolocation = lib.mkIf cfg.enableStatic {
      group = "geoclue";
      mode = "0440";

      text = ''
        ${toString cfg.staticLatitude}
        ${toString cfg.staticLongitude}
        ${toString cfg.staticAltitude}
        ${toString cfg.staticAccuracy}
      '';
    };

    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];

    services.geoclue2 = {
      enable3G = lib.mkIf cfg.enableStatic false;
      enableCDMA = lib.mkIf cfg.enableStatic false;
      enableModemGPS = lib.mkIf cfg.enableStatic false;
      enableNmea = lib.mkIf cfg.enableStatic false;
      enableWifi = lib.mkIf cfg.enableStatic false;
      staticLatitude = lib.mkDefault config.location.latitude;
      staticLongitude = lib.mkDefault config.location.longitude;
    };

    services.geoclue2.appConfig.epiphany = {
      isAllowed = true;
      isSystem = false;
    };

    services.geoclue2.appConfig.firefox = {
      isAllowed = true;
      isSystem = false;
    };

    systemd.packages = [ cfg.package ];

    systemd.services.geoclue = {
      after = lib.optionals cfg.enableWifi [ "network-online.target" ];

      # restart geoclue service when the configuration changes
      restartTriggers = [
        config.environment.etc."geoclue/geoclue.conf".source
      ];

      serviceConfig.StateDirectory = "geoclue";
      wants = lib.optionals cfg.enableWifi [ "network-online.target" ];
    };

    # this needs to run as a user service, since it's associated with the
    # user who is making the requests
    systemd.user.services = lib.mkIf cfg.enableDemoAgent {
      geoclue-agent = {
        after = lib.optionals cfg.enableWifi [ "network-online.target" ];
        description = "Geoclue agent";

        serviceConfig = {
          ExecStart = "${cfg.package}/libexec/geoclue-2.0/demos/agent";
          PrivateTmp = true;
          Restart = "on-failure";
          Type = "exec";
        };

        unitConfig.ConditionUser = "!@system";
        # this should really be `partOf = [ "geoclue.service" ]`, but
        # we can't be part of a system service, and the agent should
        # be okay with the main service coming and going
        wantedBy = [ "default.target" ];
        wants = lib.optionals cfg.enableWifi [ "network-online.target" ];
      };
    };

    # we cannot use DynamicUser as we need the the geoclue user to exist for the
    # dbus policy to work
    users = {
      groups.geoclue = { };

      users.geoclue = {
        description = "Geoinformation service";
        group = "geoclue";
        home = "/var/lib/geoclue";
        isSystemUser = true;
      };
    };
  };

  meta = {
    teams = [ lib.teams.pantheon ];
  };
}
