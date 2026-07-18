{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.changedetection-io;
in
{
  options.services.changedetection-io = {
    enable = mkEnableOption "changedetection-io";
    package = lib.mkPackageOption pkgs "changedetection-io" { };

    baseURL = mkOption {
      default = null;

      description = ''
        The base url used in notifications and `{base_url}` token.
      '';

      example = "https://changedetection-io.example";
      type = types.nullOr types.str;
    };

    behindProxy = mkOption {
      default = false;

      description = ''
        Enable this option when changedetection-io runs behind a reverse proxy, so that it trusts X-* headers.
        It is recommend to run changedetection-io behind a TLS reverse proxy.
      '';

      type = types.bool;
    };

    chromePort = mkOption {
      default = 4444;

      description = ''
        A free port on which webDriverSupport or playwrightSupport listen on localhost.
      '';

      type = types.port;
    };

    datastorePath = mkOption {
      default = "/var/lib/changedetection-io";

      description = ''
        The directory used to store all data for changedetection-io.
      '';

      type = types.str;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Securely pass environment variables to changedetection-io.

        This can be used to set for example a frontend password reproducible via `SALTED_PASS`
        which convinetly also deactivates nags about the hosted version.
        `SALTED_PASS` should be 64 characters long while the first 32 are the salt and the second the frontend password.
        It can easily be retrieved from the settings file when first set via the frontend with the following command:
        ``jq -r .settings.application.password /var/lib/changedetection-io/url-watches.json``
      '';

      example = "/run/secrets/changedetection-io.env";
      type = types.nullOr types.path;
    };

    group = mkOption {
      default = "changedetection-io";

      description = ''
        Group account under which changedetection-io runs.
      '';

      type = types.str;
    };

    listenAddress = mkOption {
      default = "localhost";
      description = "Address the server will listen on.";
      type = types.str;
    };

    playwrightSupport = mkOption {
      default = false;

      description = ''
        Enable support for fetching web pages using playwright and Chromium.
        This starts a headless Chromium controlled by puppeteer in an oci container.

        ::: {.note}
        Playwright can currently leak memory.
        See <https://github.com/dgtlmoon/changedetection.io/wiki/Playwright-content-fetcher#playwright-memory-leak>
        :::
      '';

      type = types.bool;
    };

    port = mkOption {
      default = 5000;
      description = "Port the server will listen on.";
      type = types.port;
    };

    user = mkOption {
      default = "changedetection-io";

      description = ''
        User account under which changedetection-io runs.
      '';

      type = types.str;
    };

    webDriverSupport = mkOption {
      default = false;

      description = ''
        Enable support for fetching web pages using WebDriver and Chromium.
        This starts a headless chromium controlled by puppeteer in an oci container.

        ::: {.note}
        Playwright can currently leak memory.
        See <https://github.com/dgtlmoon/changedetection.io/wiki/Playwright-content-fetcher#playwright-memory-leak>
        :::
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !((cfg.webDriverSupport == true) && (cfg.playwrightSupport == true));
        message = "'services.changedetection-io.webDriverSupport' and 'services.changedetection-io.playwrightSupport' cannot be used together.";
      }
    ];

    systemd =
      let
        defaultStateDir = cfg.datastorePath == "/var/lib/changedetection-io";
      in
      {
        services.changedetection-io = {
          after = [ "network.target" ];

          serviceConfig = {
            Environment = [
              "HIDE_REFERER=true"
            ]
            ++ lib.optional (cfg.baseURL != null) "BASE_URL=${cfg.baseURL}"
            ++ lib.optional cfg.behindProxy "USE_X_SETTINGS=1"
            ++ lib.optional cfg.webDriverSupport "WEBDRIVER_URL=http://127.0.0.1:${toString cfg.chromePort}/wd/hub"
            ++ lib.optional cfg.playwrightSupport "PLAYWRIGHT_DRIVER_URL=ws://127.0.0.1:${toString cfg.chromePort}/?stealth=1&--disable-web-security=true";

            EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

            ExecStart = ''
              ${cfg.package}/bin/changedetection.py \
                -h ${cfg.listenAddress} -p ${toString cfg.port} -d ${cfg.datastorePath}
            '';

            Group = cfg.group;
            ProtectHome = true;
            ProtectSystem = true;
            Restart = "on-failure";
            StateDirectory = mkIf defaultStateDir "changedetection-io";
            StateDirectoryMode = mkIf defaultStateDir "0750";
            User = cfg.user;
            WorkingDirectory = cfg.datastorePath;
          };

          wantedBy = [ "multi-user.target" ];
        };

        tmpfiles.rules = mkIf (!defaultStateDir) [
          "d ${cfg.datastorePath} 0750 ${cfg.user} ${cfg.group} - -"
        ];
      };

    users = {
      groups = optionalAttrs (cfg.group == "changedetection-io") {
        "changedetection-io" = { };
      };

      users = optionalAttrs (cfg.user == "changedetection-io") {
        "changedetection-io" = {
          group = "changedetection-io";
          isSystemUser = true;
        };
      };
    };

    virtualisation = {
      oci-containers.containers = lib.mkMerge [
        (mkIf cfg.webDriverSupport {
          changedetection-io-webdriver = {
            environment = {
              SCREEN_DEPTH = "24";
              SCREEN_HEIGHT = "1080";
              SCREEN_WIDTH = "1920";
              VNC_NO_PASSWORD = "1";
            };

            extraOptions = [ "--network=bridge" ];
            image = "selenium/standalone-chrome";

            ports = [
              "127.0.0.1:${toString cfg.chromePort}:4444"
            ];

            volumes = [
              "/dev/shm:/dev/shm"
            ];
          };
        })

        (mkIf cfg.playwrightSupport {
          changedetection-io-playwright = {
            environment = {
              CHROME_REFRESH_TIME = "600000";
              CONNECTION_TIMEOUT = "300000";
              DEFAULT_BLOCK_ADS = "true";
              DEFAULT_STEALTH = "true";
              ENABLE_DEBUGGER = "false";
              MAX_CONCURRENT_SESSIONS = "10";
              PREBOOT_CHROME = "true";
              SCREEN_DEPTH = "16";
              SCREEN_HEIGHT = "1024";
              SCREEN_WIDTH = "1920";
            };

            extraOptions = [ "--network=bridge" ];
            image = "browserless/chrome";

            ports = [
              "127.0.0.1:${toString cfg.chromePort}:3000"
            ];
          };
        })
      ];

      podman.defaultNetwork.settings.dns_enabled = true;
    };
  };
}
