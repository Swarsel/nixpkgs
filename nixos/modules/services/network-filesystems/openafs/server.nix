{
  config,
  lib,
  pkgs,
  ...
}:

# openafsBin, openafsSrv, mkCellServDB
with import ./lib.nix { inherit config lib pkgs; };

let
  inherit (lib)
    concatStringsSep
    literalExpression
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    optionalString
    types
    ;

  bosConfig = pkgs.writeText "BosConfig" (
    ''
      restrictmode 1
      restarttime 16 0 0 0 0
      checkbintime 3 0 5 0 0
    ''
    + (optionalString cfg.roles.database.enable ''
      bnode simple vlserver 1
      parm ${openafsSrv}/libexec/openafs/vlserver ${optionalString cfg.dottedPrincipals "-allow-dotted-principals"} ${cfg.roles.database.vlserverArgs}
      end
      bnode simple ptserver 1
      parm ${openafsSrv}/libexec/openafs/ptserver ${optionalString cfg.dottedPrincipals "-allow-dotted-principals"} ${cfg.roles.database.ptserverArgs}
      end
    '')
    + (optionalString cfg.roles.fileserver.enable ''
      bnode dafs dafs 1
      parm ${openafsSrv}/libexec/openafs/dafileserver ${optionalString cfg.dottedPrincipals "-allow-dotted-principals"} -udpsize ${udpSizeStr} ${cfg.roles.fileserver.fileserverArgs}
      parm ${openafsSrv}/libexec/openafs/davolserver ${optionalString cfg.dottedPrincipals "-allow-dotted-principals"} -udpsize ${udpSizeStr} ${cfg.roles.fileserver.volserverArgs}
      parm ${openafsSrv}/libexec/openafs/salvageserver ${cfg.roles.fileserver.salvageserverArgs}
      parm ${openafsSrv}/libexec/openafs/dasalvager ${cfg.roles.fileserver.salvagerArgs}
      end
    '')
    + (optionalString
      (cfg.roles.database.enable && cfg.roles.backup.enable && (!cfg.roles.backup.enableFabs))
      ''
        bnode simple buserver 1
        parm ${openafsSrv}/libexec/openafs/buserver ${cfg.roles.backup.buserverArgs} ${optionalString useBuCellServDB "-cellservdb /etc/openafs/backup/"}
        end
      ''
    )
    + (optionalString
      (cfg.roles.database.enable && cfg.roles.backup.enable && cfg.roles.backup.enableFabs)
      ''
        bnode simple buserver 1
        parm ${lib.getBin pkgs.fabs}/bin/fabsys server --config ${fabsConfFile} ${cfg.roles.backup.fabsArgs}
        end
      ''
    )
  );

  netInfo =
    if (cfg.advertisedAddresses != [ ]) then
      pkgs.writeText "NetInfo" ((concatStringsSep "\nf " cfg.advertisedAddresses) + "\n")
    else
      null;

  buCellServDB = pkgs.writeText "backup-cellServDB-${cfg.cellName}" (
    mkCellServDB cfg.roles.backup.cellServDB
  );

  useBuCellServDB = (cfg.roles.backup.cellServDB != { }) && (!cfg.roles.backup.enableFabs);

  cfg = config.services.openafsServer;

  udpSizeStr = toString cfg.udpPacketSize;

  fabsConfFile = pkgs.writeText "fabs.yaml" (
    builtins.toJSON (
      {
        afs = {
          aklog = cfg.package + "/bin/aklog";
          cell = cfg.cellName;
          dumpscan = cfg.package + "/bin/afsdump_scan";
          fs = cfg.package + "/bin/fs";
          pts = cfg.package + "/bin/pts";
          vos = cfg.package + "/bin/vos";
        };

        k5start.command = (lib.getBin pkgs.kstart) + "/bin/k5start";
      }
      // cfg.roles.backup.fabsExtraConfig
    )
  );

