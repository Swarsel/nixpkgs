{
  config,
  lib,
  pkgs,
  ...
}:
let
  gunicorn = pkgs.python3Packages.gunicorn;
  bepasty = pkgs.bepasty;
  gevent = pkgs.python3Packages.gevent;
  python = pkgs.python3Packages.python;
  cfg = config.services.bepasty;
  user = "bepasty";
  group = "bepasty";
  default_home = "/var/lib/bepasty";
in
{
  options.services.bepasty = {
    enable = lib.mkEnableOption "bepasty, a binary pastebin server";

    servers = lib.mkOption {
      default = { };

      description = ''
        configure a number of bepasty servers which will be started with
        gunicorn.
      '';

      type =
        with lib.types;
        attrsOf (
          submodule (
            { config, ... }:
            {

              options = {

                bind = lib.mkOption {
                  default = "127.0.0.1:8000";

                  description = ''
                    Bind address to be used for this server.
                  '';

                  example = "0.0.0.0:8000";
                  type = lib.types.str;
                };

                dataDir = lib.mkOption {
                  default = default_home + "/data";

                  description = ''
                    Path to the directory where the pastes will be saved to
                  '';

                  type = lib.types.str;
                };

                defaultPermissions = lib.mkOption {
                  default = "read";

                  description = ''
                    default permissions for all unauthenticated accesses.
                  '';

                  example = "read,create,delete";
                  type = lib.types.str;
                };

                extraConfig = lib.mkOption {
                  default = "";

                  description = ''
                    Extra configuration for bepasty server to be appended on the
                    configuration.
                    see <https://bepasty-server.readthedocs.org/en/latest/quickstart.html#configuring-bepasty>
                    for all options.
                  '';

                  example = ''
                    PERMISSIONS = {
                      'myadminsecret': 'admin,list,create,read,delete',
                    }
                    MAX_ALLOWED_FILE_SIZE = 5 * 1000 * 1000
                  '';

                  type = lib.types.lines;
                };

                secretKey = lib.mkOption {
                  default = "";

                  description = ''
                    server secret for safe session cookies, must be set.

                    Warning: this secret is stored in the WORLD-READABLE Nix store!

                    It's recommended to use {option}`secretKeyFile`
                    which takes precedence over {option}`secretKey`.
                  '';

                  type = lib.types.str;
                };

                secretKeyFile = lib.mkOption {
                  default = null;

                  description = ''
                    A file that contains the server secret for safe session cookies, must be set.

                    {option}`secretKeyFile` takes precedence over {option}`secretKey`.

                    Warning: when {option}`secretKey` is non-empty {option}`secretKeyFile`
                    defaults to a file in the WORLD-READABLE Nix store containing that secret.
                  '';

                  type = lib.types.nullOr lib.types.str;
                };

                workDir = lib.mkOption {
                  default = default_home;

                  description = ''
                    Path to the working directory (used for config and pidfile).
                    Defaults to the users home directory.
                  '';

                  type = lib.types.str;
                };

              };

              config = {
                secretKeyFile = lib.mkDefault (
                  if config.secretKey != "" then
                    toString (
                      pkgs.writeTextFile {
                        name = "bepasty-secret-key";
                        text = config.secretKey;
                      }
                    )
                  else
                    null
                );
              };
            }
          )
        );
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ bepasty ];

    # creates gunicorn systemd service for each configured server
    systemd.services = lib.mapAttrs' (
      name: server:
      lib.nameValuePair "bepasty-server-${name}-gunicorn" {
        after = [ "network.target" ];
        description = "Bepasty Server ${name}";

        environment =
          let
            penv = python.buildEnv.override {
              extraLibs = [
                bepasty
                gevent
              ];
            };
          in
          {
            BEPASTY_CONFIG = "${server.workDir}/bepasty-${name}.conf";
            PYTHONPATH = "${penv}/${python.sitePackages}/";
          };

        restartIfChanged = true;

        serviceConfig = {
          ExecStart = ''
            ${gunicorn}/bin/gunicorn bepasty.wsgi --name ${name} \
                          -u ${user} \
                          -g ${group} \
                          --workers 3 --log-level=info \
                          --bind=${server.bind} \
                          --pid ${server.workDir}/gunicorn-${name}.pid \
                          -k gevent
          '';

          ExecStartPre =
            assert server.secretKeyFile != null;
            pkgs.writeScript "bepasty-server.${name}-init" ''
              #!/bin/sh
              mkdir -p "${server.workDir}"
              mkdir -p "${server.dataDir}"
              chown ${user}:${group} "${server.workDir}" "${server.dataDir}"
              cat > ${server.workDir}/bepasty-${name}.conf <<EOF
              SITENAME="${name}"
              STORAGE_FILESYSTEM_DIRECTORY="${server.dataDir}"
              SECRET_KEY="$(cat "${server.secretKeyFile}")"
              DEFAULT_PERMISSIONS="${server.defaultPermissions}"
              ${server.extraConfig}
              EOF
            '';

          PrivateTmp = true;
          Type = "simple";
        };

        wantedBy = [ "multi-user.target" ];
      }
    ) cfg.servers;

    users.groups.${group}.gid = config.ids.gids.bepasty;

    users.users.${user} = {
      group = group;
      home = default_home;
      uid = config.ids.uids.bepasty;
    };
  };
}
