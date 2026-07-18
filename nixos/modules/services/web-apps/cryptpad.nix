{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cryptpad;

  inherit (lib)
    mkIf
    mkMerge
    mkOption
    strings
    types
    ;

  # The Cryptpad configuration file isn't JSON, but a JavaScript source file that assigns a JSON value
  # to a variable.
  cryptpadConfigFile = builtins.toFile "cryptpad_config.js" ''
    module.exports = ${builtins.toJSON cfg.settings}
  '';

  # Derive domain names for Nginx configuration from Cryptpad configuration
  mainDomain = strings.removePrefix "https://" cfg.settings.httpUnsafeOrigin;
  sandboxDomain =
    if cfg.settings.httpSafeOrigin == null then
      mainDomain
    else
      strings.removePrefix "https://" cfg.settings.httpSafeOrigin;

in
{
  options.services.cryptpad = {
    enable = lib.mkEnableOption "cryptpad";
    package = lib.mkPackageOption pkgs "cryptpad" { };

    configureNginx = mkOption {
      default = false;

      description = ''
        Configure Nginx as a reverse proxy for Cryptpad.
        Note that this makes some assumptions on your setup, and sets settings that will
        affect other virtualHosts running on your Nginx instance, if any.
        Alternatively you can configure a reverse-proxy of your choice.
      '';

      type = types.bool;
    };

    settings = mkOption {
      description = ''
        Cryptpad configuration settings.
        See <https://github.com/cryptpad/cryptpad/blob/main/config/config.example.js> for a more extensive
        reference documentation.
        Test your deployed instance through `https://<domain>/checkup/`.
      '';

      type = types.submodule {
        options = {
          adminKeys = mkOption {
            default = [ ];
            description = "List of public signing keys of users that can access the admin panel";
            example = [ "[cryptpad-user1@my.awesome.website/YZgXQxKR0Rcb6r6CmxHPdAGLVludrAF2lEnkbx1vVOo=]" ];
            type = types.listOf types.str;
          };

          blockDailyCheck = mkOption {
            default = true;

            description = ''
              Disable telemetry. This setting is only effective if the 'Disable server telemetry'
              setting in the admin menu has been untouched, and will be ignored by cryptpad once
              that option is set either way.
              Note that due to the service confinement, just enabling the option in the admin
              menu will not be able to resolve DNS and fail; this setting must be set as well.
            '';

            type = types.bool;
          };

          httpAddress = mkOption {
            default = "127.0.0.1";
            description = "Address on which the Node.js server should listen";
            type = types.str;
          };

          httpPort = mkOption {
            default = 3000;
            description = "Port on which the Node.js server should listen";
            type = types.port;
          };

          httpSafeOrigin = mkOption {
            description = "Cryptpad sandbox URL";
            example = "https://cryptpad-ui.example.com. Apparently optional but recommended.";
            type = types.nullOr types.str;
          };

          httpUnsafeOrigin = mkOption {
            default = "";
            description = "This is the URL that users will enter to load your instance";
            example = "https://cryptpad.example.com";
            type = types.str;
          };

          installMethod = mkOption {
            default = "nixos";

            description = ''
              Install method is listed in telemetry if you agree to it through the consentToContact
              setting in the admin panel.
            '';

            type = types.str;
          };

          logLevel = mkOption {
            default = "info";
            description = "Controls log level";
            type = types.str;
          };

          logToStdout = mkOption {
            default = true;
            description = "Controls whether log output should go to stdout of the systemd service";
            type = types.bool;
          };

          maxWorkers = mkOption {
            default = null;
            description = "Number of child processes, defaults to number of cores available";
            type = types.nullOr types.int;
          };

          websocketPort = mkOption {
            default = 3003;
            description = "Port for the websocket that needs to be separate";
            type = types.port;
          };
        };

        freeformType = (pkgs.formats.json { }).type;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.services.cryptpad = {
        after = [ "network.target" ];

        confinement = {
          enable = true;
          binSh = null;
          mode = "chroot-only";
        };

        description = "Cryptpad service";

        serviceConfig = {
          # security way too many numerous options, from the systemd-analyze security output
          # at end of test: block everything except
          # - SystemCallFiters=@resources is required for node
          # - MemoryDenyWriteExecute for node JIT
          # - RestrictAddressFamilies=~AF_(INET|INET6) / PrivateNetwork to bind to sockets
          # - IPAddressDeny likewise allow localhost if binding to localhost or any otherwise
          # - PrivateUsers somehow service doesn't start with that
          # - DeviceAllow (char-rtc r added by ProtectClock)
          AmbientCapabilities = "";

          BindReadOnlyPaths = [
            cryptpadConfigFile
            # apparently needs proc for workers management
            "/proc"
            "/dev/urandom"
          ];

          CapabilityBoundingSet = "";
          DeviceAllow = "";
          DynamicUser = true;

          Environment = [
            "CRYPTPAD_CONFIG=${cryptpadConfigFile}"
            "HOME=%S/cryptpad"
          ];

          ExecStart = lib.getExe cfg.package;
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
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
          RemoveIPC = true;
          Restart = "always";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectoryMode = "700";

          SocketBindAllow = [
            "tcp:${toString cfg.settings.httpPort}"
            "tcp:${toString cfg.settings.websocketPort}"
          ];

          SocketBindDeny = [ "any" ];
          StateDirectory = "cryptpad";
          StateDirectoryMode = "0700";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@pkey"
            "@system-service"
            # /!\ order matters: @privileged contains @chown, so we need
            # @privileged negated before we re-list @chown for libuv copy
            "~@privileged"
            "~@chown:EPERM"
            "~@keyring"
            "~@memlock"
            "~@resources"
            "~@setuid"
            "~@timer"
          ];

          UMask = "0077";
          WorkingDirectory = "%S/cryptpad";
        };

        wantedBy = [ "multi-user.target" ];
      };
    }
    # block external network access if not phoning home and
    # binding to localhost (default)
    (mkIf
      (
        cfg.settings.blockDailyCheck
        && (builtins.elem cfg.settings.httpAddress [
          "127.0.0.1"
          "::1"
        ])
      )
      {
        systemd.services.cryptpad = {
          serviceConfig = {
            IPAddressAllow = [ "localhost" ];
            IPAddressDeny = [ "any" ];
          };
        };
      }
    )
    # .. conversely allow DNS & TLS if telemetry is explicitly enabled
    (mkIf (!cfg.settings.blockDailyCheck) {
      systemd.services.cryptpad = {
        serviceConfig = {
          BindReadOnlyPaths = [
            "-/etc/resolv.conf"
            "-/run/systemd"
            "/etc/hosts"
            "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
          ];
        };
      };
    })

    (mkIf cfg.configureNginx {
      assertions = [
        {
          assertion = cfg.settings.httpUnsafeOrigin != "";
          message = "services.cryptpad.settings.httpUnsafeOrigin is required";
        }
        {
          assertion = strings.hasPrefix "https://" cfg.settings.httpUnsafeOrigin;
          message = "services.cryptpad.settings.httpUnsafeOrigin must start with https://";
        }
        {
          assertion =
            cfg.settings.httpSafeOrigin == null || strings.hasPrefix "https://" cfg.settings.httpSafeOrigin;

          message = "services.cryptpad.settings.httpSafeOrigin must start with https:// (or be unset)";
        }
      ];

      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        virtualHosts = mkMerge [
          {
            "${mainDomain}" = {
              enableACME = lib.mkDefault true;
              forceSSL = true;

              locations."/" = {
                extraConfig = ''
                  client_max_body_size 150m;
                '';

                proxyPass = "http://${cfg.settings.httpAddress}:${toString cfg.settings.httpPort}";
              };

              locations."/cryptpad_websocket" = {
                proxyPass = "http://${cfg.settings.httpAddress}:${toString cfg.settings.websocketPort}";
                proxyWebsockets = true;
              };

              serverAliases = lib.optionals (cfg.settings.httpSafeOrigin != null) [ sandboxDomain ];
            };
          }
        ];
      };
    })
  ]);
}
