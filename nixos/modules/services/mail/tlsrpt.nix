{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.tlsrpt;

  format = pkgs.formats.ini { };
  dropNullValues = lib.filterAttrsRecursive (_: value: value != null);

  commonServiceSettings = {
    # Hardening
    CapabilityBoundingSet = [ "" ];
    DynamicUser = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    PrivateDevices = true;
    PrivateUsers = false;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "noaccess";
    Restart = "always";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    StateDirectory = "tlsrpt";
    StateDirectoryMode = "0700";
    SystemCallArchitectures = "native";

    SystemCallFilter = [
      "@system-service"
      "~@privileged @resources"
    ];

    User = "tlsrpt";
  };

  collectdConfigFile = format.generate "tlsrpt-collectd.cfg" {
    tlsrpt_collectd = dropNullValues cfg.collectd.settings;
  };
  fetcherConfigFile = format.generate "tlsrpt-fetcher.cfg" {
    tlsrpt_fetcher = dropNullValues cfg.fetcher.settings;
  };
  reportdConfigFile = format.generate "tlsrpt-reportd.cfg" {
    tlsrpt_reportd = dropNullValues cfg.reportd.settings;
  };
in

{
  options.services.tlsrpt = {
    enable = mkEnableOption "the TLSRPT services";
    package = mkPackageOption pkgs "tlsrpt-reporter" { };

    collectd = {
      extraFlags = mkOption {
        default = [ ];

        description = ''
          List of extra flags to pass to the tlsrpt-reportd executable.

          See {manpage}`tlsrpt-collectd(1)` for possible flags.
        '';

        type = with types; listOf str;
      };

      settings = mkOption {
        default = { };

        description = ''
          Flags from {manpage}`tlsrpt-collectd(1)` as key-value pairs.
        '';

        type = types.submodule {
          options = {
            log_level = mkOption {
              default = "info";

              description = ''
                Level of log messages to emit.
              '';

              type = types.enum [
                "debug"
                "info"
                "warning"
                "error"
                "critical"
              ];
            };

            socketmode = mkOption {
              default = "0220";

              description = ''
                Permissions on the UNIX socket.
              '';

              type = types.str;
            };

            socketname = mkOption {
              default = "/run/tlsrpt/collectd.sock";

              description = ''
                Path at which the UNIX socket will be created.
              '';

              type = types.path;
            };

            storage = mkOption {
              default = "sqlite:///var/lib/tlsrpt/collectd.sqlite";

              description = ''
                Storage backend definition.
              '';

              type = types.str;
            };
          };

          freeformType = format.type;
        };
      };
    };

    configurePostfix = mkOption {
      default = true;

      description = ''
        Whether to configure permissions to allow integration with Postfix.
      '';

      type = types.bool;
    };

    fetcher = {
      settings = mkOption {
        default = { };

        description = ''
          Flags from {manpage}`tlsrpt-fetcher(1)` as key-value pairs.
        '';

        type = types.submodule {
          options = {
            log_level = mkOption {
              default = "info";

              description = ''
                Level of log messages to emit.
              '';

              type = types.enum [
                "debug"
                "info"
                "warning"
                "error"
                "critical"
              ];
            };

            storage = mkOption {
              default = config.services.tlsrpt.collectd.settings.storage;

              defaultText = lib.literalExpression ''
                config.services.tlsrpt.collectd.settings.storage
              '';

              description = ''
                Path to the collectd sqlite database.
              '';

              type = types.str;
            };
          };

          freeformType = format.type;
        };
      };
    };

    reportd = {
      extraFlags = mkOption {
        default = [ ];

        description = ''
          List of extra flags to pass to the tlsrpt-reportd executable.

          See {manpage}`tlsrpt-report(1)` for possible flags.
        '';

        type = with types; listOf str;
      };

      settings = mkOption {
        default = { };

        description = ''
          Flags from {manpage}`tlsrpt-reportd(1)` as key-value pairs.
        '';

        type = types.submodule {
          options = {
            contact_info = mkOption {
              description = ''
                Contact information embedded into the reports.
              '';

              example = "smtp-tls-reporting@example.com";
              type = types.str;
            };

            dbname = mkOption {
              default = "/var/lib/tlsrpt/reportd.sqlite";

              description = ''
                Path to the sqlite database.
              '';

              type = types.str;
            };

            fetchers = mkOption {
              default = lib.getExe' cfg.package "tlsrpt-fetcher";

              defaultText = lib.literalExpression ''
                lib.getExe' cfg.package "tlsrpt-fetcher"
              '';

              description = ''
                Comma-separated list of fetcher programs that retrieve collectd data.
              '';

              type = types.str;
            };

            http_script = mkOption {
              default = "${lib.getExe pkgs.curl} --silent --header 'Content-Type: application/tlsrpt+gzip' --data-binary @-";

              defaultText = lib.literalExpression ''
                ''${lib.getExe pkgs.curl} --silent --header 'Content-Type: application/tlsrpt+gzip' --data-binary @-
              '';

              description = ''
                Call to an HTTPS client, that accepts the URL on the commandline and the request body from stdin.
              '';

              type = with types; nullOr str;
            };

            log_level = mkOption {
              default = "info";

              description = ''
                Level of log messages to emit.
              '';

              type = types.enum [
                "debug"
                "info"
                "warning"
                "error"
                "critical"
              ];
            };

            organization_name = mkOption {
              description = ''
                Name of the organization sending out the reports.
              '';

              example = "ACME Corp.";
              type = types.str;
            };

            sender_address = mkOption {
              description = ''
                Sender address used for reports.
              '';

              example = "noreply@example.com";
              type = types.str;
            };

            sendmail_script = mkOption {
              default =
                if config.services.postfix.enable && config.services.postfix.setSendmail then
                  "/run/wrappers/bin/sendmail -i -t -f ${cfg.reportd.settings.sender_address}"
                else
                  null;

              defaultText = lib.literalExpression ''
                if config.services.postfix.enable && config.services.postfix.setSendmail then
                  "/run/wrappers/bin/sendmail -i -t -f $${cfg.reportd.settings.sender_address}"
                else
                  null
              '';

              description = ''
                Path to a sendmail-compatible executable for delivery reports.
              '';

              type = with types; nullOr str;
            };
          };

          freeformType = format.type;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && config.services.postfix.enable && cfg.configurePostfix) {
      services.postfix.settings.main = {
        smtp_tlsrpt_enable = true;
        smtp_tlsrpt_socket_name = cfg.collectd.settings.socketname;
      };

      systemd.services.tlsrpt-reportd.serviceConfig = {
        ReadWritePaths = [ "/var/lib/postfix/queue/maildrop" ];
        SupplementaryGroups = [ "postdrop" ];
      };

      users.users.postfix.extraGroups = [
        "tlsrpt"
      ];
    })

    (mkIf cfg.enable {
      environment.etc = {
        "tlsrpt/collectd.cfg".source = collectdConfigFile;
        "tlsrpt/fetcher.cfg".source = fetcherConfigFile;
        "tlsrpt/reportd.cfg".source = reportdConfigFile;
      };

      systemd.services.tlsrpt-collectd = {
        description = "TLSRPT datagram collector";
        documentation = [ "man:tlsrpt-collectd(1)" ];
        restartTriggers = [ collectdConfigFile ];

        serviceConfig = commonServiceSettings // {
          ExecStart = toString (
            [
              (lib.getExe' cfg.package "tlsrpt-collectd")
            ]
            ++ cfg.collectd.extraFlags
          );

          IPAddressDeny = "any";
          PrivateNetwork = true;
          RestrictAddressFamilies = [ "AF_UNIX" ];
          RuntimeDirectory = "tlsrpt";
          RuntimeDirectoryMode = "0750";
          UMask = "0157";
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.tlsrpt-reportd = {
        description = "TLSRPT report generator";
        documentation = [ "man:tlsrpt-reportd(1)" ];
        restartTriggers = [ reportdConfigFile ];

        serviceConfig = commonServiceSettings // {
          ExecStart = toString (
            [
              (lib.getExe' cfg.package "tlsrpt-reportd")
            ]
            ++ cfg.reportd.extraFlags
          );

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          UMask = "0077";
        };

        wantedBy = [ "multi-user.target" ];
      };

      users.groups.tlsrpt = { };

      users.users.tlsrpt = {
        group = "tlsrpt";
        isSystemUser = true;
      };
    })
  ];
}
