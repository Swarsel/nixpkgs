{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.authelia;

  format = pkgs.formats.yaml { };

  autheliaName = name: "authelia" + lib.optionalString (name != "") "-${name}";

  autheliaOpts =
    with lib;
    { config, name, ... }:
    {
      options = {
        enable = mkEnableOption "Authelia instance";
        package = mkPackageOption pkgs "authelia" { };

        environmentVariables = mkOption {
          default = { };

          description = ''
            Additional environment variables to provide to authelia.
            If you are providing secrets please consider the options under {option}`services.authelia.<instance>.secrets`
            or make sure you use the `_FILE` suffix.
            If you provide the raw secret rather than the location of a secret file that secret will be preserved in the nix store.
            For more details: <https://www.authelia.com/configuration/methods/secrets/>
          '';

          type = types.attrsOf types.str;
        };

        group = mkOption {
          defaultText = lib.literalExpression ''
            if name == "" then "authelia" else "authelia-''${name}"
          '';

          description = "The name of the group for this authelia instance.";
          type = types.str;
        };

        name = mkOption {
          default = name;

          description = ''
            Name is used as a suffix for the service name, user, and group.
            By default it takes the value you use for `<instance>` in:
            {option}`services.authelia.instances.<instance>`

            When set to the empty string `""`, the service name, user, and group
            will be just `authelia` without a suffix.
          '';

          type = types.str;
        };

        secrets = mkOption {
          default = { };

          description = ''
            It is recommended you keep your secrets separate from the configuration.
            It's especially important to keep the raw secrets out of your nix configuration,
            as the values will be preserved in your nix store.
            This attribute allows you to configure the location of secret files to be loaded at runtime.

            <https://www.authelia.com/configuration/methods/secrets/>
          '';

          type = types.submodule {
            options = {
              # required
              jwtSecretFile = mkOption {
                default = null;

                description = ''
                  Path to your JWT secret used during identity verificaton.
                '';

                type = types.nullOr types.path;
              };

              manual = mkOption {
                default = false;

                description = ''
                  Configuring authelia's secret files via the secrets attribute set
                  is intended to be convenient and help catch cases where values are required
                  to run at all.
                  If a user wants to set these values themselves and bypass the validation they can set this value to true.
                '';

                example = true;
                type = types.bool;
              };

              oidcHmacSecretFile = mkOption {
                default = null;

                description = ''
                  Path to your HMAC secret used to sign OIDC JWTs.
                '';

                type = types.nullOr types.path;
              };

              oidcIssuerPrivateKeyFile = mkOption {
                default = null;

                description = ''
                  Path to your private key file used to encrypt OIDC JWTs.
                '';

                type = types.nullOr types.path;
              };

              sessionSecretFile = mkOption {
                default = null;

                description = ''
                  Path to your session secret. Only used when redis is used as session storage.
                '';

                type = types.nullOr types.path;
              };

              # required
              storageEncryptionKeyFile = mkOption {
                default = null;

                description = ''
                  Path to your storage encryption key.
                '';

                type = types.nullOr types.path;
              };
            };
          };
        };

        settings = mkOption {
          default = { };

          description = ''
            Your Authelia config.yml as a Nix attribute set.
            There are several values that are defined and documented in nix such as `default_2fa_method`,
            but additional items can also be included.

            <https://github.com/authelia/authelia/blob/master/config.template.yml>
          '';

          example = ''
            {
              theme = "light";
              default_2fa_method = "totp";
              log.level = "debug";
              server.disable_healthcheck = true;
            }
          '';

          type = types.submodule {
            options = {
              default_2fa_method = mkOption {
                default = "";

                description = ''
                  Default 2FA method for new users and fallback for preferred but disabled methods.
                '';

                example = "webauthn";

                type = types.enum [
                  ""
                  "totp"
                  "webauthn"
                  "mobile_push"
                ];
              };

              log = {
                file_path = mkOption {
                  default = null;
                  description = "File path where the logs will be written. If not set logs are written to stdout.";
                  example = "/var/log/authelia/authelia.log";
                  type = types.nullOr types.path;
                };

                format = mkOption {
                  default = "json";
                  description = "Format the logs are written as.";
                  example = "text";

                  type = types.enum [
                    "json"
                    "text"
                  ];
                };

                keep_stdout = mkOption {
                  default = false;
                  description = "Whether to also log to stdout when a `file_path` is defined.";
                  example = true;
                  type = types.bool;
                };

                level = mkOption {
                  default = "debug";
                  description = "Level of verbosity for logs.";
                  example = "info";

                  type = types.enum [
                    "trace"
                    "debug"
                    "info"
                    "warn"
                    "error"
                  ];
                };
              };

              server = {
                address = mkOption {
                  default = "tcp://:9091/";
                  description = "The address to listen on.";
                  example = "unix:///var/run/authelia.sock?path=authelia&umask=0117";
                  type = types.str;
                };
              };

              telemetry = {
                metrics = {
                  address = mkOption {
                    default = "tcp://127.0.0.1:9959";
                    description = "The address to listen on for metrics. This should be on a different port to the main `server.port` value.";
                    example = "tcp://0.0.0.0:8888";
                    type = types.str;
                  };

                  enabled = mkOption {
                    default = false;
                    description = "Enable Metrics.";
                    example = true;
                    type = types.bool;
                  };
                };
              };

              theme = mkOption {
                default = "light";
                description = "The theme to display.";
                example = "dark";

                type = types.enum [
                  "light"
                  "dark"
                  "grey"
                  "auto"
                ];
              };
            };

            freeformType = format.type;
          };
        };

        settingsFiles = mkOption {
          default = [ ];

          description = ''
            Here you can provide authelia with configuration files or directories.
            It is possible to give authelia multiple files and use the nix generated configuration
            file set via {option}`services.authelia.<instance>.settings`.
          '';

          example = [
            "/etc/authelia/config.yml"
            "/etc/authelia/access-control.yml"
            "/etc/authelia/config/"
          ];

          type = types.listOf types.path;
        };

        user = mkOption {
          defaultText = lib.literalExpression ''
            if name == "" then "authelia" else "authelia-''${name}"
          '';

          description = "The name of the user for this authelia instance.";
          type = types.str;
        };
      };

      config = {
        group = mkDefault (autheliaName config.name);
        user = mkDefault (autheliaName config.name);
      };
    };

  writeOidcJwksConfigFile =
    oidcIssuerPrivateKeyFile:
    pkgs.writeText "oidc-jwks.yaml" ''
      identity_providers:
        oidc:
          jwks:
            - key: {{ secret "${oidcIssuerPrivateKeyFile}" | mindent 10 "|" | msquote }}
    '';

  # Remove an attribute in a nested set
  # https://discourse.nixos.org/t/modify-an-attrset-in-nix/29919/5
  removeAttrByPath =
    set: pathList:
    lib.updateManyAttrsByPath [
      {
        path = lib.init pathList;
        update = old: lib.removeAttrs old [ (lib.last pathList) ];
      }
    ] set;
in
{
  options.services.authelia.instances =
    with lib;
    mkOption {
      default = { };

      description = ''
        Multi-domain protection currently requires multiple instances of Authelia.
        If you don't require multiple instances of Authelia you can define just the one.

        <https://www.authelia.com/roadmap/active/multi-domain-protection/>
      '';

      example = ''
        {
          main = {
            enable = true;
            secrets.storageEncryptionKeyFile = "/etc/authelia/storageEncryptionKeyFile";
            secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
            settings = {
              theme = "light";
              default_2fa_method = "totp";
              log.level = "debug";
              server.disable_healthcheck = true;
            };
          };
          preprod = {
            enable = false;
            secrets.storageEncryptionKeyFile = "/mnt/pre-prod/authelia/storageEncryptionKeyFile";
            secrets.jwtSecretFile = "/mnt/pre-prod/jwtSecretFile";
            settings = {
              theme = "dark";
              default_2fa_method = "webauthn";
              server.host = "0.0.0.0";
            };
          };
          test.enable = true;
          test.secrets.manual = true;
          test.settings.theme = "grey";
          test.settings.server.disable_healthcheck = true;
          test.settingsFiles = [ "/mnt/test/authelia" "/mnt/test-authelia.conf" ];
          };
        }
      '';

      type = types.attrsOf (types.submodule autheliaOpts);
    };

  config =
    let
      mkInstanceServiceConfig =
        instance:
        let
          cleanedSettings =
            if
              (
                instance.settings.server ? host
                || instance.settings.server ? port
                || instance.settings.server ? path
              )
            then
              # Old settings are used: display a warning and remove the default value of server.address
              # as authelia does not allow both old and new settings to be set
              lib.warn
                "Please replace services.authelia.instances.${instance.name}.settings.{host,port,path} with services.authelia.instances.${instance.name}.settings.address, before release 5.0.0"
                (
                  removeAttrByPath instance.settings [
                    "server"
                    "address"
                  ]
                )
            else
              instance.settings;

          execCommand = "${instance.package}/bin/authelia";
          configFile = format.generate "config.yml" cleanedSettings;
          oidcJwksConfigFile = lib.optional (instance.secrets.oidcIssuerPrivateKeyFile != null) (
            writeOidcJwksConfigFile instance.secrets.oidcIssuerPrivateKeyFile
          );
          configArg = "--config ${
            builtins.concatStringsSep "," (
              lib.concatLists [
                [ configFile ]
                instance.settingsFiles
                oidcJwksConfigFile
              ]
            )
          }";
        in
        {
          after = [ "network-online.target" ]; # Checks SMTP notifier creds during startup
          description = "Authelia authentication and authorization server";

          environment =
            (lib.filterAttrs (_: v: v != null) {
              AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET_FILE = instance.secrets.oidcHmacSecretFile;
              AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE = instance.secrets.jwtSecretFile;
              AUTHELIA_SESSION_SECRET_FILE = instance.secrets.sessionSecretFile;
              AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = instance.secrets.storageEncryptionKeyFile;
              X_AUTHELIA_CONFIG_FILTERS = lib.mkIf (oidcJwksConfigFile != [ ]) "template";
            })
            // instance.environmentVariables;

          preStart = "${execCommand} ${configArg} validate-config";

          serviceConfig = {
            # Security options:
            AmbientCapabilities = "";
            CapabilityBoundingSet = "";
            DeviceAllow = "";
            ExecStart = "${execCommand} ${configArg}";
            Group = instance.group;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            PrivateUsers = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = "read-only";
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "noaccess";
            ProtectSystem = "strict";
            Restart = "always";
            RestartSec = "5s";

            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            StateDirectory = autheliaName instance.name;
            StateDirectoryMode = "0700";
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";

            SystemCallFilter = [
              "@system-service"
              "~@cpu-emulation"
              "~@debug"
              "~@keyring"
              "~@memlock"
              "~@obsolete"
              "~@privileged"
              "~@setuid"
            ];

            User = instance.user;
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };
      mkInstanceUsersConfig = instance: {
        groups.${autheliaName instance.name} = lib.mkIf (instance.group == autheliaName instance.name) { };

        users.${autheliaName instance.name} = lib.mkIf (instance.user == autheliaName instance.name) {
          group = instance.group;
          isSystemUser = true;
        };
      };
      instances = lib.attrValues cfg.instances;
    in
    {
      assertions = lib.flatten (
        lib.flip lib.mapAttrsToList cfg.instances (
          name: instance: [
            {
              assertion =
                instance.secrets.manual
                || (instance.secrets.jwtSecretFile != null && instance.secrets.storageEncryptionKeyFile != null);

              message = ''
                Authelia requires a JWT Secret and a Storage Encryption Key to work.
                Either set them like so:
                services.authelia.${name}.secrets.jwtSecretFile = /my/path/to/jwtsecret;
                services.authelia.${name}.secrets.storageEncryptionKeyFile = /my/path/to/encryptionkey;
                Or set services.authelia.${name}.secrets.manual = true and provide them yourself via
                environmentVariables or settingsFiles.
                Do not include raw secrets in nix settings.
              '';
            }
          ]
        )
      );

      systemd.services = lib.mkMerge (
        map (
          instance:
          lib.mkIf instance.enable {
            ${autheliaName instance.name} = mkInstanceServiceConfig instance;
          }
        ) instances
      );

      users = lib.mkMerge (
        map (instance: lib.mkIf instance.enable (mkInstanceUsersConfig instance)) instances
      );
    };

  meta.maintainers = with lib.maintainers; [
    jk
    nicomem
    connor-grady
  ];
}
