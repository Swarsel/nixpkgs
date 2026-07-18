{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.SystemdJournal2Gelf;
in

{
  options = {
    services.SystemdJournal2Gelf = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable SystemdJournal2Gelf.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "systemd-journal2gelf" { };

      extraOptions = lib.mkOption {
        default = "";

        description = ''
          Any extra flags to pass to SystemdJournal2Gelf. Note that
          these are basically `journalctl` flags.
        '';

        type = lib.types.separatedString " ";
      };

      graylogServer = lib.mkOption {
        description = ''
          Host and port of your graylog2 input. This should be a GELF
          UDP input.
        '';

        example = "graylog2.example.com:11201";
        type = lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.SystemdJournal2Gelf = {
      after = [ "network.target" ];
      description = "SystemdJournal2Gelf";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/SystemdJournal2Gelf ${cfg.graylogServer} --follow ${cfg.extraOptions}";
        Restart = "on-failure";
        RestartSec = "30";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
