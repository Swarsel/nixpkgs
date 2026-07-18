{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.szurubooru;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    mkPackageOption
    types
    ;
  format = pkgs.formats.yaml { };
  python = pkgs.python3;
in

{
  options = {
    services.szurubooru = {
      enable = mkEnableOption "Szurubooru, an image board engine dedicated for small and medium communities";

      client = {
        package = mkPackageOption pkgs [
          "szurubooru"
          "client"
        ] { };
      };

      dataDir = mkOption {
        default = "/var/lib/szurubooru";

        description = ''
          The path to the data directory in which Szurubooru will store its data.
        '';

        example = "/var/lib/szuru";
        type = types.path;
      };

      database = {
        host = mkOption {
          default = "localhost";
          description = "Host on which the PostgreSQL database runs.";
          example = "192.168.1.2";
          type = types.str;
        };

        name = mkOption {
          default = cfg.database.user;
          defaultText = lib.literalExpression "szurubooru.database.name";
          description = "Name of the PostgreSQL database.";
          example = "szuru";
          type = types.str;
        };

        passwordFile = mkOption {
          description = "A file containing the password for the PostgreSQL user.";
          example = "/run/secrets/szurubooru-db-password";
          type = types.path;
        };

        port = mkOption {
          default = 5432;
          description = "The port under which PostgreSQL listens to.";
          type = types.port;
        };

        user = mkOption {
          default = "szurubooru";
          description = "PostgreSQL user.";
          example = "szuru";
          type = types.str;
        };
      };

      group = mkOption {
        default = "szurubooru";

        description = ''
          Group under which Szurubooru runs.
        '';

        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open the firewall for the port in {option}`services.szurubooru.server.port`.
        '';

        example = true;
        type = types.bool;
      };

      server = {
        package = mkPackageOption pkgs [
          "szurubooru"
          "server"
        ] { };

        host = lib.mkOption {
          default = "127.0.0.1";
          description = "The host address for Szurubooru to bind to.";
          example = "0.0.0.0";
          type = types.str;
        };

        port = mkOption {
          default = 8080;

          description = ''
            Port to expose HTTP service.
          '';

          example = 9000;
          type = types.port;
        };

        settings = mkOption {
          description = ''
            Configuration to write to {file}`config.yaml`.
            See <https://github.com/rr-/szurubooru/blob/master/server/config.yaml.dist> for more information.
          '';

          type = types.submodule {
            options = {
              data_dir = mkOption {
                default = "${cfg.dataDir}/data";
                defaultText = lib.literalExpression ''"''${services.szurubooru.dataDir}/data"'';
                description = "Path to the static files.";
                example = "/srv/szurubooru/data";
                type = types.path;
              };

              data_url = mkOption {
                default = "${cfg.server.settings.domain}/data/";
                defaultText = lib.literalExpression ''"''${services.szurubooru.server.settings.domain}/data/"'';
                description = "Full URL to the data endpoint.";
                example = "http://example.com/content/";
                type = types.str;
              };

              debug = mkOption {
                default = 0;
                description = "Whether to generate server logs.";
                example = 1;
                type = types.int;
              };

              delete_source_files = mkOption {
                default = "no";
                description = "Whether to delete thumbnails and source files on post delete.";
                example = "yes";

                type = types.enum [
                  "yes"
                  "no"
                ];
              };

              domain = mkOption {
                description = "Full URL to the homepage of this szurubooru site (with no trailing slash).";
                example = "http://example.com";
                type = types.str;
              };

              name = mkOption {
                default = "szurubooru";
                description = "Name shown in the website title and on the front page.";
                example = "Szuru";
                type = types.str;
              };

              # NOTE: this is not a real upstream option
              secretFile = mkOption {
                description = ''
                  File containing a secret used to salt the users' password hashes and generate filenames for static content.
                '';

                example = "/run/secrets/szurubooru-server-secret";
                type = types.path;
              };

              show_sql = mkOption {
                default = 0;
                description = "Whether to show SQL in server logs.";
                example = 1;
                type = types.int;
              };

              smtp = {
                host = mkOption {
                  default = null;
                  description = "Host of the SMTP server used to send reset password.";
                  example = "localhost";
                  type = types.nullOr types.str;
                };

                # NOTE: this is not a real upstream option
                passFile = mkOption {
                  default = null;
                  description = "File containing the password associated to the given user for the SMTP server.";
                  example = "/run/secrets/szurubooru-smtp-pass";
                  type = types.nullOr types.path;
                };

                port = mkOption {
                  default = null;
                  description = "Port of the SMTP server.";
                  example = 25;
                  type = types.nullOr types.port;
                };

                user = mkOption {
                  default = null;
                  description = "User to connect to the SMTP server.";
                  example = "bot";
                  type = types.nullOr types.str;
                };
              };
            };

            freeformType = format.type;
          };
        };

        threads = mkOption {
          default = 4;
          description = "Number of waitress threads to start.";
          example = 6;
          type = types.int;
        };
      };

      user = mkOption {
        default = "szurubooru";

        description = ''
          User account under which Szurubooru runs.
        '';

        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.server.port ];

    systemd.services.szurubooru =
      let
        configFile = format.generate "config.yaml" (
          lib.pipe cfg.server.settings [
            (
              settings:
              lib.recursiveUpdate settings {
                database = "postgresql://${cfg.database.user}:$SZURUBOORU_DATABASE_PASSWORD@${cfg.database.host}:${toString cfg.database.port}/${cfg.database.name}";
                secret = "$SZURUBOORU_SECRET";
                secretFile = null;
                smtp.enable = null;
                smtp.pass = if settings.smtp.passFile != null then "$SZURUBOORU_SMTP_PASS" else null;
                smtp.passFile = null;
              }
            )
            (lib.filterAttrsRecursive (_: x: x != null))
          ]
        );
      in
      {
        after = [
          "network.target"
          "network-online.target"
        ];

        before = [ "szurubooru-client.service" ];
        description = "Server of Szurubooru, an image board engine dedicated for small and medium communities";

        path = with pkgs; [
          ffmpeg_4-full
        ];

        script = ''
          export SZURUBOORU_SECRET="$(<$CREDENTIALS_DIRECTORY/secret)"
          export SZURUBOORU_DATABASE_PASSWORD="$(<$CREDENTIALS_DIRECTORY/database)"
          ${lib.optionalString (cfg.server.settings.smtp.passFile != null) ''
            export SZURUBOORU_SMTP_PASS=$(<$CREDENTIALS_DIRECTORY/smtp)
          ''}
          install -m0640 ${cfg.server.package.src}/config.yaml.dist ${cfg.dataDir}/config.yaml.dist
          touch ${cfg.dataDir}/config.yaml
          chmod 0640 ${cfg.dataDir}/config.yaml
          ${lib.getExe pkgs.envsubst} -i ${configFile} -o ${cfg.dataDir}/config.yaml
          sed 's|script_location = |script_location = ${cfg.server.package.src}/|' ${cfg.server.package.src}/alembic.ini > ${cfg.dataDir}/alembic.ini
          ${lib.getExe cfg.server.package.alembic} upgrade head
          ${lib.getExe cfg.server.package.waitress} --host ${cfg.server.host} --port ${toString cfg.server.port} --threads ${toString cfg.server.threads} szurubooru.facade:app
        '';

        serviceConfig = {
          Group = cfg.group;

          LoadCredential = [
            "secret:${cfg.server.settings.secretFile}"
            "database:${cfg.database.passwordFile}"
          ]
          ++ (lib.optionals (cfg.server.settings.smtp.passFile != null) [
            "smtp:${cfg.server.settings.smtp.passFile}"
          ]);

          Restart = "on-failure";
          StateDirectory = mkIf (cfg.dataDir == "/var/lib/szurubooru") "szurubooru";
          Type = "simple";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        };

        wantedBy = [
          "multi-user.target"
          "szurubooru-client.service"
        ];

        wants = [ "network-online.target" ];
      };

    users.groups = mkIf (cfg.group == "szurubooru") {
      szurubooru = { };
    };

    users.users = mkIf (cfg.user == "szurubooru") {
      szurubooru = {
        description = "Szurubooru Daemon user";
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta = {
    doc = ./szurubooru.md;
    maintainers = with lib.maintainers; [ ratcornu ];
  };
}
