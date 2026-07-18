{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.alerta;

  alertaConf = pkgs.writeTextFile {
    name = "alertad.conf";

    text = ''
      DATABASE_URL = '${cfg.databaseUrl}'
      DATABASE_NAME = '${cfg.databaseName}'
      LOG_FILE = '${cfg.logDir}/alertad.log'
      LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
      CORS_ORIGINS = [ ${lib.concatMapStringsSep ", " (s: "\"" + s + "\"") cfg.corsOrigins} ];
      AUTH_REQUIRED = ${if cfg.authenticationRequired then "True" else "False"}
      SIGNUP_ENABLED = ${if cfg.signupEnabled then "True" else "False"}
      ${cfg.extraConfig}
    '';
  };
in
{
  options.services.alerta = {
    enable = lib.mkEnableOption "alerta";

    authenticationRequired = lib.mkOption {
      default = false;
      description = "Whether users must authenticate when using the web UI or command-line tool";
      type = lib.types.bool;
    };

    bind = lib.mkOption {
      default = "0.0.0.0";
      description = "Address to bind to. The default is to bind to all addresses";
      type = lib.types.str;
    };

    corsOrigins = lib.mkOption {
      default = [
        "http://localhost"
        "http://localhost:5000"
      ];

      description = "List of URLs that can access the API for Cross-Origin Resource Sharing (CORS)";
      type = lib.types.listOf lib.types.str;
    };

    databaseName = lib.mkOption {
      default = "monitoring";
      description = "Name of the database instance to connect to";
      type = lib.types.str;
    };

    databaseUrl = lib.mkOption {
      default = "mongodb://localhost";
      description = "URL of the MongoDB or PostgreSQL database to connect to";
      type = lib.types.str;
    };

    extraConfig = lib.mkOption {
      default = "";
      description = "These lines go into alertad.conf verbatim.";
      type = lib.types.lines;
    };

    logDir = lib.mkOption {
      default = "/var/log/alerta";
      description = "Location where the logfiles are stored";
      type = lib.types.path;
    };

    port = lib.mkOption {
      default = 5000;
      description = "Port of Alerta";
      type = lib.types.port;
    };

    signupEnabled = lib.mkOption {
      default = true;
      description = "Whether to prevent sign-up of new users via the web UI";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.alerta ];

    systemd.services.alerta = {
      after = [ "network.target" ];
      description = "Alerta Monitoring System";

      environment = {
        ALERTA_SVR_CONF_FILE = alertaConf;
      };

      serviceConfig = {
        ExecStart = "${pkgs.alerta-server}/bin/alertad run --port ${toString cfg.port} --host ${cfg.bind}";
        Group = "alerta";
        User = "alerta";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-alerta".${cfg.logDir}.d = {
      group = "alerta";
      user = "alerta";
    };

    users.groups.alerta = {
      gid = config.ids.gids.alerta;
    };

    users.users.alerta = {
      description = "Alerta user";
      uid = config.ids.uids.alerta;
    };
  };
}
