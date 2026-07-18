{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.lambdabot;

  rc = builtins.toFile "script.rc" cfg.script;

in

{

  ### configuration

  options = {

    services.lambdabot = {

      enable = lib.mkOption {
        default = false;
        description = "Enable the Lambdabot IRC bot";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "lambdabot" { };

      script = lib.mkOption {
        default = "";
        description = "Lambdabot script";
        type = lib.types.str;
      };

    };

  };

  ### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.lambdabot = {
      after = [ "network.target" ];
      description = "Lambdabot daemon";

      # Workaround for https://github.com/lambdabot/lambdabot/issues/117
      script = ''
        mkdir -p ~/.lambdabot
        cd ~/.lambdabot
        mkfifo /run/lambdabot/offline
        (
          echo 'rc ${rc}'
          while true; do
            cat /run/lambdabot/offline
          done
        ) | ${cfg.package}/bin/lambdabot
      '';

      serviceConfig = {
        RuntimeDirectory = [ "lambdabot" ];
        User = "lambdabot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.lambdabot.gid = config.ids.gids.lambdabot;

    users.users.lambdabot = {
      createHome = true;
      description = "Lambdabot daemon user";
      group = "lambdabot";
      home = "/var/lib/lambdabot";
      uid = config.ids.uids.lambdabot;
    };

  };

}
