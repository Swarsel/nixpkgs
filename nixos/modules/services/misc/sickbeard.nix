{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let

  name = "sickbeard";

  cfg = config.services.sickbeard;
  opt = options.services.sickbeard;
  sickbeard = cfg.package;

in
{

  ###### interface

  options = {
    services.sickbeard = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the sickbeard server.";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "sickbeard" {
        example = "sickrage";

        extraDescription = ''
          Enable `pkgs.sickrage` or `pkgs.sickgear`
          as an alternative to SickBeard
        '';
      };

      configFile = lib.mkOption {
        default = "${cfg.dataDir}/config.ini";
        defaultText = lib.literalExpression ''"''${config.${opt.dataDir}}/config.ini"'';
        description = "Path to config file.";
        type = lib.types.path;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/${name}";
        description = "Path where to store data files.";
        type = lib.types.path;
      };

      group = lib.mkOption {
        default = name;
        description = "Group to run the service as";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8081;
        description = "Port to bind to.";
        type = lib.types.port;
      };

      user = lib.mkOption {
        default = name;
        description = "User to run the service as";
        type = lib.types.str;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.sickbeard = {
      after = [ "network.target" ];
      description = "Sickbeard Server";

      serviceConfig = {
        ExecStart = "${sickbeard}/bin/${sickbeard.pname} --datadir ${cfg.dataDir} --config ${cfg.configFile} --port ${toString cfg.port}";
        Group = cfg.group;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == name) {
      ${name}.gid = config.ids.gids.sickbeard;
    };

    users.users = lib.optionalAttrs (cfg.user == name) {
      ${name} = {
        createHome = true;
        description = "sickbeard user";
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.sickbeard;
      };
    };
  };
}
