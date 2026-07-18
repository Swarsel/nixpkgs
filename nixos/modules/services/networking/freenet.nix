{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.freenet;
  varDir = "/var/lib/freenet";
in
{
  options = {
    services.freenet = {
      enable = lib.mkEnableOption "Freenet daemon";

      nice = lib.mkOption {
        default = 10;
        description = "Set the nice level for the Freenet daemon";
        type = lib.types.ints.between (-20) 19;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.freenet = {
      after = [ "network.target" ];
      description = "Freenet daemon";

      serviceConfig = {
        ExecStart = lib.getExe pkgs.freenet;
        Nice = cfg.nice;
        UMask = "0007";
        User = "freenet";
        WorkingDirectory = varDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.freenet.gid = config.ids.gids.freenet;

    users.users.freenet = {
      createHome = true;
      description = "Freenet daemon user";
      group = "freenet";
      home = varDir;
      uid = config.ids.uids.freenet;
    };
  };

  meta.maintainers = with lib.maintainers; [ nagy ];
}
