{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.graphite;
  opt = options.services.graphite;
  writeTextOrNull = f: t: lib.mapNullable (pkgs.writeTextDir f) t;

  dataDir = cfg.dataDir;
  staticDir = cfg.dataDir + "/static";

  graphiteLocalSettingsDir =
    pkgs.runCommand "graphite_local_settings"
      {
        inherit graphiteLocalSettings;
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out
        ln -s $graphiteLocalSettings $out/graphite_local_settings.py
      '';

  graphiteLocalSettings = pkgs.writeText "graphite_local_settings.py" (
    "STATIC_ROOT = '${staticDir}'\n"
    + lib.optionalString (config.time.timeZone != null) "TIME_ZONE = '${config.time.timeZone}'\n"
    + cfg.web.extraConfig
  );

  seyrenConfig = {
    GRAPHITE_URL = cfg.seyren.graphiteUrl;
    MONGO_URL = cfg.seyren.mongoUrl;
    SEYREN_URL = cfg.seyren.seyrenUrl;
  }
  // cfg.seyren.extraConfig;

  configDir = pkgs.buildEnv {
    name = "graphite-config";

    paths = lib.lists.filter (el: el != null) [
      (writeTextOrNull "carbon.conf" cfg.carbon.config)
      (writeTextOrNull "storage-aggregation.conf" cfg.carbon.storageAggregation)
      (writeTextOrNull "storage-schemas.conf" cfg.carbon.storageSchemas)
      (writeTextOrNull "blacklist.conf" cfg.carbon.blacklist)
      (writeTextOrNull "whitelist.conf" cfg.carbon.whitelist)
      (writeTextOrNull "rewrite-rules.conf" cfg.carbon.rewriteRules)
      (writeTextOrNull "relay-rules.conf" cfg.carbon.relayRules)
      (writeTextOrNull "aggregation-rules.conf" cfg.carbon.aggregationRules)
    ];
  };

  carbonOpts = name: ''
    --nodaemon --syslog --prefix=${name} --pidfile /run/${name}/${name}.pid ${name}
  '';

  carbonEnv = {
    GRAPHITE_CONF_DIR = configDir;
    GRAPHITE_ROOT = dataDir;
    GRAPHITE_STORAGE_DIR = dataDir;

    PYTHONPATH =
      let
        cenv = pkgs.python3.buildEnv.override {
          extraLibs = [ pkgs.python3Packages.carbon ];
        };
      in
      "${cenv}/${pkgs.python3.sitePackages}";
  };

in
{

  imports = [
    (lib.mkRemovedOptionModule [ "services" "graphite" "api" ] "")
    (lib.mkRemovedOptionModule [ "services" "graphite" "beacon" ] "")
    (lib.mkRemovedOptionModule [ "services" "graphite" "pager" ] "")
  ];

  ###### interface

  options.services.graphite = {
    carbon = {
      config = lib.mkOption {
        default = ''
          [cache]
          # Listen on localhost by default for security reasons
          UDP_RECEIVER_INTERFACE = 127.0.0.1
          PICKLE_RECEIVER_INTERFACE = 127.0.0.1
          LINE_RECEIVER_INTERFACE = 127.0.0.1
          CACHE_QUERY_INTERFACE = 127.0.0.1
          # Do not log every update
          LOG_UPDATES = False
          LOG_CACHE_HITS = False
        '';

        description = "Content of carbon configuration file.";
        type = lib.types.str;
      };

      aggregationRules = lib.mkOption {
        default = null;
        description = "Defines if and how received metrics will be aggregated.";

        example = ''
          <env>.applications.<app>.all.requests (60) = sum <env>.applications.<app>.*.requests
          <env>.applications.<app>.all.latency (60) = avg <env>.applications.<app>.*.latency
        '';

        type = lib.types.nullOr lib.types.str;
      };

      blacklist = lib.mkOption {
        default = null;
        description = "Any metrics received which match one of the expressions will be dropped.";
        example = "^some\\.noisy\\.metric\\.prefix\\..*";
        type = lib.types.nullOr lib.types.str;
      };

      enableAggregator = lib.mkOption {
        default = false;
        description = "Whether to enable carbon aggregator, the carbon buffering service.";
        type = lib.types.bool;
      };

      enableCache = lib.mkOption {
        default = false;
        description = "Whether to enable carbon cache, the graphite storage daemon.";
        type = lib.types.bool;
      };

      enableRelay = lib.mkOption {
        default = false;
        description = "Whether to enable carbon relay, the carbon replication and sharding service.";
        type = lib.types.bool;
      };

      relayRules = lib.mkOption {
        default = null;
        description = "Relay rules are used to send certain metrics to a certain backend.";

        example = ''
          [example]
          pattern = ^mydata\.foo\..+
          servers = 10.1.2.3, 10.1.2.4:2004, myserver.mydomain.com
        '';

        type = lib.types.nullOr lib.types.str;
      };

      rewriteRules = lib.mkOption {
        default = null;

        description = ''
          Regular expression patterns that can be used to rewrite metric names
          in a search and replace fashion.
        '';

        example = ''
          [post]
          _sum$ =
          _avg$ =
        '';

        type = lib.types.nullOr lib.types.str;
      };

      storageAggregation = lib.mkOption {
        default = null;
        description = "Defines how to aggregate data to lower-precision retentions.";

        example = ''
          [all_min]
          pattern = \.min$
          xFilesFactor = 0.1
          aggregationMethod = min
        '';

        type = lib.types.nullOr lib.types.str;
      };

      storageSchemas = lib.mkOption {
        default = "";
        description = "Defines retention rates for storing metrics.";

        example = ''
          [apache_busyWorkers]
          pattern = ^servers\.www.*\.workers\.busyWorkers$
          retentions = 15s:7d,1m:21d,15m:5y
        '';

        type = lib.types.nullOr lib.types.str;
      };

      whitelist = lib.mkOption {
        default = null;
        description = "Only metrics received which match one of the expressions will be persisted.";
        example = ".*";
        type = lib.types.nullOr lib.types.str;
      };
    };

    dataDir = lib.mkOption {
      default = "/var/db/graphite";

      description = ''
        Data directory for graphite.
      '';

      type = lib.types.path;
    };

    seyren = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable seyren service.";
        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = { };

        description = ''
          Extra seyren configuration. See
          <https://github.com/scobal/seyren#config>
        '';

        example = lib.literalExpression ''
          {
            GRAPHITE_USERNAME = "user";
            GRAPHITE_PASSWORD = "pass";
          }
        '';

        type = lib.types.attrsOf lib.types.str;
      };

      graphiteUrl = lib.mkOption {
        default = "http://${cfg.web.listenAddress}:${toString cfg.web.port}";
        defaultText = lib.literalExpression ''"http://''${config.${opt.web.listenAddress}}:''${toString config.${opt.web.port}}"'';
        description = "Host where graphite service runs.";
        type = lib.types.str;
      };

      mongoUrl = lib.mkOption {
        default = "mongodb://${config.services.mongodb.bind_ip}:27017/seyren";
        defaultText = lib.literalExpression ''"mongodb://''${config.services.mongodb.bind_ip}:27017/seyren"'';
        description = "Mongodb connection string.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8081;
        description = "Seyren listening port.";
        type = lib.types.port;
      };

      seyrenUrl = lib.mkOption {
        default = "http://localhost:${toString cfg.seyren.port}/";
        defaultText = lib.literalExpression ''"http://localhost:''${toString config.${opt.seyren.port}}/"'';
        description = "Host where seyren is accessible.";
        type = lib.types.str;
      };
    };

    web = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable graphite web frontend.";
        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Graphite webapp settings. See:
          <https://graphite.readthedocs.io/en/latest/config-local-settings.html>
        '';

        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "127.0.0.1";
        description = "Graphite web frontend listen address.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8080;
        description = "Graphite web frontend port.";
        type = lib.types.port;
      };
    };
  };

  ###### implementation

  config = lib.mkMerge [
    (lib.mkIf cfg.carbon.enableCache {
      systemd.services.carbonCache =
        let
          name = "carbon-cache";
        in
        {
          after = [ "network.target" ];
          description = "Graphite Data Storage Backend";
          environment = carbonEnv;

          preStart = ''
            install -dm0700 -o graphite -g graphite ${cfg.dataDir}
            install -dm0700 -o graphite -g graphite ${cfg.dataDir}/whisper
          '';

          serviceConfig = {
            ExecStart = "${lib.getExe' pkgs.python3Packages.twisted "twistd"} ${carbonOpts name}";
            Group = "graphite";
            PIDFile = "/run/${name}/${name}.pid";
            PermissionsStartOnly = true;
            RuntimeDirectory = name;
            Slice = "system-graphite.slice";
            User = "graphite";
          };

          wantedBy = [ "multi-user.target" ];
        };
    })

    (lib.mkIf cfg.carbon.enableAggregator {
      systemd.services.carbonAggregator =
        let
          name = "carbon-aggregator";
        in
        {
          enable = cfg.carbon.enableAggregator;
          after = [ "network.target" ];
          description = "Carbon Data Aggregator";
          environment = carbonEnv;

          serviceConfig = {
            ExecStart = "${lib.getExe' pkgs.python3Packages.twisted "twistd"} ${carbonOpts name}";
            Group = "graphite";
            PIDFile = "/run/${name}/${name}.pid";
            RuntimeDirectory = name;
            Slice = "system-graphite.slice";
            User = "graphite";
          };

          wantedBy = [ "multi-user.target" ];
        };
    })

    (lib.mkIf cfg.carbon.enableRelay {
      systemd.services.carbonRelay =
        let
          name = "carbon-relay";
        in
        {
          after = [ "network.target" ];
          description = "Carbon Data Relay";
          environment = carbonEnv;

          serviceConfig = {
            ExecStart = "${lib.getExe' pkgs.python3Packages.twisted "twistd"} ${carbonOpts name}";
            Group = "graphite";
            PIDFile = "/run/${name}/${name}.pid";
            RuntimeDirectory = name;
            Slice = "system-graphite.slice";
            User = "graphite";
          };

          wantedBy = [ "multi-user.target" ];
        };
    })

    (lib.mkIf (cfg.carbon.enableCache || cfg.carbon.enableAggregator || cfg.carbon.enableRelay) {
      environment.systemPackages = [
        pkgs.python3Packages.carbon
      ];
    })

    (lib.mkIf cfg.web.enable {
      environment.systemPackages = [ pkgs.python3Packages.graphite-web ];

      systemd.services.graphiteWeb = {
        after = [ "network.target" ];
        description = "Graphite Web Interface";

        environment = {
          DJANGO_SETTINGS_MODULE = "graphite.settings";
          GRAPHITE_CONF_DIR = configDir;
          GRAPHITE_SETTINGS_MODULE = "graphite_local_settings";
          GRAPHITE_STORAGE_DIR = dataDir;
          LD_LIBRARY_PATH = "${pkgs.cairo.out}/lib";

          PYTHONPATH =
            let
              penv = pkgs.python3.buildEnv.override {
                extraLibs = [
                  pkgs.python3Packages.graphite-web
                ];
              };
              penvPack = "${penv}/${pkgs.python3.sitePackages}";
            in
            lib.concatStringsSep ":" [
              "${graphiteLocalSettingsDir}"
              "${penvPack}"
              # explicitly adding pycairo in path because it cannot be imported via buildEnv
              "${pkgs.python3Packages.pycairo}/${pkgs.python3.sitePackages}"
            ];
        };

        path = [ pkgs.perl ];

        preStart = ''
          if ! test -e ${dataDir}/db-created; then
            mkdir -p ${dataDir}/{whisper/,log/webapp/}
            chmod 0700 ${dataDir}/{whisper/,log/webapp/}

            ${lib.getExe' pkgs.python3Packages.django "django-admin"} migrate --noinput

            chown -R graphite:graphite ${dataDir}

            touch ${dataDir}/db-created
          fi

          # Only collect static files when graphite_web changes.
          if ! [ "${dataDir}/current_graphite_web" -ef "${pkgs.python3Packages.graphite-web}" ]; then
            mkdir -p ${staticDir}
            ${lib.getExe' pkgs.python3Packages.django "django-admin"} collectstatic  --noinput --clear
            chown -R graphite:graphite ${staticDir}
            ln -sfT "${pkgs.python3Packages.graphite-web}" "${dataDir}/current_graphite_web"
          fi
        '';

        serviceConfig = {
          ExecStart = ''
            ${lib.getExe pkgs.python3Packages.waitress-django} \
              --host=${cfg.web.listenAddress} --port=${toString cfg.web.port}
          '';

          Group = "graphite";
          PermissionsStartOnly = true;
          Slice = "system-graphite.slice";
          User = "graphite";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })

    (lib.mkIf cfg.seyren.enable {
      services.mongodb.enable = lib.mkDefault true;

      systemd.services.seyren = {
        after = [
          "network.target"
          "mongodb.service"
        ];

        description = "Graphite Alerting Dashboard";
        environment = seyrenConfig;

        preStart = ''
          if ! test -e ${dataDir}/db-created; then
            mkdir -p ${dataDir}
            chown graphite:graphite ${dataDir}
          fi
        '';

        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.seyren} -httpPort ${toString cfg.seyren.port}";
          Group = "graphite";
          Slice = "system-graphite.slice";
          User = "graphite";
          WorkingDirectory = dataDir;
        };

        wantedBy = [ "multi-user.target" ];
      };
    })

    (lib.mkIf
      (
        cfg.carbon.enableCache
        || cfg.carbon.enableAggregator
        || cfg.carbon.enableRelay
        || cfg.web.enable
        || cfg.seyren.enable
      )
      {
        systemd.slices.system-graphite = {
          description = "Graphite Graphing System Slice";
          documentation = [ "https://graphite.readthedocs.io/en/latest/overview.html" ];
        };

        users.groups.graphite.gid = config.ids.gids.graphite;

        users.users.graphite = {
          description = "Graphite daemon user";
          group = "graphite";
          home = dataDir;
          uid = config.ids.uids.graphite;
        };
      }
    )
  ];
}
