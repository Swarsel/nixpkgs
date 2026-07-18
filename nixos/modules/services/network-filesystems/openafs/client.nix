{
  config,
  lib,
  pkgs,
  ...
}:

# openafsMod, openafsBin, mkCellServDB
with import ./lib.nix { inherit config lib pkgs; };

let
  inherit (lib)
    getBin
    literalExpression
    mkOption
    mkIf
    optionalString
    singleton
    types
    ;

  cfg = config.services.openafsClient;

  clientServDB = pkgs.writeText "client-cellServDB-${cfg.cellName}" (mkCellServDB cfg.cellServDB);

  cellServDB =
    let
      localCells = builtins.attrNames cfg.cellServDB;
      localCellsRegex = lib.concatMapStringsSep "\\|" (lib.replaceStrings [ "." ] [ "\\." ]) localCells;
      sedExpr = '':x /^>\(${localCellsRegex}\) / { n; :y /^>/! { n; by }; bx }; p'';
      globalCommand =
        if cfg.cellServDB != { } then
          "sed -n -e ${lib.escapeShellArg sedExpr} ${cfg.globalCellServDBFile}"
        else
          "cat ${cfg.globalCellServDBFile}";
    in
    pkgs.runCommand "CellServDB" { preferLocalBuild = true; } ''
      ${lib.optionalString (cfg.globalCellServDBFile != null) "${globalCommand} > $out"}
      cat ${clientServDB} >> $out
    '';

  afsConfig = pkgs.runCommand "afsconfig" { preferLocalBuild = true; } ''
    mkdir -p $out
    echo ${cfg.cellName} > $out/ThisCell
    cp ${cellServDB} $out/CellServDB
    echo "${cfg.mountPoint}:${cfg.cache.directory}:${toString cfg.cache.blocks}" > $out/cacheinfo
  '';

