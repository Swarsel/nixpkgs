{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let

  cfg = config.systemd.shutdownRamfs;

  ramfsContents = pkgs.writeText "shutdown-ramfs-contents.json" (builtins.toJSON cfg.storePaths);

in
{
  options.systemd.shutdownRamfs = {
    enable = lib.mkEnableOption "pivoting back to an initramfs for shutdown" // {
      default = true;
    };

    contents = lib.mkOption {
      description = "Set of files that have to be linked into the shutdown ramfs";

      example = lib.literalExpression ''
        {
          "/lib/systemd/system-shutdown/zpool-sync-shutdown".source = writeShellScript "zpool" "exec ''${zfs}/bin/zpool sync"
        }
      '';

      type = utils.systemdUtils.types.initrdContents;
    };

    shell.enable = lib.mkEnableOption "" // {
      default = config.environment.shell.enable;

      description = ''
        Whether to enable a shell in the shutdown ramfs.

        In contrast to `environment.shell.enable`, this option actually
        strictly disables all shells in the shutdown ramfs because they're not
        copied into it anymore. Paths that use a shell (e.g. via the `script`
        option), will break if this option is set.

        Only set this option if you're sure that you can recover from potential
        issues.
      '';

      internal = true;
    };

    storePaths = lib.mkOption {
      default = [ ];

      description = ''
        Store paths to copy into the shutdown ramfs as well.
      '';

      type = utils.systemdUtils.types.initrdStorePath;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.mounts = [
      {
        options = "mode=0700";
        type = "tmpfs";
        what = "tmpfs";
        where = "/run/initramfs";
      }
    ];

    systemd.services.generate-shutdown-ramfs = {
      before = [ "shutdown.target" ];
      description = "Generate shutdown ramfs";

      serviceConfig = {
        ExecStart = "${pkgs.makeInitrdNGTool}/bin/make-initrd-ng ${ramfsContents} /run/initramfs";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateNetwork = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        # Sandboxing
        ProtectSystem = "strict";
        ReadWritePaths = "/run/initramfs";
        Type = "oneshot";
      };

      unitConfig = {
        ConditionFileIsExecutable = [
          "!/run/initramfs/shutdown"
        ];

        DefaultDependencies = false;
        RequiresMountsFor = "/run/initramfs";
      };

      wantedBy = [ "shutdown.target" ];
    };

    systemd.shutdownRamfs.contents = {
      "/etc/initrd-release".source = config.environment.etc.os-release.source;
      "/etc/os-release".source = config.environment.etc.os-release.source;
      "/shutdown".source = "${config.systemd.package}/lib/systemd/systemd-shutdown";
    };

    systemd.shutdownRamfs.storePaths = [
      "${pkgs.coreutils}/bin"
    ]
    ++ lib.optionals cfg.shell.enable [
      pkgs.runtimeShell
    ]
    ++ map (c: removeAttrs c [ "text" ]) (builtins.attrValues cfg.contents);
  };
}
