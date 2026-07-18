{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.vault;
  opt = options.services.vault;

  configFile = pkgs.writeText "vault.hcl" ''
    # vault in dev mode will refuse to start if its configuration sets listener
    ${lib.optionalString (!cfg.dev) ''
      listener "tcp" {
        address = "${cfg.address}"
        ${
          if (cfg.tlsCertFile == null || cfg.tlsKeyFile == null) then
            ''
              tls_disable = "true"
            ''
          else
            ''
              tls_cert_file = "${cfg.tlsCertFile}"
              tls_key_file = "${cfg.tlsKeyFile}"
            ''
        }
        ${cfg.listenerExtraConfig}
      }
    ''}
    storage "${cfg.storageBackend}" {
      ${lib.optionalString (cfg.storagePath != null) ''path = "${cfg.storagePath}"''}
      ${lib.optionalString (cfg.storageConfig != null) cfg.storageConfig}
    }
    ${lib.optionalString (cfg.telemetryConfig != "") ''
      telemetry {
        ${cfg.telemetryConfig}
      }
    ''}
    ${cfg.extraConfig}
  '';

  allConfigPaths = [ configFile ] ++ cfg.extraSettingsPaths;
  configOptions = lib.escapeShellArgs (
    lib.optional cfg.dev "-dev"
    ++ lib.optional (cfg.dev && cfg.devRootTokenID != null) "-dev-root-token-id=${cfg.devRootTokenID}"
    ++ (lib.concatMap (p: [
      "-config"
      p
    ]) allConfigPaths)
  );

in

{
  options = {
    services.vault = {
      enable = lib.mkEnableOption "Vault daemon";
      package = lib.mkPackageOption pkgs "vault" { };

      address = lib.mkOption {
        default = "127.0.0.1:8200";
        description = "The name of the ip interface to listen to";
        type = lib.types.str;
      };

      dev = lib.mkOption {
        default = false;

        description = ''
          In this mode, Vault runs in-memory and starts unsealed. This option is not meant production but for development and testing i.e. for nixos tests.
        '';

        type = lib.types.bool;
      };

      devRootTokenID = lib.mkOption {
        default = null;

        description = ''
          Initial root token. This only applies when {option}`services.vault.dev` is true
        '';

        type = lib.types.nullOr lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Extra text appended to {file}`vault.hcl`.";
        type = lib.types.lines;
      };

      extraSettingsPaths = lib.mkOption {
        default = [ ];

        description = ''
          Configuration files to load besides the immutable one defined by the NixOS module.
          This can be used to avoid putting credentials in the Nix store, which can be read by any user.

          Each path can point to a JSON- or HCL-formatted file, or a directory
          to be scanned for files with `.hcl` or
          `.json` extensions.

          To upload the confidential file with NixOps, use for example:

          ```
          # https://releases.nixos.org/nixops/latest/manual/manual.html#opt-deployment.keys
          deployment.keys."vault.hcl" = let db = import ./db-credentials.nix; in {
            text = ${"''"}
              storage "postgresql" {
                connection_url = "postgres://''${db.username}:''${db.password}@host.example.com/exampledb?sslmode=verify-ca"
              }
            ${"''"};
            user = "vault";
          };
          services.vault.extraSettingsPaths = ["/run/keys/vault.hcl"];
          services.vault.storageBackend = "postgresql";
          users.users.vault.extraGroups = ["keys"];
          ```
        '';

        type = lib.types.listOf lib.types.path;
      };

      listenerExtraConfig = lib.mkOption {
        default = ''
          tls_min_version = "tls12"
        '';

        description = "Extra text appended to the listener section.";
        type = lib.types.lines;
      };

      storageBackend = lib.mkOption {
        default = "inmem";
        description = "The name of the type of storage backend";

        type = lib.types.enum [
          "inmem"
          "file"
          "consul"
          "zookeeper"
          "s3"
          "azure"
          "dynamodb"
          "etcd"
          "mssql"
          "mysql"
          "postgresql"
          "swift"
          "gcs"
          "raft"
        ];
      };

      storageConfig = lib.mkOption {
        default = null;

        description = ''
          HCL configuration to insert in the storageBackend section.

          Confidential values should not be specified here because this option's
          value is written to the Nix store, which is publicly readable.
          Provide credentials and such in a separate file using
          [](#opt-services.vault.extraSettingsPaths).
        '';

        type = lib.types.nullOr lib.types.lines;
      };

      storagePath = lib.mkOption {
        default =
          if cfg.storageBackend == "file" || cfg.storageBackend == "raft" then "/var/lib/vault" else null;

        defaultText = lib.literalExpression ''
          if config.${opt.storageBackend} == "file" || cfg.storageBackend == "raft"
          then "/var/lib/vault"
          else null
        '';

        description = "Data directory for file backend";
        type = lib.types.nullOr lib.types.path;
      };

      telemetryConfig = lib.mkOption {
        default = "";
        description = "Telemetry configuration";
        type = lib.types.lines;
      };

      tlsCertFile = lib.mkOption {
        default = null;
        description = "TLS certificate file. TLS will be disabled unless this option is set";
        example = "/path/to/your/cert.pem";
        type = lib.types.nullOr lib.types.str;
      };

      tlsKeyFile = lib.mkOption {
        default = null;
        description = "TLS private key file. TLS will be disabled unless this option is set";
        example = "/path/to/your/key.pem";
        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.storageBackend == "inmem" -> (cfg.storagePath == null && cfg.storageConfig == null);
        message = ''The "inmem" storage expects no services.vault.storagePath nor services.vault.storageConfig'';
      }
      {
        assertion = (
          (cfg.storageBackend == "file" -> (cfg.storagePath != null && cfg.storageConfig == null))
          && (cfg.storagePath != null -> (cfg.storageBackend == "file" || cfg.storageBackend == "raft"))
        );

        message = ''You must set services.vault.storagePath only when using the "file" or "raft" backend'';
      }
    ];

    systemd.services.vault = {
      after = [
        "network.target"
      ]
      ++ lib.optional (config.services.consul.enable && cfg.storageBackend == "consul") "consul.service";

      description = "Vault server daemon";
      restartIfChanged = false; # do not restart on "nixos-rebuild switch". It would seal the storage and disrupt the clients.

      serviceConfig = {
        AmbientCapabilities = "cap_ipc_lock";
        # In `dev` mode vault will put its token here
        Environment = lib.optional (cfg.dev) "HOME=/var/lib/vault";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
        ExecStart = "${cfg.package}/bin/vault server ${configOptions}";
        Group = "vault";
        KillSignal = "SIGINT";
        LimitCORE = 0;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = "read-only";
        ProtectSystem = "full";
        Restart = "on-failure";
        StateDirectory = "vault";
        TimeoutStopSec = "30s";
        User = "vault";
      };

      startLimitBurst = 3;
      startLimitIntervalSec = 60;
      unitConfig.RequiresMountsFor = lib.optional (cfg.storagePath != null) cfg.storagePath;
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = lib.optional (
      cfg.storagePath != null
    ) "d '${cfg.storagePath}' 0700 vault vault - -";

    users.groups.vault.gid = config.ids.gids.vault;

    users.users.vault = {
      description = "Vault daemon user";
      group = "vault";
      name = "vault";
      uid = config.ids.uids.vault;
    };
  };

}
