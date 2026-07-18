{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.omnom;
  settingsFormat = pkgs.formats.yaml { };

  configFile = settingsFormat.generate "omnom-config.yml" cfg.settings;
in
{
  options = {
    services.omnom = {
      enable = lib.mkEnableOption "Omnom, a webpage bookmarking and snapshotting service";
      package = lib.mkPackageOption pkgs "omnom" { };

      dataDir = lib.mkOption {
        default = "/var/lib/omnom";
        description = "The directory where Omnom stores its data files.";
        type = lib.types.path;
      };

      group = lib.mkOption {
        default = "omnom";
        description = "The Omnom service group.";
        type = lib.types.nonEmptyStr;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to open ports in the firewall.";
        type = lib.types.bool;
      };

      passwordFile = lib.mkOption {
        default = null;
        description = "File containing the password for the SMTP user.";
        type = lib.types.nullOr lib.types.path;
      };

      port = lib.mkOption {
        default = 7331;
        description = "The Omnom service port.";
        type = lib.types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration options for the /etc/omnom/config.yml file.
        '';

        type = lib.types.submodule {
          options = {
            activitypub = {
              privkey = lib.mkOption {
                default = "${cfg.dataDir}/private.pem";

                defaultText = lib.literalExpression ''
                  "''${config.services.omnom.dataDir}/private.pem"
                '';

                description = "ActivityPub private key. Will be generated, by default.";
                type = lib.types.path;
              };

              pubkey = lib.mkOption {
                default = "${cfg.dataDir}/public.pem";

                defaultText = lib.literalExpression ''
                  "''${config.services.omnom.dataDir}/public.pem"
                '';

                description = "ActivityPub public key. Will be generated, by default.";
                type = lib.types.path;
              };
            };

            app = {
              debug = lib.mkEnableOption "debug mode";
              disable_signup = lib.mkEnableOption "restricting user creation";

              results_per_page = lib.mkOption {
                default = 20;
                description = "Number of results per page.";
                type = lib.types.int;
              };
            };

            db = {
              connection = lib.mkOption {
                default = "${cfg.dataDir}/db.sqlite3";

                defaultText = lib.literalExpression ''
                  "''${config.services.omnom.dataDir}/db.sqlite3"
                '';

                description = "Database connection URI.";
                type = lib.types.str;
              };

              type = lib.mkOption {
                default = "sqlite";
                description = "Database type.";
                type = lib.types.enum [ "sqlite" ];
              };
            };

            server = {
              address = lib.mkOption {
                default = "127.0.0.1:${toString cfg.port}";

                defaultText = lib.literalExpression ''
                  "127.0.0.1:''${config.services.omnom.port}"
                '';

                description = "Server address.";
                type = lib.types.str;
              };

              # NOTE: this can't be empty, because it will be overwritten by
              # Omnom's internal default config.
              base_url = lib.mkOption {
                default = "http://127.0.0.1:${toString cfg.port}/";

                defaultText = lib.literalExpression ''
                  "http://''${config.services.omnom.settings.server.address}/"
                '';

                description = "Full server URL.";
                example = "https://local.omnom/xy/";
                internal = true;
                type = lib.types.str;
              };

              secure_cookie = lib.mkOption {
                default = true;
                description = "Whether to limit cookies to a secure channel.";
                type = lib.types.bool;
              };
            };

            smtp = {
              connection_timeout = lib.mkOption {
                default = 5;
                description = "Connection timeout duration in seconds.";
                type = lib.types.int;
              };

              host = lib.mkOption {
                default = "";
                description = "SMTP server hostname.";
                type = lib.types.str;
              };

              port = lib.mkOption {
                default = 25;
                description = "SMTP server port address.";
                type = lib.types.port;
              };

              send_timeout = lib.mkOption {
                default = 10;
                description = "Send timeout duration in seconds.";
                type = lib.types.int;
              };

              sender = lib.mkOption {
                default = "Omnom <omnom@127.0.0.1>";
                description = "Omnom sender e-mail.";
                type = lib.types.str;
              };

              tls = lib.mkEnableOption "Whether TLS encryption should be used.";
              tls_allow_insecure = lib.mkEnableOption "Whether to allow insecure TLS.";
            };

            storage = {
              type = lib.mkOption {
                default = "fs";
                description = "Storage type.";
                type = lib.types.str;
              };
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      user = lib.mkOption {
        default = "omnom";
        description = "The Omnom service user.";
        type = lib.types.nonEmptyStr;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !lib.hasAttr "password" cfg.settings.smtp;

        message = ''
          `services.omnom.settings.smtp.password` must be defined in `services.omnom.passwordFile`.
        '';
      }
    ];

    environment.systemPackages =
      let
        omnom-wrapped = pkgs.writeScriptBin "omnom" ''
          #! ${pkgs.runtimeShell}
          cd ${cfg.dataDir}
          sudo=exec
          if [[ "$USER" != ${cfg.user} ]]; then
            sudo='exec /run/wrappers/bin/sudo -u ${cfg.user}'
          fi
          $sudo ${lib.getExe cfg.package} "$@"
        '';
      in
      [ omnom-wrapped ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    services.omnom = {
      settings.app = {
        static_dir = "${cfg.dataDir}/static";
        template_dir = "${cfg.package}/share/templates";
      };
    };

    systemd.services.omnom = {
      after = [
        "network.target"
        "systemd-tmpfiles-setup.service"
      ];

      path = with pkgs; [
        yq-go # needed by startup script
      ];

      script = ''
        install -m 600 ${configFile} $STATE_DIRECTORY/config.yml

        ${lib.optionalString (cfg.passwordFile != null) ''
          # merge password into main config
          yq -i '.smtp.password = load(env(CREDENTIALS_DIRECTORY) + "/PASSWORD_FILE")' \
            "$STATE_DIRECTORY/config.yml"
        ''}

        ${lib.getExe cfg.package} listen --config "$STATE_DIRECTORY/config.yml"
      '';

      serviceConfig = {
        Group = cfg.group;
        LoadCredential = lib.optional (cfg.passwordFile != null) "PASSWORD_FILE:${cfg.passwordFile}";
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "omnom";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-omnom" =
      let
        settings = {
          inherit (cfg) user group;
        };
      in
      {
        "${cfg.dataDir}"."d" = settings;

        "${cfg.settings.app.static_dir}"."C" = settings // {
          argument = "${cfg.package}/share/static";
        };

        "${cfg.settings.app.static_dir}/data"."d" = settings;
      };

    # TODO: The program needs to run from the dataDir for it the work, which
    # is difficult to do with a DynamicUser.
    # After this has been fixed upstream, remove this and use DynamicUser, instead.
    # See: https://github.com/asciimoo/omnom/issues/21
    users = {
      groups = lib.mkIf (cfg.group == "omnom") { omnom = { }; };

      users = lib.mkIf (cfg.user == "omnom") {
        omnom = {
          group = cfg.group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };
}
