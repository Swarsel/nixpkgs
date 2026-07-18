{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.suwayomi-server;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  format = pkgs.formats.hocon { };
in
{
  options = {
    services.suwayomi-server = {
      enable = mkEnableOption "Suwayomi, a free and open source manga reader server that runs extensions built for Tachiyomi";
      package = lib.mkPackageOption pkgs "suwayomi-server" { };

      dataDir = mkOption {
        default = "/var/lib/suwayomi-server";

        description = ''
          The path to the data directory in which Suwayomi-Server will download scans.
        '';

        example = "/var/data/mangas";
        type = types.path;
      };

      group = mkOption {
        default = "suwayomi";

        description = ''
          Group under which Suwayomi-Server runs.
        '';

        example = "medias";
        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open the firewall for the port in {option}`services.suwayomi-server.settings.server.port`.
        '';

        type = types.bool;
      };

      settings = mkOption {
        default = { };

        description = ''
          Configuration to write to {file}`server.conf`.
          See <https://github.com/Suwayomi/Suwayomi-Server/wiki/Configuring-Suwayomi-Server> for more information.
        '';

        example = {
          server.socksProxyEnabled = true;
          server.socksProxyHost = "yourproxyhost.com";
          server.socksProxyPort = "8080";
        };

        type = types.submodule {
          options = {
            server = {
              basicAuthEnabled = mkEnableOption ''
                basic access authentication for Suwayomi-Server.
                Enabling this option is useful when hosting on a public network/the Internet
              '';

              # NOTE: this is not a real upstream option
              basicAuthPasswordFile = mkOption {
                default = null;

                description = ''
                  The password file containing the value that you have to provide when authenticating.
                '';

                example = "/var/secrets/suwayomi-server-password";
                type = types.nullOr types.path;
              };

              basicAuthUsername = mkOption {
                default = null;

                description = ''
                  The username value that you have to provide when authenticating.
                '';

                type = types.nullOr types.str;
              };

              downloadAsCbz = mkOption {
                default = false;

                description = ''
                  Download chapters as `.cbz` files.
                '';

                type = types.bool;
              };

              extensionRepos = mkOption {
                default = [ ];

                description = ''
                  URL of repositories from which the extensions can be installed.
                '';

                example = [
                  "https://raw.githubusercontent.com/MY_ACCOUNT/MY_REPO/repo/index.min.json"
                ];

                type = types.listOf types.str;
              };

              ip = mkOption {
                default = "0.0.0.0";

                description = ''
                  The ip that Suwayomi will bind to.
                '';

                example = "127.0.0.1";
                type = types.str;
              };

              localSourcePath = mkOption {
                default = cfg.dataDir;
                defaultText = lib.literalExpression "suwayomi-server.dataDir";

                description = ''
                  Path to the local source folder.
                '';

                example = "/var/data/local_mangas";
                type = types.path;
              };

              port = mkOption {
                default = 8080;

                description = ''
                  The port that Suwayomi will listen to.
                '';

                example = 4567;
                type = types.port;
              };

              systemTrayEnabled = mkOption {
                default = false;

                description = ''
                  Whether to enable a system tray icon, if possible.
                '';

                type = types.bool;
              };
            };
          };

          freeformType = format.type;
        };
      };

      user = mkOption {
        default = "suwayomi";

        description = ''
          User account under which Suwayomi-Server runs.
        '';

        example = "root";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion =
          with cfg.settings.server;
          basicAuthEnabled -> (basicAuthUsername != null && basicAuthPasswordFile != null);

        message = ''
          [suwayomi-server]: the username and the password file cannot be null when the basic auth is enabled
        '';
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.server.port ];

    systemd.services.suwayomi-server =
      let
        configFile = format.generate "server.conf" (
          lib.pipe cfg.settings [
            (
              settings:
              lib.recursiveUpdate settings {
                server.basicAuthPassword =
                  if settings.server.basicAuthEnabled then "$TACHIDESK_SERVER_BASIC_AUTH_PASSWORD" else null;

                server.basicAuthPasswordFile = null;
              }
            )
            (lib.filterAttrsRecursive (_: x: x != null))
          ]
        );
      in
      {
        after = [ "network-online.target" ];
        description = "A free and open source manga reader server that runs extensions built for Tachiyomi.";

        script = ''
          ${lib.optionalString cfg.settings.server.basicAuthEnabled ''
            export TACHIDESK_SERVER_BASIC_AUTH_PASSWORD="$(<${cfg.settings.server.basicAuthPasswordFile})"
          ''}
          ${lib.getExe pkgs.envsubst} -i ${configFile} -o ${cfg.dataDir}/.local/share/Tachidesk/server.conf
          ${lib.getExe cfg.package} -Dsuwayomi.tachidesk.config.server.rootDir=${cfg.dataDir}
        '';

        serviceConfig = {
          Group = cfg.group;
          Restart = "on-failure";
          StateDirectory = mkIf (cfg.dataDir == "/var/lib/suwayomi-server") "suwayomi-server";
          Type = "simple";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

    systemd.tmpfiles.settings."10-suwayomi-server" = {
      "${cfg.dataDir}/.local/share/Tachidesk".d = {
        inherit (cfg) user group;
        mode = "0700";
      };
    };

    users.groups = mkIf (cfg.group == "suwayomi") {
      suwayomi = { };
    };

    users.users = mkIf (cfg.user == "suwayomi") {
      suwayomi = {
        description = "Suwayomi Daemon user";
        group = cfg.group;
        # Need to set the user home because the package writes to ~/.local/Tachidesk
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };

  meta = {
    doc = ./suwayomi-server.md;
    maintainers = with lib.maintainers; [ ratcornu ];
  };
}
