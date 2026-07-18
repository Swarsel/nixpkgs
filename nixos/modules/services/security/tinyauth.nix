{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    maintainers
    mapAttrs'
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    nameValuePair
    optionalAttrs
    types
    ;

  cfg = config.services.tinyauth;

  format = pkgs.formats.keyValue { };
  settingsFile = format.generate "tinyauth-env-vars" (
    mapAttrs' (name: value: nameValuePair "TINYAUTH_${name}" value) cfg.settings
  );
in
{
  options.services.tinyauth = {
    enable = mkEnableOption "Tinyauth server";
    package = mkPackageOption pkgs "tinyauth" { };

    dataDir = mkOption {
      default = "/var/lib/tinyauth";

      description = ''
        The directory where Tinyauth will store its data.
      '';

      type = types.path;
    };

    environmentFile = mkOption {
      default = "/dev/null";

      description = ''
        Path to an environment file loaded for Tinyauth.

        This can be used to securely store tokens and secrets outside of the world-readable Nix store.

        Example contents of the file:
        ```
        TINYAUTH_AUTH_USERS=user-hash
        TINYAUTH_OAUTH_PROVIDERS_GOOGLE_CLIENTSECRET=client-secret
        ```
      '';

      example = "/var/lib/secrets/tinyauth";
      type = types.path;
    };

    group = mkOption {
      default = "tinyauth";
      description = "Group account under which Tinyauth runs.";
      type = types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Environment variables that will be passed to Tinyauth.
        The "TINYAUTH_" prefix will be prepended to the setting names.
        See [configuration options](https://tinyauth.app/docs/reference/configuration)
        for supported values.
      '';

      type = types.submodule {
        options = {
          ANALYTICS_ENABLED = mkOption {
            default = false;

            description = ''
              Whether to enable anonymous version collection.
            '';

            type = types.bool;
          };

          APPURL = mkOption {
            description = ''
              URL of the app.
            '';

            example = "https://auth.example.com";
            type = types.str;
          };

          AUTH_LOGINMAXRETRIES = mkOption {
            default = 3;

            description = ''
              Maximum login attempts before timeout (0 to disable).
            '';

            type = types.ints.unsigned;
          };

          AUTH_LOGINTIMEOUT = mkOption {
            default = 300;

            description = ''
              Login timeout in seconds after max retries reached (0 to disable).
            '';

            type = types.ints.unsigned;
          };

          AUTH_TRUSTEDPROXIES = mkOption {
            default = "";

            description = ''
              Comma-separated list of trusted proxy addresses.
            '';

            type = types.str;
          };

          RESOURCES_ENABLED = mkOption {
            default = true;

            description = ''
              Whether to enable the resources server.
            '';

            type = types.bool;
          };

          SERVER_ADDRESS = mkOption {
            default = "0.0.0.0";

            description = ''
              Address to bind the server to.
            '';

            type = types.str;
          };

          SERVER_PORT = mkOption {
            default = 3000;

            description = ''
              The port to run the server on.
            '';

            type = types.port;
          };
        };

        freeformType = format.type;
      };
    };

    user = mkOption {
      default = "tinyauth";
      description = "User account under which Tinyauth runs.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.tinyauth = {
      after = [ "network.target" ];
      description = "Tinyauth";

      environment = {
        GIN_MODE = "release";
        TINYAUTH_DATABASE_PATH = "${cfg.dataDir}/tinyauth.db";
        TINYAUTH_RESOURCES_PATH = "${cfg.dataDir}/resources";
      };

      restartTriggers = [
        cfg.package
        cfg.environmentFile
        settingsFile
      ];

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";

        EnvironmentFile = [
          cfg.environmentFile
          settingsFile
        ];

        ExecStart = getExe cfg.package;
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = "disconnected";
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
        ReadWritePaths = [ cfg.dataDir ];
        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        Type = "simple";
        UMask = "0077";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings.tinyauth = {
      "${cfg.dataDir}".d = {
        group = cfg.group;
        mode = "0750";
        user = cfg.user;
      };
    };

    users.groups = optionalAttrs (cfg.group == "tinyauth") {
      tinyauth = { };
    };

    users.users = optionalAttrs (cfg.user == "tinyauth") {
      tinyauth = {
        description = "Tinyauth user";
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with maintainers; [ shaunren ];
}
