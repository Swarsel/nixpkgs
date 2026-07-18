{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    any
    attrValues
    converge
    elem
    filterAttrsRecursive
    hasPrefix
    literalExpression
    makeLibraryPath
    mkDefault
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    optionalAttrs
    optionals
    types
    ;

  cfg = config.services.frigate;

  format = pkgs.formats.yaml { };

  filteredConfig = converge (filterAttrsRecursive (_: v: !elem v [ null ])) cfg.settings;

  configFileUnchecked = format.generate "frigate.yaml" filteredConfig;
  configFileChecked =
    pkgs.runCommand "frigate-config"
      {
        preferLocalBuilds = true;
      }
      ''
        function error() {
          cat << 'HEREDOC'

        Note that not all configurations can be reliably checked in the
        build sandbox.

        This check can be disabled using `services.frigate.checkConfig`.
        HEREDOC

          exit 1
        }

        cp ${configFileUnchecked} $out
        export CONFIG_FILE=$out
        export PYTHONPATH=${cfg.package.pythonPath}
        ${cfg.preCheckConfig}
        ${cfg.package.python.interpreter} -m frigate --validate-config || error
      '';
  configFile = if cfg.checkConfig then configFileChecked else configFileUnchecked;

  cameraFormat =
    with types;
    submodule {
      options = {
        ffmpeg = {
          inputs = mkOption {
            description = ''
              List of inputs for this camera.
            '';

            type = listOf (submodule {
              options = {
                path = mkOption {
                  description = ''
                    Stream URL
                  '';

                  example = "rtsp://192.0.2.1:554/rtsp";
                  type = str;
                };

                roles = mkOption {
                  description = ''
                    List of roles for this stream
                  '';

                  example = [
                    "detect"
                    "record"
                  ];

                  type = listOf (enum [
                    "audio"
                    "detect"
                    "record"
                  ]);
                };
              };

              freeformType = format.type;
            });
          };
        };
      };

      freeformType = format.type;
    };

  # auth_request.conf
  nginxAuthRequest = ''
    # Send a subrequest to verify if the user is authenticated and has permission to access the resource.
    auth_request /auth;

    # Save the upstream metadata response headers from the auth request to variables
    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $role $upstream_http_remote_role;
    auth_request_set $groups $upstream_http_remote_groups;
    auth_request_set $name $upstream_http_remote_name;
    auth_request_set $email $upstream_http_remote_email;

    # Inject the metadata response headers from the variables into the request made to the backend.
    proxy_set_header Remote-User $user;
    proxy_set_header Remote-Role $role;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Email $email;
    proxy_set_header Remote-Name $name;

    # Refresh the cookie as needed
    auth_request_set $auth_cookie $upstream_http_set_cookie;
    add_header Set-Cookie $auth_cookie;

    # Pass the location header back up if it exists
    auth_request_set $redirection_url $upstream_http_location;
    add_header Location $redirection_url;
  '';

  nginxProxySettings = ''
    # Basic Proxy Configuration
    client_body_buffer_size 128k;
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
    proxy_redirect  http://  $scheme://;
    proxy_cache_bypass $cookie_session;
    proxy_no_cache $cookie_session;
    proxy_buffers 64 256k;

    # Advanced Proxy Configuration
    send_timeout 5m;
    proxy_read_timeout 360;
    proxy_send_timeout 360;
    proxy_connect_timeout 360;
  '';

  # Discover configured detectors for acceleration support
  detectors = attrValues cfg.settings.detectors or { };
  withCoralUSB = any (d: d.type == "edgetpu" && hasPrefix "usb" d.device or "") detectors;
  withCoralPCI = any (d: d.type == "edgetpu" && hasPrefix "pci" d.device or "") detectors;
  withCoral = withCoralPCI || withCoralUSB;
in

{
  options.services.frigate = with types; {
    enable = mkEnableOption "Frigate NVR";
    package = mkPackageOption pkgs "frigate" { };

    checkConfig = mkOption {
      default =
        pkgs.stdenv.buildPlatform.canExecute pkgs.stdenv.hostPlatform
        && (!pkgs.stdenv.hostPlatform.isAarch64);

      defaultText = literalExpression ''
        pkgs.stdenv.buildPlatform.canExecute pkgs.stdenv.hostPlatform && !(pkgs.stdenv.hostPlaform.isAarch64)
      '';

      description = ''
        Whether to check the configuration at build time.
      '';

      type = bool;
    };

    hostname = mkOption {
      description = ''
        Hostname of the nginx vhost to configure.

        Only nginx is supported by upstream for direct reverse proxying.
      '';

      example = "frigate.exampe.com";
      type = str;
    };

    preCheckConfig = mkOption {
      default = "";

      description = ''
        This script gets run before the config is checked. It can be used to,
        e.g., set environment variables needed or transform the config
        (available as `$out`) to make it checkable in the sandbox.
      '';

      type = types.lines;
    };

    settings = mkOption {
      default = { };

      description = ''
        Frigate configuration as a nix attribute set.

        See the project documentation for how to configure frigate.
        - [Creating a config file](https://docs.frigate.video/guides/getting_started)
        - [Configuration reference](https://docs.frigate.video/configuration/index)
      '';

      type = submodule {
        options = {
          cameras = mkOption {
            description = ''
              Attribute set of cameras configurations.

              <https://docs.frigate.video/configuration/cameras>
            '';

            type = attrsOf cameraFormat;
          };

          database = {
            path = mkOption {
              default = "/var/lib/frigate/frigate.db";

              description = ''
                Path to the SQLite database used
              '';

              type = path;
            };
          };

          ffmpeg = {
            path = mkOption {
              default = pkgs.ffmpeg-headless;

              description = ''
                Package providing the ffmpeg and ffprobe executables below the bin/ directory.
              '';

              example = literalExpression "pkgs.ffmpeg-full";
              type = coercedTo package toString str;
            };
          };

          mqtt = {
            enabled = mkEnableOption "MQTT support";

            host = mkOption {
              default = null;

              description = ''
                MQTT server hostname
              '';

              example = "mqtt.example.com";
              type = nullOr str;
            };
          };
        };

        freeformType = format.type;
      };
    };

    vaapiDriver = mkOption {
      default = null;

      description = ''
        Force usage of a particular VA-API driver for video acceleration. Use together with `settings.ffmpeg.hwaccel_args`.

        Setting this *is not required* for VA-API to work, but it can help steer VA-API towards the correct card if you have multiple.

        :::{.note}
        For VA-API to work you must enable {option}`hardware.graphics.enable` (sufficient for AMDGPU) and pass for example
        `pkgs.intel-media-driver` (required for Intel 5th Gen. and newer) into {option}`hardware.graphics.extraPackages`.
        :::

        See also:

        - <https://docs.frigate.video/configuration/hardware_acceleration>
        - <https://docs.frigate.video/configuration/ffmpeg_presets#hwaccel-presets>
      '';

      example = "radeonsi";

      type = nullOr (enum [
        "i965"
        "iHD"
        "nouveau"
        "vdpau"
        "nvidia"
        "radeonsi"
      ]);
    };
  };

  config = mkIf cfg.enable {
    hardware.coral = {
      pcie.enable = mkDefault withCoralPCI;
      usb.enable = mkDefault withCoralUSB;
    };

    services.nginx = {
      enable = true;

      additionalModules = with pkgs.nginxModules; [
        develkit
        rtmp
        secure-token
        set-misc
        vod
      ];

      appendConfig = ''
        # frigate
        rtmp {
            server {
                listen 1935;
                chunk_size 4096;
                allow publish 127.0.0.1;
                deny publish all;
                allow play all;
                application live {
                    live on;
                    record off;
                    meta copy;
                }
            }
        }
      '';

      appendHttpConfig = ''
        # frigate
        map $sent_http_content_type $should_not_cache {
          'application/json' 0;
          default 1;
        }
      '';

      mapHashBucketSize = mkDefault 128;

      proxyCachePath."frigate" = {
        enable = true;
        inactive = "1m";
        keysZoneName = "frigate_api_cache";
        keysZoneSize = "10m";
        levels = "1:2";
        maxSize = "10m";
      };

      recommendedGzipSettings = mkDefault true;

      upstreams = {
        frigate-api.servers = {
          "127.0.0.1:5001" = { };
        };

        frigate-go2rtc.servers = {
          "127.0.0.1:1984" = { };
        };

        frigate-jsmpeg.servers = {
          "127.0.0.1:8082" = { };
        };

        frigate-mqtt-ws.servers = {
          "127.0.0.1:5002" = { };
        };
      };

      # Based on https://github.com/blakeblackshear/frigate/blob/v0.13.1/docker/main/rootfs/usr/local/nginx/conf/nginx.conf
      virtualHosts."${cfg.hostname}" = {
        extraConfig = ''
          # Frigate wants to connect on 127.0.0.1:5000 for unauthenticated requests
          # https://github.com/NixOS/nixpkgs/issues/370349
          listen 127.0.0.1:5000;

          # vod settings
          vod_hls_version 6;
          vod_base_url "";
          vod_segments_base_url "";
          vod_mode mapped;
          vod_max_mapping_response_size 1m;
          vod_upstream_location /api;
          vod_align_segments_to_key_frames on;
          vod_manifest_segment_durations_mode accurate;
          vod_ignore_edit_list on;
          vod_segment_duration 10000;

          # MPEG-TS settings (not used when fMP4 is enabled, kept for reference)
          vod_hls_mpegts_align_frames off;
          vod_hls_mpegts_interleave_frames on;

          # file handle caching / aio
          open_file_cache max=1000 inactive=5m;
          open_file_cache_valid 2m;
          open_file_cache_min_uses 1;
          open_file_cache_errors on;
          aio on;

          # file upload size
          client_max_body_size 20M;

          # https://github.com/kaltura/nginx-vod-module#vod_open_file_thread_pool
          vod_open_file_thread_pool default;

          # vod caches
          vod_metadata_cache metadata_cache 512m;
          vod_mapping_cache mapping_cache 5m 10m;

          # gzip manifest
          gzip_types application/vnd.apple.mpegurl;
        '';

        locations = {
          "/" = {
            extraConfig = ''
              add_header Cache-Control "no-store";
              expires off;
            '';

            root = cfg.package.web;
            tryFiles = "$uri $uri.html $uri/ /index.html";
          };

          "/api/" = {
            extraConfig =
              nginxAuthRequest
              + nginxProxySettings
              + ''
                add_header Cache-Control "no-store";
                expires off;

                proxy_cache frigate_api_cache;
                proxy_cache_lock on;
                proxy_cache_use_stale updating;
                proxy_cache_valid 200 5s;
                proxy_cache_bypass $http_x_cache_bypass;
                proxy_no_cache $should_not_cache;
                add_header X-Cache-Status $upstream_cache_status;

                location /api/vod/ {
                    ${nginxAuthRequest}
                    proxy_pass http://frigate-api/vod/;
                    proxy_cache off;
                    add_header Cache-Control "no-store";
                    ${nginxProxySettings}
                }

                location /api/login {
                    auth_request off;
                    rewrite ^/api(/.*)$ $1 break;
                    proxy_pass http://frigate-api;
                    ${nginxProxySettings}
                }

                location /api/auth/first_time_login {
                    auth_request off;
                    limit_except GET {
                        deny all;
                    }
                    rewrite ^/api(/.*)$ $1 break;
                    proxy_pass http://frigate-api;
                    ${nginxProxySettings}
                }

                location /api/stats {
                    ${nginxAuthRequest}
                    access_log off;
                    rewrite ^/api(/.*)$ $1 break;
                    add_header Cache-Control "no-store";
                    proxy_pass http://frigate-api;
                    ${nginxProxySettings}
                }

                location /api/version {
                    ${nginxAuthRequest}
                    access_log off;
                    rewrite ^/api(/.*)$ $1 break;
                    add_header Cache-Control "no-store";
                    proxy_pass http://frigate-api;
                    ${nginxProxySettings}
                }
              '';

            proxyPass = "http://frigate-api/";
            recommendedProxySettings = true;
          };

          # frontend uses this to fetch the version
          "/api/go2rtc/api" = {
            extraConfig =
              nginxAuthRequest
              + nginxProxySettings
              + ''
                limit_except GET {
                    deny  all;
                }
              '';

            proxyPass = "http://frigate-go2rtc/api";
            recommendedProxySettings = true;
          };

          # integrationn uses this to add webrtc candidate
          "/api/go2rtc/webrtc" = {
            extraConfig =
              nginxAuthRequest
              + nginxProxySettings
              + ''
                limit_except POST {
                    deny  all;
                }
              '';

            proxyPass = "http://frigate-go2rtc/api/webrtc";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };

          "/assets/" = {
            extraConfig = ''
              access_log off;
              expires 1y;
              add_header Cache-Control "public";
            '';

            root = cfg.package.web;
          };

          # auth_location.conf
          "/auth" = {
            extraConfig = ''
              internal;

              # Strip all request headers
              proxy_pass_request_headers off;

              # Pass info about the request
              proxy_set_header X-Original-Method $request_method;
              proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
              proxy_set_header X-Server-Port $server_port;
              proxy_set_header Content-Length "";

              # Pass along auth related info
              proxy_set_header Authorization $http_authorization;
              proxy_set_header Cookie $http_cookie;
              proxy_set_header X-CSRF-TOKEN "1";

              # Header used to validate reverse proxy trust
              proxy_set_header X-Proxy-Secret $http_x_proxy_secret;

              # Pass headers for common auth proxies
              proxy_set_header Remote-User $http_remote_user;
              proxy_set_header Remote-Groups $http_remote_groups;
              proxy_set_header Remote-Email $http_remote_email;
              proxy_set_header Remote-Name $http_remote_name;
              proxy_set_header X-Forwarded-User $http_x_forwarded_user;
              proxy_set_header X-Forwarded-Groups $http_x_forwarded_groups;
              proxy_set_header X-Forwarded-Email $http_x_forwarded_email;
              proxy_set_header X-Forwarded-Preferred-Username $http_x_forwarded_preferred_username;
              proxy_set_header X-Auth-Request-User $http_x_auth_request_user;
              proxy_set_header X-Auth-Request-Groups $http_x_auth_request_groups;
              proxy_set_header X-Auth-Request-Email $http_x_auth_request_email;
              proxy_set_header X-Auth-Request-Preferred-Username $http_x_auth_request_preferred_username;
              proxy_set_header X-authentik-username $http_x_authentik_username;
              proxy_set_header X-authentik-groups $http_x_authentik_groups;
              proxy_set_header X-authentik-email $http_x_authentik_email;
              proxy_set_header X-authentik-name $http_x_authentik_name;
              proxy_set_header X-authentik-uid $http_x_authentik_uid;

              ${nginxProxySettings}
            '';

            proxyPass = "http://frigate-api/auth";
            recommendedProxySettings = true;
          };

          "/cache/" = {
            alias = "/var/cache/frigate/";

            extraConfig = ''
              internal;
            '';
          };

          "/clips/" = {
            extraConfig = nginxAuthRequest + ''
              types {
                  video/mp4 mp4;
                  image/jpeg jpg;
              }

              expires 7d;
              add_header Cache-Control "public";
              autoindex on;
            '';

            root = "/var/lib/frigate";
          };

          "/exports/" = {
            extraConfig = nginxAuthRequest + ''
              types {
                video/mp4 mp4;
              }

              autoindex on;
              autoindex_format json;
            '';

            root = "/var/lib/frigate";
          };

          "/fonts" = {
            extraConfig = ''
              access_log off;
              expires 1y;
              add_header Cache-Control "public";
            '';

            root = cfg.package.web;
          };

          "/live/jsmpeg" = {
            extraConfig = nginxAuthRequest + nginxProxySettings;
            proxyPass = "http://frigate-jsmpeg/";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };

          # frigate lovelace card uses this path
          "/live/mse/api/ws" = {
            extraConfig =
              nginxAuthRequest
              + nginxProxySettings
              + ''
                limit_except GET {
                    deny  all;
                }
              '';

            proxyPass = "http://frigate-go2rtc/api/ws";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };

          "/live/webrtc/api/ws" = {
            extraConfig =
              nginxAuthRequest
              + nginxProxySettings
              + ''
                limit_except GET {
                    deny  all;
                }
              '';

            proxyPass = "http://frigate-go2rtc/api/ws";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };

          # pass through go2rtc player
          "/live/webrtc/webrtc.html" = {
            extraConfig =
              nginxAuthRequest
              + nginxProxySettings
              + ''
                limit_except GET {
                    deny  all;
                }
              '';

            proxyPass = "http://frigate-go2rtc/webrtc.html";
            recommendedProxySettings = true;
          };

          "/locales/" = {
            extraConfig = ''
              access_log off;
              add_header Cache-Control "public";
            '';

            root = cfg.package.web;
          };

          "/recordings/" = {
            extraConfig = nginxAuthRequest + ''
              types {
                  video/mp4 mp4;
              }

              autoindex on;
              autoindex_format json;
            '';

            root = "/var/lib/frigate";
          };

          "/stream/" = {
            alias = "/var/cache/frigate/stream/";

            extraConfig = nginxAuthRequest + ''
              add_header Cache-Control "no-store";
              expires off;

              types {
                  application/dash+xml mpd;
                  application/vnd.apple.mpegurl m3u8;
                  video/mp2t ts;
                  image/jpeg jpg;
              }
            '';
          };

          "/vod-not-found" = {
            return = 404;
          };

          "/vod/" = {
            extraConfig = nginxAuthRequest + ''
              aio threads;
              vod hls;

              # Use fMP4 (fragmented MP4) instead of MPEG-TS for better performance
              # Smaller segments, faster generation, better browser compatibility
              vod_hls_container_format fmp4;

              secure_token $args;
              secure_token_types application/vnd.apple.mpegurl;

              add_header Cache-Control "no-store";
              expires off;

              keepalive_disable safari;

              # vod module returns 502 for non-existent media
              # https://github.com/kaltura/nginx-vod-module/issues/468
              error_page 502 =404 /vod-not-found;
            '';
          };

          "/ws" = {
            extraConfig = nginxAuthRequest + nginxProxySettings;
            proxyPass = "http://frigate-mqtt-ws/";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };

          "~ ^/.*-([A-Za-z0-9]+)\\.webmanifest$" = {
            extraConfig = ''
              access_log off;
              expires 1y;
              add_header Cache-Control "public";
              default_type application/json;
              proxy_set_header Accept-Encoding "";
            '';

            root = cfg.package.web;
          };

          "~* /api/.*\\.(jpg|jpeg|png|webp|gif)$" = {
            extraConfig =
              nginxAuthRequest
              + nginxProxySettings
              + ''
                rewrite ^/api/(.*)$ /$1 break;
              '';

            proxyPass = "http://frigate-api";
            recommendedProxySettings = true;
          };
        };
      };
    };

    systemd.services.frigate = {
      after = [
        "go2rtc.service"
        "network.target"
      ];

      environment = {
        CONFIG_FILE = "/run/frigate/frigate.yml";
        HOME = "/var/lib/frigate";
        PYTHONPATH = cfg.package.pythonPath;
      }
      // optionalAttrs (cfg.vaapiDriver != null) {
        LIBVA_DRIVER_NAME = cfg.vaapiDriver;
      }
      // optionalAttrs withCoral {
        LD_LIBRARY_PATH = makeLibraryPath (with pkgs; [ libedgetpu ]);
      };

      path =
        with pkgs;
        [
          # unfree:
          # config.boot.kernelPackages.nvidiaPackages.latest.bin
          libva-utils
          procps
          radeontop
        ]
        ++ optionals (!stdenv.hostPlatform.isAarch64) [
          # not available on aarch64-linux
          intel-gpu-tools
          rocmPackages.rocminfo
        ];

      serviceConfig = {
        AmbientCapabilities = optionals (elem cfg.vaapiDriver [
          "i965"
          "iHD"
        ]) [ "CAP_PERFMON" ]; # for intel_gpu_top

        CacheDirectory = [
          "frigate"
          # https://github.com/blakeblackshear/frigate/discussions/18129
          "frigate/model_cache"
        ];

        CacheDirectoryMode = "0750";
        EnvironmentFile = [ "-/run/frigate/ffmpeg-env" ];
        ExecStart = "${cfg.package.python.interpreter} -m frigate";

        ExecStartPre = [
          (pkgs.writeShellScript "frigate-clear-cache" ''
            ${lib.getExe pkgs.findutils} /var/cache/frigate -not -path '/var/cache/frigate/model_cache/*' -type f -delete
          '')
          (pkgs.writeShellScript "frigate-create-writable-config" ''
            cp --no-preserve=mode ${configFile} /run/frigate/frigate.yml
          '')
        ]
        ++ lib.optionals (!config.systemd.services.frigate.environment ? LIBAVFORMAT_VERSION_MAJOR) [
          # Extract libavformat version to enable version-dependent flags in ffmpeg
          (pkgs.writeShellScript "frigate-libavformat-major-version" ''
            echo "LIBAVFORMAT_VERSION_MAJOR=$(${cfg.settings.ffmpeg.path}/bin/ffmpeg -version | ${lib.getExe pkgs.gnugrep} -Po "libavformat\W+\K\d+")" > /run/frigate/ffmpeg-env
            echo "Detected $(cat /run/frigate/ffmpeg-env)"
          '')
        ];

        Group = "frigate";
        # Caches
        PrivateTmp = true;
        # Reduce visible process scope to cgroup
        ProtectProc = "invisible";
        Restart = "on-failure";
        # Sockets/IPC
        RuntimeDirectory = "frigate";
        StateDirectory = "frigate";
        StateDirectoryMode = "0750";
        SupplementaryGroups = [ "render" ] ++ optionals withCoral [ "coral" ];
        SyslogIdentifier = "frigate";
        UMask = "0027";
        User = "frigate";
      };

      wantedBy = [
        "multi-user.target"
      ];
    };

    systemd.services.nginx.serviceConfig.SupplementaryGroups = [
      "frigate"
    ];

    users.groups.frigate = { };

    users.users.frigate = {
      group = "frigate";
      isSystemUser = true;
    };
  };

  meta.buildDocsInSandbox = false;
}
