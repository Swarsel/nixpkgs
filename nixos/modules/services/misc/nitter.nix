{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nitter;
  configFile = pkgs.writeText "nitter.conf" ''
    ${lib.generators.toINI
      {
        # String values need to be quoted
        mkKeyValue = lib.generators.mkKeyValueDefault {
          mkValueString =
            v:
            if lib.isString v then
              "\"" + (lib.escape [ "\"" ] (toString v)) + "\""
            else
              lib.generators.mkValueStringDefault { } v;
        } " = ";
      }
      (
        lib.recursiveUpdate {
          Cache = cfg.cache;

          Config = cfg.config // {
            hmacKey = "@hmac@";
          };

          Preferences = cfg.preferences;
          Server = cfg.server;
        } cfg.settings
      )
    }
  '';
  # `hmac` is a secret used for cryptographic signing of video URLs.
  # Generate it on first launch, then copy configuration and replace
  # `@hmac@` with this value.
  # We are not using sed as it would leak the value in the command line.
  preStart = pkgs.writers.writePython3 "nitter-prestart" { } ''
    import os
    import secrets

    state_dir = os.environ.get("STATE_DIRECTORY")
    if not os.path.isfile(f"{state_dir}/hmac"):
        # Generate hmac on first launch
        hmac = secrets.token_hex(32)
        with open(f"{state_dir}/hmac", "w") as f:
            f.write(hmac)
    else:
        # Load previously generated hmac
        with open(f"{state_dir}/hmac", "r") as f:
            hmac = f.read()

    configFile = "${configFile}"
    with open(configFile, "r") as f_in:
        with open(f"{state_dir}/nitter.conf", "w") as f_out:
            f_out.write(f_in.read().replace("@hmac@", hmac))
  '';
