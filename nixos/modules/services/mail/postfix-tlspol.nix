{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    hasPrefix
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.postfix-tlspol;

  format = pkgs.formats.yaml_1_2 { };
  configFile = format.generate "postfix-tlspol.yaml" cfg.settings;
in

{
  options.services.postfix-tlspol = {
    enable = mkEnableOption "postfix-tlspol";
    package = mkPackageOption pkgs "postfix-tlspol" { };

    configurePostfix = mkOption {
      default = true;

      description = ''
        Whether to configure the required settings to use postfix-tlspol in the local Postfix instance.
      '';

      type = types.bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        The postfix-tlspol configuration file as a Nix attribute set.

        See the reference documentation for possible options.
        <https://github.com/Zuplu/postfix-tlspol/blob/main/configs/config.default.yaml>
      '';

      type = types.submodule {
        options = {
          dns = {
            address = mkOption {
              default = null;

              description = ''
                IP and port to your DNS resolver.

                Uses resolvers from /etc/resolv.conf if unset.

                ::: {.note}
                The configured DNS resolver must validate DNSSEC signatures.
                :::
              '';

              example = "127.0.0.1:53";
              type = with types; nullOr str;
            };
          };

          server = {
            address = mkOption {
              default = "unix:/run/postfix-tlspol/tlspol.sock";

              description = ''
                Path or address/port where postfix-tlspol binds its socket to.
              '';

              example = "127.0.0.1:8642";
              type = types.str;
            };

            cache-file = mkOption {
              default = "/var/cache/postfix-tlspol/cache.db";

              description = ''
                Path to the cache file.
              '';

              readOnly = true;
              type = types.path;
            };

            log-level = mkOption {
              default = "info";

              description = ''
                Log level
              '';

              example = "warn";

              type = types.enum [
                "debug"
                "info"
                "warn"
                "error"
              ];
            };

            prefetch = mkOption {
              default = true;

              description = ''
                Whether to prefetch DNS records when the TTL of a cached record is about to expire.
              '';

              example = false;
              type = types.bool;
            };

            socket-permissions = mkOption {
              apply = value: (fromTOML "v=0o${value}").v;
              default = "0660";

              description = ''
                Permissions to the UNIX socket, if configured.

                ::: {.note}
                Due to hardening on the systemd unit the socket can never be created world readable/writable.
                :::
              '';

              readOnly = true;
              type = types.str;
            };
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && config.services.postfix.enable && cfg.configurePostfix) {
      # https://github.com/Zuplu/postfix-tlspol#postfix-configuration
      services.postfix.settings.main = {
        smtp_dns_support_level = "dnssec";

        smtp_tls_policy_maps =
          let
            address =
              if (hasPrefix "unix:" cfg.settings.server.address) then
                cfg.settings.server.address
              else
                "inet:${cfg.settings.server.address}";
          in
          [ "socketmap:${address}:QUERYwithTLSRPT" ];

        smtp_tls_security_level = "dane";
      };

      systemd.services.postfix = {
        after = [ "postfix-tlspol.service" ];
        wants = [ "postfix-tlspol.service" ];
      };

      users.users.postfix.extraGroups = [ "postfix-tlspol" ];
    })

    (mkIf cfg.enable {
      environment.etc."postfix-tlspol/config.yaml".source = configFile;
      environment.systemPackages = [ cfg.package ];

      systemd.services.postfix-tlspol = {
        after = [
          "nss-lookup.target"
          "network-online.target"
        ];

        description = "Postfix DANE/MTA-STS TLS policy socketmap service";
        documentation = [ "https://github.com/Zuplu/postfix-tlspol" ];
        restartTriggers = [ configFile ];

        # https://github.com/Zuplu/postfix-tlspol/blob/main/init/postfix-tlspol.service
        serviceConfig = {
          CacheDirectory = "postfix-tlspol";
          CapabilityBoundingSet = [ "" ];
          ExecReload = "${lib.getExe' pkgs.util-linux "kill"} -HUP $MAINPID";

          ExecStart = toString [
            (lib.getExe cfg.package)
            "-config"
            "/etc/postfix-tlspol/config.yaml"
          ];

          Group = "postfix-tlspol";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadOnlyPaths = [ "/etc/postfix-tlspol/config.yaml" ];
          RemoveIPC = true;
          Restart = "always";
          RestartSec = 5;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "postfix-tlspol";
          RuntimeDirectoryMode = "1750";

          SecureBits = [
            "noroot"
            "noroot-locked"
          ];

          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";

          SystemCallFilter = [
            "@system-service"
            "~@privileged @resources"
          ];

          UMask = "0077";
          User = "postfix-tlspol";
          WorkingDirectory = "/var/cache/postfix-tlspol";
        };

        wants = [
          "nss-lookup.target"
          "network-online.target"
        ];
      };

      systemd.sockets.postfix-tlspol = {
        socketConfig = {
          Accept = false;
          DirectoryMode = "0755";

          ListenStream = [
            (lib.removePrefix "unix:" cfg.settings.server.address)
          ];

          SocketGroup = "postfix-tlspol";
          SocketMode = cfg.settings.server.socket-permissions;
          SocketUser = "postfix-tlspol";
        };

        wantedBy = [ "sockets.target" ];
      };

      users.groups.postfix-tlspol = { };

      users.users.postfix-tlspol = {
        group = "postfix-tlspol";
        isSystemUser = true;
      };
    })
  ];

  meta.maintainers = pkgs.postfix-tlspol.meta.maintainers;
}
