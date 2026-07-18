{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.metabase;

  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib) optional optionalAttrs types;

  dataDir = "/var/lib/metabase";

in
{

  options = {

    services.metabase = {
      enable = mkEnableOption "Metabase service";
      package = lib.mkPackageOption pkgs "metabase" { };

      listen = {
        ip = mkOption {
          default = "0.0.0.0";

          description = ''
            IP address that Metabase should listen on.
          '';

          type = types.str;
        };

        port = mkOption {
          default = 3000;

          description = ''
            Listen port for Metabase.
          '';

          type = types.port;
        };
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports in the firewall for Metabase.
        '';

        type = types.bool;
      };

      ssl = {
        enable = mkOption {
          default = false;

          description = ''
            Whether to enable SSL (https) support.
          '';

          type = types.bool;
        };

        keystore = mkOption {
          default = "${dataDir}/metabase.jks";

          description = ''
            [Java KeyStore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) file containing the certificates.
          '';

          example = "/etc/secrets/keystore.jks";
          type = types.nullOr types.path;
        };

        port = mkOption {
          default = 8443;

          description = ''
            Listen port over SSL (https) for Metabase.
          '';

          type = types.port;
        };

      };
    };

  };

  config = mkIf cfg.enable {

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ] ++ optional cfg.ssl.enable cfg.ssl.port;
    };

    systemd.services.metabase = {
      after = [ "network-online.target" ];
      description = "Metabase server";

      environment = {
        MB_DB_FILE = "${dataDir}/metabase.db";
        MB_JETTY_HOST = cfg.listen.ip;
        MB_JETTY_PORT = toString cfg.listen.port;
        MB_PLUGINS_DIR = "${dataDir}/plugins";
      }
      // optionalAttrs (cfg.ssl.enable) {
        MB_JETTY_SSL = true;
        MB_JETTY_SSL_KEYSTORE = cfg.ssl.keystore;
        MB_JETTY_SSL_PORT = toString cfg.ssl.port;
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        StateDirectory = baseNameOf dataDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

  };
}
