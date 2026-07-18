{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.rstudio-server;

  rserver-conf = builtins.toFile "rserver.conf" ''
    server-working-dir=${cfg.serverWorkingDir}
    www-address=${cfg.listenAddr}
    ${cfg.rserverExtraConfig}
  '';

  rsession-conf = builtins.toFile "rsession.conf" ''
    ${cfg.rsessionExtraConfig}
  '';

in
{
  options.services.rstudio-server = {
    enable = lib.mkEnableOption "RStudio server";

    package = lib.mkPackageOption pkgs "rstudio-server" {
      example = "rstudioServerWrapper.override { packages = [ pkgs.rPackages.ggplot2 ]; }";
    };

    listenAddr = lib.mkOption {
      default = "127.0.0.1";

      description = ''
        Address to listen on (www-address in rserver.conf).
      '';

      type = lib.types.str;
    };

    rserverExtraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra contents for rserver.conf.
      '';

      type = lib.types.str;
    };

    rsessionExtraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra contents for resssion.conf.
      '';

      type = lib.types.str;
    };

    serverWorkingDir = lib.mkOption {
      default = "/var/lib/rstudio-server";

      description = ''
        Default working directory for server (server-working-dir in rserver.conf).
      '';

      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "pam.d/rstudio".source = "/etc/pam.d/login";
      "rstudio/rserver.conf".source = rserver-conf;
      "rstudio/rsession.conf".source = rsession-conf;
    };

    environment.systemPackages = [ cfg.package ];

    systemd.services.rstudio-server = {
      after = [ "network.target" ];
      description = "Rstudio server";

      restartTriggers = [
        rserver-conf
        rsession-conf
      ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/rserver";
        Restart = "on-failure";
        RuntimeDirectory = "rstudio-server";
        StateDirectory = "rstudio-server";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.rstudio-server = {
        gid = config.ids.gids.rstudio-server;
      };

      users.rstudio-server = {
        description = "rstudio-server";
        group = "rstudio-server";
        uid = config.ids.uids.rstudio-server;
      };
    };

  };

  meta.maintainers = with lib.maintainers; [
    jbedo
  ];
}