in
{

  options = {

    services.openafsServer = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to enable the OpenAFS server. An OpenAFS server needs a
          complex setup. So, be aware that enabling this service and setting
          some options does not give you a turn-key-ready solution. You need
          at least a running Kerberos 5 setup, as OpenAFS relies on it for
          authentication. See the Guide "QuickStartUnix" coming with
          `pkgs.openafs.doc` for complete setup
          instructions.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "openafs" { };

      advertisedAddresses = mkOption {
        default = [ ];
        description = "List of IP addresses this server is advertised under. See {manpage}`NetInfo(5)`";
        type = types.listOf types.str;
      };

      cellName = mkOption {
        default = "";
        description = "Cell name, this server will serve.";
        example = "grand.central.org";
        type = types.str;
      };

      cellServDB = mkOption {
        default = { };

        description = ''
          Definition of all cell-local database server machines. If a single
          list is provided, it will be used as the servers for `cellName`.
        '';

        example = [
          {
            dnsname = "first.afsdb.server.dns.fqdn.org";
            ip = "1.2.3.4";
          }
          {
            dnsname = "second.afsdb.server.dns.fqdn.org";
            ip = "2.3.4.5";
          }
        ];

        type = cellServDBType cfg.cellName;
      };

      dottedPrincipals = mkOption {
        default = false;

        description = ''
          If enabled, allow principal names containing (.) dots. Enabling
          this has security implications!
        '';

        type = types.bool;
      };

      roles = {
        backup = {
          enable = mkEnableOption ''
            the backup server role. When using OpenAFS built-in buserver, use in conjunction with the
            `database` role to maintain the Backup
            Database. Normally only used in conjunction with tape storage
            or IBM's Tivoli Storage Manager.

            For a modern backup server, enable this role and see
            {option}`enableFabs`
          '';

          buserverArgs = mkOption {
            default = "";
            description = "Arguments to the buserver process. See its man page.";
            example = "-p 8";
            type = types.str;
          };

          cellServDB = mkOption {
            default = { };

            description = ''
              Definition of all cell-local backup database server machines.
              Use this when your cell uses less backup database servers than
              other database server machines.
            '';

            type = cellServDBType cfg.cellName;
          };

          enableFabs = mkEnableOption ''
            FABS, the flexible AFS backup system. It stores volumes as dump files, relying on other
            pre-existing backup solutions for handling them
          '';

          fabsArgs = mkOption {
            default = "";

            description = ''
              Arguments to the fabsys process. See
              {manpage}`fabsys_server(1)` and
              {manpage}`fabsys_config(1)`.
            '';

            type = types.str;
          };

          fabsExtraConfig = mkOption {
            default = { };

            description = ''
              Additional configuration parameters for the FABS backup server.
            '';

            example = literalExpression ''
              {
                afs.localauth = true;
                afs.keytab = config.sops.secrets.fabsKeytab.path;
              }
            '';

            type = types.attrs;
          };
        };

        database = {
          enable = mkOption {
            default = true;

            description = ''
              Database server role, maintains the Volume Location Database,
              Protection Database (and Backup Database, see
              `backup` role). There can be multiple
              servers in the database role for replication, which then need
              reliable network connection to each other.

              Servers in this role appear in AFSDB DNS records or the
              CellServDB.
            '';

            type = types.bool;
          };

          ptserverArgs = mkOption {
            default = "";
            description = "Arguments to the ptserver process. See its man page.";
            example = "-restricted -default_access S---- S-M---";
            type = types.str;
          };

          vlserverArgs = mkOption {
            default = "";
            description = "Arguments to the vlserver process. See its man page.";
            example = "-rxbind";
            type = types.str;
          };
        };

        fileserver = {
          enable = mkOption {
            default = true;
            description = "Fileserver role, serves files and volumes from its local storage.";
            type = types.bool;
          };

          fileserverArgs = mkOption {
            default = "-vattachpar 128 -vhashsize 11 -L -rxpck 400 -cb 1000000";
            description = "Arguments to the dafileserver process. See its man page.";
            type = types.str;
          };

          salvagerArgs = mkOption {
            default = "";
            description = "Arguments to the dasalvager process. See its man page.";
            example = "-showlog -showmounts";
            type = types.str;
          };

          salvageserverArgs = mkOption {
            default = "";
            description = "Arguments to the salvageserver process. See its man page.";
            example = "-showlog";
            type = types.str;
          };

          volserverArgs = mkOption {
            default = "";
            description = "Arguments to the davolserver process. See its man page.";
            example = "-sync never";
            type = types.str;
          };
        };
      };

      udpPacketSize = mkOption {
        default = 1310720;

        description = ''
          UDP packet size to use in Bytes. Higher values can speed up
          communications. The default of 1 MB is a sufficient in most
          cases. Make sure to increase the kernel's UDP buffer size
          accordingly via `net.core(w|r|opt)mem_max`
          sysctl.
        '';

        type = types.int;
      };

    };

  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.cellServDB != { } && (cfg.cellServDB."${cfg.cellName}" or [ ]) != [ ];
        message = "You must specify all cell-local database servers in config.services.openafsServer.cellServDB.";
      }
      {
        assertion = cfg.cellName != "";
        message = "You must specify the local cell name in config.services.openafsServer.cellName.";
      }
    ];

    environment.etc = {
      bosConfig = {
        mode = "0644";
        source = bosConfig;
        target = "openafs/BosConfig";
      };

      buCellServDB = {
        enable = useBuCellServDB;
        mode = "0644";
        target = "openafs/backup/CellServDB";
        text = mkCellServDB cfg.roles.backup.cellServDB;
      };

      cellServDB = {
        mode = "0644";
        target = "openafs/server/CellServDB";
        text = mkCellServDB cfg.cellServDB;
      };

      thisCell = {
        mode = "0644";
        target = "openafs/server/ThisCell";
        text = cfg.cellName;
      };
    };

    environment.systemPackages = [ openafsBin ];

    systemd.services = {
      openafs-server = {
        after = [ "network.target" ];
        description = "OpenAFS server";

        preStart = ''
          mkdir -m 0755 -p /var/openafs
          ${optionalString (netInfo != null) "cp ${netInfo} /var/openafs/netInfo"}
        '';

        restartIfChanged = false;

        serviceConfig = {
          ExecStart = "${openafsBin}/bin/bosserver -nofork";
          ExecStop = "${openafsBin}/bin/bos shutdown localhost -wait -localauth";
        };

        unitConfig.ConditionPathExists = [
          "|/etc/openafs/server/KeyFileExt"
        ];

        wantedBy = [ "multi-user.target" ];
      };
    };

    warnings =
      lib.optional ((builtins.attrNames cfg.cellServDB) != [ cfg.cellName ]) ''
        config.services.openafsServer.cellServDB should normally only contain servers for one cell. It currently contains servers for ${toString (builtins.attrNames cfg.cellServDB)}.
      ''
      ++
        lib.optional (useBuCellServDB && (builtins.attrNames cfg.backup.cellServDB) != [ cfg.cellName ])
          ''
            config.services.openafsServer.backup.cellServDB should normally only contain servers for one cell. It currently contains servers for ${toString (builtins.attrNames cfg.cellServDB)}.
          '';
  };
}
