{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.peerflix;
  opt = options.services.peerflix;

  configFile = pkgs.writeText "peerflix-config.json" ''
    {
      "connections": 50,
      "tmp": "${cfg.downloadDir}"
    }
  '';

in
{

  ###### interface

  options.services.peerflix = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable peerflix service.";
      type = lib.types.bool;
    };

    downloadDir = lib.mkOption {
      default = "${cfg.stateDir}/torrents";
      defaultText = lib.literalExpression ''"''${config.${opt.stateDir}}/torrents"'';
      description = "Peerflix temporary download directory.";
      type = lib.types.path;
    };

    stateDir = lib.mkOption {
      default = "/var/lib/peerflix";
      description = "Peerflix state directory.";
      type = lib.types.path;
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.services.peerflix = {
      after = [ "network.target" ];
      description = "Peerflix Daemon";
      environment.HOME = cfg.stateDir;

      preStart = ''
        mkdir -p "${cfg.stateDir}"/{torrents,.config/peerflix-server}
        ln -fs "${configFile}" "${cfg.stateDir}/.config/peerflix-server/config.json"
      '';

      serviceConfig = {
        ExecStart = "${pkgs.peerflix-server}/bin/peerflix-server";
        User = "peerflix";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' - peerflix - - -"
    ];

    users.groups.peerflix = { };

    users.users.peerflix = {
      group = "peerflix";
      isSystemUser = true;
    };
  };
}
