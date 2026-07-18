{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tika;
  inherit (lib)
    literalExpression
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    getExe
    types
    ;
in
{
  options = {
    services.tika = {
      enable = mkEnableOption "Apache Tika server";
      package = mkPackageOption pkgs "tika" { };

      configFile = mkOption {
        default = null;

        description = ''
          The Apache Tika configuration (XML) file to use.
        '';

        example = literalExpression "./tika/tika-config.xml";
        type = types.nullOr types.path;
      };

      enableOcr = mkOption {
        default = true;

        description = ''
          Whether to enable OCR support by adding the `tesseract` package as a dependency.
        '';

        type = types.bool;
      };

      listenAddress = mkOption {
        default = "127.0.0.1";

        description = ''
          The Apache Tika bind address.
        '';

        example = "0.0.0.0";
        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open the firewall for Apache Tika.
          This adds `services.tika.port` to `networking.firewall.allowedTCPPorts`.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 9998;

        description = ''
          The Apache Tike port to listen on
        '';

        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.tika = {
      after = [ "network.target" ];
      description = "Apache Tika Server";

      serviceConfig =
        let
          package = cfg.package.override {
            inherit (cfg) enableOcr;
            enableGui = false;
          };
        in
        {
          CacheDirectory = "tika";
          DynamicUser = true;

          ExecStart = "${getExe package} --host ${cfg.listenAddress} --port ${toString cfg.port} ${
            lib.optionalString (cfg.configFile != null) "--config ${cfg.configFile}"
          }";

          StateDirectory = "tika";
          Type = "simple";
        };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
