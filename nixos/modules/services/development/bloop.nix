{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.bloop;

in
{

  options.services.bloop = {
    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Specifies additional command line argument to pass to bloop
        java process.
      '';

      example = [
        "-J-Xmx2G"
        "-J-XX:MaxInlineLevel=20"
        "-J-XX:+UseParallelGC"
      ];

      type = lib.types.listOf lib.types.str;
    };

    install = lib.mkOption {
      default = false;

      description = ''
        Whether to install a user service for the Bloop server.

        The service must be manually started for each user with
        "systemctl --user start bloop".
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf (cfg.install) {
    environment.systemPackages = [ pkgs.bloop ];

    systemd.user.services.bloop = {
      description = "Bloop Scala build server";

      environment = {
        PATH = lib.mkForce "${lib.makeBinPath [ config.programs.java.package ]}";
      };

      serviceConfig = {
        ExecStart = "${pkgs.bloop}/bin/bloop start";
        ExecStop = "${pkgs.bloop}/bin/bloop exit";
        Restart = "always";
        Type = "forking";
      };
    };
  };
}
