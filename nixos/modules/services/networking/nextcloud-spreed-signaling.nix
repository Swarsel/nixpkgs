{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.services.nextcloud-spreed-signaling;

  iniFmt = pkgs.formats.ini { };

  filterSettings =
    settings: lib.filterAttrsRecursive (n: v: (v != null) && (!(lib.hasSuffix "File" n))) settings;

  finalSettings = filterSettings (cfg.backends // cfg.settings);

  configFile = iniFmt.generate "server.conf" finalSettings;

  mkSecretOptions =
    {
      description,
      name,
      path,
      nullable ? false,
    }:
    {
      ${name} = mkOption {
        default = "#${path}-${name}#";
        internal = true;
        readOnly = true;
        type = types.str;
      };

      "${name}File" =
        mkOption {
          description = ''
            The path to the file containing the value for `${path}.${name}`.

            ${description}
          '';

          example = "/run/secrets/${path}.${name}";
          type = if nullable then types.nullOr types.path else types.path;
        }
        // (lib.optionalAttrs nullable { default = null; });
    };

  mkManySecretOptions =
    {
      options,
      path,
      nullable ? false,
    }:
    lib.foldlAttrs (
      acc: name: value:
      acc
      // (mkSecretOptions {
        inherit name path nullable;
        description = value;
      })
    ) { } options;

  # backends are declared alongside other config groups,
  # so we need to make sure users don't accidentally override their configs,
  # since backend names can be chosen arbitrarily
  illegalBackendNames = [
    "app"
    "backend"
    "clients"
    "continent-overrides"
    "etcd"
    "federation"
    "geoip"
    "geoip-overrides"
    "grpc"
    "http"
    "https"
    "mcu"
    "nats"
    "sessions"
    "stats"
    "tun"
  ];
