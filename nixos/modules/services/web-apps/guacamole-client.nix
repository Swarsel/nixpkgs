{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.guacamole-client;
  settingsFormat = pkgs.formats.javaProperties { };
in
{
  options = {
    services.guacamole-client = {
      enable = lib.mkEnableOption "Apache Guacamole Client (Tomcat)";
      package = lib.mkPackageOption pkgs "guacamole-client" { };

      enableWebserver = lib.mkOption {
        default = true;

        description = ''
          Enable the Guacamole web application in a Tomcat webserver.
        '';

        type = lib.types.bool;
      };

      logbackXml = lib.mkOption {
        default = null;

        description = ''
          Configuration file that correspond to `logback.xml`.
        '';

        example = "/path/to/logback.xml";
        type = lib.types.nullOr lib.types.path;
      };

      settings = lib.mkOption {
        default = {
          guacd-hostname = "localhost";
          guacd-port = 4822;
        };

        description = ''
          Configuration written to `guacamole.properties`.

          ::: {.note}
          The Guacamole web application uses one main configuration file called
          `guacamole.properties`. This file is the common location for all
          configuration properties read by Guacamole or any extension of
          Guacamole, including authentication providers.
          :::
        '';

        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
      };

      userMappingXml = lib.mkOption {
        default = null;

        description = ''
          Configuration file that correspond to `user-mapping.xml`.
        '';

        example = "/path/to/user-mapping.xml";
        type = lib.types.nullOr lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Setup configuration files.
    environment.etc."guacamole/guacamole.properties" = lib.mkIf (cfg.settings != { }) {
      source = (settingsFormat.generate "guacamole.properties" cfg.settings);
    };

    environment.etc."guacamole/logback.xml" = lib.mkIf (cfg.logbackXml != null) {
      source = cfg.logbackXml;
    };

    environment.etc."guacamole/user-mapping.xml" = lib.mkIf (cfg.userMappingXml != null) {
      source = cfg.userMappingXml;
    };

    services = lib.mkIf cfg.enableWebserver {
      tomcat = {
        enable = true;

        webapps = [
          cfg.package
        ];
      };
    };
  };
}
