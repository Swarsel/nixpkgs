{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.locate;
  isMLocate = lib.hasPrefix "mlocate" cfg.package.name;
  isPLocate = lib.hasPrefix "plocate" cfg.package.name;
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "locate" "period" ] [ "services" "locate" "interval" ])
    (lib.mkRenamedOptionModule [ "services" "locate" "locate" ] [ "services" "locate" "package" ])
    (lib.mkRemovedOptionModule [ "services" "locate" "includeStore" ] "Use services.locate.prunePaths")
    (lib.mkRemovedOptionModule [ "services" "locate" "localuser" ]
      "The services.locate.localuser option has been removed because support for findutils locate has been removed."
    )
  ];

  options.services.locate = {
    enable = lib.mkOption {
      default = false;

      description = ''
        If enabled, NixOS will periodically update the database of
        files used by the {command}`locate` command.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs [ "plocate" ] {
      example = "mlocate";
    };

    extraFlags = lib.mkOption {
      default = [ ];

      description = ''
        Extra flags to pass to {command}`updatedb`.
      '';

      type = lib.types.listOf lib.types.str;
    };

    interval = lib.mkOption {
      default = "02:15";

      description = ''
        Update the locate database at this interval. Updates by
        default at 2:15 AM every day.

        The format is described in
        {manpage}`systemd.time(7)`.

        To disable automatic updates, set to `"never"`
        and run {command}`updatedb` manually.
      '';

      example = "hourly";
      type = lib.types.str;
    };

    output = lib.mkOption {
      default = "/var/cache/locatedb";

      description = ''
        The database file to build.
      '';

      type = lib.types.externalPath;
    };

    pruneBindMounts = lib.mkOption {
      default = false;

      description = ''
        Whether not to index bind mounts
      '';

      type = lib.types.bool;
    };

    pruneFS = lib.mkOption {
      default = [
        "afs"
        "anon_inodefs"
        "auto"
        "autofs"
        "bdev"
        "binfmt"
        "binfmt_misc"
        "ceph"
        "cgroup"
        "cgroup2"
        "cifs"
        "coda"
        "configfs"
        "cramfs"
        "cpuset"
        "curlftpfs"
        "debugfs"
        "devfs"
        "devpts"
        "devtmpfs"
        "eventpollfs"
        "exofs"
        "futexfs"
        "ftpfs"
        "fuse"
        "fusectl"
        "fusesmb"
        "fuse.ceph"
        "fuse.glusterfs"
        "fuse.gvfsd-fuse"
        "fuse.mfs"
        "fuse.rclone"
        "fuse.rozofs"
        "fuse.sshfs"
        "gfs"
        "gfs2"
        "hostfs"
        "hugetlbfs"
        "inotifyfs"
        "iso9660"
        "jffs2"
        "lustre"
        "lustre_lite"
        "misc"
        "mfs"
        "mqueue"
        "ncpfs"
        "nfs"
        "NFS"
        "nfs4"
        "nfsd"
        "nnpfs"
        "ocfs"
        "ocfs2"
        "pipefs"
        "proc"
        "ramfs"
        "rpc_pipefs"
        "securityfs"
        "selinuxfs"
        "sfs"
        "shfs"
        "smbfs"
        "sockfs"
        "spufs"
        "sshfs"
        "subfs"
        "supermount"
        "sysfs"
        "tmpfs"
        "tracefs"
        "ubifs"
        "udev"
        "udf"
        "usbfs"
        "vboxsf"
        "vperfctrfs"
      ];

      description = ''
        Which filesystem types to exclude from indexing
      '';

      type = lib.types.listOf lib.types.str;
    };

    pruneNames = lib.mkOption {
      default = [
        ".bzr"
        ".cache"
        ".git"
        ".hg"
        ".svn"
      ];

      defaultText = lib.literalMD ''
        `[ ".bzr" ".cache" ".git" ".hg" ".svn" ]`, if
        supported by the locate implementation (i.e. mlocate or plocate).
      '';

      description = ''
        Directory components which should exclude paths containing them from indexing
      '';

      type = lib.types.listOf lib.types.str;
    };

    prunePaths = lib.mkOption {
      default = [
        "/tmp"
        "/var/tmp"
        "/var/cache"
        "/var/lock"
        "/var/run"
        "/var/spool"
        "/nix/store"
        "/nix/var/log/nix"
      ];

      description = ''
        Which paths to exclude from indexing
      '';

      type = lib.types.listOf lib.types.path;
    };

  };

  config = lib.mkIf cfg.enable {
    environment = {
      # write /etc/updatedb.conf for manual calls to `updatedb`
      etc."updatedb.conf".text = ''
        PRUNEFS="${lib.concatStringsSep " " cfg.pruneFS}"
        PRUNENAMES="${lib.concatStringsSep " " cfg.pruneNames}"
        PRUNEPATHS="${lib.concatStringsSep " " cfg.prunePaths}"
        PRUNE_BIND_MOUNTS="${lib.boolToYesNo cfg.pruneBindMounts}"
      '';

      systemPackages = [ cfg.package ];
    };

    security.wrappers =
      let
        common = {
          owner = "root";
          permissions = "u+rx,g+x,o+x";
          setgid = true;
          setuid = false;
        };
        mlocate = lib.mkIf isMLocate {
          group = "mlocate";
          source = "${cfg.package}/bin/locate";
        };
        plocate = lib.mkIf isPLocate {
          group = "plocate";
          source = "${cfg.package}/bin/plocate";
        };
      in
      {
        locate = lib.mkMerge [
          common
          mlocate
          plocate
        ];

        plocate = lib.mkIf isPLocate (
          lib.mkMerge [
            common
            plocate
          ]
        );
      };

    systemd.services.update-locatedb = {
      description = "Update Locate Database";

      serviceConfig = {
        CapabilityBoundingSet = "CAP_DAC_READ_SEARCH CAP_CHOWN";

        # mlocate's updatedb takes flags via a configuration file or
        # on the command line, but not by environment variable.
        ExecStart =
          let
            toFlags =
              x:
              lib.optionals (cfg.${x} != [ ]) [
                "--${lib.toLower x}"
                (lib.concatStringsSep " " cfg.${x})
              ];
            args = lib.concatMap toFlags [
              "pruneFS"
              "pruneNames"
              "prunePaths"
            ];
          in
          utils.escapeSystemdExecArgs (
            [
              (lib.getExe' cfg.package "updatedb")
              "--output"
              cfg.output
              "--prune-bind-mounts"
              (lib.boolToYesNo cfg.pruneBindMounts)
            ]
            ++ args
            ++ cfg.extraFlags
          );

        IOSchedulingClass = "idle";
        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        Nice = 19;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = "yes";
        PrivateTmp = "yes";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ReadOnlyPaths = "/";
        # Use dirOf cfg.output because mlocate creates temporary files next to
        # the actual database. We could specify and create them as well,
        # but that would make this quite brittle when they change something.
        # NOTE: If /var/cache does not exist, this leads to the misleading error message:
        # update-locatedb.service: Failed at step NAMESPACE spawning …/update-locatedb-start: No such file or directory
        ReadWritePaths = dirOf cfg.output;
        RestrictAddressFamilies = "AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service @chown";
      };
    };

    systemd.timers.update-locatedb = lib.mkIf (cfg.interval != "never") {
      description = "Update timer for locate database";
      partOf = [ "update-locatedb.service" ];

      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };

      wantedBy = [ "timers.target" ];
    };

    users.groups = lib.mkMerge [
      (lib.mkIf isMLocate { mlocate = { }; })
      (lib.mkIf isPLocate { plocate = { }; })
    ];
  };

  meta.maintainers = with lib.maintainers; [ SuperSandro2000 ];
}
