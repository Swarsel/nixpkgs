{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.storagebox;
  inherit (lib) mkPackageOption;
in
{
  extraOpts = {
    package = mkPackageOption pkgs "prometheus-storagebox-exporter" { };

    tokenFile = lib.mkOption {
      description = "File that contains the Hetzner API token to use.";
      type = lib.types.externalPath;
    };

  };

  port = 9509;

  serviceOpts = {
    after = [ "network.target" ];

    environment = {
      LISTEN_ADDR = "${toString cfg.listenAddress}:${toString cfg.port}";
    };

    script = ''
      export HETZNER_TOKEN=$(< "''${CREDENTIALS_DIRECTORY}/token")
      exec ${lib.getExe cfg.package}
    '';

    serviceConfig = {
      DynamicUser = true;

      LoadCredential = [
        "token:${cfg.tokenFile}"
      ];

      Restart = "always";
      RestartSec = "10s";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
