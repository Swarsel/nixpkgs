{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.journald.upload;
  format = pkgs.formats.systemd { };
in
{
  options.services.journald.upload = {
    enable = lib.mkEnableOption "uploading the systemd journal to a remote server";

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for journal-upload. See {manpage}`journal-upload.conf(5)`
        for available options.
      '';

      type = lib.types.submodule {
        options.Upload = {
          NetworkTimeoutSec = lib.mkOption {
            default = null;

            description = ''
              When network connectivity to the server is lost, this option
              configures the time to wait for the connectivity to get restored.

              If the server is not reachable over the network for the
              configured time, `systemd-journal-upload` exits. Takes a value in
              seconds (or in other time units if suffixed with "ms", "min",
              "h", etc). For details, see {manpage}`systemd.time(5)`.
            '';

            example = "1s";
            type = with lib.types; nullOr str;
          };

          ServerCertificateFile = lib.mkOption {
            default = null;

            description = ''
              SSL CA certificate in PEM format.

              In contrary to what the name suggests, this option configures the
              client certificate sent to the remote journal server.
            '';

            example = lib.literalExpression "./server-ca.pem";
            type = with lib.types; nullOr str;
          };

          ServerKeyFile = lib.mkOption {
            default = null;

            # Since systemd-journal-upload uses a DynamicUser, permissions must
            # be done using groups
            description = ''
              SSL key in PEM format.

              In contrary to what the name suggests, this option configures the
              client private key sent to the remote journal server.

              This key should not be world-readable, and must be readably by
              the `systemd-journal` group.
            '';

            example = lib.literalExpression "./server-key.pem";
            type = with lib.types; nullOr str;
          };

          TrustedCertificateFile = lib.mkOption {
            default = null;

            description = ''
              SSL CA certificate.

              This certificate will be used to check the remote journal HTTPS
              server certificate.
            '';

            example = lib.literalExpression "./ca";
            type = with lib.types; nullOr str;
          };

          URL = lib.mkOption {
            description = ''
              The URL to upload the journal entries to.

              See the description of `--url=` option in
              {manpage}`systemd-journal-upload(8)` for the description of
              possible values.
            '';

            example = "https://192.168.1.1";
            type = lib.types.str;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."systemd/journal-upload.conf".source =
      format.generate "journal-upload.conf" cfg.settings;

    systemd.additionalUpstreamSystemUnits = [ "systemd-journal-upload.service" ];

    systemd.services."systemd-journal-upload" = {
      serviceConfig = {
        Restart = "always";
        # To prevent flooding the server in case the server is struggling
        RestartSec = "3sec";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
