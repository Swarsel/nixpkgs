{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.corosync;
in
{
  # interface
  options.services.corosync = {
    enable = lib.mkEnableOption "corosync";
    package = lib.mkPackageOption pkgs "corosync" { };

    clusterName = lib.mkOption {
      default = "nixcluster";
      description = "Name of the corosync cluster.";
      type = lib.types.str;
    };

    extraOptions = lib.mkOption {
      default = [ ];
      description = "Additional options with which to start corosync.";
      type = with lib.types; listOf str;
    };

    nodelist = lib.mkOption {
      default = [ ];
      description = "Corosync nodelist: all cluster members.";

      type =
        with lib.types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              description = "Node name";
              type = str;
            };

            nodeid = lib.mkOption {
              description = "Node ID number";
              type = int;
            };

            ring_addrs = lib.mkOption {
              description = "List of addresses, one for each ring.";
              type = listOf str;
            };
          };
        });
    };
  };

  # implementation
  config = lib.mkIf cfg.enable {
    environment.etc."corosync/corosync.conf".text = ''
      totem {
        version: 2
        secauth: on
        cluster_name: ${cfg.clusterName}
        transport: knet
      }

      nodelist {
        ${lib.concatMapStrings (
          {
            name,
            nodeid,
            ring_addrs,
          }:
          ''
            node {
              nodeid: ${toString nodeid}
              name: ${name}
              ${lib.concatStrings (
                lib.imap0 (i: addr: ''
                  ring${toString i}_addr: ${addr}
                '') ring_addrs
              )}
            }
          ''
        ) cfg.nodelist}
      }

      quorum {
        # only corosync_votequorum is supported
        provider: corosync_votequorum
        wait_for_all: 0
        ${lib.optionalString (builtins.length cfg.nodelist < 3) ''
          two_node: 1
        ''}
      }

      logging {
        to_syslog: yes
      }
    '';

    environment.etc."corosync/uidgid.d/root".text = ''
      # allow pacemaker connection by root
      uidgid {
        uid: 0
        gid: 0
      }
    '';

    environment.etc."sysconfig/corosync".text = lib.optionalString (cfg.extraOptions != [ ]) ''
      COROSYNC_OPTIONS="${lib.escapeShellArgs cfg.extraOptions}"
    '';

    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.corosync = {
      serviceConfig = {
        StateDirectory = "corosync";
        StateDirectoryMode = "0700";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
