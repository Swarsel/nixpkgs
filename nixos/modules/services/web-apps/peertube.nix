{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.peertube;
  opt = options.services.peertube;

  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "production.json" cfg.settings;

  env = {
    # Used for auto video transcription
    HF_HOME = "/var/cache/peertube/huggingface";
    HOME = cfg.package;
    NODE_CONFIG_DIR = "/var/lib/peertube/config";
    NODE_ENV = "production";
    NODE_EXTRA_CA_CERTS = config.security.pki.caBundle;
    NPM_CONFIG_CACHE = "/var/cache/peertube/.npm";
    NPM_CONFIG_PREFIX = cfg.package;
    XDG_CACHE_HOME = "/var/cache/peertube";
  };

  systemCallsList = [
    "@cpu-emulation"
    "@debug"
    "@keyring"
    "@ipc"
    "@memlock"
    "@mount"
    "@obsolete"
    "@privileged"
    "@setuid"
  ];

  cfgService = {
    # Capabilities
    CapabilityBoundingSet = "";
    LockPersonality = true;
    # Security
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    # Proc filesystem
    ProtectProc = "invisible";
    # Sandboxing
    ProtectSystem = "strict";
    RemoveIPC = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    # System Call Filtering
    SystemCallArchitectures = "native";
    # Access write directories
    UMask = "0027";
  };

  envFile = pkgs.writeText "peertube.env" (
    lib.concatMapStrings (s: s + "\n") (
      lib.concatLists (
        lib.mapAttrsToList (name: value: lib.optional (value != null) ''${name}="${toString value}"'') env
      )
    )

  );

  peertubeEnv = pkgs.writeShellScriptBin "peertube-env" ''
    set -a
    source "${envFile}"
    eval -- "\$@"
  '';

  nginxCommonHeaders =
    lib.optionalString config.services.nginx.virtualHosts.${cfg.localDomain}.forceSSL ''
      add_header Strict-Transport-Security 'max-age=31536000';
    ''
    +
      lib.optionalString
        (
          config.services.nginx.virtualHosts.${cfg.localDomain}.quic
          && config.services.nginx.virtualHosts.${cfg.localDomain}.http3
        )
        ''
          add_header Alt-Svc 'h3=":$server_port"; ma=604800';
        '';

  nginxCommonHeadersExtra = ''
    add_header Access-Control-Allow-Origin '*';
    add_header Access-Control-Allow-Methods 'GET, OPTIONS';
    add_header Access-Control-Allow-Headers 'Range,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
  '';

in
{
  options.services.peertube = {
    enable = lib.mkEnableOption "Peertube";
    package = lib.mkPackageOption pkgs "peertube" { };

    configureNginx = lib.mkOption {
      default = false;
      description = "Configure nginx as a reverse proxy for peertube.";
      type = lib.types.bool;
    };

    dataDirs = lib.mkOption {
      default = [ ];
      description = "Allow access to custom data locations.";

      example = [
        "/opt/peertube/storage"
        "/var/cache/peertube"
      ];

      type = lib.types.listOf lib.types.path;
    };

    database = {
      createLocally = lib.mkOption {
        default = false;
        description = "Configure local PostgreSQL database server for PeerTube.";
        type = lib.types.bool;
      };

      host = lib.mkOption {
        default = if cfg.database.createLocally then "/run/postgresql" else null;

        defaultText = lib.literalExpression ''
          if config.${opt.database.createLocally}
          then "/run/postgresql"
          else null
        '';

        description = "Database host address or unix socket.";
        example = "192.168.15.47";
        type = lib.types.str;
      };

      name = lib.mkOption {
        default = "peertube";
        description = "Database name.";
        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        default = null;
        description = "Password for PostgreSQL database.";
        example = "/run/keys/peertube/password-postgresql";
        type = lib.types.nullOr lib.types.path;
      };

      port = lib.mkOption {
        default = 5432;
        description = "Database host port.";
        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "peertube";
        description = "Database user.";
        type = lib.types.str;
      };
    };

    enableWebHttps = lib.mkOption {
      default = false;
      description = "Whether clients will access your PeerTube instance with HTTPS. Does NOT configure the PeerTube webserver itself to listen for incoming HTTPS connections.";
      type = lib.types.bool;
    };

    group = lib.mkOption {
      default = "peertube";
      description = "Group under which Peertube runs.";
      type = lib.types.str;
    };

    listenHttp = lib.mkOption {
      default = 9000;
      description = "The port that the local PeerTube web server will listen on.";
      type = lib.types.port;
    };

    listenWeb = lib.mkOption {
      default = 9000;
      description = "The public-facing port that PeerTube will be accessible at (likely 80 or 443 if running behind a reverse proxy). Clients will try to access PeerTube at this port.";
      type = lib.types.port;
    };

    localDomain = lib.mkOption {
      description = "The domain serving your PeerTube instance.";
      example = "peertube.example.com";
      type = lib.types.str;
    };

    redis = {
      createLocally = lib.mkOption {
        default = false;
        description = "Configure local Redis server for PeerTube.";
        type = lib.types.bool;
      };

      enableUnixSocket = lib.mkOption {
        default = cfg.redis.createLocally;
        defaultText = lib.literalExpression "config.${opt.redis.createLocally}";
        description = "Use Unix socket.";
        type = lib.types.bool;
      };

      host = lib.mkOption {
        default = if cfg.redis.createLocally && !cfg.redis.enableUnixSocket then "127.0.0.1" else null;

        defaultText = lib.literalExpression ''
          if config.${opt.redis.createLocally} && !config.${opt.redis.enableUnixSocket}
          then "127.0.0.1"
          else null
        '';

        description = "Redis host.";
        type = lib.types.nullOr lib.types.str;
      };

      passwordFile = lib.mkOption {
        default = null;
        description = "Password for redis database.";
        example = "/run/keys/peertube/password-redis-db";
        type = lib.types.nullOr lib.types.path;
      };

      port = lib.mkOption {
        default = if cfg.redis.createLocally && cfg.redis.enableUnixSocket then null else 31638;

        defaultText = lib.literalExpression ''
          if config.${opt.redis.createLocally} && config.${opt.redis.enableUnixSocket}
          then null
          else 6379
        '';

        description = "Redis port.";
        type = lib.types.nullOr lib.types.port;
      };
    };

    secrets = {
      secretsFile = lib.mkOption {
        default = null;

        description = ''
          Secrets to run PeerTube.
          Generate one using `openssl rand -hex 32`
        '';

        example = "/run/secrets/peertube";
        type = lib.types.nullOr lib.types.path;
      };
    };

    serviceEnvironmentFile = lib.mkOption {
      default = null;

      description = ''
        Set environment variables for the service. Mainly useful for setting the initial root password.
        For example write to file:
        PT_INITIAL_ROOT_PASSWORD=changeme
      '';

      example = "/run/keys/peertube/password-init-root";
      type = lib.types.nullOr lib.types.path;
    };

    settings = lib.mkOption {
      description = "Configuration for peertube.";

      example = lib.literalExpression ''
        {
          listen = {
            hostname = "0.0.0.0";
          };
          log = {
            level = "debug";
          };
          storage = {
            tmp = "/opt/data/peertube/storage/tmp/";
            logs = "/opt/data/peertube/storage/logs/";
            cache = "/opt/data/peertube/storage/cache/";
          };
        }
      '';

      type = lib.types.submodule (
        { config, ... }:
        {
          options = {
            video_transcription = {
              enabled = lib.mkOption {
                default = false;
                description = "Enable automatic transcription of videos.";
                type = lib.types.bool;
              };

              engine_path = lib.mkOption {
                default =
                  if config.video_transcription.enabled then
                    lib.getExe pkgs.whisper-ctranslate2
                  else
                    # This will be in the error message when someone enables
                    # transcription manually in the web UI and tries to run a
                    # transcription job.
                    "Set `services.peertube.settings.video_transcription.enabled = true`.";

                defaultText = lib.literalExpression ''
                  if config.services.peertube.settings.video_transcription.enabled then
                    lib.getExe pkgs.whisper-ctranslate2
                  else
                    "Set `services.peertube.settings.video_transcription.enabled = true`."
                '';

                description = "Custom engine path for local transcription.";
                type = with lib.types; either path str;
              };
            };
          };

          freeformType = settingsFormat.type;
        }
      );
    };

    smtp = {
      createLocally = lib.mkOption {
        default = false;
        description = "Configure local Postfix SMTP server for PeerTube.";
        type = lib.types.bool;
      };

      passwordFile = lib.mkOption {
        default = null;
        description = "Password for smtp server.";
        example = "/run/keys/peertube/password-smtp";
        type = lib.types.nullOr lib.types.path;
      };
    };

    user = lib.mkOption {
      default = "peertube";
      description = "User account under which Peertube runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.serviceEnvironmentFile == null || !lib.hasPrefix builtins.storeDir cfg.serviceEnvironmentFile;

        message = ''
          <option>services.peertube.serviceEnvironmentFile</option> points to
          a file in the Nix store. You should use a quoted absolute path to
          prevent this.
        '';
      }
      {
        assertion = cfg.secrets.secretsFile != null;

        message = ''
          <option>services.peertube.secrets.secretsFile</option> needs to be set.
        '';
      }
      {
        assertion = !(cfg.redis.enableUnixSocket && (cfg.redis.host != null || cfg.redis.port != null));

        message = ''
          <option>services.peertube.redis.createLocally</option> and redis network connection (<option>services.peertube.redis.host</option> or <option>services.peertube.redis.port</option>) enabled. Disable either of them.
        '';
      }
      {
        assertion = cfg.redis.enableUnixSocket || (cfg.redis.host != null && cfg.redis.port != null);

        message = ''
          <option>services.peertube.redis.host</option> and <option>services.peertube.redis.port</option> needs to be set if <option>services.peertube.redis.enableUnixSocket</option> is not enabled.
        '';
      }
      {
        assertion =
          cfg.redis.passwordFile == null || !lib.hasPrefix builtins.storeDir cfg.redis.passwordFile;

        message = ''
          <option>services.peertube.redis.passwordFile</option> points to
          a file in the Nix store. You should use a quoted absolute path to
          prevent this.
        '';
      }
      {
        assertion =
          cfg.database.passwordFile == null || !lib.hasPrefix builtins.storeDir cfg.database.passwordFile;

        message = ''
          <option>services.peertube.database.passwordFile</option> points to
          a file in the Nix store. You should use a quoted absolute path to
          prevent this.
        '';
      }
      {
        assertion = cfg.smtp.passwordFile == null || !lib.hasPrefix builtins.storeDir cfg.smtp.passwordFile;

        message = ''
          <option>services.peertube.smtp.passwordFile</option> points to
          a file in the Nix store. You should use a quoted absolute path to
          prevent this.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package.cli ];

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = true;

      upstreams."peertube".servers = {
        "127.0.0.1:${toString cfg.listenHttp}".fail_timeout = "0";
      };

      virtualHosts."${cfg.localDomain}" = {
        # Application
        locations."/" = {
          priority = 1110;
          tryFiles = "/dev/null @api";
        };

        # Websocket
        locations."/socket.io" = {
          priority = 1210;
          tryFiles = "/dev/null @api_websocket";
        };

        locations."/tracker/socket" = {
          extraConfig = ''
            proxy_read_timeout 15m;
          '';

          priority = 1220;
          tryFiles = "/dev/null @api_websocket";
        };

        locations."@api" = {
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_connect_timeout 10m;

            proxy_send_timeout 10m;
            proxy_read_timeout 10m;

            client_max_body_size 100k;
            send_timeout 10m;
          ''
          + nginxCommonHeaders;

          priority = 1170;
          proxyPass = "http://peertube";
        };

        locations."@api_websocket" = {
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          ''
          + nginxCommonHeaders;

          priority = 1240;
          proxyPass = "http://peertube";
        };

        locations."^~ /download/" = {
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_limit_rate 5M;
          ''
          + nginxCommonHeaders;

          priority = 1410;
          proxyPass = "http://peertube";
        };

        locations."^~ /static/redundancy/" = {
          alias = cfg.settings.storage.redundancy;

          extraConfig = ''
            set $peertube_limit_rate 5M;

            if ($request_method = 'OPTIONS') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
              add_header Access-Control-Max-Age 1728000;
              add_header Content-Type 'text/plain charset=UTF-8';
              add_header Content-Length 0;
              return 204;
            }
            if ($request_method = 'GET') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
            }

            aio threads;
            sendfile on;
            sendfile_max_chunk 1M;

            limit_rate $peertube_limit_rate;
            limit_rate_after 5M;
          '';

          priority = 1450;
          tryFiles = "$uri @api";
        };

        locations."^~ /static/streaming-playlists/" = {
          alias = cfg.settings.storage.streaming_playlists;

          extraConfig = ''
            set $peertube_limit_rate 5M;

            if ($request_method = 'OPTIONS') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
              add_header Access-Control-Max-Age 1728000;
              add_header Content-Type 'text/plain charset=UTF-8';
              add_header Content-Length 0;
              return 204;
            }
            if ($request_method = 'GET') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
            }

            aio threads;
            sendfile on;
            sendfile_max_chunk 1M;

            limit_rate $peertube_limit_rate;
            limit_rate_after 5M;
          '';

          priority = 1460;
          tryFiles = "$uri @api";
        };

        locations."^~ /static/streaming-playlists/hls/private/" = {
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_limit_rate 5M;
          ''
          + nginxCommonHeaders;

          priority = 1420;
          proxyPass = "http://peertube";
        };

        locations."^~ /static/web-videos/" = {
          alias = cfg.settings.storage.web_videos;

          extraConfig = ''
            set $peertube_limit_rate 5M;

            if ($request_method = 'OPTIONS') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
              add_header Access-Control-Max-Age 1728000;
              add_header Content-Type 'text/plain charset=UTF-8';
              add_header Content-Length 0;
              return 204;
            }
            if ($request_method = 'GET') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
            }

            aio threads;
            sendfile on;
            sendfile_max_chunk 1M;

            limit_rate $peertube_limit_rate;
            limit_rate_after 5M;
          '';

          priority = 1470;
          tryFiles = "$uri @api";
        };

        locations."^~ /static/web-videos/private/" = {
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_limit_rate 5M;
          ''
          + nginxCommonHeaders;

          priority = 1430;
          proxyPass = "http://peertube";
        };

        locations."^~ /static/webseed/" = {
          alias = cfg.settings.storage.web_videos;

          extraConfig = ''
            set $peertube_limit_rate 5M;

            if ($request_method = 'OPTIONS') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
              add_header Access-Control-Max-Age 1728000;
              add_header Content-Type 'text/plain charset=UTF-8';
              add_header Content-Length 0;
              return 204;
            }
            if ($request_method = 'GET') {
              ${nginxCommonHeaders}
              ${nginxCommonHeadersExtra}
            }

            aio threads;
            sendfile on;
            sendfile_max_chunk 1M;

            limit_rate $peertube_limit_rate;
            limit_rate_after 5M;
          '';

          priority = 1480;
          tryFiles = "$uri @api";
        };

        locations."^~ /static/webseed/private/" = {
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_limit_rate 5M;
          ''
          + nginxCommonHeaders;

          priority = 1440;
          proxyPass = "http://peertube";
        };

        locations."~ ^/api/v1/(videos|video-playlists|video-channels|users/me)" = {
          extraConfig = ''
            client_max_body_size 12M;
            add_header X-File-Maximum-Size 8M always;
          ''
          + nginxCommonHeaders;

          priority = 1160;
          tryFiles = "/dev/null @api";
        };

        locations."~ ^/api/v1/runners/jobs/[^/]+/(update|success)$" = {
          extraConfig = ''
            client_max_body_size 0;
            proxy_request_buffering off;
          ''
          + nginxCommonHeaders;

          priority = 1150;
          tryFiles = "/dev/null @api";
        };

        locations."~ ^/api/v1/users/[^/]+/imports/import-resumable$" = {
          extraConfig = ''
            client_max_body_size 0;
            proxy_request_buffering off;
          ''
          + nginxCommonHeaders;

          priority = 1130;
          tryFiles = "/dev/null @api";
        };

        locations."~ ^/api/v1/videos/(upload-resumable|([^/]+/source/replace-resumable))$" = {
          extraConfig = ''
            client_max_body_size 0;
            proxy_request_buffering off;
          ''
          + nginxCommonHeaders;

          priority = 1120;
          tryFiles = "/dev/null @api";
        };

        locations."~ ^/api/v1/videos/(upload|([^/]+/studio/edit))$" = {
          extraConfig = ''
            limit_except POST HEAD { deny all; }

            client_max_body_size 12G;
            add_header X-File-Maximum-Size 8G always;
            proxy_request_buffering off;
          ''
          + nginxCommonHeaders;

          priority = 1140;
          tryFiles = "/dev/null @api";
        };

        # Bypass PeerTube for performance reasons.
        locations."~ ^/client/(.*\\.(js|css|png|svg|woff2|otf|ttf|woff|eot))$" = {
          alias = "${cfg.package}/client/dist/$1";

          extraConfig = ''
            add_header Cache-Control 'public, max-age=604800, immutable';
          ''
          + nginxCommonHeaders;

          priority = 1320;
        };

        locations."~ ^/client/(assets/images/(default-playlist\\.jpg|default-avatar-account\\.png|default-avatar-account-48x48\\.png|default-avatar-video-channel\\.png|default-avatar-video-channel-48x48\\.png))$" =
          {
            extraConfig = nginxCommonHeaders;
            priority = 1320;
            tryFiles = "/client-overrides/$1 /client/$1 $1";
          };

        locations."~ ^/plugins/[^/]+(/[^/]+)?/ws/" = {
          priority = 1230;
          tryFiles = "/dev/null @api_websocket";
        };

        root = "/var/lib/peertube/www";
      };
    };

    services.peertube.settings = lib.mkMerge [
      {
        database = {
          hostname = "${cfg.database.host}";
          name = "${cfg.database.name}";
          port = cfg.database.port;
          username = "${cfg.database.user}";
        };

        import = {
          videos = {
            http = {
              youtube_dl_release = {
                python_path = "${pkgs.python3}/bin/python";
              };
            };
          };
        };

        listen = {
          port = cfg.listenHttp;
        };

        redis = {
          hostname = "${toString cfg.redis.host}";
          port = (lib.optionalString (cfg.redis.port != null) cfg.redis.port);
        };

        storage = {
          avatars = lib.mkDefault "/var/lib/peertube/storage/avatars/";
          bin = lib.mkDefault "/var/lib/peertube/storage/bin/";
          cache = lib.mkDefault "/var/lib/peertube/storage/cache/";
          captions = lib.mkDefault "/var/lib/peertube/storage/captions/";
          client_overrides = lib.mkDefault "/var/lib/peertube/storage/client-overrides/";
          logs = lib.mkDefault "/var/lib/peertube/storage/logs/";
          original_video_files = lib.mkDefault "/var/lib/peertube/storage/original-video-files/";
          plugins = lib.mkDefault "/var/lib/peertube/storage/plugins/";
          previews = lib.mkDefault "/var/lib/peertube/storage/previews/";
          redundancy = lib.mkDefault "/var/lib/peertube/storage/redundancy/";
          storyboards = lib.mkDefault "/var/lib/peertube/storage/storyboards/";
          streaming_playlists = lib.mkDefault "/var/lib/peertube/storage/streaming-playlists/";
          thumbnails = lib.mkDefault "/var/lib/peertube/storage/thumbnails/";
          tmp = lib.mkDefault "/var/lib/peertube/storage/tmp/";
          tmp_persistent = lib.mkDefault "/var/lib/peertube/storage/tmp_persistent/";
          torrents = lib.mkDefault "/var/lib/peertube/storage/torrents/";
          uploads = lib.mkDefault "/var/lib/peertube/storage/uploads/";
          web_videos = lib.mkDefault "/var/lib/peertube/storage/web-videos/";
          well_known = lib.mkDefault "/var/lib/peertube/storage/well_known/";
        };

        video_transcription = {
          engine = lib.mkDefault "whisper-ctranslate2";
        };

        webserver = {
          hostname = "${cfg.localDomain}";
          https = (if cfg.enableWebHttps then true else false);
          port = cfg.listenWeb;
        };
      }
      (lib.mkIf cfg.redis.enableUnixSocket {
        redis = {
          socket = "/run/redis-peertube/redis.sock";
        };
      })
    ];

    services.postfix = lib.mkIf cfg.smtp.createLocally {
      enable = true;
      settings.main.myhostname = lib.mkDefault "${cfg.localDomain}";
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
    };

    services.redis.servers.peertube = lib.mkMerge [
      (lib.mkIf cfg.redis.createLocally {
        enable = true;
      })
      (lib.mkIf (cfg.redis.createLocally && !cfg.redis.enableUnixSocket) {
        bind = "127.0.0.1";
        port = cfg.redis.port;
      })
      (lib.mkIf (cfg.redis.createLocally && cfg.redis.enableUnixSocket) {
        unixSocket = "/run/redis-peertube/redis.sock";
        unixSocketPerm = 660;
      })
    ];

    systemd.services.peertube = {
      after = [
        "network.target"
      ]
      ++ lib.optional cfg.redis.createLocally "redis-peertube.service"
      ++ lib.optionals cfg.database.createLocally [
        "postgresql.target"
        "peertube-init-db.service"
      ];

      description = "PeerTube daemon";
      environment = env;

      path = with pkgs; [
        cfg.package.nodejs
        yarn
        ffmpeg-headless
        openssl
      ];

      requires =
        lib.optional cfg.redis.createLocally "redis-peertube.service"
        ++ lib.optionals cfg.database.createLocally [
          "postgresql.target"
          "peertube-init-db.service"
        ];

      script = ''
        umask 077
        cat > /var/lib/peertube/config/local.yaml <<EOF
        ${lib.optionalString (cfg.secrets.secretsFile != null) ''
          secrets:
            peertube: '$(cat ${cfg.secrets.secretsFile})'
        ''}
        ${lib.optionalString ((!cfg.database.createLocally) && (cfg.database.passwordFile != null)) ''
          database:
            password: '$(cat ${cfg.database.passwordFile})'
        ''}
        ${lib.optionalString (cfg.redis.passwordFile != null) ''
          redis:
            auth: '$(cat ${cfg.redis.passwordFile})'
        ''}
        ${lib.optionalString (cfg.smtp.passwordFile != null) ''
          smtp:
            password: '$(cat ${cfg.smtp.passwordFile})'
        ''}
        EOF
        umask 027
        ln -sf ${configFile} /var/lib/peertube/config/production.json
        ln -sf ${cfg.package}/config/default.yaml /var/lib/peertube/config/default.yaml
        ln -sf ${cfg.package}/client/dist -T /var/lib/peertube/www/client
        ln -sf ${cfg.settings.storage.client_overrides} -T /var/lib/peertube/www/client-overrides
        exec node dist/server
      '';

      serviceConfig = {
        # Cache directory and mode
        CacheDirectory = "peertube";
        CacheDirectoryMode = "0750";
        # Environment
        EnvironmentFile = cfg.serviceEnvironmentFile;
        Group = cfg.group;
        MemoryDenyWriteExecute = false;
        # Access write directories
        ReadWritePaths = cfg.dataDirs;
        Restart = "always";
        RestartSec = 20;

        # Sandboxing
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        # State directory and mode
        StateDirectory = "peertube";
        StateDirectoryMode = "0750";
        SyslogIdentifier = "peertube";

        # System Call Filtering
        SystemCallFilter = [
          ("~" + lib.concatStringsSep " " systemCallsList)
          "fchown"
          "pipe"
          "pipe2"
        ];

        TimeoutSec = 60;
        Type = "simple";
        # User and group
        User = cfg.user;
        WorkingDirectory = cfg.package;
      }
      // cfgService;

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.peertube-init-db = lib.mkIf cfg.database.createLocally {
      after = [
        "network.target"
        "postgresql.target"
      ];

      description = "Initialization database for PeerTube daemon";
      requires = [ "postgresql.target" ];

      script =
        let
          psqlSetupCommands = pkgs.writeText "peertube-init.sql" ''
            SELECT 'CREATE USER "${cfg.database.user}"' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${cfg.database.user}')\gexec
            SELECT 'CREATE DATABASE "${cfg.database.name}" OWNER "${cfg.database.user}" TEMPLATE template0 ENCODING UTF8' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${cfg.database.name}')\gexec
            \c '${cfg.database.name}'
            CREATE EXTENSION IF NOT EXISTS pg_trgm;
            CREATE EXTENSION IF NOT EXISTS unaccent;
          '';
        in
        "${config.services.postgresql.package}/bin/psql -f ${psqlSetupCommands}";

      serviceConfig = {
        Group = "postgres";
        MemoryDenyWriteExecute = true;
        # Sandboxing
        RestrictAddressFamilies = [ "AF_UNIX" ];
        # System Call Filtering
        SystemCallFilter = "~" + lib.concatStringsSep " " (systemCallsList ++ [ "@resources" ]);
        Type = "oneshot";
        # User and group
        User = "postgres";
        WorkingDirectory = cfg.package;
      }
      // cfgService;
    };

    systemd.tmpfiles.rules = [
      "d '/var/lib/peertube/config' 0700 ${cfg.user} ${cfg.group} - -"
      "z '/var/lib/peertube/config' 0700 ${cfg.user} ${cfg.group} - -"
      "d '/var/lib/peertube/www' 0750 ${cfg.user} ${cfg.group} - -"
      "z '/var/lib/peertube/www' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = {
      ${cfg.group} = {
        members = lib.optional cfg.configureNginx config.services.nginx.user;
      };
    };

    users.users = lib.mkMerge [
      (lib.mkIf (cfg.user == "peertube") {
        peertube = {
          group = cfg.group;
          home = cfg.package;
          isSystemUser = true;
        };
      })
      (lib.attrsets.setAttrByPath
        [ cfg.user "packages" ]
        [ peertubeEnv cfg.package.nodejs pkgs.yarn pkgs.ffmpeg-headless ]
      )
      (lib.mkIf cfg.redis.enableUnixSocket {
        ${config.services.peertube.user}.extraGroups = [ "redis-peertube" ];
      })
    ];
  };
}
