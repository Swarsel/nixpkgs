{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options = {

    services.xray = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to run xray server.

          Either `settingsFile` or `settings` must be specified.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "xray" { };

      settings = mkOption {
        default = null;

        description = ''
          The configuration object.

          Either `settingsFile` or `settings` must be specified.

          See <https://www.v2fly.org/en_US/config/overview.html>.
        '';

        example = {
          inbounds = [
            {
              listen = "127.0.0.1";
              port = 1080;
              protocol = "http";
            }
          ];

          outbounds = [
            {
              protocol = "freedom";
            }
          ];
        };

        type = types.nullOr (types.attrsOf types.unspecified);
      };

      settingsFile = mkOption {
        default = null;

        description = ''
          The absolute path to the configuration file.

          Either `settingsFile` or `settings` must be specified.

          See <https://www.v2fly.org/en_US/config/overview.html>.
        '';

        example = "/etc/xray/config.json";
        type = types.nullOr types.path;
      };
    };

  };

  config =
    let
      cfg = config.services.xray;
      settingsFile =
        if cfg.settingsFile != null then
          cfg.settingsFile
        else
          pkgs.writeTextFile {
            checkPhase = ''
              ${cfg.package}/bin/xray -test -config $out
            '';

            name = "xray.json";
            text = builtins.toJSON cfg.settings;
          };

    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.settingsFile == null) != (cfg.settings == null);
          message = "Either but not both `settingsFile` and `settings` should be specified for xray.";
        }
      ];

      systemd.services.xray = {
        after = [ "network.target" ];
        description = "xray Daemon";

        script = ''
          exec "${cfg.package}/bin/xray" -config "$CREDENTIALS_DIRECTORY/config.json"
        '';

        serviceConfig = {
          AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
          CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
          DynamicUser = true;
          LoadCredential = "config.json:${settingsFile}";
          NoNewPrivileges = true;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
}
