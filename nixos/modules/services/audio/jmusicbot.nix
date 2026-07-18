{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jmusicbot;
in
{
  options = {
    services.jmusicbot = {
      enable = lib.mkEnableOption "jmusicbot, a Discord music bot that's easy to set up and run yourself";
      package = lib.mkPackageOption pkgs "jmusicbot" { };

      stateDir = lib.mkOption {
        default = "/var/lib/jmusicbot/";

        description = ''
          The directory where config.txt and serversettings.json is saved.
          If left as the default value this directory will automatically be created before JMusicBot starts, otherwise the sysadmin is responsible for ensuring the directory exists with appropriate ownership and permissions.
          Untouched by the value of this option config.txt needs to be placed manually into this directory.
        '';

        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.jmusicbot = {
      after = [ "network-online.target" ];
      description = "Discord music bot that's easy to set up and run yourself!";

      serviceConfig = lib.mkMerge [
        {
          DynamicUser = true;
          ExecStart = "${cfg.package}/bin/JMusicBot";
          Restart = "always";
          RestartSec = 20;
          WorkingDirectory = cfg.stateDir;
        }
        (lib.mkIf (cfg.stateDir == "/var/lib/jmusicbot") { StateDirectory = "jmusicbot"; })
      ];

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = [ ];
}
