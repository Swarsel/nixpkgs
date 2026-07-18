# SVN server
{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.svnserve;

in

{

  ###### interface

  options = {

    services.svnserve = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable svnserve to serve Subversion repositories through the SVN protocol.";
        type = lib.types.bool;
      };

      svnBaseDir = lib.mkOption {
        default = "/repos";
        description = "Base directory from which Subversion repositories are accessed.";
        type = lib.types.str;
      };
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.services.svnserve = {
      after = [ "network.target" ];
      preStart = "mkdir -p ${cfg.svnBaseDir}";
      script = "${pkgs.subversion.out}/bin/svnserve -r ${cfg.svnBaseDir} -d --foreground --pid-file=/run/svnserve.pid";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
