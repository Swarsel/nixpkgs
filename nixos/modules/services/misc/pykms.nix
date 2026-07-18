{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pykms;
  libDir = "/var/lib/pykms";

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "pykms" "verbose" ] "Use services.pykms.logLevel instead")
  ];

  options = {
    services.pykms = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the PyKMS service.";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "pykms" { };

      extraArgs = lib.mkOption {
        default = [ ];
        description = "Additional arguments";
        type = lib.types.listOf lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "0.0.0.0";
        description = "The IP address on which to listen.";
        example = "::";
        type = lib.types.str;
      };

      logLevel = lib.mkOption {
        default = "INFO";
        description = "How much to log";

        type = lib.types.enum [
          "CRITICAL"
          "ERROR"
          "WARNING"
          "INFO"
          "DEBUG"
          "MININFO"
        ];
      };

      memoryLimit = lib.mkOption {
        default = "64M";
        description = "How much memory to use at most.";
        type = lib.types.str;
      };

      openFirewallPort = lib.mkOption {
        default = false;
        description = "Whether the listening port should be opened automatically.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 1688;
        description = "The port on which to listen.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewallPort [ cfg.port ];

    systemd.services.pykms = {
      after = [ "network.target" ];
      description = "Python KMS";
      # python programs with DynamicUser = true require HOME to be set
      environment.HOME = libDir;

      serviceConfig = {
        DynamicUser = true;

        ExecStart = lib.concatStringsSep " " (
          [
            "${lib.getBin cfg.package}/bin/server"
            "--logfile=STDOUT"
            "--loglevel=${cfg.logLevel}"
            "--sqlite=${libDir}/clients.db"
          ]
          ++ cfg.extraArgs
          ++ [
            cfg.listenAddress
            (toString cfg.port)
          ]
        );

        ExecStartPre = "${lib.getBin cfg.package}/libexec/create_pykms_db.sh ${libDir}/clients.db";
        MemoryMax = cfg.memoryLimit;
        ProtectHome = "tmpfs";
        Restart = "on-failure";
        StateDirectory = baseNameOf libDir;
        SyslogIdentifier = "pykms";
        WorkingDirectory = libDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ peterhoeg ];
}
