{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let

  name = "headphones";

  cfg = config.services.headphones;
  opt = options.services.headphones;

in

{

  ###### interface

  options = {
    services.headphones = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the headphones server.";
        type = lib.types.bool;
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

      host = lib.mkOption {
        default = "localhost";
        description = "Host to listen on.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8181;
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

    systemd.services.headphones = {
      after = [ "network.target" ];
      description = "Headphones Server";

      serviceConfig = {
        ExecStart = "${pkgs.headphones}/bin/headphones --datadir ${cfg.dataDir} --config ${cfg.configFile} --host ${cfg.host} --port ${toString cfg.port}";
        Group = cfg.group;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == name) {
      ${name}.gid = config.ids.gids.headphones;
    };

    users.users = lib.optionalAttrs (cfg.user == name) {
      ${name} = {
        createHome = true;
        description = "headphones user";
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.headphones;
      };
    };
  };
}
