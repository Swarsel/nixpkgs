{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkDefault
    mkIf
    types
    literalExpression
    ;

  cfg = config.services.mobilizon;

  user = "mobilizon";
  group = "mobilizon";

  settingsFormat = pkgs.formats.elixirConf { elixir = cfg.package.elixirPackage; };

  configFile = settingsFormat.generate "mobilizon-config.exs" cfg.settings;

  # Make a package containing launchers with the correct envirenment, instead of
  # setting it with systemd services, so that the user can also use them without
  # troubles
  launchers =
    pkgs.runCommand "${cfg.package.pname}-launchers-${cfg.package.version}"
      {
        nativeBuildInputs = with pkgs; [ makeWrapper ];
        src = cfg.package;
      }
      ''
        mkdir -p $out/bin

        makeWrapper \
          $src/bin/mobilizon \
          $out/bin/mobilizon \
          --run '. ${secretEnvFile}' \
          --set MOBILIZON_CONFIG_PATH "${configFile}" \
          --set-default RELEASE_TMP "/tmp"

        makeWrapper \
          $src/bin/mobilizon_ctl \
          $out/bin/mobilizon_ctl \
          --run '. ${secretEnvFile}' \
          --set MOBILIZON_CONFIG_PATH "${configFile}" \
          --set-default RELEASE_TMP "/tmp"
      '';

  repoSettings = cfg.settings.":mobilizon"."Mobilizon.Storage.Repo";
  instanceSettings = cfg.settings.":mobilizon".":instance";

  isLocalPostgres = repoSettings.socket_dir != null;

  dbUser = if repoSettings.username != null then repoSettings.username else "mobilizon";

  postgresql = config.services.postgresql.package;
  postgresqlSocketDir = "/run/postgresql";

  secretEnvFile = "/var/lib/mobilizon/secret-env.sh";
in
{
  options = {
    services.mobilizon = {
      enable = mkEnableOption "Mobilizon federated organization and mobilization platform";
      package = mkPackageOption pkgs "mobilizon" { };

      nginx.enable = lib.mkOption {
        default = true;

        description = ''
          Whether an Nginx virtual host should be
          set up to serve Mobilizon.
        '';

        type = lib.types.bool;
      };

      settings = mkOption {
        default = { };

        description = ''
          Mobilizon Elixir documentation, see
          <https://docs.joinmobilizon.org/administration/configure/reference/>
          for supported values.
        '';

        type =
          let
            elixirTypes = settingsFormat.lib.types;
          in
          types.submodule {
            options = {
              ":mobilizon" = {

                ":instance" = {
                  email_from = mkOption {
                    defaultText = literalExpression ''
                      noreply@''${settings.":mobilizon".":instance".hostname}
                    '';

                    description = ''
                      The email for the From: header in emails
                    '';

                    type = elixirTypes.str;
                  };

                  email_reply_to = mkOption {
                    defaultText = literalExpression ''
                      ''${email_from}
                    '';

                    description = ''
                      The email for the Reply-To: header in emails
                    '';

                    type = elixirTypes.str;
                  };

                  hostname = mkOption {
                    description = ''
                      Your instance's hostname
                    '';

                    type = elixirTypes.str;
                  };

                  name = mkOption {
                    description = ''
                      The fallback instance name if not configured into the admin UI
                    '';

                    type = elixirTypes.str;
                  };
                };

                "Mobilizon.Storage.Repo" = {
                  database = mkOption {
                    default = "mobilizon_prod";

                    description = ''
                      Name of the database
                    '';

                    type = types.nullOr elixirTypes.str;
                  };

                  socket_dir = mkOption {
                    default = postgresqlSocketDir;

                    description = ''
                      Path to the postgres socket directory.

                      Set this to null if you want to connect to a remote database.

                      If non-null, the local PostgreSQL server will be configured with
                      the configured database, permissions, and required extensions.

                      If connecting to a remote database, please follow the
                      instructions on how to setup your database:
                      <https://docs.joinmobilizon.org/administration/install/release/#database-setup>
                    '';

                    type = types.nullOr elixirTypes.str;
                  };

                  username = mkOption {
                    default = user;

                    description = ''
                      User used to connect to the database
                    '';

                    type = types.nullOr elixirTypes.str;
                  };
                };

                "Mobilizon.Web.Endpoint" = {
                  has_reverse_proxy = mkOption {
                    default = true;

                    description = ''
                      Whether you use a reverse proxy
                    '';

                    type = elixirTypes.bool;
                  };

                  http = {
                    ip = mkOption {
                      default = settingsFormat.lib.mkTuple [
                        0
                        0
                        0
                        0
                        0
                        0
                        0
                        1
                      ];

                      description = ''
                        The IP address to listen on. Defaults to [::1] notated as a byte tuple.
                      '';

                      type = elixirTypes.tuple;
                    };

                    port = mkOption {
                      default = 4000;

                      description = ''
                        The port to run the server
                      '';

                      type = elixirTypes.port;
                    };
                  };

                  url.host = mkOption {
                    defaultText = lib.literalMD ''
                      ''${settings.":mobilizon".":instance".hostname}
                    '';

                    description = ''
                      Your instance's hostname for generating URLs throughout the app
                    '';

                    type = elixirTypes.str;
                  };
                };
              };
            };

            freeformType = settingsFormat.type;
          };
      };
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion =
          cfg.nginx.enable
          -> (
            cfg.settings.":mobilizon"."Mobilizon.Web.Endpoint".http.ip == settingsFormat.lib.mkTuple [
              0
              0
              0
              0
              0
              0
              0
              1
            ]
          );

        message = "Setting the IP mobilizon listens on is only possible when the nginx config is not used, as it is hardcoded there.";
      }
    ];

    # So that we have the `mobilizon` and `mobilizon_ctl` commands.
    # The `mobilizon remote` command is useful for dropping a shell into the
    # running Mobilizon instance, and `mobilizon_ctl` is used for common
    # management tasks (e.g. adding users).
    environment.systemPackages = [ launchers ];

    services.mobilizon.settings = {
      ":mobilizon" = {
        ":instance" = {
          demo = mkDefault false;
          email_from = mkDefault "noreply@${instanceSettings.hostname}";
          email_reply_to = mkDefault instanceSettings.email_from;
          registrations_open = mkDefault false;
        };

        "Mobilizon.Storage.Repo" = {
          # Forced by upstream since it uses PostgreSQL-specific extensions
          adapter = settingsFormat.lib.mkAtom "Ecto.Adapters.Postgres";
          pool_size = mkDefault 10;
        };

        "Mobilizon.Web.Auth.Guardian".secret_key = settingsFormat.lib.mkGetEnv {
          envVariable = "MOBILIZON_AUTH_SECRET";
        };

        "Mobilizon.Web.Endpoint" = {
          secret_key_base = settingsFormat.lib.mkGetEnv { envVariable = "MOBILIZON_INSTANCE_SECRET"; };
          server = true;
          url.host = mkDefault instanceSettings.hostname;
        };
      };

      ":tzdata".":data_dir" = "/var/lib/mobilizon/tzdata/";
    };

    # Nginx config taken from support/nginx/mobilizon-release.conf
    services.nginx =
      let
        inherit (cfg.settings.":mobilizon".":instance") hostname;
        proxyPass = "http://[::1]:" + toString cfg.settings.":mobilizon"."Mobilizon.Web.Endpoint".http.port;
      in
      lib.mkIf cfg.nginx.enable {
        enable = true;

        virtualHosts."${hostname}" = {
          enableACME = lib.mkDefault true;
          forceSSL = lib.mkDefault true;

          locations."/" = {
            inherit proxyPass;

            extraConfig = ''
              expires off;
              add_header Cache-Control "public, max-age=0, s-maxage=0, must-revalidate" always;
            '';

            proxyWebsockets = true;
            recommendedProxySettings = lib.mkDefault true;
          };

          locations."~ ^/(assets|img)" = {
            extraConfig = ''
              access_log off;
              add_header Cache-Control "public, max-age=31536000, s-maxage=31536000, immutable";
            '';

            root = "${cfg.package}/lib/mobilizon-${cfg.package.version}/priv/static";
          };

          locations."~ ^/(media|proxy)" = {
            inherit proxyPass;

            # Combination of HTTP/1.1 and disabled request buffering is
            # needed to directly forward chunked responses
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_request_buffering off;
              access_log off;
              add_header Cache-Control "public, max-age=31536000, s-maxage=31536000, immutable";
            '';

            recommendedProxySettings = lib.mkDefault true;
          };
        };
      };

    services.postgresql = mkIf isLocalPostgres {
      enable = true;
      ensureDatabases = [ repoSettings.database ];

      ensureUsers = [
        {
          # Given that `dbUser` is potentially arbitrarily custom, we will perform
          # manual fixups in mobilizon-postgres.
          # TODO(to maintainers of mobilizon): Feel free to simplify your setup by using `ensureDBOwnership`.
          ensureDBOwnership = false;
          name = dbUser;
        }
      ];

      extensions = ps: with ps; [ postgis ];
    };

    # This somewhat follows upstream's systemd service here:
    # https://framagit.org/framasoft/mobilizon/-/blob/master/support/systemd/mobilizon.service
    systemd.services.mobilizon = {
      description = "Mobilizon federated organization and mobilization platform";

      path = with pkgs; [
        gawk
        imagemagick
        libwebp
        file

        # Optional:
        gifsicle
        jpegoptim
        optipng
        pngquant
      ];

      serviceConfig = {
        ExecStart = "${launchers}/bin/mobilizon start";
        ExecStartPre = "${launchers}/bin/mobilizon_ctl migrate";
        ExecStop = "${launchers}/bin/mobilizon stop";
        Group = group;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "full";
        ReadWritePaths = mkIf isLocalPostgres postgresqlSocketDir;
        Restart = "on-failure";
        StateDirectory = "mobilizon";
        User = user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    # Add the required PostgreSQL extensions to the local PostgreSQL server,
    # if local PostgreSQL is configured.
    systemd.services.mobilizon-postgresql = mkIf isLocalPostgres {
      after = [ "postgresql.target" ];

      before = [
        "mobilizon.service"
        "mobilizon-setup-secrets.service"
      ];

      description = "Mobilizon PostgreSQL setup";
      path = [ postgresql ];

      # Taken from here:
      # https://framagit.org/framasoft/mobilizon/-/blob/1.1.0/priv/templates/setup_db.eex
      # TODO(to maintainers of mobilizon): the owner database alteration is necessary
      # as PostgreSQL 15 changed their behaviors w.r.t. to privileges.
      # See https://github.com/NixOS/nixpkgs/issues/216989 to get rid
      # of that workaround.
      script = ''
        psql "${repoSettings.database}" -c "\
          CREATE EXTENSION IF NOT EXISTS postgis; \
          CREATE EXTENSION IF NOT EXISTS pg_trgm; \
          CREATE EXTENSION IF NOT EXISTS unaccent;"
        psql -tAc 'ALTER DATABASE "${repoSettings.database}" OWNER TO "${dbUser}";'

      '';

      serviceConfig = {
        Restart = "on-failure";
        Type = "oneshot";
        User = config.services.postgresql.superUser;
      };

      wantedBy = [ "mobilizon.service" ];
    };

    # Create the needed secrets before running Mobilizon, so that they are not
    # in the nix store
    #
    # Since some of these tasks are quite common for Elixir projects (COOKIE for
    # every BEAM project, Phoenix and Guardian are also quite common), this
    # service could be abstracted in the future, and used by other Elixir
    # projects.
    systemd.services.mobilizon-setup-secrets = {
      before = [ "mobilizon.service" ];
      description = "Mobilizon setup secrets";

      script =
        let
          # Taken from here:
          # https://framagit.org/framasoft/mobilizon/-/blob/1.0.7/lib/mix/tasks/mobilizon/instance.ex#L132-133
          genSecret =
            "IO.puts(:crypto.strong_rand_bytes(64)" + "|> Base.encode64()" + "|> binary_part(0, 64))";

          # Taken from here:
          # https://github.com/elixir-lang/elixir/blob/v1.11.3/lib/mix/lib/mix/release.ex#L499
          genCookie = "IO.puts(Base.encode32(:crypto.strong_rand_bytes(32)))";

          evalElixir = str: ''
            ${cfg.package.elixirPackage}/bin/elixir --eval '${str}'
          '';
        in
        ''
          set -euxo pipefail

          if [ ! -f "${secretEnvFile}" ]; then
            install -m 600 /dev/null "${secretEnvFile}"
            cat > "${secretEnvFile}" <<EOF
          # This file was automatically generated by mobilizon-setup-secrets.service
          export MOBILIZON_AUTH_SECRET='$(${evalElixir genSecret})'
          export MOBILIZON_INSTANCE_SECRET='$(${evalElixir genSecret})'
          export RELEASE_COOKIE='$(${evalElixir genCookie})'
          EOF
          fi
        '';

      serviceConfig = {
        Group = group;
        StateDirectory = "mobilizon";
        Type = "oneshot";
        User = user;
      };

      wantedBy = [ "mobilizon.service" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/mobilizon 700 mobilizon mobilizon - -"
      "d /var/lib/mobilizon/sitemap 700 mobilizon mobilizon - -"
      "d /var/lib/mobilizon/uploads 700 mobilizon mobilizon - -"
      "d /var/lib/mobilizon/uploads/exports 700 mobilizon mobilizon - -"
      "d /var/lib/mobilizon/uploads/exports/csv 700 mobilizon mobilizon - -"
      "Z /var/lib/mobilizon 700 mobilizon mobilizon - -"
    ];

    users.groups.${group} = { };

    users.users.${user} = {
      description = "Mobilizon daemon user";
      group = group;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    minijackson
    erictapen
  ];
}
