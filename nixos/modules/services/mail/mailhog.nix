{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mailhog;

  args = lib.concatStringsSep " " (
    [
      "-api-bind-addr :${toString cfg.apiPort}"
      "-smtp-bind-addr :${toString cfg.smtpPort}"
      "-ui-bind-addr :${toString cfg.uiPort}"
      "-storage ${cfg.storage}"
    ]
    ++ lib.optional (cfg.storage == "maildir") "-maildir-path $STATE_DIRECTORY"
    ++ cfg.extraArgs
  );

  mhsendmail = pkgs.writeShellScriptBin "mailhog-sendmail" ''
    exec ${lib.getExe pkgs.mailhog} sendmail $@
  '';
in
{
  ###### interface

  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "mailhog"
      "user"
    ] "")
  ];

  options = {

    services.mailhog = {
      enable = lib.mkEnableOption "MailHog, web and API based SMTP testing";

      apiPort = lib.mkOption {
        default = 8025;
        description = "Port on which the API endpoint will listen.";
        type = lib.types.port;
      };

      extraArgs = lib.mkOption {
        default = [ ];
        description = "List of additional arguments to pass to the MailHog process.";
        type = lib.types.listOf lib.types.str;
      };

      setSendmail = lib.mkEnableOption "set the system sendmail to mailhogs's" // {
        default = true;
      };

      smtpPort = lib.mkOption {
        default = 1025;
        description = "Port on which the SMTP endpoint will listen.";
        type = lib.types.port;
      };

      storage = lib.mkOption {
        default = "memory";
        description = "Store mails on disk or in memory.";

        type = lib.types.enum [
          "maildir"
          "memory"
        ];
      };

      uiPort = lib.mkOption {
        default = 8025;
        description = "Port on which the HTTP UI will listen.";
        type = lib.types.port;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    services.mail.sendmailSetuidWrapper = lib.mkIf cfg.setSendmail {
      group = "nogroup";
      # Communication happens through the network, no data is written to disk
      owner = "nobody";
      program = "sendmail";
      source = lib.getExe mhsendmail;
    };

    systemd.services.mailhog = {
      after = [ "network.target" ];
      description = "MailHog - Web and API based SMTP testing";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe pkgs.mailhog} ${args}";
        Restart = "on-failure";
        StateDirectory = "mailhog";
        Type = "exec";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ RTUnreal ];
}
