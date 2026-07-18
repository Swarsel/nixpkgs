{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  inherit (lib) mkOption types;
  cfg = config.services.prometheus.exporters.sabnzbd;
in
{
  extraOpts = {
    servers = mkOption {
      description = "List of sabnzbd servers to connect to.";

      type = types.listOf (
        types.submodule {
          options = {
            apiKeyFile = mkOption {
              description = ''
                The path to a file containing the API key.
                The file is securely passed to the service by leveraging systemd credentials.
                No special permissions need to be set on this file.
              '';

              example = "/run/secrets/sabnzbd_apikey";
              type = types.str;
            };

            baseUrl = mkOption {
              description = "Base URL of the sabnzbd server.";
              example = "http://localhost:8080/sabnzbd";
              type = types.str;
            };
          };
        }
      );
    };
  };

  port = 9387;

  serviceOpts =
    let
      servers = lib.zipAttrs cfg.servers;
      credentials = lib.imap0 (i: v: {
        name = "apikey-${toString i}";
        path = v;
      }) servers.apiKeyFile;
    in
    {
      environment = {
        METRICS_ADDR = cfg.listenAddress;
        METRICS_PORT = toString cfg.port;
        SABNZBD_BASEURLS = lib.concatStringsSep "," servers.baseUrl;
      };

      script =
        let
          apiKeys = lib.concatStringsSep "," (
            map (cred: "$(< $CREDENTIALS_DIRECTORY/${cred.name})") credentials
          );
        in
        ''
          export SABNZBD_APIKEYS="${apiKeys}"
          exec ${lib.getExe pkgs.prometheus-sabnzbd-exporter}
        '';

      serviceConfig.LoadCredential = map ({ name, path }: "${name}:${path}") credentials;
    };
}
