{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.security.audit;

  failureModes = {
    panic = 2;
    printk = 1;
    silent = 0;
  };

  # The order of the fixed rules is determined by augenrules(8)
  rules = pkgs.writeTextDir "audit.rules" ''
    -D
    -b ${toString cfg.backlogLimit}
    -f ${toString failureModes.${cfg.failureMode}}
    -r ${toString cfg.rateLimit}
    ${lib.concatLines cfg.rules}
    -e ${if cfg.enable == "lock" then "2" else "1"}
  '';
in
{
  options = {
    security.audit = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Linux audit system. The special `lock` value can be used to
          enable auditing and prevent disabling it until a restart. Be careful about locking
          this, as it will prevent you from changing your audit configuration until you
          restart. If possible, test your configuration using build-vm beforehand.
        '';

        type = lib.types.enum [
          false
          true
          "lock"
        ];
      };

      package = lib.mkPackageOption pkgs "audit" { };

      backlogLimit = lib.mkOption {
        # Significantly increase from the kernel default of 64 because a
        # normal systems generates way more logs.
        default = 1024;

        description = ''
          The maximum number of outstanding audit buffers allowed; exceeding this is
          considered a failure and handled in a manner specified by failureMode.
        '';

        type = lib.types.int;
      };

      failureMode = lib.mkOption {
        default = "printk";
        description = "How to handle critical errors in the auditing system";

        type = lib.types.enum [
          "silent"
          "printk"
          "panic"
        ];
      };

      rateLimit = lib.mkOption {
        default = 0;

        description = ''
          The maximum messages per second permitted before triggering a failure as
          specified by failureMode. Setting it to zero disables the limit.
        '';

        type = lib.types.int;
      };

      rules = lib.mkOption {
        default = [ ];

        description = ''
          The ordered audit rules, with each string appearing as one line of the audit.rules file.
        '';

        example = [ "-a exit,always -F arch=b64 -S execve" ];
        type = lib.types.listOf lib.types.str; # (types.either types.str (types.submodule rule));
      };
    };
  };

  config = lib.mkIf (cfg.enable == "lock" || cfg.enable) {
    boot.kernelParams = [
      # A lot of audit events happen before the systemd service starts. Thus
      # enable it via the kernel commandline to have the audit subsystem ready
      # as soon as the kernel starts.
      "audit=1"
      # Also set the backlog limit because the kernel default is too small to
      # capture all of them before the service starts.
      "audit_backlog_limit=${toString cfg.backlogLimit}"
    ];

    environment.systemPackages = [ cfg.package ];

    # upstream contains a audit-rules.service, which uses augenrules.
    # That script does not handle cleanup correctly and insists on loading from /etc/audit.
    # So, instead we have our own service for loading rules.
    systemd.services.audit-rules-nixos = {
      before = [
        "sysinit.target"
        "shutdown.target"
      ];

      conflicts = [ "shutdown.target" ];
      description = "Load Audit Rules";

      serviceConfig = {
        ExecStart = "${lib.getExe' cfg.package "auditctl"} -R ${rules}/audit.rules";

        ExecStopPost = [
          # Disable auditing
          "${lib.getExe' cfg.package "auditctl"} -e 0"
          # Delete all rules
          "${lib.getExe' cfg.package "auditctl"} -D"
        ];

        RemainAfterExit = true;
        Type = "oneshot";
      };

      unitConfig = {
        ConditionKernelCommandLine = [
          "!audit=0"
          "!audit=off"
        ];

        ConditionVirtualization = "!container";
        DefaultDependencies = false;
      };

      wantedBy = [ "sysinit.target" ];
    };
  };
}
