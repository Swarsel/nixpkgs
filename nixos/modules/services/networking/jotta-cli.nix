{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jotta-cli;
in
{
  options = {
    services.jotta-cli = {

      options = lib.mkOption {
        default = [
          "stdoutlog"
          "datadir"
          "%h/.jottad/"
        ];

        description = "Command-line options passed to jottad.";
        example = [ ];
        type = with lib.types; listOf str;
      };

      enable = lib.mkEnableOption "Jottacloud Command-line Tool";
      package = lib.mkPackageOption pkgs "jotta-cli" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.jotta-cli ];

    systemd.user.services.jottad = {

      after = [ "network-online.target" ];
      description = "Jottacloud Command-line Tool daemon";

      serviceConfig = {
        EnvironmentFile = "-%h/.config/jotta-cli/jotta-cli.env";
        ExecStart = "${lib.getExe' cfg.package "jottad"} ${lib.concatStringsSep " " cfg.options}";
        Restart = "on-failure";
        Type = "notify";
      };

      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.doc = ./jotta-cli.md;
  meta.maintainers = with lib.maintainers; [ evenbrenden ];
}
