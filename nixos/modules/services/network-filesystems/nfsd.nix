{
  config,
  lib,
  pkgs,
  ...
}:
let

  attrsToExports = lib.concatMapAttrsStringSep "\n" (
    exportPoint: clientsAndOptions:
    exportPoint
    + lib.concatMapAttrsStringSep "" (
      client: options: " ${client}(${lib.concatStringsSep "," options})"
    ) clientsAndOptions
  );

  cfg = config.services.nfs.server;

  exports = pkgs.writeText "exports" cfg.exports;

in

{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "nfs" "lockdPort" ]
      [ "services" "nfs" "server" "lockdPort" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "nfs" "statdPort" ]
      [ "services" "nfs" "server" "statdPort" ]
    )
  ];

  ###### interface

  options = {

    services.nfs = {

      server = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Whether to enable the kernel's NFS server.
          '';

          type = lib.types.bool;
        };

        createMountPoints = lib.mkOption {
          default = false;
          description = "Whether to create the mount points in the exports file at startup time.";
          type = lib.types.bool;
        };

        exports = lib.mkOption {
          default = "";

          description = ''
            Contents of the /etc/exports file.  See
            {manpage}`exports(5)` for the format.
          '';

          example = {
            "/home/joe" = {
              "pc001" = [
                "rw"
                "all_squash"
                "anonuid=150"
                "anongid=100"
              ];
            };

            "/usr" = {
              "*.local.domain" = [ "ro" ];
              "@trusted" = [ "rw" ];
            };
          };

          type = with lib.types; coercedTo (attrsOf (attrsOf (listOf str))) attrsToExports lines;
        };

        extraNfsdConfig = lib.mkOption {
          default = "";

          description = ''
            Extra configuration options for the [nfsd] section of /etc/nfs.conf.
          '';

          type = lib.types.str;
        };

        hostName = lib.mkOption {
          default = null;

          description = ''
            Hostname or address on which NFS requests will be accepted.
            Default is all.  See the {option}`-H` option in
            {manpage}`nfsd(8)`.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        lockdPort = lib.mkOption {
          default = null;

          description = ''
            Use a fixed port for the NFS lock manager kernel module
            (`lockd/nlockmgr`).  This is useful if the
            NFS server is behind a firewall.
          '';

          example = 4001;
          type = lib.types.nullOr lib.types.port;
        };

        mountdPort = lib.mkOption {
          default = null;

          description = ''
            Use fixed port for rpc.mountd, useful if server is behind firewall.
          '';

          example = 4002;
          type = lib.types.nullOr lib.types.port;
        };

        nproc = lib.mkOption {
          default = 8;

          description = ''
            Number of NFS server threads.  Defaults to the recommended value of 8.
          '';

          type = lib.types.int;
        };

        statdPort = lib.mkOption {
          default = null;

          description = ''
            Use a fixed port for {command}`rpc.statd`. This is
            useful if the NFS server is behind a firewall.
          '';

          example = 4000;
          type = lib.types.nullOr lib.types.port;
        };

      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    boot.supportedFilesystems = [ "nfs" ]; # needed for statd and idmapd
    environment.etc.exports.source = exports;
    services.rpcbind.enable = true;

    systemd.services.nfs-mountd = {
      enable = true;

      preStart = ''
        mkdir -p /var/lib/nfs

        ${lib.optionalString cfg.createMountPoints ''
          # create export directories:
          # skip comments, take first col which may either be a quoted
          # "foo bar" or just foo (-> man export)
          sed '/^#.*/d;s/^"\([^"]*\)".*/\1/;t;s/[ ].*//' ${exports} \
          | xargs -d '\n' mkdir -p
        ''}
      '';

      restartTriggers = [ exports ];
    };

    systemd.services.nfs-server = {
      enable = true;

      preStart = ''
        mkdir -p /var/lib/nfs/v4recovery
      '';

      wantedBy = [ "multi-user.target" ];
    };

  };

}
