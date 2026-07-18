{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.wealthfolio;
in
{
  options.services.wealthfolio = {
    enable = lib.mkEnableOption "Wealthfolio personal investment tracker";
    package = lib.mkPackageOption pkgs "wealthfolio-server" { };

    address = lib.mkOption {
      default = "127.0.0.1";
      description = "The IP address the Wealthfolio server binds to.";
      type = lib.types.str;
    };

    authPasswordHashFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing the Argon2id PHC string defining the login password.
        Required for web access unless `authRequired` is false.

        Generate with: `printf 'your-password' | argon2 yoursalt16chars! -id -e`
      '';

      example = lib.literalExpression "config.age.secrets.wealthfolio-hash.path";
      type = lib.types.nullOr lib.types.path;
    };

    authRequired = lib.mkOption {
      default = true;

      description = ''
        Whether to require internal authentication.

        Security Note: The server panics at startup if the listener is bound to a
        non-loopback address and authentication is disabled. Set this to `false`
        only if a reverse proxy handles authentication for you.
      '';

      type = lib.types.bool;
    };

    authTokenTtlMinutes = lib.mkOption {
      default = 60;
      description = "JWT access token lifetime in minutes. (e.g., 1440 for 24h, 10080 for 7d).";
      type = lib.types.ints.positive;
    };

    cookieSecure = lib.mkOption {
      default = "auto";

      description = ''
        Controls the Secure attribute on the authentication session cookie.
        - auto: Sets Secure based on HTTPS protocol.
        - true: Always sets Secure (Use behind a reverse proxy that terminates HTTPS).
        - false: Never sets Secure (Not recommended).
      '';

      type = lib.types.enum [
        "auto"
        "true"
        "false"
      ];
    };

    corsAllowOrigins = lib.mkOption {
      default = "*";

      description = ''
        Comma-separated list of allowed CORS origins.

        Security Note: The server panics at startup if `*` is used while authentication
        is enabled, as this is a CSRF vector. Set explicit origins matching your
        deployment URL (scheme + host + port).
      '';

      example = "https://wealthfolio.example.com";
      type = lib.types.str;
    };

    logFormat = lib.mkOption {
      default = "text";
      description = "Log output format. `json` is recommended if shipping to log aggregators.";

      type = lib.types.enum [
        "text"
        "json"
      ];
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to automatically open the specified port in the system firewall.";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 8088;
      description = "The port the Wealthfolio server listens on.";
      type = lib.types.port;
    };

    requestTimeoutMs = lib.mkOption {
      default = 300000;
      description = "HTTP request timeout in milliseconds. Default (5m) accommodates large broker syncs.";
      type = lib.types.ints.positive;
    };

    secretKeyFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing the 32-byte secret key used for encrypting sensitive data
        at rest (broker credentials, API keys) and signing JWT tokens.

        Generate with: `openssl rand -base64 32`.

        Note: Losing this key means losing access to all stored encrypted secrets.
        There is no recovery.
      '';

      example = lib.literalExpression "config.age.secrets.wealthfolio-key.path";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.secretKeyFile != null;
        message = "services.wealthfolio: secretKeyFile must be provided.";
      }
      {
        assertion = cfg.authRequired -> cfg.authPasswordHashFile != null;
        message = "services.wealthfolio: authPasswordHashFile must be provided when authRequired is true.";
      }
      {
        assertion = cfg.authRequired -> cfg.corsAllowOrigins != "*";
        message = "services.wealthfolio: corsAllowOrigins cannot be '*' when authRequired is true. Provide an explicit domain.";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    systemd.services.wealthfolio = {
      after = [ "network.target" ];
      description = "Wealthfolio server service daemon.";

      environment = {
        WF_AUTH_REQUIRED = lib.boolToString cfg.authRequired;
        WF_AUTH_TOKEN_TTL_MINUTES = toString cfg.authTokenTtlMinutes;
        WF_COOKIE_SECURE = cfg.cookieSecure;
        WF_CORS_ALLOW_ORIGINS = cfg.corsAllowOrigins;
        WF_DB_PATH = "/var/lib/wealthfolio/wealthfolio.db";
        WF_LISTEN_ADDR = "${cfg.address}:${toString cfg.port}";
        WF_LOG_FORMAT = cfg.logFormat;
        WF_REQUEST_TIMEOUT_MS = toString cfg.requestTimeoutMs;
      };

      script = ''
        ${lib.optionalString (
          cfg.secretKeyFile != null
        ) "export WF_SECRET_KEY=$(<\"$CREDENTIALS_DIRECTORY/secret_key\")"}
        ${lib.optionalString (
          cfg.authPasswordHashFile != null
        ) "export WF_AUTH_PASSWORD_HASH=$(<\"$CREDENTIALS_DIRECTORY/auth_hash\")"}

        exec ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        DynamicUser = true;

        LoadCredential =
          lib.optional (cfg.secretKeyFile != null) "secret_key:${cfg.secretKeyFile}"
          ++ lib.optional (cfg.authPasswordHashFile != null) "auth_hash:${cfg.authPasswordHashFile}";

        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        StateDirectory = "wealthfolio";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ luuumine ];
  };
}
