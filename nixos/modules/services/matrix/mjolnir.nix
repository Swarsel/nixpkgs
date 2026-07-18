{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mjolnir;

  yamlConfig = {
    inherit (cfg) dataPath managementRoom protectedRooms;
    accessToken = "@ACCESS_TOKEN@"; # will be replaced in "generateConfig"

    homeserverUrl =
      if cfg.pantalaimon.enable then
        "http://${cfg.pantalaimon.options.listenAddress}:${toString cfg.pantalaimon.options.listenPort}"
      else
        cfg.homeserverUrl;

    pantalaimon = {
      inherit (cfg.pantalaimon) username;
      password = "@PANTALAIMON_PASSWORD@"; # will be replaced in "generateConfig"
      use = cfg.pantalaimon.enable;
    };

    rawHomeserverUrl = cfg.homeserverUrl;
  };

  moduleConfigFile = pkgs.writeText "module-config.yaml" (
    lib.generators.toYAML { } (
      lib.filterAttrs (_: v: v != null) (
        lib.foldr lib.recursiveUpdate { } [
          yamlConfig
          cfg.settings
        ]
      )
    )
  );

  # these config files will be merged one after the other to build the final config
  configFiles = [
    "${pkgs.mjolnir}/lib/node_modules/mjolnir/config/default.yaml"
    moduleConfigFile
  ];

  # this will generate the default.yaml file with all configFiles as inputs and
  # replace all secret strings using replace-secret
  generateConfig = pkgs.writeShellScript "mjolnir-generate-config" (
    let
      yqEvalStr = lib.concatImapStringsSep " * " (
        pos: _: "select(fileIndex == ${toString (pos - 1)})"
      ) configFiles;
      yqEvalArgs = lib.concatStringsSep " " configFiles;
    in
    ''
      set -euo pipefail

      umask 077

      # mjolnir will try to load a config from "./config/default.yaml" in the working directory
      # -> let's place the generated config there
      mkdir -p ${cfg.dataPath}/config

      # merge all config files into one, overriding settings of the previous one with the next config
      # e.g. "eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' filea.yaml fileb.yaml" will merge filea.yaml with fileb.yaml
      ${pkgs.yq-go}/bin/yq eval-all -P '${yqEvalStr}' ${yqEvalArgs} > ${cfg.dataPath}/config/default.yaml

      ${lib.optionalString (cfg.accessTokenFile != null) ''
        ${pkgs.replace-secret}/bin/replace-secret '@ACCESS_TOKEN@' '${cfg.accessTokenFile}' ${cfg.dataPath}/config/default.yaml
      ''}
      ${lib.optionalString (cfg.pantalaimon.passwordFile != null) ''
        ${pkgs.replace-secret}/bin/replace-secret '@PANTALAIMON_PASSWORD@' '${cfg.pantalaimon.passwordFile}' ${cfg.dataPath}/config/default.yaml
      ''}
    ''
  );
in
{
  options.services.mjolnir = {
    enable = lib.mkEnableOption "Mjolnir, a moderation tool for Matrix";

    accessTokenFile = lib.mkOption {
      default = null;

      description = ''
        File containing the matrix access token for the `mjolnir` user.
      '';

      type = with lib.types; nullOr path;
    };

    dataPath = lib.mkOption {
      default = "/var/lib/mjolnir";

      description = ''
        The directory the bot should store various bits of information in.
      '';

      type = lib.types.path;
    };

    homeserverUrl = lib.mkOption {
      default = "https://matrix.org";

      description = ''
        Where the homeserver is located (client-server URL).

        If `pantalaimon.enable` is `true`, this option will become the homeserver to which `pantalaimon` connects.
        The listen address of `pantalaimon` will then become the `homeserverUrl` of `mjolnir`.
      '';

      type = lib.types.str;
    };

    managementRoom = lib.mkOption {
      default = "#moderators:example.org";

      description = ''
        The room ID where people can use the bot. The bot has no access controls, so
        anyone in this room can use the bot - secure your room!
        This should be a room alias or room ID - not a matrix.to URL.
        Note: `mjolnir` is fairly verbose - expect a lot of messages from it.
      '';

      type = lib.types.str;
    };

    pantalaimon = lib.mkOption {
      default = { };

      description = ''
        `pantalaimon` options (enables E2E Encryption support).

        This will create a `pantalaimon` instance with the name "mjolnir".
      '';

      type = lib.types.submodule {
        options = {
          options = lib.mkOption {
            default = { };

            description = ''
              passthrough additional options to the `pantalaimon` service.
            '';

            type = lib.types.submodule (import ./pantalaimon-options.nix);
          };

          enable = lib.mkEnableOption ''
            ignoring the accessToken. If true, accessToken is ignored and the username/password below will be
            used instead. The access token of the bot will be stored in the dataPath
          '';

          passwordFile = lib.mkOption {
            default = null;

            description = ''
              File containing the matrix password for the `mjolnir` user.
            '';

            type = with lib.types; nullOr path;
          };

          username = lib.mkOption {
            description = "The username to login with.";
            type = lib.types.str;
          };
        };
      };
    };

    protectedRooms = lib.mkOption {
      default = [ ];

      description = ''
        A list of rooms to protect (matrix.to URLs).
      '';

      example = lib.literalExpression ''
        [
          "https://matrix.to/#/#yourroom:example.org"
          "https://matrix.to/#/#anotherroom:example.org"
        ]
      '';

      type = lib.types.listOf lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Additional settings (see [mjolnir default config](https://github.com/matrix-org/mjolnir/blob/main/config/default.yaml) for available settings). These settings will override settings made by the module config.
      '';

      example = lib.literalExpression ''
        {
          autojoinOnlyIfManager = true;
          automaticallyRedactForReasons = [ "spam" "advertising" ];
        }
      '';

      type = (pkgs.formats.yaml { }).type;
    };
  };

  config = lib.mkIf config.services.mjolnir.enable {
    assertions = [
      {
        assertion = !(cfg.pantalaimon.enable && cfg.pantalaimon.passwordFile == null);
        message = "Specify pantalaimon.passwordFile";
      }
      {
        assertion = !(cfg.pantalaimon.enable && cfg.accessTokenFile != null);
        message = "Do not specify accessTokenFile when using pantalaimon";
      }
      {
        assertion = !(!cfg.pantalaimon.enable && cfg.accessTokenFile == null);
        message = "Specify accessTokenFile when not using pantalaimon";
      }
    ];

    # This defaults to true in the application,
    # which breaks older configs using pantalaimon or access tokens
    services.mjolnir.settings.encryption.use = lib.mkDefault false;

    services.pantalaimon-headless.instances."mjolnir" =
      lib.mkIf cfg.pantalaimon.enable {
        homeserver = cfg.homeserverUrl;
      }
      // cfg.pantalaimon.options;

    systemd.services.mjolnir = {
      after = [
        "network-online.target"
      ]
      ++ lib.optionals (cfg.pantalaimon.enable) [ "pantalaimon-mjolnir.service" ];

      description = "mjolnir - a moderation tool for Matrix";

      serviceConfig = {
        ExecStart = "${pkgs.mjolnir}/bin/mjolnir --mjolnir-config ./config/default.yaml";
        ExecStartPre = [ generateConfig ];
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        StateDirectory = "mjolnir";
        StateDirectoryMode = "0700";
        User = "mjolnir";
        WorkingDirectory = cfg.dataPath;
        /*
          TODO: wait for #102397 to be resolved. Then load secrets from $CREDENTIALS_DIRECTORY+"/NAME"
          DynamicUser = true;
          LoadCredential = [] ++
            lib.optionals (cfg.accessTokenFile != null) [
              "access_token:${cfg.accessTokenFile}"
            ] ++
            lib.optionals (cfg.pantalaimon.passwordFile != null) [
              "pantalaimon_password:${cfg.pantalaimon.passwordFile}"
            ];
        */
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
      ]
      ++ lib.optionals (cfg.pantalaimon.enable) [ "pantalaimon-mjolnir.service" ];
    };

    users = {
      groups.mjolnir = { };

      users.mjolnir = {
        group = "mjolnir";
        isSystemUser = true;
      };
    };
  };

  meta = {
    doc = ./mjolnir.md;
    maintainers = with lib.maintainers; [ jojosch ];
  };
}
