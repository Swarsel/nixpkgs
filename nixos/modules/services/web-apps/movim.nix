{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    filterAttrsRecursive
    generators
    literalExpression
    mkDefault
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    mkMerge
    pipe
    types
    ;

  cfg = config.services.movim;

  defaultPHPCfg = {
    "error_reporting" = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
    "opcache.enable_cli" = 1;
    "opcache.fast_shutdown" = 1;
    "opcache.interned_strings_buffer" = 8;
    "opcache.max_accelerated_files" = 6144;
    "opcache.memory_consumption" = 128;
    "opcache.revalidate_freq" = 2;
    "output_buffering" = 0;
  };

  phpCfg = generators.toKeyValue { mkKeyValue = generators.mkKeyValueDefault { } " = "; } (
    defaultPHPCfg // cfg.phpCfg
  );

  podConfigFlags =
    let
      bevalue = a: lib.escapeShellArg (generators.mkValueStringDefault { } a);
    in
    lib.concatStringsSep " " (
      lib.attrsets.foldlAttrs (
        acc: k: v:
        acc ++ lib.optional (v != null) "--${k}=${bevalue v}"
      ) [ ] cfg.podConfig
    );

  package =
    let
      p = cfg.package.override (
        {
          inherit phpCfg;
          inherit (cfg) minifyStaticFiles;
        }
        // lib.optionalAttrs (cfg.database.type == "postgresql") {
          withPostgreSQL = true;
        }
        // lib.optionalAttrs (cfg.database.type == "mariadb") {
          withMySQL = true;
        }
      );
    in
    p.overrideAttrs (
      finalAttrs: prevAttrs:
      let
        appDir = "$out/share/php/${finalAttrs.pname}";

        stateDirectories = # sh
          ''
            # Symlinking in our state directories
            rm -rf $out/{.env,cache} ${appDir}/{log,public/cache,public/images}
            ln -s ${cfg.dataDir}/.env ${appDir}/.env
            ln -s ${cfg.dataDir}/public/cache ${appDir}/public/cache
            ln -s ${cfg.dataDir}/public/images ${appDir}/public/images
            ln -s ${cfg.logDir} ${appDir}/log
            ln -s ${cfg.runtimeDir}/cache ${appDir}/cache
          '';

        exposeComposer = # sh
          ''
            # Expose PHP Composer for scripts
            mkdir -p $out/bin
            echo "#!${lib.getExe pkgs.dash}" > $out/bin/movim-composer
            echo "${finalAttrs.php.packages.composer}/bin/composer --working-dir="${appDir}" \"\$@\"" >> $out/bin/movim-composer
            chmod +x $out/bin/movim-composer
          '';

        podConfigInputDisableReplace = lib.optionalString (podConfigFlags != "") (
          lib.concatStringsSep "\n" (
            lib.attrsets.foldlAttrs (
              acc: k: v:
              acc
              ++
                lib.optional (v != null)
                  # Disable all Admin panel options that were set in the
                  # `cfg.podConfig` to prevent confusing situtions where the
                  # values are rewritten on server reboot
                  # sh
                  ''
                    substituteInPlace ${appDir}/app/Widgets/AdminMain/adminmain.tpl \
                      --replace-warn 'name="${k}"' 'name="${k}" readonly'
                  ''
            ) [ ] cfg.podConfig
          )
        );

        precompressStaticFilesJobs =
          let
            inherit (cfg.precompressStaticFiles) brotli gzip;

            findTextFileNames = lib.concatStringsSep " -o " (
              map (n: ''-iname "*.${n}"'') [
                "css"
                "ini"
                "js"
                "json"
                "manifest"
                "mjs"
                "svg"
                "webmanifest"
              ]
            );
          in
          lib.concatStringsSep "\n" [
            (lib.optionalString brotli.enable # sh
              ''
                echo -n "Precompressing static files with Brotli …"
                find ${appDir}/public -type f ${findTextFileNames} -print0 \
                  | xargs -0 -P$NIX_BUILD_CORES -n1 -I{} \
                      ${lib.getExe brotli.package} --keep --quality=${toString brotli.compressionLevel} --output={}.br {}
                echo " done."
              ''
            )
            (lib.optionalString gzip.enable # sh
              ''
                echo -n "Precompressing static files with Gzip …"
                find ${appDir}/public -type f ${findTextFileNames} -print0 \
                  | xargs -0 -P$NIX_BUILD_CORES -n1 -I{} \
                      ${lib.getExe gzip.package} -c -${toString gzip.compressionLevel} {} > {}.gz
                echo " done."
              ''
            )
          ];
      in
      {
        postInstall = lib.concatStringsSep "\n\n" [
          prevAttrs.postInstall
          stateDirectories
          exposeComposer
          podConfigInputDisableReplace
          precompressStaticFilesJobs
        ];
      }
    );

  configFile = pipe cfg.settings [
    (filterAttrsRecursive (_: v: v != null))
    (generators.toKeyValue { })
    (pkgs.writeText "movim-env")
  ];

  pool = "movim";
  fpm = config.services.phpfpm.pools.${pool};
  phpExecutionUnit = "phpfpm-${pool}";

  dbUnit =
    {
      "mariadb" = "mysql.service";
      "postgresql" = "postgresql.target";
    }
    .${cfg.database.type};

  # exclusivity asserted in `assertions`
  webServerService =
    if cfg.h2o != null then
      "h2o.service"
    else if cfg.nginx != null then
      "nginx.service"
    else
      null;

  socketOwner =
    if cfg.h2o != null then
      config.services.h2o.user
    else if cfg.nginx != null then
      config.services.nginx.user
    else
      cfg.user;

  # Movim needs a lot of unsafe values to function at this time. Perhaps if
  # this is ever addressed in the future, the PHP application will send up the
  # proper directive. For now this fairly conservative CSP will restrict a lot
  # of potentially bad stuff as well as take in inventory of the features used.
  #
  # See: https://github.com/movim/movim/issues/314
  movimCSP = lib.concatStringsSep "; " [
    "default-src 'self'"
    "img-src 'self' aesgcm: data: https:"
    "media-src 'self' aesgcm: https:"
    "script-src 'self' 'unsafe-eval' 'unsafe-inline'"
    "style-src 'self' 'unsafe-inline'"
  ];
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "minifyStaticFiles" "script" "package" ] ''
      Override services.movim.package instead.
    '')
    (lib.mkRemovedOptionModule [ "minifyStaticFiles" "style" "package" ] ''
      Override services.movim.package instead.
    '')
    (lib.mkRemovedOptionModule [ "minifyStaticFiles" "svg" "package" ] ''
      Override services.movim.package instead.
    '')
  ];

  options.services = {
    movim = {
      enable = mkEnableOption "a Movim instance";
      package = mkPackageOption pkgs "movim" { };

      dataDir = mkOption {
        default = "/var/lib/movim";
        description = "State directory of the `movim` user which holds the application’s state & data.";
        type = types.path;
      };

      database = {
        createLocally = mkOption {
          default = true;
          description = "local database using UNIX socket authentication";
          type = types.bool;
        };

        name = mkOption {
          default = "movim";
          description = "Database name.";
          type = types.nonEmptyStr;
        };

        type = mkOption {
          default = "postgresql";
          description = "Database engine to use.";
          example = "mariadb";

          type = types.enum [
            "mariadb"
            "postgresql"
          ];
        };

        user = mkOption {
          default = "movim";
          description = "Database username.";
          type = types.nonEmptyStr;
        };
      };

      debug = mkOption {
        default = false;
        description = "Debugging logs.";
        type = types.bool;
      };

      domain = mkOption {
        description = "Fully-qualified domain name (FQDN) for the Movim instance.";
        type = types.nonEmptyStr;
      };

      group = mkOption {
        default = "movim";
        description = "Group running Movim service";
        type = types.nonEmptyStr;
      };

      h2o = mkOption {
        default = null;

        description = ''
          With this option, you can customize an H2O virtual host which already
          has sensible defaults for Movim. Set to `{ }` if you do not need any
          customization to the virtual host. If enabled, then by default, the
          {option}`serverName` is `''${domain}`, If this is set to `null` (the
          default), no H2O `hosts` will be configured.
        '';

        example =
          lib.literalExpression # nix
            ''
              {
                serverAliases = [
                  "pics.''${config.movim.domain}"
                ];
                acme.enable = true;
                tls.policy = "force";
              }
            '';

        type = types.nullOr (
          types.submodule (import ../web-servers/h2o/vhost-options.nix { inherit config lib; })
        );
      };

      logDir = mkOption {
        default = "/var/log/movim";
        description = "Log directory of the `movim` user which holds the application’s logs.";
        type = types.path;
      };

      minifyStaticFiles = mkOption {
        default = true;

        description = ''
          Do minification on public static files which reduces the size of
          assets — saving data for the server & users as well as offering a
          performance improvement. This adds typing for the `minifyStaticFiles`
          attribute for the Movim package which *will* override any existing
          override value. The default `true` will enable minification for all
          supported asset types with sane defaults.
        '';

        example =
          lib.literalExpression # nix
            ''
              {
                script.enable = false;
                style = {
                  enable = true;
                  target = "> 0.5%, last 2 versions, Firefox ESR, not dead";
                };
                svg.enable = true;
              }
            '';

        type = types.either types.bool (
          types.submodule {
            options = {
              script = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "Script minification via esbuild";

                    target = mkOption {
                      default = null;

                      description = ''
                        esbuild target environment string. If not set, a sane
                        default will be provided. See:
                        <https://esbuild.github.io/api/#target>.
                      '';

                      type = types.nullOr types.nonEmptyStr;
                    };
                  };
                };
              };

              style = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "Script minification via Lightning CSS";

                    target = mkOption {
                      default = null;

                      description = ''
                        Browserslists string target for browser compatibility.
                        If not set, a sane default will be provided. See:
                        <https://browsersl.ist>.
                      '';

                      type = types.nullOr types.nonEmptyStr;
                    };
                  };
                };
              };

              svg = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption "SVG minification via Scour";
                  };
                };
              };
            };
          }
        );
      };

      nginx = mkOption {
        default = null;

        description = ''
          With this option, you can customize an Nginx virtual host which
          already has sensible defaults for Movim. Set to `{ }` if you do not
          need any customization to the virtual host. If enabled, then by
          default, the {option}`serverName` is `''${domain}`, If this is set to
          `null` (the default), no Nginx `virtualHost` will be configured.
        '';

        example =
          lib.literalExpression # nix
            ''
              {
                serverAliases = [
                  "pics.''${config.movim.domain}"
                ];
                enableACME = true;
                forceHttps = true;
              }
            '';

        type = types.nullOr (
          types.submodule (import ../web-servers/nginx/vhost-options.nix { inherit config lib; })
        );
      };

      phpCfg = mkOption {
        default = { };
        defaultText = literalExpression (generators.toPretty { } defaultPHPCfg);
        description = "Extra PHP INI options such as `memory_limit`, `max_execution_time`, etc.";

        type =
          with types;
          attrsOf (oneOf [
            int
            str
            bool
          ]);
      };

      phpPackage = mkPackageOption pkgs "php" { };

      podConfig = mkOption {
        default = { };

        description = ''
          Pod configuration (values from `php daemon.php config --help`).
          Note that these values will now be disabled in the admin panel.
        '';

        type = types.submodule {
          options = {
            chatonly = mkOption {
              default = null;
              description = "Disable all the social feature (Communities, Blog…) and keep only the chat ones";
              type = types.nullOr types.bool;
            };

            description = mkOption {
              default = null;
              description = "General description of the instance";
              type = types.nullOr types.nonEmptyStr;
            };

            disableregistration = mkOption {
              default = null;
              description = "Remove the XMPP registration flow and buttons from the interface";
              type = types.nullOr types.bool;
            };

            info = mkOption {
              default = null;
              description = "Content of the info box on the login page";
              type = types.nullOr types.nonEmptyStr;
            };

            locale = mkOption {
              default = null;
              description = "The server main locale";
              type = types.nullOr types.nonEmptyStr;
            };

            loglevel = mkOption {
              default = null;
              description = "The server loglevel";
              type = types.nullOr (types.ints.between 0 3);
            };

            restrictsuggestions = mkOption {
              default = null;
              description = "Only suggest chatrooms, Communities and other contents that are available on the user XMPP server and related services";
              type = types.nullOr types.bool;
            };

            timezone = mkOption {
              default = null;
              description = "The server timezone";
              type = types.nullOr types.nonEmptyStr;
            };

            xmppdescription = mkOption {
              default = null;
              description = "The default XMPP server description";
              type = types.nullOr types.nonEmptyStr;
            };

            xmppdomain = mkOption {
              default = null;
              description = "The default XMPP server domain";
              type = types.nullOr types.nonEmptyStr;
            };

            xmppwhitelist = mkOption {
              default = null;
              description = "The allowlisted XMPP servers";
              type = types.nullOr types.nonEmptyStr;
            };
          };
        };
      };

      poolConfig = mkOption {
        default = { };
        description = "Options for Movim’s PHP-FPM pool.";

        type =
          with types;
          attrsOf (oneOf [
            int
            str
            bool
          ]);
      };

      port = mkOption {
        default = 8080;
        description = "Movim daemon port.";
        type = types.port;
      };

      precompressStaticFiles = mkOption {
        default = {
          brotli.enable = true;
          gzip.enable = false;
        };

        description = "Aggressively precompress static files";

        type = types.submodule {
          options = {
            brotli = {
              enable = mkEnableOption "Brotli precompression";
              package = mkPackageOption pkgs "brotli" { };

              compressionLevel = mkOption {
                default = 11;
                description = "Brotli compression level";
                type = types.ints.between 0 11;
              };
            };

            gzip = {
              enable = mkEnableOption "Gzip precompression";
              package = mkPackageOption pkgs "gzip" { };

              compressionLevel = mkOption {
                default = 9;
                description = "Gzip compression level";
                type = types.ints.between 1 9;
              };
            };
          };
        };
      };

      runtimeDir = mkOption {
        default = "/run/movim";
        description = "Runtime directory of the `movim` user which holds the application’s caches & temporary files.";
        type = types.path;
      };

      secretFile = mkOption {
        default = null;
        description = "The secret file to be sourced for the .env settings.";
        type = types.nullOr types.path;
      };

      settings = mkOption {
        default = { };
        description = ".env settings for Movim. Secrets should use `secretFile` option instead. `null`s will be culled.";

        type =
          with types;
          attrsOf (
            nullOr (oneOf [
              int
              str
              bool
            ])
          );
      };

      user = mkOption {
        default = "movim";
        description = "User running Movim service";
        type = types.nonEmptyStr;
      };

      verbose = mkOption {
        default = false;
        description = "Verbose logs.";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (
        let
          webServers = [
            "h2o"
            "nginx"
          ];
          checkConfigs = lib.concatMapStringsSep ", " (ws: "services.movim.${ws}") webServers;
        in
        {
          assertion = builtins.length (lib.lists.filter (ws: cfg.${ws} != null) webServers) <= 1;

          message = ''
            At most 1 web server virtual host configuration should be enabled
            for Movim at a time. Check ${checkConfigs}.
          '';
        }
      )
    ];

    environment.systemPackages = [ package ];

    services = {
      h2o = mkIf (cfg.h2o != null) {
        enable = true;

        hosts."${cfg.domain}" = mkMerge [
          {
            settings = {
              "file.custom-handler" = {
                extension = [ ".php" ];

                "fastcgi.connect" = {
                  port = fpm.socket;
                  type = "unix";
                };

                "fastcgi.document_root" = package;
              };

              paths = {
                "/" = {
                  "file.dir" = "${package}/share/php/movim/public";

                  "file.index" = [
                    "index.php"
                    "index.html"
                  ];

                  "header.set" = [
                    "Content-Security-Policy: ${movimCSP}"
                  ];

                  redirect = {
                    internal = "YES";
                    status = 307;
                    url = "/index.php/";
                  };
                }
                // lib.optionalAttrs (with cfg.precompressStaticFiles; brotli.enable || gzip.enable) {
                  "file.send-compressed" = "ON";
                };

                "/ws/" = {
                  "proxy.preserve-host" = "ON";
                  "proxy.reverse.url" = "http://${cfg.settings.DAEMON_INTERFACE}:${toString cfg.port}/";
                  "proxy.tunnel" = "ON";
                };
              };
            };
          }
          cfg.h2o
        ];
      };

      movim = {
        poolConfig = lib.mapAttrs' (n: v: lib.nameValuePair n (lib.mkDefault v)) {
          "catch_workers_output" = true;
          "php_admin_flag[log_errors]" = true;
          "php_admin_value[error_log]" = "stderr";
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.max_requests" = 500;
          "pm.max_spare_servers" = 8;
          "pm.min_spare_servers" = 2;
          "pm.start_servers" = 2;
        };

        settings = mkMerge [
          {
            DAEMON_DEBUG = cfg.debug;
            DAEMON_INTERFACE = "127.0.0.1";
            DAEMON_PORT = cfg.port;
            DAEMON_URL = "//${cfg.domain}";
            DAEMON_VERBOSE = cfg.verbose;
          }
          (mkIf cfg.database.createLocally {
            DB_DATABASE = cfg.database.name;

            DB_DRIVER =
              {
                "mariadb" = "mysql";
                "postgresql" = "pgsql";
              }
              .${cfg.database.type};

            DB_HOST = "localhost";
            DB_PASSWORD = "";
            DB_PORT = config.services.${cfg.database.type}.settings.port;
            DB_USERNAME = cfg.database.user;
          })
        ];
      };

      mysql = mkIf (cfg.database.createLocally && cfg.database.type == "mariadb") {
        enable = mkDefault true;
        package = mkDefault pkgs.mariadb;
        ensureDatabases = [ cfg.database.name ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = cfg.database.user;
          }
        ];
      };

      nginx = mkIf (cfg.nginx != null) (
        {
          enable = true;

          # TODO: recommended cache options already in Nginx⁇
          appendHttpConfig = # nginx
            ''
              fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=nginx_cache:100m inactive=60m;
              fastcgi_cache_key "$scheme$request_method$host$request_uri";
            '';

          recommendedOptimisation = mkDefault true;
          recommendedProxySettings = true;

          virtualHosts."${cfg.domain}" = mkMerge [
            cfg.nginx
            {
              extraConfig = # nginx
                ''
                  index index.php;
                '';

              locations = {
                "/" = {
                  extraConfig = # nginx
                    ''
                      add_header Content-Security-Policy "${movimCSP}";
                      set $no_cache 1;
                    '';

                  priority = 490;
                  tryFiles = "$uri $uri/ /index.php$is_args$args";
                };

                "/favicon.ico" = {
                  extraConfig = # nginx
                    ''
                      access_log off;
                      log_not_found off;
                    '';

                  priority = 100;
                };

                # Ask nginx to cache every URL starting with "/picture"
                "/picture" = {
                  extraConfig = # nginx
                    ''
                      set $no_cache 0; # Enable cache only there
                    '';

                  priority = 400;
                  tryFiles = "$uri $uri/ /index.php$is_args$args";
                };

                "/robots.txt" = {
                  extraConfig = # nginx
                    ''
                      access_log off;
                      log_not_found off;
                    '';

                  priority = 100;
                };

                "/ws/" = {
                  extraConfig = # nginx
                    ''
                      proxy_set_header X-Forwarded-Proto $scheme;
                      proxy_redirect off;
                    '';

                  priority = 900;
                  proxyPass = "http://${cfg.settings.DAEMON_INTERFACE}:${toString cfg.port}/";
                  proxyWebsockets = true;
                  recommendedProxySettings = true;
                };

                "~ /\\.(?!well-known).*" = {
                  extraConfig = # nginx
                    ''
                      deny all;
                    '';

                  priority = 210;
                };

                "~ \\.php$" = {
                  extraConfig = # nginx
                    ''
                      include ${config.services.nginx.package}/conf/fastcgi.conf;
                      add_header X-Cache $upstream_cache_status;
                      fastcgi_ignore_headers "Cache-Control" "Expires" "Set-Cookie";
                      fastcgi_cache nginx_cache;
                      fastcgi_cache_valid any 7d;
                      fastcgi_cache_bypass $no_cache;
                      fastcgi_no_cache $no_cache;
                      fastcgi_split_path_info ^(.+\.php)(/.+)$;
                      fastcgi_index index.php;
                      fastcgi_pass unix:${fpm.socket};
                    '';

                  priority = 500;
                  tryFiles = "$uri =404";
                };
              };

              root = lib.mkForce "${package}/share/php/movim/public";
            }
          ];
        }
        // lib.optionalAttrs (cfg.precompressStaticFiles.gzip.enable) {
          recommendedGzipSettings = mkDefault true;
        }
        // lib.optionalAttrs (cfg.precompressStaticFiles.brotli.enable) {
          recommendedBrotliSettings = mkDefault true;
        }
      );

      phpfpm.pools.${pool} = {
        group = cfg.group;

        phpOptions = ''
          error_log = 'stderr'
          log_errors = on
        '';

        phpPackage = package.php;

        settings = {
          "catch_workers_output" = true;
          "listen.group" = cfg.group;
          "listen.mode" = "0660";
          "listen.owner" = socketOwner;
        }
        // cfg.poolConfig;

        user = cfg.user;
      };

      postgresql = mkIf (cfg.database.createLocally && cfg.database.type == "postgresql") {
        enable = mkDefault true;

        authentication = ''
          host ${cfg.database.name} ${cfg.database.user} localhost trust
        '';

        ensureDatabases = [ cfg.database.name ];

        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = cfg.database.user;
          }
        ];
      };
    };

    systemd = {
      services.${phpExecutionUnit} = {
        after = [ "movim-data-setup.service" ] ++ lib.optional cfg.database.createLocally dbUnit;
        before = [ "movim.service" ] ++ lib.optional (webServerService != null) webServerService;
        requiredBy = [ "movim.service" ];
        requires = [ "movim-data-setup.service" ] ++ lib.optional cfg.database.createLocally dbUnit;
        wantedBy = lib.optional (webServerService != null) webServerService;
        wants = [ "network.target" ];
      };

      services.movim = {
        after = [
          "movim-data-setup.service"
          "${phpExecutionUnit}.service"
        ]
        ++ lib.optional cfg.database.createLocally dbUnit
        ++ lib.optional (webServerService != null) webServerService;

        description = "Movim daemon";

        environment = {
          PUBLIC_URL = "//${cfg.domain}";
          WS_PORT = toString cfg.port;
        };

        requires = [
          "movim-data-setup.service"
          "${phpExecutionUnit}.service"
        ]
        ++ lib.optional cfg.database.createLocally dbUnit
        ++ lib.optional (webServerService != null) webServerService;

        serviceConfig = {
          ExecStart = "${lib.getExe package} start";
          Group = cfg.group;
          User = cfg.user;
          WorkingDirectory = "${package}/share/php/movim";
        };

        wantedBy = [ "multi-user.target" ];

        wants = [
          "network.target"
          "local-fs.target"
        ];
      };

      services.movim-data-setup = {
        after = lib.optional cfg.database.createLocally dbUnit;
        before = [ "${phpExecutionUnit}.service" ];
        description = "Movim setup: .env file, databases init, cache reload";
        requiredBy = [ "${phpExecutionUnit}.service" ];
        requires = lib.optional cfg.database.createLocally dbUnit;

        script = # sh
        ''
          # Env vars
          rm -f ${cfg.dataDir}/.env
          cp --no-preserve=all ${configFile} ${cfg.dataDir}/.env
          echo -e '\n' >> ${cfg.dataDir}/.env
          if [[ -f "$CREDENTIALS_DIRECTORY/env-secrets"  ]]; then
            cat "$CREDENTIALS_DIRECTORY/env-secrets" >> ${cfg.dataDir}/.env
            echo -e '\n' >> ${cfg.dataDir}/.env
          fi

          # Caches, logs
          mkdir -p ${cfg.dataDir}/public/{cache,images} ${cfg.logDir} ${cfg.runtimeDir}/cache
          chmod -R ug+rw ${cfg.dataDir}/public/cache
          chmod -R ug+rw ${cfg.dataDir}/public/images
          chmod -R ug+rw ${cfg.logDir}
          chmod -R ug+rwx ${cfg.runtimeDir}/cache

          # Migrations
          MOVIM_VERSION="${package.version}"
          if [[ ! -f "${cfg.dataDir}/.migration-version" ]] || [[ "$MOVIM_VERSION" != "$(<${cfg.dataDir}/.migration-version)" ]]; then
            ${package}/bin/movim-composer movim:migrate && echo $MOVIM_VERSION > ${cfg.dataDir}/.migration-version
          fi
        ''
        + lib.optionalString (podConfigFlags != "") (
          let
            flags = lib.concatStringsSep " " (
              [ "--no-interaction" ]
              ++ lib.optional cfg.debug "-vvv"
              ++ lib.optional (!cfg.debug && cfg.verbose) "-v"
            );
          in
          ''
            ${lib.getExe package} config ${podConfigFlags}
          ''
        );

        serviceConfig = {
          Group = cfg.group;
          Type = "oneshot";
          UMask = "077";
          User = cfg.user;
        }
        // lib.optionalAttrs (cfg.secretFile != null) {
          LoadCredential = "env-secrets:${cfg.secretFile}";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "local-fs.target" ];
      };

      tmpfiles.settings."10-movim" = with cfg; {
        "${dataDir}".d = {
          inherit user group;
          mode = "0710";
        };

        "${dataDir}/public".d = {
          inherit user group;
          mode = "0750";
        };

        "${dataDir}/public/cache".d = {
          inherit user group;
          mode = "0750";
        };

        "${dataDir}/public/images".d = {
          inherit user group;
          mode = "0750";
        };

        "${logDir}".d = {
          inherit user group;
          mode = "0700";
        };

        "${runtimeDir}".d = {
          inherit user group;
          mode = "0700";
        };

        "${runtimeDir}/cache".d = {
          inherit user group;
          mode = "0700";
        };
      };
    };

    users = {
      groups = {
        ${cfg.group} = { };
      };

      users = {
        movim = mkIf (cfg.user == "movim") {
          group = cfg.group;
          isSystemUser = true;
        };
      }
      // lib.optionalAttrs (cfg.h2o != null) {
        "${config.services.h2o.user}".extraGroups = [ cfg.group ];
      }
      // lib.optionalAttrs (cfg.nginx != null) {
        "${config.services.nginx.user}".extraGroups = [ cfg.group ];
      };
    };
  };
}