in
{
  ###### interface

  options = {

    services.openafsClient = {

      enable = mkOption {
        default = false;
        description = "Whether to enable the OpenAFS client.";
        type = types.bool;
      };

      afsdb = mkOption {
        default = true;
        description = "Resolve cells via AFSDB DNS records.";
        type = types.bool;
      };

      cache = {
        blocks = mkOption {
          default = 100000;
          description = "Cache size in 1KB blocks.";
          type = types.int;
        };

        chunksize = mkOption {
          default = 0;

          description = ''
            Size of each cache chunk given in powers of
            2. `0` resets the chunk size to its default
            values (13 (8 KB) for memcache, 18-20 (256 KB to 1 MB) for
            diskcache). Maximum value is 30. Important performance
            parameter. Set to higher values when dealing with large files.
          '';

          type = types.ints.between 0 30;
        };

        directory = mkOption {
          default = "/var/cache/openafs";
          description = "Cache directory.";
          type = types.str;
        };

        diskless = mkOption {
          default = false;

          description = ''
            Use in-memory cache for diskless machines. Has no real
            performance benefit anymore.
          '';

          type = types.bool;
        };
      };

      cellName = mkOption {
        default = "";
        description = "Cell name.";
        example = "grand.central.org";
        type = types.str;
      };

      cellServDB = mkOption {
        default = { };

        description = ''
          This cell's database server records, added to the global
          CellServDB. See {manpage}`CellServDB(5)` man page for syntax. Ignored when
          `afsdb` is set to `true`.
        '';

        example = {
          "dns.fqdn.org" = [
            {
              dnsname = "first.afsdb.server.dns.fqdn.org";
              ip = "1.2.3.4";
            }
            {
              dnsname = "second.afsdb.server.dns.fqdn.org";
              ip = "2.3.4.5";
            }
          ];
        };

        type = cellServDBType cfg.cellName;
      };

      crypt = mkOption {
        default = true;
        description = "Whether to enable (weak) protocol encryption.";
        type = types.bool;
      };

      daemons = mkOption {
        default = 2;

        description = ''
          Number of daemons to serve user requests. Numbers higher than 6
          usually do no increase performance. Default is sufficient for up
          to five concurrent users.
        '';

        type = types.int;
      };

      fakestat = mkOption {
        default = false;

        description = ''
          Return fake data on stat() calls. If `true`,
          always do so. If `false`, only do so for
          cross-cell mounts (as these are potentially expensive).
        '';

        type = types.bool;
      };

      globalCellServDBFile = mkOption {
        default = pkgs.openafs.cellservdb;
        defaultText = literalExpression "pkgs.openafs.cellservdb";

        description = ''
          Global CellServDB file to be deployed. Set to `null` to only deploy the
          cells in `cellServDB`. Any cells defined in `cellServDB` will override
          cells in the global file.
        '';

        example = lib.literalExpression "./CellServDB";
        type = types.nullOr types.pathInStore;
      };

      inumcalc = mkOption {
        default = "compat";

        description = ''
          Inode calculation method. `compat` is
          computationally less expensive, but `md5` greatly
          reduces the likelihood of inode collisions in larger scenarios
          involving multiple cells mounted into one AFS space.
        '';

        type = types.strMatching "compat|md5";
      };

      mountPoint = mkOption {
        default = "/afs";

        description = ''
          Mountpoint of the AFS file tree, conventionally
          `/afs`. When set to a different value, only
          cross-cells that use the same value can be accessed.
        '';

        type = types.str;
      };

      packages = {
        module = mkOption {
          default = config.boot.kernelPackages.openafs;
          defaultText = literalExpression "config.boot.kernelPackages.openafs";
          description = "OpenAFS kernel module package. MUST match the userland package!";
          type = types.package;
        };

        programs = mkOption {
          default = getBin pkgs.openafs;
          defaultText = literalExpression "getBin pkgs.openafs";
          description = "OpenAFS programs package. MUST match the kernel module package!";
          type = types.package;
        };
      };

      sparse = mkOption {
        default = true;
        description = "Minimal cell list in /afs.";
        type = types.bool;
      };

      startDisconnected = mkOption {
        default = false;

        description = ''
          Start up in disconnected mode.  You need to execute
          `fs disco online` (as root) to switch to
          connected mode. Useful for roaming devices.
        '';

        type = types.bool;
      };

    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.afsdb || cfg.cellServDB != [ ];
        message = "You should specify all cell-local database servers in config.services.openafsClient.cellServDB or set config.services.openafsClient.afsdb.";
      }
      {
        assertion = cfg.cellName != "";
        message = "You must specify the local cell name in config.services.openafsClient.cellName.";
      }
    ];

    environment.etc = {
      clientCell = {
        mode = "0644";
        target = "openafs/ThisCell";

        text = ''
          ${cfg.cellName}
        '';
      };

      clientCellServDB = {
        mode = "0644";
        source = cellServDB;
        target = "openafs/CellServDB";
      };
    };

    environment.systemPackages = [ openafsBin ];

    systemd.services.afsd = {
      after = singleton (if cfg.startDisconnected then "network.target" else "network-online.target");
      description = "AFS client";

      preStart = ''
        mkdir -p -m 0755 ${cfg.mountPoint}
        mkdir -m 0700 -p ${cfg.cache.directory}
        ${pkgs.kmod}/bin/insmod ${openafsMod}/lib/modules/*/extra/openafs/libafs.ko.xz
        ${openafsBin}/sbin/afsd \
          -mountdir ${cfg.mountPoint} \
          -confdir ${afsConfig} \
          ${optionalString (!cfg.cache.diskless) "-cachedir ${cfg.cache.directory}"} \
          -blocks ${toString cfg.cache.blocks} \
          -chunksize ${toString cfg.cache.chunksize} \
          ${optionalString cfg.cache.diskless "-memcache"} \
          -inumcalc ${cfg.inumcalc} \
          ${if cfg.fakestat then "-fakestat-all" else "-fakestat"} \
          ${if cfg.sparse then "-dynroot-sparse" else "-dynroot"} \
          ${optionalString cfg.afsdb "-afsdb"}
        ${openafsBin}/bin/fs setcrypt ${if cfg.crypt then "on" else "off"}
        ${optionalString cfg.startDisconnected "${openafsBin}/bin/fs discon offline"}
      '';

      # Doing this in preStop, because after these commands AFS is basically
      # stopped, so systemd has nothing to do, just noticing it.  If done in
      # postStop, then we get a hang + kernel oops, because AFS can't be
      # stopped simply by sending signals to processes.
      preStop = ''
        ${pkgs.util-linux}/bin/umount ${cfg.mountPoint}
        ${openafsBin}/sbin/afsd -shutdown
        ${pkgs.kmod}/sbin/rmmod libafs
      '';

      restartIfChanged = false;

      serviceConfig = {
        RemainAfterExit = true;
      };

      wantedBy = [ "multi-user.target" ];
      wants = lib.optional (!cfg.startDisconnected) "network-online.target";
    };
  };
}
