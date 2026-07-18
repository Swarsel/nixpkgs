{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matrix-appservice-irc;

  pkg = pkgs.matrix-appservice-irc;
  bin = "${pkg}/bin/matrix-appservice-irc";

  jsonType = (pkgs.formats.json { }).type;

  configFile =
    pkgs.runCommand "matrix-appservice-irc.yml"
      {
        config = builtins.toJSON cfg.settings;

        # Because this program will be run at build time, we need `nativeBuildInputs`
        nativeBuildInputs = [
          (pkgs.python3.withPackages (ps: [ ps.jsonschema ]))
          pkgs.remarshal
        ];

        passAsFile = [ "config" ];
        preferLocalBuild = true;
      }
      ''
        # The schema is given as yaml, we need to convert it to json
        remarshal --if yaml --of json -i ${pkg}/config.schema.yml -o config.schema.json
        python -m jsonschema config.schema.json -i $configPath
        cp "$configPath" "$out"
      '';
  registrationFile = "/var/lib/matrix-appservice-irc/registration.yml";
in
{
  options.services.matrix-appservice-irc = with lib.types; {
    enable = lib.mkEnableOption "the Matrix/IRC bridge";

    localpart = lib.mkOption {
      default = "appservice-irc";
      description = "The user_id localpart to assign to the appservice";
      type = str;
    };

    needBindingCap = lib.mkOption {
      default = false;
      description = "Whether the daemon needs to bind to ports below 1024 (e.g. for the ident service)";
      type = bool;
    };

    passwordEncryptionKeyLength = lib.mkOption {
      default = 4096;
      description = "Length of the key to encrypt IRC passwords with";
      example = 8192;
      type = ints.unsigned;
    };

    port = lib.mkOption {
      default = 8009;
      description = "The port to listen on";
      type = port;
    };

    registrationUrl = lib.mkOption {
      description = ''
        The URL where the application service is listening for homeserver requests,
        from the Matrix homeserver perspective.
      '';

      example = "http://localhost:8009";
      type = str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for the appservice, see
        <https://github.com/matrix-org/matrix-appservice-irc/blob/${pkgs.matrix-appservice-irc.version}/config.sample.yaml>
        for supported values
      '';

      type = submodule {
        options = {
          database = lib.mkOption {
            default = { };
            description = "Configuration for the database";

            type = submodule {
              options = {
                connectionString = lib.mkOption {
                  default = "nedb://var/lib/matrix-appservice-irc/data";
                  description = "The database connection string";
                  example = "postgres://username:password@host:port/databasename";
                  type = str;
                };

                engine = lib.mkOption {
                  default = "nedb";
                  description = "Which database engine to use";
                  example = "postgres";
                  type = str;
                };
              };

              freeformType = jsonType;
            };
          };

          homeserver = lib.mkOption {
            default = { };
            description = "Homeserver configuration";

            type = submodule {
              options = {
                domain = lib.mkOption {
                  description = ''
                    The 'domain' part for user IDs on this home server. Usually
                    (but not always) is the "domain name" part of the homeserver URL.
                  '';

                  type = str;
                };

                url = lib.mkOption {
                  description = "The URL to the home server for client-server API calls";
                  type = str;
                };
              };

              freeformType = jsonType;
            };
          };

          ircService = lib.mkOption {
            default = { };
            description = "IRC bridge configuration";

            type = submodule {
              options = {
                mediaProxy = {
                  bindPort = lib.mkOption {
                    default = 11111;

                    description = ''
                      Port that the media proxy binds to.
                    '';

                    type = port;
                  };

                  publicUrl = lib.mkOption {
                    description = ''
                      URL under which the media proxy is publicly acccessible.
                    '';

                    example = "https://matrix.example.com/media";
                    type = str;
                  };

                  signingKeyPath = lib.mkOption {
                    default = "/var/lib/matrix-appservice-irc/media-signingkey.jwk";

                    description = ''
                      Path to the signing key file for authenticated media.
                    '';

                    type = path;
                  };

                  ttlSeconds = lib.mkOption {
                    default = 3600;

                    description = ''
                      Lifetime in seconds, that generated URLs stay valid.

                      Set the lifetime to 0 to prevent URLs from becoming invalid.
                    '';

                    example = 0;
                    type = ints.unsigned;
                  };
                };

                passwordEncryptionKeyPath = lib.mkOption {
                  default = "/var/lib/matrix-appservice-irc/passkey.pem";

                  description = ''
                    Location of the key with which IRC passwords are encrypted
                    for storage. Will be generated on first run if not present.
                  '';

                  type = str;
                };

                servers = lib.mkOption {
                  description = "IRC servers to connect to";
                  type = submodule { freeformType = jsonType; };
                };
              };

              freeformType = jsonType;
            };
          };
        };

        freeformType = jsonType;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.matrix-appservice-irc = {
      after = lib.optionals (cfg.settings.database.engine == "postgres") [
        "postgresql.target"
      ];

      before = [ "matrix-synapse.service" ]; # So the registration can be used by Synapse
      description = "Matrix-IRC bridge";

      preStart = ''
        umask 077
        # Generate key for crypting passwords
        if ! [ -f "${cfg.settings.ircService.passwordEncryptionKeyPath}" ]; then
          ${pkgs.openssl}/bin/openssl genpkey \
              -out "${cfg.settings.ircService.passwordEncryptionKeyPath}" \
              -outform PEM \
              -algorithm RSA \
              -pkeyopt "rsa_keygen_bits:${toString cfg.passwordEncryptionKeyLength}"
        fi
        # Generate registration file
        if ! [ -f "${registrationFile}" ]; then
          # The easy case: the file has not been generated yet
          ${bin} --generate-registration --file ${registrationFile} --config ${configFile} --url ${cfg.registrationUrl} --localpart ${cfg.localpart}
        else
          # The tricky case: we already have a generation file. Because the NixOS configuration might have changed, we need to
          # regenerate it. But this would give the service a new random ID and tokens, so we need to back up and restore them.
          # 1. Backup
          id=$(grep "^id:.*$" ${registrationFile})
          hs_token=$(grep "^hs_token:.*$" ${registrationFile})
          as_token=$(grep "^as_token:.*$" ${registrationFile})
          # 2. Regenerate
          ${bin} --generate-registration --file ${registrationFile} --config ${configFile} --url ${cfg.registrationUrl} --localpart ${cfg.localpart}
          # 3. Restore
          sed -i "s/^id:.*$/$id/g" ${registrationFile}
          sed -i "s/^hs_token:.*$/$hs_token/g" ${registrationFile}
          sed -i "s/^as_token:.*$/$as_token/g" ${registrationFile}
        fi
        if ! [ -f "${cfg.settings.ircService.mediaProxy.signingKeyPath}" ]; then
          ${lib.getExe pkgs.nodejs-slim} ${pkg}/lib/generate-signing-key.js > "${cfg.settings.ircService.mediaProxy.signingKeyPath}"
        fi
        # Allow synapse access to the registration
        if ${pkgs.getent}/bin/getent group matrix-synapse > /dev/null; then
          chgrp matrix-synapse ${registrationFile}
          chmod g+r ${registrationFile}
        fi
      '';

      serviceConfig = rec {
        AmbientCapabilities = CapabilityBoundingSet;
        CapabilityBoundingSet = [ "CAP_CHOWN" ] ++ lib.optional (cfg.needBindingCap) "CAP_NET_BIND_SERVICE";
        ExecStart = "${bin} --config ${configFile} --file ${registrationFile} --port ${toString cfg.port}";
        Group = "matrix-appservice-irc";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        # AF_UNIX is required to connect to a postgres socket.
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictRealtime = true;
        StateDirectory = "matrix-appservice-irc";
        StateDirectoryMode = "755";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service @pkey"
          "~@privileged @resources"
          "@chown"
        ];

        Type = "simple";
        User = "matrix-appservice-irc";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.matrix-appservice-irc = { };

    users.users.matrix-appservice-irc = {
      description = "Service user for the Matrix-IRC bridge";
      group = "matrix-appservice-irc";
      isSystemUser = true;
    };
  };

  # uses attributes of the linked package
  meta.buildDocsInSandbox = false;
}
