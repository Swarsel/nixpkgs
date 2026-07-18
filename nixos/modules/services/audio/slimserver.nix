{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.slimserver;

in
{
  options = {

    services.slimserver = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable slimserver.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "slimserver" { };

      dataDir = lib.mkOption {
        default = "/var/lib/slimserver";

        description = ''
          The directory where slimserver stores its state, tag cache,
          playlists etc.
        '';

        type = lib.types.path;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.slimserver = {
      after = [ "network.target" ];
      description = "Slim Server for Logitech Squeezebox Players";

      serviceConfig = {
        # Issue 40589: Disable broken image/video support (audio still works!)
        ExecStart = "${lib.getExe cfg.package} --logdir ${cfg.dataDir}/logs --prefsdir ${cfg.dataDir}/prefs --cachedir ${cfg.dataDir}/cache --noimage --novideo";

        # Allow only IPv4 since slimserver breaks with IPv6
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_UNIX"
        ];

        User = "slimserver";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - slimserver slimserver - -"
    ];

    users = {
      groups.slimserver = { };

      users.slimserver = {
        description = "Slimserver daemon user";
        group = "slimserver";
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };

}
