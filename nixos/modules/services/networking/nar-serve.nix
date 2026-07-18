{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
  cfg = config.services.nar-serve;
in
{
  options = {
    services.nar-serve = {
      enable = lib.mkEnableOption "serving NAR file contents via HTTP";
      package = lib.mkPackageOption pkgs "nar-serve" { };

      cacheURL = mkOption {
        default = "https://cache.nixos.org/";

        description = ''
          Binary cache URL to connect to.

          The URL format is compatible with the nix remote url style, such as:
          - http://, https:// for binary caches via HTTP or HTTPS
          - s3:// for binary caches stored in Amazon S3
          - gs:// for binary caches stored in Google Cloud Storage
        '';

        type = types.str;
      };

      domain = mkOption {
        default = "";

        description = ''
          When set, enables the feature of serving <nar-hash>.<domain>
          on top of <domain>/nix/store/<nar-hash>-<pname>.

          Useful to preview static websites where paths are absolute.
        '';

        type = types.str;
      };

      port = mkOption {
        default = 8383;

        description = ''
          Port number where nar-serve will listen on.
        '';

        type = types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nar-serve = {
      after = [ "network.target" ];
      description = "NAR server";
      environment.NAR_CACHE_URL = cfg.cacheURL;
      environment.PORT = toString cfg.port;

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Restart = "always";
        RestartSec = "5s";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      rizary
      zimbatm
    ];
  };
}
