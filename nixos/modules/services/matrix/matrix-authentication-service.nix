{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatMapStringsSep
    filter
    filterAttrs
    getExe
    getExe'
    isAttrs
    isList
    mapAttrs
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    types
    ;

  cfg = config.services.matrix-authentication-service;
  format = pkgs.formats.yaml { };
  filterRecursiveNull =
    o:
    if isAttrs o then
      mapAttrs (_: v: filterRecursiveNull v) (filterAttrs (_: v: v != null) o)
    else if isList o then
      map filterRecursiveNull (filter (v: v != null) o)
    else
      o;

  # remove null values from the final configuration
  finalSettings =
    let
      pruned = filterRecursiveNull cfg.settings;
    in
    if pruned ? upstream_oauth2 && pruned.upstream_oauth2 == { } then
      removeAttrs pruned [ "upstream_oauth2" ]
    else
      pruned;
  configFile = format.generate "config.yaml" finalSettings;

  extraConfigFiles = lib.imap0 (
    i: _: "\${CREDENTIALS_DIRECTORY}/config-${toString i}"
  ) cfg.extraConfigFiles;
  runtimeConfig = "/run/matrix-authentication-service/config.yaml";
in
{
  options.services.matrix-authentication-service = {
    enable = mkEnableOption "Matrix Authentication Service";
    package = mkPackageOption pkgs "matrix-authentication-service" { };

    createDatabase = mkOption {
      default = false;

      description = ''
        Whether to enable and configure `services.postgresql` to ensure that the database user `matrix-authentication-service`
        and the database `matrix-authentication-service` exist.
      '';

      type = types.bool;
    };

    credentials = lib.mkOption {
      default = { };

      description = ''
        Mapping of credential name to  source file-path. Exposed to the unit via LoadCredential and
        readable inside the service at `''${CREDENTIALS_DIRECTORY}/<name>`.

        For example:

        ```
        services.matrix-authentication-service.credentials."synapse-secret" = "/run/agenix/synapse-shared";
        services.matrix-authentication-service.settings.matrix.secret_file =
          "\''${CREDENTIALS_DIRECTORY}/synapse-secret";
        ```
      '';

      type = lib.types.attrsOf lib.types.str;
    };

    extraConfigFiles = mkOption {
      default = [ ];

      description = ''
        Extra config files to include.

        The configuration files will be included based on the command line
        argument --config. This allows to configure secrets without
        having to go through the Nix store, e.g. based on deployment keys if
        NixOps is in use.
      '';

      type = types.listOf types.str;
    };

    serviceDependencies = mkOption {
      default = optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit;

      defaultText = lib.literalExpression ''
        lib.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit
      '';

      description = ''
        List of Systemd services to require and wait for when starting the application service,
        such as the Matrix homeserver if it's running on the same host.
      '';

      type = types.listOf types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        The primary mas configuration. See the
        [configuration reference](https://element-hq.github.io/matrix-authentication-service/usage/configuration.html)
        for possible values.

        Secrets should be passed in by using the `extraConfigFiles` option.
      '';

      type = types.submodule {
        options = {
          database.connect_timeout = mkOption {
            default = 30;

            description = ''
              Connection timeout for the connection pool.
            '';

            type = types.ints.unsigned;
          };

          database.idle_timeout = mkOption {
            default = 600;

            description = ''
              Idle timeout for the connection pool.
            '';

            type = types.ints.unsigned;
          };

          database.max_connections = mkOption {
            default = 10;

            description = ''
              Maximum number of connections for the connection pool.
            '';

            type = types.ints.unsigned;
          };

          database.max_lifetime = mkOption {
            default = 1800;

            description = ''
              Maximum lifetime for the connection pool.
            '';

            type = types.ints.unsigned;
          };

          database.min_connections = mkOption {
            default = 0;

            description = ''
              Minimum number of connections for the connection pool.
            '';

            type = types.ints.unsigned;
          };

          database.uri = mkOption {
            default = "postgresql:///matrix-authentication-service?host=/run/postgresql";

            description = ''
              The postgres connection string.
              Refer to <https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING>.
              If you need to put secrets in the uri, please use the `extraConfigFiles` option.
            '';

            type = types.str;
          };

          http.listeners = mkOption {
            default = [
              {
                binds = [
                  {
                    host = "0.0.0.0";
                    port = 8080;
                  }
                ];

                name = "web";
                proxy_protocol = false;

                resources = [
                  { name = "discovery"; }
                  { name = "human"; }
                  { name = "oauth"; }
                  { name = "compat"; }
                  { name = "graphql"; }
                  { name = "assets"; }
                ];
              }
              {
                binds = [
                  {
                    host = "0.0.0.0";
                    port = 8081;
                  }
                ];

                name = "internal";
                proxy_protocol = false;

                resources = [
                  { name = "health"; }
                ];
              }
            ];

            description = ''
              Each listener can serve multiple resources, and listen on multiple TCP ports or UNIX sockets.
            '';

            type = types.listOf (
              types.submodule {
                options = {
                  binds = mkOption {
                    description = ''
                      List of addresses and ports to listen to.
                    '';

                    type = types.listOf (
                      types.submodule {
                        options = {
                          host = mkOption {
                            description = ''
                              Listen on the given host.
                            '';

                            type = types.nullOr types.str;
                          };

                          port = mkOption {
                            description = ''
                              Listen on the given port.
                            '';

                            type = types.nullOr types.port;
                          };
                        };

                        freeformType = format.type;
                      }
                    );
                  };

                  name = mkOption {
                    description = ''
                      The name of the listener, used in logs and metrics.
                    '';

                    example = "web";
                    type = types.str;
                  };

                  proxy_protocol = mkOption {
                    default = false;

                    description = ''
                      Whether to enable the PROXY protocol on the listener.
                    '';

                    type = types.bool;
                  };

                  resources = mkOption {
                    description = ''
                      List of resources to serve.
                    '';

                    type = types.listOf (
                      types.submodule {
                        options = {
                          name = mkOption {
                            description = ''
                              Serve the given resource.
                            '';

                            type = types.str;
                          };
                        };

                        freeformType = format.type;
                      }
                    );
                  };
                };

                freeformType = format.type;
              }
            );
          };

          http.public_base = mkOption {
            default = "http://[::]:8080/";

            description = ''
              Public URL base used when building absolute public URLs.
            '';

            type = types.str;
          };

          http.trusted_proxies = mkOption {
            default = [
              "127.0.0.1/8"
              "::1/128"
            ];

            description = ''
              MAS can infer the client IP address from the X-Forwarded-For header. It will trust the value for this header only if the request comes from a trusted reverse proxy listed here.
            '';

            type = types.listOf types.str;
          };

          matrix.endpoint = mkOption {
            default = "";

            description = ''
              The URL to which the homeserver is accessible from the service.
            '';

            type = types.str;
          };

          matrix.homeserver = mkOption {
            default = "";

            description = ''
              Corresponds to the server_name in the Synapse configuration file.
            '';

            type = types.str;
          };

          passwords.enabled = mkOption {
            default = true;

            description = ''
              Whether to enable the password database. If disabled, users will only be able to log in using upstream OIDC providers.
            '';

            type = types.bool;
          };

          passwords.minimum_complexity = mkOption {
            default = 3;

            description = ''
              Minimum complexity required for passwords, estimated by the zxcvbn algorithm.
              Must be between 0 and 4, default is 3. See <https://github.com/dropbox/zxcvbn#usage> for more information.
            '';

            type = types.enum [
              0
              1
              2
              3
              4
            ];
          };

          passwords.schemes = mkOption {
            default = [
              {
                algorithm = "argon2id";
                version = 1;
              }
            ];

            description = ''
              List of password hashing schemes being used. Only change this if you know what you're doing.
            '';

            type = types.listOf (
              types.submodule {
                options = {
                  algorithm = mkOption {
                    description = ''
                      Password scheme algorithm.
                    '';

                    type = types.str;
                  };

                  version = mkOption {
                    description = ''
                      Password scheme version.
                    '';

                    type = types.ints.unsigned;
                  };
                };

                freeformType = format.type;
              }
            );
          };

          upstream_oauth2.providers = mkOption {
            default = null;

            description = ''
              Configuration of upstream providers
            '';

            type = types.nullOr (
              types.listOf (
                types.submodule {
                  options = {
                    id = mkOption {
                      default = null;

                      description = ''
                        Unique id for the provider, must be a ULID, and can be generated using online tools like <https://www.ulidtools.com>.
                      '';

                      example = "01H8PKNWKKRPCBW4YGH1RWV279";
                      type = types.nullOr types.str;
                    };
                  };

                  freeformType = format.type;
                }
              )
            );
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = mkIf cfg.createDatabase {
      enable = true;
      ensureDatabases = [ "matrix-authentication-service" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "matrix-authentication-service";
        }
      ];
    };

    systemd.services.matrix-authentication-service = rec {
      after = optional cfg.createDatabase "postgresql.service" ++ cfg.serviceDependencies;

      serviceConfig = {
        AmbientCapabilities = "";
        # Security Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;

        ExecStart = ''
          ${getExe cfg.package} server --config ${runtimeConfig} \
            ${concatMapStringsSep " " (x: "--config ${x}") extraConfigFiles}
        '';

        ExecStartPre = pkgs.writeShellScript "mas-prepare" ''
          ${getExe' pkgs.gettext "envsubst"} \
            '$CREDENTIALS_DIRECTORY' \
            < ${configFile} \
            > /run/matrix-authentication-service/config.yaml
          ${getExe cfg.package} config check --config ${runtimeConfig} \
            ${concatMapStringsSep " " (x: "--config ${x}") extraConfigFiles}
        '';

        LoadCredential =
          (lib.imap0 (i: path: "config-${toString i}:${path}") cfg.extraConfigFiles)
          ++ (lib.mapAttrsToList (name: path: "${name}:${path}") cfg.credentials);

        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
        Restart = "on-failure";
        RestartSec = "1s";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "matrix-authentication-service";
        # Working and state directories
        StateDirectory = "matrix-authentication-service";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
        ];

        UMask = "0077";
        WorkingDirectory = "/var/lib/matrix-authentication-service";
      };

      wantedBy = [ "multi-user.target" ];
      wants = after;
    };
  };

  meta.maintainers = with lib.maintainers; [
    eymeric
    flashonfire
    mkoppmann
    skowalak
  ];

  meta.teams = [ lib.teams.matrix ];
}
