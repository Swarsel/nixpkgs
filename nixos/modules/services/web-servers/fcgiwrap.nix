{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  forEachInstance =
    f:
    flip mapAttrs' config.services.fcgiwrap.instances (
      name: cfg: nameValuePair "fcgiwrap-${name}" (f cfg)
    );

in
{
  imports =
    forEach
      [
        "enable"
        "user"
        "group"
        "socketType"
        "socketAddress"
        "preforkProcesses"
      ]
      (
        attr:
        mkRemovedOptionModule [ "services" "fcgiwrap" attr ] ''
          The global shared fcgiwrap instance is no longer supported due to
          security issues.
          Isolated instances should instead be configured through
          `services.fcgiwrap.instances.*'.
        ''
      );

  options.services.fcgiwrap.instances = mkOption {
    default = { };
    description = "Configuration for fcgiwrap instances.";

    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        {
          options = {
            process.group = mkOption {
              default = null;
              description = "Group as which this instance of fcgiwrap will be run.";
              type = types.nullOr types.str;
            };

            process.prefork = mkOption {
              default = 1;
              description = "Number of processes to prefork.";
              type = types.ints.positive;
            };

            process.user = mkOption {
              default = null;

              description = ''
                User as which this instance of fcgiwrap will be run.
                Set to `null` (the default) to use a dynamically allocated user.
              '';

              type = types.nullOr types.str;
            };

            socket.address = mkOption {
              default = "/run/fcgiwrap-${config._module.args.name}.sock";

              description = ''
                Socket address.
                In case of a UNIX socket, this should be its filesystem path.
              '';

              example = "1.2.3.4:5678";
              type = types.str;
            };

            socket.group = mkOption {
              default = null;

              description = ''
                Group to be set as owner of the UNIX socket.
              '';

              type = types.nullOr types.str;
            };

            socket.mode = mkOption {
              default = if config.socket.type == "unix" then "0600" else null;

              defaultText = literalExpression ''
                if config.socket.type == "unix" then "0600" else null
              '';

              description = ''
                Mode to be set on the UNIX socket.
                Defaults to private to the socket's owner.
              '';

              type = types.nullOr types.str;
            };

            socket.type = mkOption {
              default = "unix";
              description = "Socket type: 'unix', 'tcp' or 'tcp6'.";

              type = types.enum [
                "unix"
                "tcp"
                "tcp6"
              ];
            };

            socket.user = mkOption {
              default = null;

              description = ''
                User to be set as owner of the UNIX socket.
              '';

              type = types.nullOr types.str;
            };
          };
        }
      )
    );
  };

  config = {
    assertions = concatLists (
      mapAttrsToList (name: cfg: [
        {
          assertion = cfg.socket.type == "unix" -> cfg.socket.user != null;
          message = "Socket owner is required for the UNIX socket type.";
        }
        {
          assertion = cfg.socket.type == "unix" -> cfg.socket.group != null;
          message = "Socket owner is required for the UNIX socket type.";
        }
        {
          assertion = cfg.socket.user != null -> cfg.socket.type == "unix";
          message = "Socket owner can only be set for the UNIX socket type.";
        }
        {
          assertion = cfg.socket.group != null -> cfg.socket.type == "unix";
          message = "Socket owner can only be set for the UNIX socket type.";
        }
        {
          assertion = cfg.socket.mode != null -> cfg.socket.type == "unix";
          message = "Socket mode can only be set for the UNIX socket type.";
        }
      ]) config.services.fcgiwrap.instances
    );

    systemd.services = forEachInstance (cfg: {
      after = [ "nss-user-lookup.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.fcgiwrap}/sbin/fcgiwrap ${
            cli.toCommandLineShellGNU { } (
              {
                c = cfg.process.prefork;
              }
              // (optionalAttrs (cfg.socket.type != "unix") {
                s = "${cfg.socket.type}:${cfg.socket.address}";
              })
            )
          }
        '';
      }
      // (
        if cfg.process.user != null then
          {
            Group = cfg.process.group;
            User = cfg.process.user;
          }
        else
          {
            DynamicUser = true;
          }
      );

      wantedBy = optional (cfg.socket.type != "unix") "multi-user.target";
    });

    systemd.sockets = forEachInstance (
      cfg:
      mkIf (cfg.socket.type == "unix") {
        socketConfig = {
          ListenStream = cfg.socket.address;
          SocketGroup = cfg.socket.group;
          SocketMode = cfg.socket.mode;
          SocketUser = cfg.socket.user;
        };

        wantedBy = [ "sockets.target" ];
      }
    );
  };
}
