{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.freeradius;

  freeradiusService = cfg: {
    after = [ "network.target" ];
    description = "FreeRadius server";

    preStart = ''
      ${cfg.package}/bin/radiusd -C -d ${cfg.configDir} -l stdout
    '';

    serviceConfig = {
      ExecReload = [
        "${cfg.package}/bin/radiusd -C -d ${cfg.configDir} -l stdout"
        "${pkgs.coreutils}/bin/kill -HUP $MAINPID"
      ];

      ExecStart =
        "${cfg.package}/bin/radiusd -f -d ${cfg.configDir} -l stdout" + lib.optionalString cfg.debug " -xx";

      LogsDirectory = "radius";
      ProtectHome = "on";
      ProtectSystem = "full";
      Restart = "on-failure";
      RestartSec = 2;
      User = "radius";
    };

    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
  };

  freeradiusConfig = {
    enable = lib.mkEnableOption "the freeradius server";
    package = lib.mkPackageOption pkgs "freeradius" { };

    configDir = lib.mkOption {
      default = "/etc/raddb";

      description = ''
        The path of the freeradius server configuration directory.
      '';

      type = lib.types.path;
    };

    debug = lib.mkOption {
      default = false;

      description = ''
        Whether to enable debug logging for freeradius (-xx
        option). This should not be left on, since it includes
        sensitive data such as passwords in the logs.
      '';

      type = lib.types.bool;
    };

  };

in

{

  ###### interface

  options = {
    services.freeradius = freeradiusConfig;
  };

  ###### implementation

  config = lib.mkIf (cfg.enable) {

    systemd.services.freeradius = freeradiusService cfg;

    users = {
      groups.radius = { };

      users.radius = {
        # uid = config.ids.uids.radius;
        description = "Radius daemon user";
        group = "radius";
        isSystemUser = true;
      };
    };

    warnings = lib.optional cfg.debug "Freeradius debug logging is enabled. This will log passwords in plaintext to the journal!";

  };

}
