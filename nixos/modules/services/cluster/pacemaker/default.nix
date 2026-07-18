{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pacemaker;
in
{
  # interface
  options.services.pacemaker = {
    enable = lib.mkEnableOption "pacemaker";
    package = lib.mkPackageOption pkgs "pacemaker" { };
  };

  # implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.corosync.enable;

        message = ''
          Enabling services.pacemaker requires a services.corosync configuration.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.pacemaker = {
      serviceConfig = {
        StateDirectory = "pacemaker";
        StateDirectoryMode = "0700";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/log/pacemaker 0700 hacluster pacemaker -"
    ];

    users.groups.pacemaker = { };

    # required by pacemaker
    users.users.hacluster = {
      group = "pacemaker";
      home = "/var/lib/pacemaker";
      isSystemUser = true;
    };
  };
}
