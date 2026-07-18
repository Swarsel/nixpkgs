{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) glusterfs rsync;

  tlsCmd =
    if (cfg.tlsSettings != null) then
      ''
        mkdir -p /var/lib/glusterd
        touch /var/lib/glusterd/secure-access
      ''
    else
      ''
        rm -f /var/lib/glusterd/secure-access
      '';

  restartTriggers = lib.optionals (cfg.tlsSettings != null) [
    config.environment.etc."ssl/glusterfs.pem".source
    config.environment.etc."ssl/glusterfs.key".source
    config.environment.etc."ssl/glusterfs.ca".source
  ];

  cfg = config.services.glusterfs;

in

{

  ###### interface

  options = {

    services.glusterfs = {

      enable = lib.mkEnableOption "GlusterFS Daemon";

      enableGlustereventsd = lib.mkOption {
        default = true;
        description = "Whether to enable the GlusterFS Events Daemon";
        type = lib.types.bool;
      };

      extraFlags = lib.mkOption {
        default = [ ];
        description = "Extra flags passed to the GlusterFS daemon";
        type = lib.types.listOf lib.types.str;
      };

      killMode = lib.mkOption {
        default = "control-group";

        description = ''
          The systemd KillMode to use for glusterd.

          glusterd spawns other daemons like gsyncd.
          If you want these to stop when glusterd is stopped (e.g. to ensure
          that NixOS config changes are reflected even for these sub-daemons),
          set this to 'control-group'.
          If however you want running volume processes (glusterfsd) and thus
          gluster mounts not be interrupted when glusterd is restarted
          (for example, when you want to restart them manually at a later time),
          set this to 'process'.
        '';

        type = lib.types.enum [
          "control-group"
          "process"
          "mixed"
          "none"
        ];
      };

      logLevel = lib.mkOption {
        default = "INFO";
        description = "Log level used by the GlusterFS daemon";

        type = lib.types.enum [
          "DEBUG"
          "INFO"
          "WARNING"
          "ERROR"
          "CRITICAL"
          "TRACE"
          "NONE"
        ];
      };

      stopKillTimeout = lib.mkOption {
        default = "5s";

        description = ''
          The systemd TimeoutStopSec to use.

          After this time after having been asked to shut down, glusterd
          (and depending on the killMode setting also its child processes)
          are killed by systemd.

          The default is set low because GlusterFS (as of 3.10) is known to
          not tell its children (like gsyncd) to terminate at all.
        '';

        type = lib.types.str;
      };

      tlsSettings = lib.mkOption {
        default = null;

        description = ''
          Make the server communicate via TLS.
          This means it will only connect to other gluster
          servers having certificates signed by the same CA.

          Enabling this will create a file {file}`/var/lib/glusterd/secure-access`.
          Disabling will delete this file again.

          See also: <https://gluster.readthedocs.io/en/latest/Administrator%20Guide/SSL/>
        '';

        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              caCert = lib.mkOption {
                description = "Path certificate authority used to sign the cluster certificates.";
                type = lib.types.path;
              };

              tlsKeyPath = lib.mkOption {
                description = "Path to the private key used for TLS.";
                type = lib.types.str;
              };

              tlsPem = lib.mkOption {
                description = "Path to the certificate used for TLS.";
                type = lib.types.path;
              };
            };
          }
        );
      };

      useRpcbind = lib.mkOption {
        default = true;

        description = ''
          Enable use of rpcbind. This is required for Gluster's NFS functionality.

          You may want to turn it off to reduce the attack surface for DDoS reflection attacks.

          See <https://davelozier.com/glusterfs-and-rpcbind-portmap-ddos-reflection-attacks/>
          and <https://bugzilla.redhat.com/show_bug.cgi?id=1426842> for details.
        '';

        type = lib.types.bool;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mkIf (cfg.tlsSettings != null) {
      "ssl/glusterfs.ca".source = cfg.tlsSettings.caCert;
      "ssl/glusterfs.key".source = cfg.tlsSettings.tlsKeyPath;
      "ssl/glusterfs.pem".source = cfg.tlsSettings.tlsPem;
    };

    environment.systemPackages = [ pkgs.glusterfs ];
    services.rpcbind.enable = cfg.useRpcbind;

    systemd.services.glusterd = {
      inherit restartTriggers;
      after = [ "network.target" ] ++ lib.optional cfg.useRpcbind "rpcbind.service";
      description = "GlusterFS, a clustered file-system server";

      preStart = ''
        install -m 0755 -d /var/log/glusterfs
      ''
      # The copying of hooks is due to upstream bug https://bugzilla.redhat.com/show_bug.cgi?id=1452761
      # Excludes one hook due to missing SELinux binaries.
      + ''
        mkdir -p /var/lib/glusterd/hooks/
        # --copy-unsafe-links: the glusterfind hook is a symlink into the package's
        # libexec that would dangle once copied verbatim into / (#257863).
        ${rsync}/bin/rsync -a --copy-unsafe-links --exclude="S10selinux-label-brick.sh" ${glusterfs}/var/lib/glusterd/hooks/ /var/lib/glusterd/hooks/

        ${tlsCmd}
      ''
      # `glusterfind` needs dirs that upstream installs at `make install` phase
      # https://github.com/gluster/glusterfs/blob/v3.10.2/tools/glusterfind/Makefile.am#L16-L17
      + ''
        mkdir -p /var/lib/glusterd/glusterfind/.keys
        mkdir -p /var/lib/glusterd/hooks/1/delete/post/
      ''
      # Volume option presets, installed by upstream under $out/var; copy them so
      # `gluster volume set <vol> group <name>` works (#33159).
      + ''
        mkdir -p /var/lib/glusterd/groups/
        ${rsync}/bin/rsync -a ${glusterfs}/var/lib/glusterd/groups/ /var/lib/glusterd/groups/
      '';

      requires = lib.optional cfg.useRpcbind "rpcbind.service";

      serviceConfig = {
        ExecStart = "${glusterfs}/sbin/glusterd --no-daemon --log-level=${cfg.logLevel} ${toString cfg.extraFlags}";
        KillMode = cfg.killMode;
        LimitNOFILE = 65536;
        TimeoutStopSec = cfg.stopKillTimeout;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.glustereventsd = lib.mkIf cfg.enableGlustereventsd {
      inherit restartTriggers;
      after = [ "network.target" ];
      description = "Gluster Events Notifier";
      # glustereventsd uses the `gluster` executable
      path = [ glusterfs ];

      preStart = ''
        install -m 0755 -d /var/log/glusterfs
      '';

      serviceConfig = {
        ExecReload = "/bin/kill -SIGUSR2 $MAINPID";
        ExecStart = "${glusterfs}/sbin/glustereventsd --pid-file /run/glustereventsd.pid";
        KillMode = "control-group";
        PIDFile = "/run/glustereventsd.pid";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
