{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.papra;
  defaultUser = "papra";
  defaultGroup = "papra";
  defaultEnv = {
    DATABASE_URL = "file:/var/lib/papra/db.sqlite";
    DOCUMENT_STORAGE_FILESYSTEM_ROOT = "/var/lib/papra/local-documents";
    PORT = 1221;
    SERVER_SERVE_PUBLIC_DIR = true;
  };
in
{
  options = {
    services.papra = {
      enable = lib.mkEnableOption "Papra";
      package = lib.mkPackageOption pkgs "papra" { };

      environment = lib.mkOption {
        default = defaultEnv;
        description = "Environment variables to set for the service.";

        example = {
          PORT = 1221;
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            float
            bool
            path
            package
          ]);
      };

      environmentFile = lib.mkOption {
        default = null;
        description = "Environment file, usefult to provide secrets to the service";
        type = with lib.types; nullOr path;
      };

      group = lib.mkOption {
        default = defaultGroup;

        description = ''
          If the default user "${defaultUser}" is configured then this is the primary
          group of that user.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = defaultUser;
        description = "User under which Papra runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.papra = {
      environment =
        let
          environmentwithDefaults = defaultEnv // cfg.environment;
        in
        (lib.mapAttrs (
          _: s: if lib.isBool s then lib.boolToString s else toString s
        ) environmentwithDefaults);

      serviceConfig = {
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${lib.getExe' cfg.package "papra"}";
        ExecStartPre = "${lib.getExe' cfg.package "papra-migrate-up"}";
        Group = cfg.group;
        Restart = "on-failure";
        StateDirectory = "papra";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups = lib.optionalAttrs (cfg.group == defaultGroup) {
        "${defaultGroup}" = { };
      };

      users = lib.optionalAttrs (cfg.user == defaultUser) {
        "${defaultUser}" = {
          description = "Papra service user";
          group = cfg.group;
          isSystemUser = true;
        };
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ wariuccio ];
  };
}
