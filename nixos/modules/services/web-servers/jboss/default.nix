{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.jboss;

  jbossService = pkgs.stdenv.mkDerivation {
    inherit (pkgs) jboss su;

    inherit (cfg)
      tempDir
      logDir
      libUrl
      deployDir
      serverDir
      user
      useJK
      ;

    builder = ./builder.sh;
    name = "jboss-server";
  };

in

{

  ###### interface

  options = {

    services.jboss = {

      enable = mkOption {
        default = false;
        description = "Whether to enable JBoss. WARNING : this package is outdated and is known to have vulnerabilities.";
        type = types.bool;
      };

      deployDir = mkOption {
        default = "/nix/var/nix/profiles/default/server/default/deploy/";
        description = "Location of the deployment files";
        type = types.str;
      };

      libUrl = mkOption {
        default = "file:///nix/var/nix/profiles/default/server/default/lib";
        description = "Location where the shared library JARs are stored";
        type = types.str;
      };

      logDir = mkOption {
        default = "/var/log/jboss";
        description = "Location of the logfile directory of JBoss";
        type = types.str;
      };

      serverDir = mkOption {
        default = "/var/jboss/server";
        description = "Location of the server instance files";
        type = types.str;
      };

      tempDir = mkOption {
        default = "/tmp";
        description = "Location where JBoss stores its temp files";
        type = types.str;
      };

      useJK = mkOption {
        default = false;
        description = "Whether to use to connector to the Apache HTTP server";
        type = types.bool;
      };

      user = mkOption {
        default = "nobody";
        description = "User account under which jboss runs.";
        type = types.str;
      };

    };

  };

  ###### implementation

  config = mkIf config.services.jboss.enable {
    systemd.services.jboss = {
      description = "JBoss server";
      script = "${jbossService}/bin/control start";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
