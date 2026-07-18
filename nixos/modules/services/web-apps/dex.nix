{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.dex;
  fixClient =
    client:
    if client ? secretFile then
      (
        (removeAttrs client [ "secretFile" ])
        // {
          secret = client.secretFile;
        }
      )
    else
      client;
  filteredSettings = mapAttrs (
    n: v: if n == "staticClients" then (map fixClient v) else v
  ) cfg.settings;
  secretFiles = flatten (
    map (c: optional (c ? secretFile) c.secretFile) (cfg.settings.staticClients or [ ])
  );

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" filteredSettings;

  startPreScript = pkgs.writeShellScript "dex-start-pre" (
    concatStringsSep "\n" (
      map (file: ''
        replace-secret '${file}' '${file}' /run/dex/config.yaml
      '') secretFiles
    )
  );

  restartTriggers =
    [ ]
    ++ (optionals (cfg.environmentFile != null) [ cfg.environmentFile ])
    ++ (filter (file: builtins.typeOf file == "path") secretFiles);
in
{
  options.services.dex = {
    enable = mkEnableOption "the OpenID Connect and OAuth2 identity provider";
    package = mkPackageOption pkgs "dex-oidc" { };

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file (see {manpage}`systemd.exec(5)`
        "EnvironmentFile=" section for the syntax) to define variables for dex.
        This option can be used to safely include secret keys into the dex configuration.
      '';

      type = types.nullOr types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        The available options can be found in
        [the example configuration](https://github.com/dexidp/dex/blob/v${cfg.package.version}/config.yaml.dist).

        It's also possible to refer to environment variables (defined in [services.dex.environmentFile](#opt-services.dex.environmentFile))
        using the syntax `$VARIABLE_NAME`.
      '';

      example = literalExpression ''
        {
          # External url
          issuer = "http://127.0.0.1:5556/dex";
          storage = {
            type = "postgres";
            config.host = "/var/run/postgres";
          };
          web = {
            http = "127.0.0.1:5556";
          };
          enablePasswordDB = true;
          staticClients = [
            {
              id = "oidcclient";
              name = "Client";
              redirectURIs = [ "https://example.com/callback" ];
              secretFile = "/etc/dex/oidcclient"; # The content of `secretFile` will be written into to the config as `secret`.
            }
          ];
        }
      '';

      type = settingsFormat.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dex = {
      after = [
        "network.target"
      ]
      ++ (optional (cfg.settings.storage.type == "postgres") "postgresql.target");

      description = "dex identity provider";
      path = with pkgs; [ replace-secret ];
      restartTriggers = restartTriggers;

      serviceConfig = {
        BindPaths = optional (cfg.settings.storage.type == "postgres") "/var/run/postgresql";

        BindReadOnlyPaths = [
          "/nix/store"
          "-/etc/dex"
          "-/etc/hosts"
          "-/etc/localtime"
          "-/etc/nsswitch.conf"
          "-/etc/resolv.conf"
          "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
        ];

        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/dex serve /run/dex/config.yaml";

        ExecStartPre = [
          "${pkgs.coreutils}/bin/install -m 600 ${configFile} /run/dex/config.yaml"
          "+${startPreScript}"
        ];

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        # Port needs to be exposed to the host network
        #PrivateNetwork = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "dex";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged @setuid @keyring"
        ];

        UMask = "0066";
      }
      // optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  # uses attributes of the linked package
  meta.buildDocsInSandbox = false;
}
