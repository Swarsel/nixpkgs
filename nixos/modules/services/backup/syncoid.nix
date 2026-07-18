{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.syncoid;

  # Extract local dasaset names (so no datasets containing "@")
  localDatasetName =
    d:
    lib.optionals (d != null) (
      let
        m = builtins.match "([^/@]+[^@]*)" d;
      in
      lib.optionals (m != null) m
    );

  # Escape as required by: https://www.freedesktop.org/software/systemd/man/systemd.unit.html
  escapeUnitName =
    name:
    lib.concatMapStrings (s: if lib.isList s then "-" else s) (
      builtins.split "[^a-zA-Z0-9_.\\-]+" name
    );

  # Function to build "zfs allow" commands for the filesystems we've delegated
  # permissions to. It also checks if the target dataset exists before
  # delegating permissions, if it doesn't exist we delegate it to the parent
  # dataset (if it exists). This should solve the case of provisioning new
  # datasets.
  buildAllowCommand =
    permissions: dataset:

    "-+${pkgs.writeShellScript "zfs-allow-${dataset}" ''
      # Here we explicitly use the booted system to guarantee the stable API needed by ZFS

      # Run a ZFS list on the dataset to check if it exists
      if ${
        lib.escapeShellArgs [
          "/run/booted-system/sw/bin/zfs"
          "list"
          dataset
        ]
      } 2>&1 >/dev/null; then
        ${lib.escapeShellArgs [
          "/run/booted-system/sw/bin/zfs"
          "allow"
          cfg.user
          (lib.concatStringsSep "," permissions)
          dataset
        ]}
      ${lib.optionalString ((dirOf dataset) != ".") ''
        else
          ${lib.escapeShellArgs [
            "/run/booted-system/sw/bin/zfs"
            "allow"
            cfg.user
            (lib.concatStringsSep "," permissions)
            # Remove the last part of the path
            (dirOf dataset)
          ]}
      ''}
      fi
    ''}";

  # Function to build "zfs unallow" commands for the filesystems we've
  # delegated permissions to. Here we unallow both the target but also
  # on the parent dataset because at this stage we have no way of
  # knowing if the allow command did execute on the parent dataset or
  # not in the pre-hook. We can't run the same if in the post hook
  # since the dataset should have been created at this point.
  buildUnallowCommand =
    permissions: dataset:

    "-+${pkgs.writeShellScript "zfs-unallow-${dataset}" ''
      # Here we explicitly use the booted system to guarantee the stable API needed by ZFS
      ${lib.escapeShellArgs [
        "/run/booted-system/sw/bin/zfs"
        "unallow"
        cfg.user
        (lib.concatStringsSep "," permissions)
        dataset
      ]}
      ${lib.optionalString ((dirOf dataset) != ".") (
        lib.escapeShellArgs [
          "/run/booted-system/sw/bin/zfs"
          "unallow"
          cfg.user
          (lib.concatStringsSep "," permissions)
          # Remove the last part of the path
          (dirOf dataset)
        ]
      )}
    ''}";
