{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fluentd;

  pluginArgs = lib.concatStringsSep " " (map (x: "-p ${x}") cfg.plugins);
in
{
  ###### interface

  options = {

    services.fluentd = {
      config = lib.mkOption {
        default = "";
        description = "Fluentd config.";
        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "fluentd, a data/log collector";
      package = lib.mkPackageOption pkgs "fluentd" { };

      plugins = lib.mkOption {
        default = [ ];

        description = ''
          A list of plugin paths to pass into fluentd. It will make plugins defined in ruby files
          there available in your config.
        '';

        type = lib.types.listOf lib.types.path;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.services.fluentd = {
      description = "Fluentd Daemon";

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/fluentd -c ${pkgs.writeText "fluentd.conf" cfg.config} ${pluginArgs}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
