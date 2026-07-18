{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.rspamd-trainer;
  format = pkgs.formats.toml { };

in
{
  options.services.rspamd-trainer = {

    enable = lib.mkEnableOption "Spam/ham trainer for rspamd";

    secrets = lib.mkOption {
      default = [ ];

      description = ''
        A list of files containing the various secrets. Should be in the
        format expected by systemd's `EnvironmentFile` directory. For the
        IMAP account password use `PASSWORD = mypassword`.
      '';

      type = with lib.types; listOf path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        IMAP authentication configuration for rspamd-trainer. For supplying
        the IMAP password, use the `secrets` option.
      '';

      example = lib.literalExpression ''
        {
          HOST = "localhost";
          USERNAME = "spam@example.com";
          INBOXPREFIX = "INBOX/";
        }
      '';

      type = lib.types.submodule {
        freeformType = format.type;
      };
    };

  };

  config = lib.mkIf cfg.enable {

    systemd = {
      services.rspamd-trainer = {
        description = "Spam/ham trainer for rspamd";

        serviceConfig = {
          DynamicUser = true;

          EnvironmentFile = [
            (format.generate "rspamd-trainer-env" cfg.settings)
            cfg.secrets
          ];

          ExecStart = "${pkgs.rspamd-trainer}/bin/rspamd-trainer";
          StateDirectory = [ "rspamd-trainer/log" ];
          Type = "oneshot";
          WorkingDirectory = "/var/lib/rspamd-trainer";
        };
      };

      timers."rspamd-trainer" = {
        timerConfig = {
          OnBootSec = "10m";
          OnUnitActiveSec = "10m";
          Unit = "rspamd-trainer.service";
        };

        wantedBy = [ "timers.target" ];
      };
    };

  };

  meta.maintainers = with lib.maintainers; [ onny ];

}
