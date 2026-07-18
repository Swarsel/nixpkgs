{
  config,
  lib,
  pkgs,
  ...
}:
let
  streams = builtins.attrNames config.services.liquidsoap.streams;

  streamService =
    name:
    let
      stream = builtins.getAttr name config.services.liquidsoap.streams;
    in
    {
      inherit name;

      value = {
        after = [
          "network-online.target"
          "sound.target"
        ];

        description = "${name} liquidsoap stream";
        path = [ pkgs.wget ];

        serviceConfig = {
          ExecStart = "${pkgs.liquidsoap}/bin/liquidsoap ${stream}";
          LogsDirectory = "liquidsoap";
          Restart = "always";
          User = "liquidsoap";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
in
{

  ##### interface

  options = {

    services.liquidsoap.streams = lib.mkOption {

      default = { };

      description = ''
        Set of Liquidsoap streams to start,
        one systemd service per stream.
      '';

      example = lib.literalExpression ''
        {
          myStream1 = "/etc/liquidsoap/myStream1.liq";
          myStream2 = ./myStream2.liq;
          myStream3 = "out(playlist(\"/srv/music/\"))";
        }
      '';

      type = lib.types.attrsOf (lib.types.either lib.types.path lib.types.str);
    };

  };

  ##### implementation

  config = lib.mkIf (builtins.length streams != 0) {

    systemd.services = builtins.listToAttrs (map streamService streams);
    users.groups.liquidsoap.gid = config.ids.gids.liquidsoap;

    users.users.liquidsoap = {
      createHome = true;
      description = "Liquidsoap streaming user";
      extraGroups = [ "audio" ];
      group = "liquidsoap";
      home = "/var/lib/liquidsoap";
      uid = config.ids.uids.liquidsoap;
    };
  };

}
