{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.networking.ucarp;

  ucarpExec = concatStringsSep " " (
    [
      "${cfg.package}/bin/ucarp"
      "--interface=${cfg.interface}"
      "--srcip=${cfg.srcIp}"
      "--vhid=${toString cfg.vhId}"
      "--passfile=${cfg.passwordFile}"
      "--addr=${cfg.addr}"
      "--advbase=${toString cfg.advBase}"
      "--advskew=${toString cfg.advSkew}"
      "--upscript=${cfg.upscript}"
      "--downscript=${cfg.downscript}"
      "--deadratio=${toString cfg.deadratio}"
    ]
    ++ (optional cfg.preempt "--preempt")
    ++ (optional cfg.neutral "--neutral")
    ++ (optional cfg.shutdown "--shutdown")
    ++ (optional cfg.ignoreIfState "--ignoreifstate")
    ++ (optional cfg.noMcast "--nomcast")
    ++ (optional (cfg.extraParam != null) "--xparam=${cfg.extraParam}")
  );
in
{
  options.networking.ucarp = {
    enable = mkEnableOption "ucarp, userspace implementation of CARP";

    package = mkPackageOption pkgs "ucarp" {
      extraDescription = ''
        Please note that the default package, pkgs.ucarp, has not received any
        upstream updates for a long time and can be considered as unmaintained.
      '';
    };

    addr = mkOption {
      description = "Virtual shared IP address.";
      type = types.str;
    };

    advBase = mkOption {
      default = 1;
      description = "Advertisement frequency in seconds.";
      type = types.ints.unsigned;
    };

    advSkew = mkOption {
      default = 0;
      description = "Advertisement skew in seconds.";
      type = types.ints.unsigned;
    };

    deadratio = mkOption {
      default = 3;
      description = "Ratio to consider a host as dead.";
      type = types.ints.unsigned;
    };

    downscript = mkOption {
      description = ''
        Command to run after become backup, the interface name, virtual address
        and optional extra parameters are passed as arguments.
      '';

      example = literalExpression ''
        pkgs.writeScript "downscript" '''
          #!/bin/sh
          ''${pkgs.iproute2}/bin/ip addr del "$2"/24 dev "$1"
        ''';
      '';

      type = types.path;
    };

    extraParam = mkOption {
      default = null;
      description = "Extra parameter to pass to the up/down scripts.";
      type = types.nullOr types.str;
    };

    ignoreIfState = mkOption {
      default = false;
      description = "Ignore interface state, e.g., down or no carrier.";
      type = types.bool;
    };

    interface = mkOption {
      description = "Network interface to bind to.";
      example = "eth0";
      type = types.str;
    };

    neutral = mkOption {
      default = false;
      description = "Do not run downscript at start if the host is the backup.";
      type = types.bool;
    };

    noMcast = mkOption {
      default = false;
      description = "Use broadcast instead of multicast advertisements.";
      type = types.bool;
    };

    passwordFile = mkOption {
      description = "File containing shared password between CARP hosts.";
      example = "/run/keys/ucarp-password";
      type = types.str;
    };

    preempt = mkOption {
      default = false;

      description = ''
        Enable preemptive failover.
        Thus, this host becomes the CARP master as soon as possible.
      '';

      type = types.bool;
    };

    shutdown = mkOption {
      default = false;
      description = "Call downscript at exit.";
      type = types.bool;
    };

    srcIp = mkOption {
      description = "Source (real) IP address of this host.";
      type = types.str;
    };

    upscript = mkOption {
      description = ''
        Command to run after become master, the interface name, virtual address
        and optional extra parameters are passed as arguments.
      '';

      example = literalExpression ''
        pkgs.writeScript "upscript" '''
          #!/bin/sh
          ''${pkgs.iproute2}/bin/ip addr add "$2"/24 dev "$1"
        ''';
      '';

      type = types.path;
    };

    vhId = mkOption {
      description = "Virtual IP identifier shared between CARP hosts.";
      example = 1;
      type = types.ints.between 1 255;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ucarp = {
      after = [ "network.target" ];
      description = "ucarp, userspace implementation of CARP";

      serviceConfig = {
        ExecStart = ucarpExec;
        MemoryDenyWriteExecute = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectSystem = "strict";
        RestrictRealtime = true;
        Type = "exec";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
