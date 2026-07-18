{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) htpdate;

  cfg = config.services.htpdate;
in

{

  ###### interface

  options = {

    services.htpdate = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable htpdate daemon.
        '';

        type = lib.types.bool;
      };

      extraOptions = lib.mkOption {
        default = "";

        description = ''
          Additional command line arguments to pass to htpdate.
        '';

        type = lib.types.str;
      };

      proxy = lib.mkOption {
        default = "";

        description = ''
          HTTP proxy used for requests.
        '';

        example = "127.0.0.1:8118";
        type = lib.types.str;
      };

      servers = lib.mkOption {
        default = [ "www.google.com" ];

        description = ''
          HTTP servers to use for time synchronization.
        '';

        type = lib.types.listOf lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.htpdate = {
      description = "htpdate daemon";

      serviceConfig = {
        ExecStart = lib.concatStringsSep " " [
          "${htpdate}/bin/htpdate"
          "-D -u nobody"
          "-a -s"
          "-l"
          "${lib.optionalString (cfg.proxy != "") "-P ${cfg.proxy}"}"
          "${cfg.extraOptions}"
          "${lib.concatStringsSep " " cfg.servers}"
        ];

        PIDFile = "/run/htpdate.pid";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

}
