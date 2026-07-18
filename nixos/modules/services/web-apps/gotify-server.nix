{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gotify;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [
        "services"
        "gotify"
        "port"
      ]
      [
        "services"
        "gotify"
        "environment"
        "GOTIFY_SERVER_PORT"
      ]
    )
  ];

  options.services.gotify = {
    enable = lib.mkEnableOption "Gotify webserver";
    package = lib.mkPackageOption pkgs "gotify-server" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Config environment variables for the gotify-server.
        See <https://gotify.net/docs/config> for more details.
      '';

      example = {
        GOTIFY_DATABASE_DIALECT = "sqlite3";
        GOTIFY_SERVER_PORT = 8080;
      };

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
        ]
      );
    };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files containing additional config environment variables for gotify-server.
        Secrets should be set in environmentFiles instead of environment.
      '';

      type = lib.types.listOf lib.types.path;
    };

    stateDirectoryName = lib.mkOption {
      default = "gotify-server";

      description = ''
        The name of the directory below {file}`/var/lib` where
        gotify stores its runtime data.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.gotify-server = {
      after = [ "network.target" ];
      description = "Simple server for sending and receiving messages";
      environment = lib.mapAttrs (_: toString) cfg.environment;

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        Restart = "always";
        StateDirectory = cfg.stateDirectoryName;
        WorkingDirectory = "/var/lib/${cfg.stateDirectoryName}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ DCsunset ];
}
