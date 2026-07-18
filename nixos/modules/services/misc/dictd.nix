{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dictd;
in

{

  ###### interface

  options = {

    services.dictd = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the DICT.org dictionary server.
        '';

        type = lib.types.bool;
      };

      DBs = lib.mkOption {
        default = with pkgs.dictdDBs; [
          wiktionary
          wordnet
        ];

        defaultText = lib.literalExpression "with pkgs.dictdDBs; [ wiktionary wordnet ]";
        description = "List of databases to make available.";
        example = lib.literalExpression "[ pkgs.dictdDBs.nld2eng ]";
        type = lib.types.listOf lib.types.package;
      };

    };

  };

  ###### implementation

  config =
    let
      dictdb = pkgs.dictDBCollector {
        dictlist = map (x: {
          filename = x;
          name = x.name;
        }) cfg.DBs;
      };
    in
    lib.mkIf cfg.enable {

      environment.etc."dict.conf".text = ''
        server localhost
      '';

      # get the command line client on system path to make some use of the service
      environment.systemPackages = [ pkgs.dict ];

      systemd.services.dictd = {
        description = "DICT.org Dictionary Server";

        environment = {
          LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";
        };

        serviceConfig.ExecStart = "${pkgs.dict}/sbin/dictd -s -c ${dictdb}/share/dictd/dictd.conf --locale en_US.UTF-8";
        # Work around the fact that dictd doesn't handle SIGTERM; it terminates
        # with code 143 instead of exiting with code 0.
        serviceConfig.SuccessExitStatus = [ 143 ];
        serviceConfig.Type = "forking";
        wantedBy = [ "multi-user.target" ];
      };

      users.groups.dictd.gid = config.ids.gids.dictd;

      users.users.dictd = {
        description = "DICT.org dictd server";
        group = "dictd";
        home = "${dictdb}/share/dictd";
        uid = config.ids.uids.dictd;
      };
    };
}