in
{
  imports = [
    # https://github.com/zedeus/nitter/pull/772
    (lib.mkRemovedOptionModule [
      "services"
      "nitter"
      "replaceInstagram"
    ] "Nitter no longer supports this option as Bibliogram has been discontinued.")
    (lib.mkRenamedOptionModule
      [ "services" "nitter" "guestAccounts" ]
      [ "services" "nitter" "sessionsFile" ]
    )
  ];

  options = {
    services.nitter = {
      config = {
        base64Media = lib.mkOption {
          default = false;
          description = "Use base64 encoding for proxied media URLs.";
          type = lib.types.bool;
        };

        enableDebug = lib.mkEnableOption "request logs and debug endpoints";

        enableRSS = lib.mkEnableOption "RSS feeds" // {
          default = true;
        };

        proxy = lib.mkOption {
          default = "";
          description = "URL to a HTTP/HTTPS proxy.";
          type = lib.types.str;
        };

        proxyAuth = lib.mkOption {
          default = "";
          description = "Credentials for proxy.";
          type = lib.types.str;
        };

        tokenCount = lib.mkOption {
          default = 10;

          description = ''
            Minimum amount of usable tokens.

            Tokens are used to authorize API requests, but they expire after
            ~1 hour, and have a limit of 187 requests. The limit gets reset
            every 15 minutes, and the pool is filled up so there is always at
            least tokenCount usable tokens. Only increase this if you receive
            major bursts all the time.
          '';

          type = lib.types.int;
        };
      };

      enable = lib.mkEnableOption "Nitter, an alternative Twitter front-end";
      package = lib.mkPackageOption pkgs "nitter" { };

      cache = {
        listMinutes = lib.mkOption {
          default = 240;
          description = "How long to cache list info (not the tweets, so keep it high).";
          type = lib.types.int;
        };

        redisConnections = lib.mkOption {
          default = 20;
          description = "Redis connection pool size.";
          type = lib.types.int;
        };

        redisHost = lib.mkOption {
          default = "localhost";
          description = "Redis host.";
          type = lib.types.str;
        };

        redisMaxConnections = lib.mkOption {
          default = 30;

          description = ''
            Maximum number of connections to Redis.

            New connections are opened when none are available, but if the
            pool size goes above this, they are closed when released, do not
            worry about this unless you receive tons of requests per second.
          '';

          type = lib.types.int;
        };

        redisPort = lib.mkOption {
          default = 6379;
          description = "Redis port.";
          type = lib.types.port;
        };

        rssMinutes = lib.mkOption {
          default = 10;
          description = "How long to cache RSS queries.";
          type = lib.types.int;
        };
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for Nitter web interface.";
        type = lib.types.bool;
      };

      preferences = {
        autoplayGifs = lib.mkOption {
          default = true;
          description = "Autoplay GIFs.";
          type = lib.types.bool;
        };

        bidiSupport = lib.mkOption {
          default = false;
          description = "Support bidirectional text (makes clicking on tweets harder).";
          type = lib.types.bool;
        };

        hideBanner = lib.mkOption {
          default = false;
          description = "Hide profile banner.";
          type = lib.types.bool;
        };

        hidePins = lib.mkOption {
          default = false;
          description = "Hide pinned tweets.";
          type = lib.types.bool;
        };

        hideReplies = lib.mkOption {
          default = false;
          description = "Hide tweet replies.";
          type = lib.types.bool;
        };

        hideTweetStats = lib.mkOption {
          default = false;
          description = "Hide tweet stats (replies, retweets, likes).";
          type = lib.types.bool;
        };

        hlsPlayback = lib.mkOption {
          default = false;
          description = "Enable HLS video streaming (requires JavaScript).";
          type = lib.types.bool;
        };

        infiniteScroll = lib.mkOption {
          default = false;
          description = "Infinite scrolling (requires JavaScript, experimental!).";
          type = lib.types.bool;
        };

        mp4Playback = lib.mkOption {
          default = true;
          description = "Enable MP4 video playback.";
          type = lib.types.bool;
        };

        muteVideos = lib.mkOption {
          default = false;
          description = "Mute videos by default.";
          type = lib.types.bool;
        };

        proxyVideos = lib.mkOption {
          default = true;
          description = "Proxy video streaming through the server (might be slow).";
          type = lib.types.bool;
        };

        replaceReddit = lib.mkOption {
          default = "";
          description = "Replace Reddit links with links to this instance (blank to disable).";
          example = "teddit.net";
          type = lib.types.str;
        };

        replaceTwitter = lib.mkOption {
          default = "";
          description = "Replace Twitter links with links to this instance (blank to disable).";
          example = "nitter.net";
          type = lib.types.str;
        };

        replaceYouTube = lib.mkOption {
          default = "";
          description = "Replace YouTube links with links to this instance (blank to disable).";
          example = "piped.kavin.rocks";
          type = lib.types.str;
        };

        squareAvatars = lib.mkOption {
          default = false;
          description = "Square profile pictures.";
          type = lib.types.bool;
        };

        stickyProfile = lib.mkOption {
          default = true;
          description = "Make profile sidebar stick to top.";
          type = lib.types.bool;
        };

        theme = lib.mkOption {
          default = "Nitter";
          description = "Instance theme.";
          type = lib.types.str;
        };
      };

      redisCreateLocally = lib.mkOption {
        default = true;
        description = "Configure local Redis server for Nitter.";
        type = lib.types.bool;
      };

      server = {
        address = lib.mkOption {
          default = "0.0.0.0";
          description = "The address to listen on.";
          example = "127.0.0.1";
          type = lib.types.str;
        };

        hostname = lib.mkOption {
          default = "localhost";
          description = "Hostname of the instance.";
          example = "nitter.net";
          type = lib.types.str;
        };

        httpMaxConnections = lib.mkOption {
          default = 100;
          description = "Maximum number of HTTP connections.";
          type = lib.types.int;
        };

        https = lib.mkOption {
          default = false;
          description = "Set secure attribute on cookies. Keep it disabled to enable cookies when not using HTTPS.";
          type = lib.types.bool;
        };

        port = lib.mkOption {
          default = 8080;
          description = "The port to listen on.";
          example = 8000;
          type = lib.types.port;
        };

        staticDir = lib.mkOption {
          default = "${cfg.package}/share/nitter/public";
          defaultText = lib.literalExpression ''"''${config.services.nitter.package}/share/nitter/public"'';
          description = "Path to the static files directory.";
          type = lib.types.path;
        };

        title = lib.mkOption {
          default = "nitter";
          description = "Title of the instance.";
          type = lib.types.str;
        };
      };

      sessionsFile = lib.mkOption {
        default = "/var/lib/nitter/sessions.jsonl";

        description = ''
          Path to the session tokens file.

          This file contains a list of session tokens that can be used to
          access the instance without logging in. The file is in JSONL format,
          where each line is a JSON object with the following fields:

          {"oauth_token":"some_token","oauth_token_secret":"some_secret_key"}

          See <https://github.com/zedeus/nitter/wiki/Creating-session-tokens>
          for more information on session tokens and how to generate them.
        '';

        type = lib.types.path;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Add settings here to override NixOS module generated settings.

          Check the official repository for the available settings:
          <https://github.com/zedeus/nitter/blob/master/nitter.example.conf>
        '';

        type = lib.types.attrs;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !cfg.redisCreateLocally || (cfg.cache.redisHost == "localhost" && cfg.cache.redisPort == 6379);

        message = "When services.nitter.redisCreateLocally is enabled, you need to use localhost:6379 as a cache server.";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.server.port ];
    };

    services.redis.servers.nitter = lib.mkIf (cfg.redisCreateLocally) {
      enable = true;
      port = cfg.cache.redisPort;
    };

    systemd.services.nitter = {
      after = [ "network-online.target" ];
      description = "Nitter (An alternative Twitter front-end)";

      serviceConfig = {
        AmbientCapabilities = lib.mkIf (cfg.server.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        # Hardening
        CapabilityBoundingSet = if (cfg.server.port < 1024) then [ "CAP_NET_BIND_SERVICE" ] else [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;

        Environment = [
          "NITTER_CONF_FILE=/var/lib/nitter/nitter.conf"
          "NITTER_SESSIONS_FILE=%d/sessionsFile"
        ];

        ExecStart = "${cfg.package}/bin/nitter";
        ExecStartPre = "${preStart}";
        LoadCredential = "sessionsFile:${cfg.sessionsFile}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        # A private user cannot have process capabilities on the host's user
        # namespace and thus CAP_NET_BIND_SERVICE has no effect.
        PrivateUsers = (cfg.server.port >= 1024);
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "on-failure";
        RestartSec = "5s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "nitter";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        # Some parts of Nitter expect `public` folder in working directory,
        # see https://github.com/zedeus/nitter/issues/414
        WorkingDirectory = "${cfg.package}/share/nitter";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
