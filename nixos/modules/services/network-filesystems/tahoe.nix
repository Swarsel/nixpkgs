{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tahoe;
in
{
  options.services.tahoe = {
    introducers = lib.mkOption {
      default = { };

      description = ''
        The Tahoe introducers.
      '';

      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            package = lib.mkPackageOption pkgs "tahoelafs" { };

            nickname = lib.mkOption {
              description = ''
                The nickname of this Tahoe introducer.
              '';

              type = lib.types.str;
            };

            tub.location = lib.mkOption {
              default = null;

              description = ''
                The external location that the introducer should listen on.

                If specified, the port should be included.
              '';

              type = lib.types.nullOr lib.types.str;
            };

            tub.port = lib.mkOption {
              default = 3458;

              description = ''
                The port on which the introducer will listen.
              '';

              type = lib.types.port;
            };
          };
        });
    };

    nodes = lib.mkOption {
      default = { };

      description = ''
        The Tahoe nodes.
      '';

      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            package = lib.mkPackageOption pkgs "tahoelafs" { };

            client.helper = lib.mkOption {
              default = null;

              description = ''
                The furl for a Tahoe helper node.

                Like all furls, keep this safe and don't share it.
              '';

              type = lib.types.nullOr lib.types.str;
            };

            client.introducer = lib.mkOption {
              default = null;

              description = ''
                The furl for a Tahoe introducer node.

                Like all furls, keep this safe and don't share it.
              '';

              type = lib.types.nullOr lib.types.str;
            };

            client.shares.happy = lib.mkOption {
              default = 7;

              description = ''
                The number of distinct storage nodes required to store
                a file.
              '';

              type = lib.types.int;
            };

            client.shares.needed = lib.mkOption {
              default = 3;

              description = ''
                The number of shares required to reconstitute a file.
              '';

              type = lib.types.int;
            };

            client.shares.total = lib.mkOption {
              default = 10;

              description = ''
                The number of shares required to store a file.
              '';

              type = lib.types.int;
            };

            helper.enable = lib.mkEnableOption "helper service";

            nickname = lib.mkOption {
              description = ''
                The nickname of this Tahoe node.
              '';

              type = lib.types.str;
            };

            sftpd.accounts.file = lib.mkOption {
              default = null;

              description = ''
                Path to the accounts file.
              '';

              type = lib.types.nullOr lib.types.path;
            };

            sftpd.accounts.url = lib.mkOption {
              default = null;

              description = ''
                URL of the accounts server.
              '';

              type = lib.types.nullOr lib.types.str;
            };

            sftpd.enable = lib.mkEnableOption "SFTP service";

            sftpd.hostPrivateKeyFile = lib.mkOption {
              default = null;

              description = ''
                Path to the SSH host private key.
              '';

              type = lib.types.nullOr lib.types.path;
            };

            sftpd.hostPublicKeyFile = lib.mkOption {
              default = null;

              description = ''
                Path to the SSH host public key.
              '';

              type = lib.types.nullOr lib.types.path;
            };

            sftpd.port = lib.mkOption {
              default = null;

              description = ''
                The port on which the SFTP server will listen.

                This is the correct setting to tweak if you want Tahoe's SFTP
                daemon to listen on a different port.
              '';

              type = lib.types.nullOr lib.types.port;
            };

            storage.enable = lib.mkEnableOption "storage service";

            storage.reservedSpace = lib.mkOption {
              default = "1G";

              description = ''
                The amount of filesystem space to not use for storage.
              '';

              type = lib.types.str;
            };

            tub.location = lib.mkOption {
              default = null;

              description = ''
                The external location that the node should listen on.

                This is the setting to tweak if there are multiple interfaces
                and you want to alter which interface Tahoe is advertising.

                If specified, the port should be included.
              '';

              type = lib.types.nullOr lib.types.str;
            };

            tub.port = lib.mkOption {
              default = 3457;

              description = ''
                The port on which the tub will listen.

                This is the correct setting to tweak if you want Tahoe's storage
                system to listen on a different port.
              '';

              type = lib.types.port;
            };

            web.port = lib.mkOption {
              default = 3456;

              description = ''
                The port on which the Web server will listen.

                This is the correct setting to tweak if you want Tahoe's WUI to
                listen on a different port.
              '';

              type = lib.types.port;
            };
          };
        });
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.introducers != { }) {
      environment = {
        etc = lib.flip lib.mapAttrs' cfg.introducers (
          node: settings:
          lib.nameValuePair "tahoe-lafs/introducer-${node}.cfg" {
            mode = "0444";

            text = ''
              # This configuration is generated by Nix. Edit at your own
              # peril; here be dragons.

              [node]
              nickname = ${settings.nickname}
              tub.port = ${toString settings.tub.port}
              ${lib.optionalString (settings.tub.location != null) "tub.location = ${settings.tub.location}"}
            '';
          }
        );

        # Actually require Tahoe, so that we will have it installed.
        systemPackages = lib.flip lib.mapAttrsToList cfg.introducers (node: settings: settings.package);
      };

      # Open up the firewall.
      # networking.firewall.allowedTCPPorts = lib.flip lib.mapAttrsToList cfg.introducers
      #   (node: settings: settings.tub.port);
      systemd.services = lib.flip lib.mapAttrs' cfg.introducers (
        node: settings:
        let
          pidfile = "/run/tahoe.introducer-${node}.pid";
          # This is a directory, but it has no trailing slash. Tahoe commands
          # get antsy when there's a trailing slash.
          nodedir = "/var/db/tahoe-lafs/introducer-${node}";
        in
        lib.nameValuePair "tahoe.introducer-${node}" {
          description = "Tahoe LAFS node ${node}";
          documentation = [ "info:tahoe-lafs" ];
          path = [ settings.package ];

          preStart = ''
            if [ ! -d ${lib.escapeShellArg nodedir} ]; then
              mkdir -p /var/db/tahoe-lafs
              # See https://github.com/NixOS/nixpkgs/issues/25273
              tahoe create-introducer \
                --hostname="${config.networking.hostName}" \
                ${lib.escapeShellArg nodedir}
            fi

            # Tahoe has created a predefined tahoe.cfg which we must now
            # scribble over.
            # XXX I thought that a symlink would work here, but it doesn't, so
            # we must do this on every prestart. Fixes welcome.
            # rm ${nodedir}/tahoe.cfg
            # ln -s /etc/tahoe-lafs/introducer-${node}.cfg ${nodedir}/tahoe.cfg
            cp /etc/tahoe-lafs/introducer-"${node}".cfg ${lib.escapeShellArg nodedir}/tahoe.cfg
          '';

          restartTriggers = [
            config.environment.etc."tahoe-lafs/introducer-${node}.cfg".source
          ];

          serviceConfig = {
            # Believe it or not, Tahoe is very brittle about the order of
            # arguments to $(tahoe run). The node directory must come first,
            # and arguments which alter Twisted's behavior come afterwards.
            ExecStart = ''
              ${settings.package}/bin/tahoe run ${lib.escapeShellArg nodedir} --pidfile=${lib.escapeShellArg pidfile}
            '';

            PIDFile = pidfile;
            Type = "simple";
          };

          wantedBy = [ "multi-user.target" ];
        }
      );

      users.users = lib.flip lib.mapAttrs' cfg.introducers (
        node: _:
        lib.nameValuePair "tahoe.introducer-${node}" {
          description = "Tahoe node user for introducer ${node}";
          isSystemUser = true;
        }
      );
    })
    (lib.mkIf (cfg.nodes != { }) {
      environment = {
        etc = lib.flip lib.mapAttrs' cfg.nodes (
          node: settings:
          lib.nameValuePair "tahoe-lafs/${node}.cfg" {
            mode = "0444";

            text = ''
              # This configuration is generated by Nix. Edit at your own
              # peril; here be dragons.

              [node]
              nickname = ${settings.nickname}
              tub.port = ${toString settings.tub.port}
              ${lib.optionalString (settings.tub.location != null) "tub.location = ${settings.tub.location}"}
              # This is a Twisted endpoint. Twisted Web doesn't work on
              # non-TCP. ~ C.
              web.port = tcp:${toString settings.web.port}

              [client]
              ${lib.optionalString (
                settings.client.introducer != null
              ) "introducer.furl = ${settings.client.introducer}"}
              ${lib.optionalString (settings.client.helper != null) "helper.furl = ${settings.client.helper}"}

              shares.needed = ${toString settings.client.shares.needed}
              shares.happy = ${toString settings.client.shares.happy}
              shares.total = ${toString settings.client.shares.total}

              [storage]
              enabled = ${lib.boolToString settings.storage.enable}
              reserved_space = ${settings.storage.reservedSpace}

              [helper]
              enabled = ${lib.boolToString settings.helper.enable}

              [sftpd]
              enabled = ${lib.boolToString settings.sftpd.enable}
              ${lib.optionalString (settings.sftpd.port != null) "port = ${toString settings.sftpd.port}"}
              ${lib.optionalString (
                settings.sftpd.hostPublicKeyFile != null
              ) "host_pubkey_file = ${settings.sftpd.hostPublicKeyFile}"}
              ${lib.optionalString (
                settings.sftpd.hostPrivateKeyFile != null
              ) "host_privkey_file = ${settings.sftpd.hostPrivateKeyFile}"}
              ${lib.optionalString (
                settings.sftpd.accounts.file != null
              ) "accounts.file = ${settings.sftpd.accounts.file}"}
              ${lib.optionalString (
                settings.sftpd.accounts.url != null
              ) "accounts.url = ${settings.sftpd.accounts.url}"}
            '';
          }
        );

        # Actually require Tahoe, so that we will have it installed.
        systemPackages = lib.flip lib.mapAttrsToList cfg.nodes (node: settings: settings.package);
      };

      # Open up the firewall.
      # networking.firewall.allowedTCPPorts = lib.flip lib.mapAttrsToList cfg.nodes
      #   (node: settings: settings.tub.port);
      systemd.services = lib.flip lib.mapAttrs' cfg.nodes (
        node: settings:
        let
          pidfile = "/run/tahoe.${node}.pid";
          # This is a directory, but it has no trailing slash. Tahoe commands
          # get antsy when there's a trailing slash.
          nodedir = "/var/db/tahoe-lafs/${node}";
        in
        lib.nameValuePair "tahoe.${node}" {
          description = "Tahoe LAFS node ${node}";
          documentation = [ "info:tahoe-lafs" ];
          path = [ settings.package ];

          preStart = ''
            if [ ! -d ${lib.escapeShellArg nodedir} ]; then
              mkdir -p /var/db/tahoe-lafs
              tahoe create-node --hostname=localhost ${lib.escapeShellArg nodedir}
            fi

            # Tahoe has created a predefined tahoe.cfg which we must now
            # scribble over.
            # XXX I thought that a symlink would work here, but it doesn't, so
            # we must do this on every prestart. Fixes welcome.
            # rm ${nodedir}/tahoe.cfg
            # ln -s /etc/tahoe-lafs/${lib.escapeShellArg node}.cfg ${nodedir}/tahoe.cfg
            cp /etc/tahoe-lafs/${lib.escapeShellArg node}.cfg ${lib.escapeShellArg nodedir}/tahoe.cfg
          '';

          restartTriggers = [
            config.environment.etc."tahoe-lafs/${node}.cfg".source
          ];

          serviceConfig = {
            # Believe it or not, Tahoe is very brittle about the order of
            # arguments to $(tahoe run). The node directory must come first,
            # and arguments which alter Twisted's behavior come afterwards.
            ExecStart = ''
              ${settings.package}/bin/tahoe run ${lib.escapeShellArg nodedir} --pidfile=${lib.escapeShellArg pidfile}
            '';

            PIDFile = pidfile;
            Type = "simple";
          };

          wantedBy = [ "multi-user.target" ];
        }
      );

      users.users = lib.flip lib.mapAttrs' cfg.nodes (
        node: _:
        lib.nameValuePair "tahoe.${node}" {
          description = "Tahoe node user for node ${node}";
          isSystemUser = true;
        }
      );
    })
  ];
}
