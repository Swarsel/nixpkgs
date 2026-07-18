{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    any
    concatMap
    getExe'
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    recursiveUpdate
    ;

  inherit (lib.types)
    bool
    enum
    listOf
    port
    str
    ;

  inherit (utils) escapeSystemdExecArgs genJqSecretsReplacementSnippet;

  stateDir = "/var/lib/netbird-mgmt";

  settingsFormat = pkgs.formats.json { };

  defaultSettings = {
    DataStoreEncryptionKey = "very-insecure-key";
    Datadir = "${stateDir}/data";

    DeviceAuthorizationFlow = {
      Provider = "none";

      ProviderConfig = {
        Audience = "netbird";
        ClientID = "netbird";
        DeviceAuthEndpoint = "";
        Domain = null;
        Scope = "openid profile email";
        TokenEndpoint = null;
        UseIDToken = false;
      };
    };

    HttpConfig = {
      Address = "127.0.0.1:${toString cfg.port}";
      IdpSignKeyRefreshEnabled = true;
      OIDCConfigEndpoint = cfg.oidcConfigEndpoint;
    };

    IdpManagerConfig = {
      Auth0ClientCredentials = null;
      AzureClientCredentials = null;

      ClientConfig = {
        ClientID = "netbird";
        ClientSecret = "";
        GrantType = "client_credentials";
        Issuer = "";
        TokenEndpoint = "";
      };

      ExtraConfig = { };
      KeycloakClientCredentials = null;
      ManagerType = "none";
      ZitadelClientCredentials = null;
    };

    PKCEAuthorizationFlow = {
      ProviderConfig = {
        Audience = "netbird";
        AuthorizationEndpoint = "";
        ClientID = "netbird";
        ClientSecret = "";
        RedirectURLs = [ "http://localhost:53000" ];
        Scope = "openid profile email";
        TokenEndpoint = "";
        UseIDToken = false;
      };
    };

    ReverseProxy = {
      TrustedHTTPProxies = [ ];
      TrustedHTTPProxiesCount = 0;
      TrustedPeers = [ "0.0.0.0/0" ];
    };

    Signal = {
      Password = null;
      Proto = "https";
      URI = "${cfg.domain}:443";
      Username = "";
    };

    StoreConfig = {
      Engine = "sqlite";
    };

    Stuns = [
      {
        Password = null;
        Proto = "udp";
        URI = "stun:${cfg.turnDomain}:3478";
        Username = "";
      }
    ];

    TURNConfig = {
      CredentialsTTL = "12h";
      Secret = "not-secure-secret";
      TimeBasedCredentials = false;

      Turns = [
        {
          Password = "netbird";
          Proto = "udp";
          URI = "turn:${cfg.turnDomain}:${toString cfg.turnPort}";
          Username = "netbird";
        }
      ];
    };
  };

  managementConfig = recursiveUpdate defaultSettings cfg.settings;

  managementFile = settingsFormat.generate "config.json" managementConfig;

  cfg = config.services.netbird.server.management;
in

{
  options.services.netbird.server.management = {
    enable = mkEnableOption "Netbird Management Service";
    package = mkPackageOption pkgs "netbird-management" { };

    disableAnonymousMetrics = mkOption {
      default = true;
      description = "Disables push of anonymous usage metrics to NetBird.";
      type = bool;
    };

    disableSingleAccountMode = mkOption {
      default = false;

      description = ''
        If set to true, disables single account mode.
        The `singleAccountModeDomain` property will be ignored and every new user will have a separate NetBird account.
      '';

      type = bool;
    };

    dnsDomain = mkOption {
      default = "netbird.selfhosted";
      description = "Domain used for peer resolution.";
      type = str;
    };

    domain = mkOption {
      description = "The domain under which the management API runs.";
      type = str;
    };

    enableNginx = mkEnableOption "Nginx reverse-proxy for the netbird management service";

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Additional options given to netbird-mgmt as commandline arguments.
      '';

      type = listOf str;
    };

    logLevel = mkOption {
      default = "INFO";
      description = "Log level of the netbird services.";

      type = enum [
        "ERROR"
        "WARN"
        "INFO"
        "DEBUG"
      ];
    };

    metricsPort = mkOption {
      default = 9090;
      description = "Internal port of the metrics server.";
      type = port;
    };

    oidcConfigEndpoint = mkOption {
      description = "The oidc discovery endpoint.";
      example = "https://example.eu.auth0.com/.well-known/openid-configuration";
      type = str;
    };

    port = mkOption {
      default = 8011;
      description = "Internal port of the management server.";
      type = port;
    };

    settings = mkOption {
      inherit (settingsFormat) type;
      default = { };

      defaultText = literalExpression ''
        defaultSettings = {
          Stuns = [
            {
              Proto = "udp";
              URI = "stun:''${cfg.turnDomain}:3478";
              Username = "";
              Password = null;
            }
          ];

          TURNConfig = {
            Turns = [
              {
                Proto = "udp";
                URI = "turn:''${cfg.turnDomain}:3478";
                Username = "netbird";
                Password = "netbird";
              }
            ];

            CredentialsTTL = "12h";
            Secret = "not-secure-secret";
            TimeBasedCredentials = false;
          };

          Signal = {
            Proto = "https";
            URI = "''${cfg.domain}:443";
            Username = "";
            Password = null;
          };

          ReverseProxy = {
            TrustedHTTPProxies = [ ];
            TrustedHTTPProxiesCount = 0;
            TrustedPeers = [ "0.0.0.0/0" ];
          };

          Datadir = "''${stateDir}/data";
          DataStoreEncryptionKey = "genEVP6j/Yp2EeVujm0zgqXrRos29dQkpvX0hHdEUlQ=";
          StoreConfig = { Engine = "sqlite"; };

          HttpConfig = {
            Address = "127.0.0.1:''${toString cfg.port}";
            IdpSignKeyRefreshEnabled = true;
            OIDCConfigEndpoint = cfg.oidcConfigEndpoint;
          };

          IdpManagerConfig = {
            ManagerType = "none";
            ClientConfig = {
              Issuer = "";
              TokenEndpoint = "";
              ClientID = "netbird";
              ClientSecret = "";
              GrantType = "client_credentials";
            };

            ExtraConfig = { };
            Auth0ClientCredentials = null;
            AzureClientCredentials = null;
            KeycloakClientCredentials = null;
            ZitadelClientCredentials = null;
          };

          DeviceAuthorizationFlow = {
            Provider = "none";
            ProviderConfig = {
              Audience = "netbird";
              Domain = null;
              ClientID = "netbird";
              TokenEndpoint = null;
              DeviceAuthEndpoint = "";
              Scope = "openid profile email offline_access api";
              UseIDToken = false;
            };
          };

          PKCEAuthorizationFlow = {
            ProviderConfig = {
              Audience = "netbird";
              ClientID = "netbird";
              ClientSecret = "";
              AuthorizationEndpoint = "";
              TokenEndpoint = "";
              Scope = "openid profile email offline_access api";
              RedirectURLs = "http://localhost:53000";
              UseIDToken = false;
            };
          };
        };
      '';

      description = ''
        Configuration of the netbird management server.
        Options containing secret data should be set to an attribute set containing the attribute _secret
        - a string pointing to a file containing the value the option should be set to.
        See the example to get a better picture of this: in the resulting management.json file,
        the `DataStoreEncryptionKey` key will be set to the contents of the /run/agenix/netbird_mgmt-data_store_encryption_key file.
      '';

      example = {
        DataStoreEncryptionKey = {
          _secret = "/run/agenix/netbird_mgmt-data_store_encryption_key";
        };
      };
    };

    singleAccountModeDomain = mkOption {
      default = "netbird.selfhosted";

      description = ''
        Enables single account mode.
        This means that all the users will be under the same account grouped by the specified domain.
        If the installation has more than one account, the property is ineffective.
      '';

      type = str;
    };

    turnDomain = mkOption {
      description = "The domain of the TURN server to use.";
      type = str;
    };

    turnPort = mkOption {
      default = 3478;

      description = ''
        The port of the TURN server to use.
      '';

      type = port;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.port != cfg.metricsPort;
        message = "The primary listen port cannot be the same as the listen port for the metrics endpoint";
      }
    ];

    services.nginx = mkIf cfg.enableNginx {
      enable = true;

      virtualHosts.${cfg.domain} = {
        locations = {
          "/api".proxyPass = "http://localhost:${toString cfg.port}";

          "/management.ManagementService/".extraConfig = ''
            # This is necessary so that grpc connections do not get closed early
            # see https://stackoverflow.com/a/67805465
            client_body_timeout 1d;

            grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            grpc_pass grpc://localhost:${toString cfg.port};
            grpc_read_timeout 1d;
            grpc_send_timeout 1d;
            grpc_socket_keepalive on;
          '';
        };
      };
    };

    systemd.services.netbird-management = {
      after = [ "network.target" ];
      description = "The management server for Netbird, a wireguard VPN";
      documentation = [ "https://netbird.io/docs/" ];
      preStart = genJqSecretsReplacementSnippet managementConfig "${stateDir}/management.json";
      restartTriggers = [ managementFile ];

      serviceConfig = {
        ExecStart = escapeSystemdExecArgs (
          [
            (getExe' cfg.package "netbird-mgmt")
            "management"
            # Config file
            "--config"
            "${stateDir}/management.json"
            # Data directory
            "--datadir"
            "${stateDir}/data"
            # DNS domain
            "--dns-domain"
            cfg.dnsDomain
            # Port to listen on
            "--port"
            cfg.port
            # Port the internal prometheus server listens on
            "--metrics-port"
            cfg.metricsPort
            # Log to stdout
            "--log-file"
            "console"
            # Log level
            "--log-level"
            cfg.logLevel
            #
            "--idp-sign-key-refresh-enabled"
            # Domain for internal resolution
            "--single-account-mode-domain"
            cfg.singleAccountModeDomain
          ]
          ++ (optional cfg.disableAnonymousMetrics "--disable-anonymous-metrics")
          ++ (optional cfg.disableSingleAccountMode "--disable-single-account-mode")
          ++ cfg.extraOptions
        );

        # hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = true;
        RemoveIPC = true;
        Restart = "always";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "netbird-mgmt";
        RuntimeDirectoryMode = "0750";

        StateDirectory = [
          "netbird-mgmt"
          "netbird-mgmt/data"
        ];

        StateDirectoryMode = "0750";
        WorkingDirectory = stateDir;
      };

      stopIfChanged = false;
      wantedBy = [ "multi-user.target" ];
    };

    warnings =
      concatMap
        (
          { check, name }:
          optional check "${name} is world-readable in the Nix Store, you should provide it as a _secret."
        )
        [
          {
            check = builtins.isString managementConfig.TURNConfig.Secret;
            name = "The TURNConfig.secret";
          }
          {
            check = builtins.isString managementConfig.DataStoreEncryptionKey;
            name = "The DataStoreEncryptionKey";
          }
          {
            check = any (T: (T ? Password) && builtins.isString T.Password) managementConfig.TURNConfig.Turns;
            name = "A Turn configuration's password";
          }
        ];
  };
}
