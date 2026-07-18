{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.trilium-server;
  configIni = pkgs.writeText "trilium-config.ini" ''
    [General]
    # Instance name can be used to distinguish between different instances
    instanceName=${cfg.instanceName}

    # Disable automatically generating desktop icon
    noDesktopIcon=true
    noBackup=${lib.boolToString cfg.noBackup}
    noAuthentication=${lib.boolToString cfg.noAuthentication}

    [Network]
    # host setting is relevant only for web deployments - set the host on which the server will listen
    host=${cfg.host}
    # port setting is relevant only for web deployments, desktop builds run on random free port
    port=${toString cfg.port}
    # true for TLS/SSL/HTTPS (secure), false for HTTP (unsecure).
    https=false
  '';
in
{

  options.services.trilium-server = with lib; {
    enable = mkEnableOption "trilium-server";
    package = mkPackageOption pkgs "trilium-server" { };

    dataDir = mkOption {
      default = "/var/lib/trilium";

      description = ''
        The directory storing the notes database and the configuration.
      '';

      type = types.str;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        File to load as the environment file. This allows you to pass secrets in without writing
        to the nix store.
      '';

      example = "/secrets/trilium.env";
      type = types.nullOr types.path;
    };

    host = mkOption {
      default = "127.0.0.1";

      description = ''
        The host address to bind to (defaults to localhost).
      '';

      type = types.str;
    };

    instanceName = mkOption {
      default = "Trilium";

      description = ''
        Instance name used to distinguish between different instances
      '';

      type = types.str;
    };

    nginx = mkOption {
      default = { };

      description = ''
        Configuration for nginx reverse proxy.
      '';

      type = types.submodule {
        options = {
          enable = mkOption {
            default = false;

            description = ''
              Configure the nginx reverse proxy settings.
            '';

            type = types.bool;
          };

          hostName = mkOption {
            description = ''
              The hostname use to setup the virtualhost configuration
            '';

            type = types.str;
          };
        };
      };
    };

    noAuthentication = mkOption {
      default = false;

      description = ''
        If set to true, no password is required to access the web frontend.
      '';

      type = types.bool;
    };

    noBackup = mkOption {
      default = false;

      description = ''
        Disable periodic database backups.
      '';

      type = types.bool;
    };

    port = mkOption {
      default = 8080;

      description = ''
        The port number to bind to.
      '';

      type = types.port;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        systemd.services.trilium-server = {
          environment.TRILIUM_DATA_DIR = cfg.dataDir;

          serviceConfig = {
            EnvironmentFile = cfg.environmentFile;
            ExecStart = lib.getExe cfg.package;
            Group = "trilium";
            PrivateTmp = "true";
            User = "trilium";
          };

          wantedBy = [ "multi-user.target" ];
        };

        systemd.tmpfiles.rules = [
          "d  ${cfg.dataDir}            0750 trilium trilium - -"
          "L+ ${cfg.dataDir}/config.ini -    -       -       - ${configIni}"
        ];

        users.groups.trilium = { };

        users.users.trilium = {
          description = "Trilium User";
          group = "trilium";
          home = cfg.dataDir;
          isSystemUser = true;
        };

      }

      (lib.mkIf cfg.nginx.enable {
        services.nginx = {
          enable = true;

          virtualHosts."${cfg.nginx.hostName}" = {
            extraConfig = ''
              client_max_body_size 0;
            '';

            locations."/" = {
              extraConfig = ''
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
              '';

              proxyPass = "http://${cfg.host}:${toString cfg.port}/";
            };
          };
        };
      })
    ]
  );

  meta.maintainers = with lib.maintainers; [ fliegendewurst ];
}