in
{

  # Interface

  options.services.syncoid = {
    enable = lib.mkEnableOption "Syncoid ZFS synchronization service";
    package = lib.mkPackageOption pkgs "sanoid" { };

    commands = lib.mkOption {
      default = { };
      description = "Syncoid commands to run.";

      example = lib.literalExpression ''
        {
          "pool/test".target = "root@target:pool/test";
        }
      '';

      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              extraArgs = lib.mkOption {
                default = [ ];
                description = "Extra syncoid arguments for this command.";
                example = [ "--sshport 2222" ];
                type = lib.types.listOf lib.types.str;
              };

              localSourceAllow = lib.mkOption {
                description = ''
                  Permissions granted for the {option}`services.syncoid.user` user
                  for local source datasets. See
                  <https://openzfs.github.io/openzfs-docs/man/8/zfs-allow.8.html>
                  for available permissions.
                  Defaults to {option}`services.syncoid.localSourceAllow` option.
                '';

                type = lib.types.listOf lib.types.str;
              };

              localTargetAllow = lib.mkOption {
                description = ''
                  Permissions granted for the {option}`services.syncoid.user` user
                  for local target datasets. See
                  <https://openzfs.github.io/openzfs-docs/man/8/zfs-allow.8.html>
                  for available permissions.
                  Make sure to include the `change-key` permission if you send raw encrypted datasets,
                  the `compression` permission if you send raw compressed datasets, and so on.
                  For remote target datasets you'll have to set your remote user permissions by yourself.
                '';

                type = lib.types.listOf lib.types.str;
              };

              recursive = lib.mkEnableOption "the transfer of child datasets";

              recvOptions = lib.mkOption {
                default = "";

                description = ''
                  Advanced options to pass to zfs recv. Options are specified
                  without their leading dashes and separated by spaces.
                '';

                example = "ux recordsize o compression=lz4";
                type = lib.types.separatedString " ";
              };

              sendOptions = lib.mkOption {
                default = "";

                description = ''
                  Advanced options to pass to zfs send. Options are specified
                  without their leading dashes and separated by spaces.
                '';

                example = "Lc e";
                type = lib.types.separatedString " ";
              };

              service = lib.mkOption {
                default = { };

                description = ''
                  Systemd configuration specific to this syncoid service.
                '';

                type = lib.types.attrs;
              };

              source = lib.mkOption {
                description = ''
                  Source ZFS dataset. Can be either local or remote. Defaults to
                  the attribute name.
                '';

                example = "pool/dataset";
                type = lib.types.str;
              };

              sshKey = lib.mkOption {
                description = ''
                  SSH private key file to use to login to the remote system.
                  Defaults to {option}`services.syncoid.sshKey` option.
                '';

                type = with lib.types; nullOr (coercedTo path toString str);
              };

              target = lib.mkOption {
                description = ''
                  Target ZFS dataset. Can be either local
                  («pool/dataset») or remote
                  («user@server:pool/dataset»).
                '';

                example = "user@server:pool/dataset";
                type = lib.types.str;
              };

              useCommonArgs = lib.mkOption {
                default = true;

                description = ''
                  Whether to add the configured common arguments to this command.
                '';

                type = lib.types.bool;
              };
            };

            config = {
              localSourceAllow = lib.mkDefault cfg.localSourceAllow;
              localTargetAllow = lib.mkDefault cfg.localTargetAllow;
              source = lib.mkDefault name;
              sshKey = lib.mkDefault cfg.sshKey;
            };
          }
        )
      );
    };

    commonArgs = lib.mkOption {
      default = [ ];

      description = ''
        Arguments to add to every syncoid command, unless disabled for that
        command. See
        <https://github.com/jimsalterjrs/sanoid/#syncoid-command-line-options>
        for available options.
      '';

      example = [ "--no-sync-snap" ];
      type = lib.types.listOf lib.types.str;
    };

    group = lib.mkOption {
      default = "syncoid";
      description = "The group for the service.";
      example = "backup";
      type = lib.types.str;
    };

    interval = lib.mkOption {
      default = "hourly";

      description = ''
        Run syncoid at this interval. The default is to run hourly.

        Must be in the format described in {manpage}`systemd.time(7)`.  This is
        equivalent to adding a corresponding timer unit with
        {option}`OnCalendar` set to the value given here.

        Set to an empty list to avoid starting syncoid automatically.
      '';

      example = "*-*-* *:15:00";
      type = with lib.types; either str (listOf str);
    };

    localSourceAllow = lib.mkOption {
      # Permissions snapshot and destroy are in case --no-sync-snap is not used
      default = [
        "bookmark"
        "hold"
        "send"
        "snapshot"
        "destroy"
        "mount"
      ];

      description = ''
        Permissions granted for the {option}`services.syncoid.user` user
        for local source datasets. See
        <https://openzfs.github.io/openzfs-docs/man/8/zfs-allow.8.html>
        for available permissions.
      '';

      type = lib.types.listOf lib.types.str;
    };

    localTargetAllow = lib.mkOption {
      default = [
        "change-key"
        "compression"
        "create"
        "mount"
        "mountpoint"
        "receive"
        "rollback"
      ];

      description = ''
        Permissions granted for the {option}`services.syncoid.user` user
        for local target datasets. See
        <https://openzfs.github.io/openzfs-docs/man/8/zfs-allow.8.html>
        for available permissions.
        Make sure to include the `change-key` permission if you send raw encrypted datasets,
        the `compression` permission if you send raw compressed datasets, and so on.
        For remote target datasets you'll have to set your remote user permissions by yourself.
      '';

      example = [
        "create"
        "mount"
        "receive"
        "rollback"
      ];

      type = lib.types.listOf lib.types.str;
    };

    service = lib.mkOption {
      default = { };

      description = ''
        Systemd configuration common to all syncoid services.
      '';

      type = lib.types.attrs;
    };

    sshKey = lib.mkOption {
      default = null;

      description = ''
        SSH private key file to use to login to the remote system. Can be
        overridden in individual commands.
      '';

      type = with lib.types; nullOr (coercedTo path toString str);
    };

    user = lib.mkOption {
      default = "syncoid";

      description = ''
        The user for the service. ZFS privilege delegation will be
        automatically configured for any local pools used by syncoid if this
        option is set to a user other than root. The user will be given the
        "hold" and "send" privileges on any pool that has datasets being sent
        and the "create", "mount", "receive", and "rollback" privileges on
        any pool that has datasets being received.
      '';

      example = "backup";
      type = lib.types.str;
    };
  };

  # Implementation

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs' (
      name: c:
      lib.nameValuePair "syncoid-${escapeUnitName name}" (
        lib.mkMerge [
          {
            after = [ "zfs.target" ];
            description = "Syncoid ZFS synchronization from ${c.source} to ${c.target}";
            # syncoid may need zpool to get feature@extensible_dataset
            path = [ "/run/booted-system/sw/bin/" ];

            serviceConfig = {
              # The following options are only for optimizing:
              # systemd-analyze security | grep syncoid-'*'
              AmbientCapabilities = "";
              BindPaths = [ "/dev/zfs" ];

              BindReadOnlyPaths = [
                builtins.storeDir
                "/etc"
                "/run"
                "/bin/sh"
              ];

              CapabilityBoundingSet = "";
              DeviceAllow = [ "/dev/zfs" ];

              ExecStart = lib.escapeShellArgs (
                [ "${cfg.package}/bin/syncoid" ]
                ++ lib.optionals c.useCommonArgs cfg.commonArgs
                ++ lib.optional c.recursive "-r"
                ++ lib.optionals (c.sshKey != null) [
                  "--sshkey"
                  c.sshKey
                ]
                ++ c.extraArgs
                ++ [
                  "--sendoptions"
                  c.sendOptions
                  "--recvoptions"
                  c.recvOptions
                  "--no-privilege-elevation"
                  c.source
                  c.target
                ]
              );

              ExecStartPre =
                (map (buildAllowCommand c.localSourceAllow) (localDatasetName c.source))
                ++ (map (buildAllowCommand c.localTargetAllow) (localDatasetName c.target));

              ExecStopPost =
                (map (buildUnallowCommand c.localSourceAllow) (localDatasetName c.source))
                ++ (map (buildUnallowCommand c.localTargetAllow) (localDatasetName c.target));

              Group = cfg.group;
              # Avoid useless mounting of RootDirectory= in the own RootDirectory= of ExecStart='s mount namespace.
              InaccessiblePaths = [ "-+/run/syncoid/${escapeUnitName name}" ];
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              MountAPIVFS = true;
              NoNewPrivileges = true;
              PrivateDevices = true;
              PrivateMounts = true;
              PrivateNetwork = lib.mkDefault false;
              # Prevent SSH control sockets of different syncoid services from interfering
              PrivateTmp = true;
              PrivateUsers = false; # Enabling this breaks on zfs-2.2.0
              # Permissive access to /proc because syncoid
              # calls ps(1) to detect ongoing `zfs receive`.
              ProcSubset = "all";
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHome = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectProc = "default";
              ProtectSystem = "strict";
              RemoveIPC = true;

              RestrictAddressFamilies = [
                "AF_UNIX"
                "AF_INET"
                "AF_INET6"
              ];

              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              RootDirectory = "/run/syncoid/${escapeUnitName name}";
              RootDirectoryStartOnly = true;
              # Create RootDirectory= in the host's mount namespace.
              RuntimeDirectory = [ "syncoid/${escapeUnitName name}" ];
              RuntimeDirectoryMode = "700";
              StateDirectory = [ "syncoid" ];
              StateDirectoryMode = "700";
              SystemCallArchitectures = "native";

              SystemCallFilter = [
                "@system-service"
                # Groups in @system-service which do not contain a syscall listed by:
                # perf stat -x, 2>perf.log -e 'syscalls:sys_enter_*' syncoid …
                # awk >perf.syscalls -F "," '$1 > 0 {sub("syscalls:sys_enter_","",$3); print $3}' perf.log
                # systemd-analyze syscall-filter | grep -v -e '#' | sed -e ':loop; /^[^ ]/N; s/\n //; t loop' | grep $(printf ' -e \\<%s\\>' $(cat perf.syscalls)) | cut -f 1 -d ' '
                "~@aio"
                "~@chown"
                "~@keyring"
                "~@memlock"
                "~@privileged"
                "~@resources"
                "~@setuid"
                # NB: pv after 1.11.0 uses timer syscalls (specifically setitimer)
                # "~@timer"
              ];

              # This is for BindPaths= and BindReadOnlyPaths=
              # to allow traversal of directories they create in RootDirectory=.
              UMask = "0066";
              User = cfg.user;
            };

            startAt = cfg.interval;
          }
          cfg.service
          c.service
        ]
      )
    ) cfg.commands;

    users = {
      groups = lib.mkIf (cfg.group == "syncoid") {
        syncoid = { };
      };

      users = lib.mkIf (cfg.user == "syncoid") {
        syncoid = {
          createHome = false;
          group = cfg.group;
          # For syncoid to be able to create /var/lib/syncoid/.ssh/
          # and to use custom ssh_config or known_hosts.
          home = "/var/lib/syncoid";
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    julm
    lopsided98
  ];
}
