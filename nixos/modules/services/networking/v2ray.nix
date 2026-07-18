{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  json = pkgs.formats.json { };
in
{
  options = {

    services.v2ray = {
      config = mkOption {
        default = null;

        description = ''
          The configuration object.

          Either `configFile` or `config` must be specified.

          See <https://www.v2fly.org/en_US/v5/config/overview.html>.
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

        type = types.nullOr json.type;
      };

      enable = mkOption {
        default = false;

        description = ''
          Whether to run v2ray server.

          Either `configFile` or `config` must be specified.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "v2ray" { };

      configFile = mkOption {
        default = null;

        description = ''
          The absolute path to the configuration file.

          Either `configFile` or `config` must be specified.

          See <https://www.v2fly.org/en_US/v5/config/overview.html>.
        '';

        example = "/etc/v2ray/config.json";
        type = types.nullOr types.str;
      };
    };

  };

  config =
    let
      cfg = config.services.v2ray;
      configFile =
        if cfg.configFile != null then
          cfg.configFile
        else
          pkgs.writeTextFile {
            checkPhase = ''
              ${cfg.package}/bin/v2ray test -c $out
            '';

            name = "v2ray.json";
            text = builtins.toJSON cfg.config;
          };

    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.configFile == null) != (cfg.config == null);
          message = "Either but not both `configFile` and `config` should be specified for v2ray.";
        }
      ];

      environment.etc."v2ray/config.json".source = configFile;
      systemd.packages = [ cfg.package ];

      systemd.services.v2ray = {
        restartTriggers = [ config.environment.etc."v2ray/config.json".source ];
        # Workaround: https://github.com/NixOS/nixpkgs/issues/81138
        wantedBy = [ "multi-user.target" ];
      };
    };
}
