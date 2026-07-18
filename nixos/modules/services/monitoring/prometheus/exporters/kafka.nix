{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.kafka;
  inherit (lib)
    mkIf
    mkOption
    mkMerge
    types
    ;
in
{
  extraOpts = {
    package = lib.mkPackageOption pkgs "kminion" { };

    environmentFile = mkOption {
      default = null;

      description = ''
        File containing the credentials to access the repository, in the
        format of an EnvironmentFile as described by systemd.exec(5)
      '';

      type = with types; nullOr path;
    };
  };

  port = 8080;

  serviceOpts = mkMerge (
    [
      {
        serviceConfig = {
          EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

          ExecStart = ''
            ${lib.getExe cfg.package}
          '';

          RestartSec = "5s";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
        };
      }
    ]
    ++ [
      (mkIf config.services.apache-kafka.enable {
        after = [ "apache-kafka.service" ];
        requires = [ "apache-kafka.service" ];
      })
    ]
  );
}
