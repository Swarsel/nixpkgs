{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.passless;
  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "passless.toml" cfg.settings;
in
{

  options.programs.passless = {
    enable = lib.mkEnableOption "passless";
    package = lib.mkPackageOption pkgs "passless" { };

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = { };

      description = ''
        Configuration included in `config.toml`.

        See <https://github.com/pando85/passless#configuration-1> for documentation or run `passless config print` to see default configuration.
      '';

      example = {
        pass.store-path = "/home/alice/.local/share/password-store";
      };
    };

    users = lib.options.mkOption {
      default = [ ];

      description = ''
        Users that intend to use passless and should be added to the fido group.
      '';

      example = [ "alice" ];
      type = with lib.types; listOf str;
    };
  };

  config = lib.mkIf config.programs.passless.enable {
    boot.kernelModules = [ "uhid" ];

    services.udev.extraRules = ''
      KERNEL=="uhid", GROUP="fido", MODE="0660"
    '';

    # From https://github.com/pando85/passless/blob/master/contrib/systemd/passless.service
    systemd.user.services.passless = {
      after = [ "network-online.target" ];
      description = "Passless FIDO2 Software Authenticator";
      documentation = [ "https://github.com/pando85/passless" ];
      path = [ config.programs.gnupg.package ];

      serviceConfig = {
        CapabilityBoundingSet = [
          "~CAP_BLOCK_SUSPEND"
          "CAP_BPF"
          "CAP_CHOWN"
          "CAP_MKNOD"
          "CAP_NET_RAW"
          "CAP_PERFMON"
          "CAP_SYS_BOOT"
          "CAP_SYS_CHROOT"
          "CAP_SYS_MODULE"
          "CAP_SYS_NICE"
          "CAP_SYS_PACCT"
          "CAP_SYS_PTRACE"
          "CAP_SYS_TIME"
          "CAP_SYSLOG"
          "CAP_WAKE_ALARM"
        ];

        ExecStart = "${lib.getExe cfg.package} --config-path ${settingsFile}";
        LimitMEMLOCK = "2M";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        # Security hardening
        # The application already handles its own memory locking and core dump prevention
        # but we can add additional systemd protections
        NoNewPrivileges = true;
        PrivateMounts = "true";
        PrivateTmp = "disconnected";
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = "true";
        # Found with shh
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "5s";
        RestrictAddressFamilies = "AF_UNIX";
        RestrictRealtime = true;

        SocketBindDeny = [
          "ipv4:tcp"
          "ipv4:udp"
          "ipv6:tcp"
          "ipv6:udp"
        ];

        SyslogIdentifier = "passless";

        SystemCallFilter = [
          "~@aio:EPERM"
          "@chown:EPERM"
          "@clock:EPERM"
          "@cpu-emulation:EPERM"
          "@debug:EPERM"
          "@ipc:EPERM"
          "@keyring:EPERM"
          "@module:EPERM"
          "@mount:EPERM"
          "@obsolete:EPERM"
          "@pkey:EPERM"
          "@privileged:EPERM"
          "@raw-io:EPERM"
          "@reboot:EPERM"
          "@resources:EPERM"
          "@sandbox:EPERM"
          "@setuid:EPERM"
          "@swap:EPERM"
          "@sync:EPERM"
        ];

        Type = "simple";

      };

      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.fido.members = cfg.users;
  };

  meta.maintainers = with lib.maintainers; [ erictapen ];

}
