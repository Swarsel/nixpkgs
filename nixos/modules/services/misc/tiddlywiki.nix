{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.tiddlywiki;
  listenParams = lib.concatStrings (
    lib.mapAttrsToList (n: v: " '${n}=${toString v}' ") cfg.listenOptions
  );
  exe = lib.getExe pkgs.tiddlywiki;
  name = "tiddlywiki";
  dataDir = "/var/lib/" + name;

in
{

  options.services.tiddlywiki = {

    enable = lib.mkEnableOption "TiddlyWiki nodejs server";

    listenOptions = lib.mkOption {
      default = { };

      description = ''
        Parameters passed to `--listen` command.
        Refer to <https://tiddlywiki.com/#WebServer>
        for details on supported values.
      '';

      example = {
        credentials = "../credentials.csv";
        port = 3456;
        readers = "(authenticated)";
      };

      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.tiddlywiki = {
        after = [ "network.target" ];
        description = "TiddlyWiki nodejs server";

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${exe} ${dataDir} --listen ${listenParams}";
          ExecStartPre = "-${exe} ${dataDir} --init server";
          Restart = "on-failure";
          StateDirectory = name;
          Type = "simple";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
