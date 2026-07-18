{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.uptimed;
  stateDir = "/var/lib/uptimed";
in
{
  options = {
    services.uptimed = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable `uptimed`, allowing you to track
          your highest uptimes.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.uptimed ];

    systemd.services.uptimed = {
      description = "uptimed service";

      preStart = ''
        if ! test -f ${stateDir}/bootid ; then
          ${pkgs.uptimed}/sbin/uptimed -b
        fi
      '';

      serviceConfig = {
        ExecStart = "${pkgs.uptimed}/sbin/uptimed -f -p ${stateDir}/pid";
        IOSchedulingClass = "idle";
        InaccessibleDirectories = "/home";
        Nice = 19;
        NoNewPrivileges = "yes";
        PrivateNetwork = "yes";
        PrivateTmp = "yes";
        Restart = "on-failure";
        StateDirectory = [ "uptimed" ];
        User = "uptimed";
      };

      unitConfig.Documentation = "man:uptimed(8) man:uprecords(1)";
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.uptimed = { };

    users.users.uptimed = {
      description = "Uptimed daemon user";
      group = "uptimed";
      home = stateDir;
      uid = config.ids.uids.uptimed;
    };
  };
}