in
{
  options.services.nextcloud-spreed-signaling = {
    enable = lib.mkEnableOption "Spreed standalone signaling server";
    package = lib.mkPackageOption pkgs "nextcloud-spreed-signaling" { };

    backends = mkOption {
      apply = lib.mapAttrs (
        n: v:
        (
          v
          // {
            secret = "#backend-${n}-secret#";
          }
        )
      );

      default = { };

      description = ''
        A list of backends from which clients are allowed to connect from. The name of the attribute will be used as the
        backend id.

        Each backend will have isolated rooms, i.e. clients connecting to room "abc12345" on backend 1 will be in a
        different room than clients connected to a room with the same name on backend 2. Also sessions connected from
        different backends will not be able to communicate with each other.
      '';

      example = {
        nextcloud = {
          secretFile = "/run/secrets/nextcloud-secret";
          urls = [ "https://cloud.example.com" ];
        };
      };

      type = types.attrsOf (
        types.submodule {
          options = {
            urls = mkOption {
              apply = builtins.concatStringsSep ", ";
              description = "List of URLs of the Nextcloud instance";
              type = types.listOf types.str;
            };
          }
          // (mkSecretOptions {
            description = ''
              Shared secret for requests from and to the backend servers.

              This must be the same value as configured in the Nextloud Talk admin UI.
            '';

            name = "secret";
            path = "backends.<name>";
          });
        }
      );
    };

    configureNginx = mkOption {
      default = false;

      description = ''
        Whether to set up and configure an nginx virtual host according to upstream's recommendations.

        The virtualHost domain must be specified under `config.services.nextcloud-spreed-signaling.hostName` if this is enabled.
      '';

      example = true;
      type = types.bool;
    };

    group = mkOption {
      default = "nextcloud-spreed-signaling";
      description = "Group under which to run the Spreed signaling server.";
      type = types.str;
    };

    hostName = mkOption {
      default = null;

      description = ''
        The host name to bind the nginx virtual host to, if
        `config.services.nextcloud-spreed-signaling.configureNginx` is set to `true`.
      '';

      example = "talk.mydomain.org";
      type = types.nullOr types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Declarative configuration. Refer to
        <https://github.com/strukturag/nextcloud-spreed-signaling/blob/master/server.conf.in> for a list of available
        options.
      '';

      type = types.submodule (
        { config, options, ... }:
        {
          options = {
            app = {
              debug = mkOption {
                default = false;

                description = ''
                  Set to "true" to install pprof debug handlers. Access will only be possible from IPs allowed through
                  IPs declared in `config.${options.stats.allowed_ips}`.

                  See "https://golang.org/pkg/net/http/pprof/" for further information.
                '';

                type = types.bool;
              };
            };

            backend = {
              allowall = mkOption {
                default = false;
                description = "Allow any hostname as backend endpoint. This is insecure and not advised.";
                example = true;
                type = types.bool;
              };

              backends = mkOption {
                default = builtins.concatStringsSep ", " (builtins.attrNames cfg.backends);
                internal = true;
                readOnly = true;
                type = types.str;
              };

              backendtype = mkOption {
                default = "static";

                description = ''
                  Type of backend configuration.
                  Defaults to "static".

                  Possible values:
                  - static: A comma-separated list of backends is given in the "backends" option (derived from
                    `config.services.nextcloud-spreed-signaling.backends`)
                  - etcd: Backends are retrieved from an etcd cluster.
                '';

                type = types.enum [
                  "static"
                  "etcd"
                ];
              };

              connectionsperhost = mkOption {
                default = 8;
                description = "Maximum number of concurrent backend connections per host";
                example = 12;
                type = types.ints.positive;
              };

              timeout = mkOption {
                default = 10;
                description = "Timeout in seconds for requests to the backend";
                example = 30;
                type = types.ints.positive;
              };
            };

            clients = mkSecretOptions {
              description = ''
                Shared secret for connections from internal clients.
                This must be the same value as configured in the respective internal services.
              '';

              name = "internalsecret";
              path = "clients";
            };

            etcd = {
              endpoints = mkOption {
                apply = v: if v == [ ] then null else (builtins.concatStringsSep "," v);
                default = [ ];
                description = "List of static etcd endpoints to connect to.";
                example = [ "127.0.0.1:2379" ];
                type = types.listOf types.str;
              };
            };

            grpc = {
              listen = mkOption {
                default = null;
                description = "IP and port to listen on for GRPC requests. Leave `null` to disable the listener.";
                example = "127.0.0.1:9090";
                type = types.nullOr types.str;
              };

              targets = mkOption {
                apply = v: if v == [ ] then null else (builtins.concatStringsSep ", " v);
                default = [ ];
                description = "For target type `static`: List of GRPC targets to connect to for clustering mode.";
                example = [ "192.168.0.1:9090" ];
                type = types.listOf types.str;
              };
            };

            http = {
              listen = mkOption {
                default = null;

                description = ''
                  IP and port to listen on for HTTP requests, in the format of `ip:port`.

                  If set to `null`, will not spawn a HTTP listener at all.
                '';

                example = "127.0.0.1:8080";
                type = types.nullOr types.str;
              };
            };

            https = {
              certificate = mkOption {
                default = null;

                description = ''
                  Path to the certificate used for the HTTPS listener. Must be set if `config.${options.https.listen}`
                  is not `null`.
                '';

                example = "/etc/nginx/ssl/server.crt";
                type = types.nullOr types.path;
              };

              key = mkOption {
                default = null;

                description = ''
                  Path to the private key used for the HTTPS listener. Must be set if `config.${options.https.listen}`
                  is not `null`.
                '';

                example = "/etc/nginx/ssl/server.key";
                type = types.nullOr types.path;
              };

              listen = mkOption {
                default = null;

                description = ''
                  IP and port to listen on for HTTPS requests, in the format of `ip:port`.

                  If set, must also specify `config.${options.https.certificate}` and `config.${options.https.key}`.
                  If set to `null`, will not spawn a HTTPS listener at all.
                '';

                example = "127.0.0.1:8443";
                type = types.nullOr types.str;
              };
            };

            mcu = {
              type = mkOption {
                default = null;
                description = "The type of MCU to use. Leave empty to disable MCU functionality.";
                example = "janus";

                type = types.nullOr (
                  types.enum [
                    "janus"
                    "proxy"
                  ]
                );
              };
            };

            nats = {
              url = mkOption {
                apply = builtins.concatStringsSep ",";
                default = [ "nats://loopback" ];

                description = ''
                  URL of one or more NATS backends to use.

                  This can be set to `nats://loopback` to process NATS messages internally instead.
                '';

                example = [ "nats://localhost:4222" ];
                type = types.listOf types.str;
              };
            };

            sessions = mkManySecretOptions {
              options = {
                "blockkey" = ''
                  Key for encrypting data in the sessions. Must be either 16, 24, or 32 bytes.
                  Generate one using `openssl rand -hex 16`
                '';

                "hashkey" = ''
                  Secret value used to generate the checksums of sessions.
                  This should be a random string of 32 or 64 bytes.
                  Generate one using `openssl rand -hex 32`
                '';
              };

              path = "sessions";
            };

            stats = {
              allowed_ips = mkOption {
                apply = v: if (v == null || v == [ ]) then null else (builtins.concatStringsSep ", " v);
                default = null;

                description = ''
                  List of IP addresses that are allowed to access the debug, stats and metrics endpoints.

                  Leave empty or `null` to only allow access from localhost.
                '';

                example = [ "127.0.0.1" ];
                type = types.nullOr (types.listOf types.str);
              };
            };

            turn = {
              servers = mkOption {
                apply = v: if v == [ ] then null else (builtins.concatStringsSep "," v);
                default = [ ];
                description = "A list of TURN servers to use. Leave empty to disable the TURN REST API.";
                example = [ "turn:1.2.3.4:9991?transport=udp" ];
                type = types.listOf types.str;
              };
            }
            // (mkManySecretOptions {
              options = {
                "apikey" = ''
                  API key that the MCU will need to send when requesting TURN credentials.
                '';

                "secret" = ''
                  The shared secret to use for generating TURN credentials. This must be the same as on the TURN server.
                '';
              };

              nullable = true;
              path = "turn";
            });
          };

          freeformType = iniFmt.type;
        }
      );
    };

    stateDir = mkOption {
      default = "/var/lib/nextcloud-spreed-signaling";
      description = "Directory used for state & config files.";
      type = types.path;
    };

    user = mkOption {
      default = "nextcloud-spreed-signaling";
      description = "User account under which to run the Spreed signaling server.";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion =
              (cfg.settings.https.listen != null)
              -> ((cfg.settings.https.certificate != null) && (cfg.settings.https.key != null));

            message = ''
              When enabling `services.nextcloud-spreed-signaling.settings.https.listen`, you must specify certificate &
              private key files.
            '';
          }
          {
            assertion =
              (cfg.settings.turn.servers != null)
              -> ((cfg.settings.turn.apikeyFile != null) && (cfg.settings.turn.secretFile != null));

            message = ''
              When enabling `services.nextcloud-spreed-signaling.settings.turn.servers`, api & secret keys must be
              configured.
            '';
          }
          {
            assertion =
              !(lib.lists.any (v: builtins.elem v illegalBackendNames) (builtins.attrNames cfg.backends));

            message = ''
              Backends defined in `services.nextcloud-spreed-signaling.backends` may not have any of the following names:

              ${builtins.concatStringsSep "\n" (map (e: "- `${e}`") illegalBackendNames)}
            '';
          }
          {
            assertion = cfg.configureNginx -> (cfg.settings.http.listen != null);

            message = ''
              You must specify a listening address & port in `services.nextcloud-spreed-signaling.settings.http.listen` when choosing to configure nginx.
            '';
          }
          {
            assertion = cfg.configureNginx -> (cfg.hostName != null);

            message = ''
              You must specify a host name in `services.nextcloud-spreed-signaling.hostName` when choosing to configure nginx.
            '';
          }
        ];

        systemd.services.nextcloud-spreed-signaling =
          let
            runConfig = "${cfg.stateDir}/server.conf";
          in
          {
            after = [ "network-online.target" ];
            description = "Spreed standalone signaling server";

            preStart =
              let
                replaceSecretBin = lib.getExe pkgs.replace-secret;
              in
              ''
                cp -f '${configFile}' '${runConfig}'
                chmod u+w '${runConfig}'

                ${replaceSecretBin} '${cfg.settings.sessions.hashkey}' '${cfg.settings.sessions.hashkeyFile}' '${runConfig}'
                ${replaceSecretBin} '${cfg.settings.sessions.blockkey}' '${cfg.settings.sessions.blockkeyFile}' '${runConfig}'
                ${replaceSecretBin} '${cfg.settings.clients.internalsecret}' '${cfg.settings.clients.internalsecretFile}' '${runConfig}'

                ${lib.optionalString (cfg.settings.turn.apikeyFile != null)
                  "${replaceSecretBin} '${cfg.settings.turn.apikey}' '${cfg.settings.turn.apikeyFile}' '${runConfig}'"
                }
                ${lib.optionalString (cfg.settings.turn.secretFile != null)
                  "${replaceSecretBin} '${cfg.settings.turn.secret}' '${cfg.settings.turn.secretFile}' '${runConfig}'"
                }

                ${builtins.concatStringsSep "\n" (
                  lib.mapAttrsToList (
                    _: v: "${replaceSecretBin} '${v.secret}' '${v.secretFile}' '${runConfig}'"
                  ) cfg.backends
                )}

                chmod u-w '${runConfig}'
              '';

            serviceConfig = {
              ExecStart = "${lib.getExe cfg.package} --config '${runConfig}'";
              Group = cfg.group;
              # Taken from https://github.com/strukturag/nextcloud-spreed-signaling/blob/master/dist/init/systemd/signaling.service
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

              ReadWritePaths = [
                cfg.stateDir
              ];

              RemoveIPC = true;
              Restart = "on-failure";

              RestrictAddressFamilies = [
                "AF_INET"
                "AF_INET6"
                "AF_UNIX"
              ];

              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              RuntimeDirectory = "nextcloud-spreed-signaling";
              RuntimeDirectoryMode = "0755";
              SystemCallArchitectures = "native";

              SystemCallFilter = [
                "@system-service"
                "~@privileged"
              ];

              Type = "simple";
              User = cfg.user;
              WorkingDirectory = cfg.stateDir;
            };

            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
          };

        systemd.tmpfiles.rules = [
          "d '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group} - -"
        ];

        users.groups = lib.mkIf (cfg.group == "nextcloud-spreed-signaling") {
          nextcloud-spreed-signaling = { };
        };

        users.users = lib.mkIf (cfg.user == "nextcloud-spreed-signaling") {
          nextcloud-spreed-signaling = {
            inherit (cfg) group;
            isSystemUser = true;
          };
        };
      }
      (lib.mkIf cfg.configureNginx {
        services.nginx = {
          enable = true;

          virtualHosts."${cfg.hostName}" = {
            locations."/" = {
              proxyPass = "http://${cfg.settings.http.listen}";
              recommendedProxySettings = true;
            };

            locations."/spreed" = {
              proxyPass = "http://${cfg.settings.http.listen}/spreed";
              proxyWebsockets = true;
              recommendedProxySettings = true;
            };
          };
        };
      })
    ]
  );

  meta = {
    doc = ./nextcloud-spreed-signaling.md;

    maintainers = [
      lib.maintainers.naxdy
    ];
  };
}
