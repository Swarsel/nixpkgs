{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dockerRegistry;

  blobCache = if cfg.enableRedisCache then "redis" else "inmemory";

  registryConfig = {
    health.storagedriver = {
      enabled = true;
      interval = "10s";
      threshold = 3;
    };

    http = {
      addr = "${cfg.listenAddress}:${toString cfg.port}";
      headers.X-Content-Type-Options = [ "nosniff" ];
    };

    log.fields.service = "registry";

    storage = {
      cache.blobdescriptor = blobCache;
      delete.enabled = cfg.enableDelete;
    }
    // (lib.optionalAttrs (cfg.storagePath != null) { filesystem.rootdirectory = cfg.storagePath; });

    version = "0.1";
  };

  configFile = cfg.configFile;
in
{
  options.services.dockerRegistry = {
    enable = lib.mkEnableOption "Docker Registry";

    package = lib.mkPackageOption pkgs "distribution" {
      example = "gitlab-container-registry";
    };

    configFile = lib.mkOption {
      default = pkgs.writeText "docker-registry-config.yml" (
        builtins.toJSON (lib.recursiveUpdate registryConfig cfg.extraConfig)
      );

      defaultText = lib.literalExpression ''pkgs.writeText "docker-registry-config.yml" "# my custom docker-registry-config.yml ..."'';

      description = ''
        Path to CNCF distribution config file.

        Setting this option will override any configuration applied by the extraConfig option.
      '';

      type = lib.types.path;
    };

    enableDelete = lib.mkOption {
      default = false;
      description = "Enable delete for manifests and blobs.";
      type = lib.types.bool;
    };

    enableGarbageCollect = lib.mkEnableOption "garbage collect";
    enableRedisCache = lib.mkEnableOption "redis as blob cache";

    extraConfig = lib.mkOption {
      default = { };

      description = ''
        Docker extra registry configuration.
      '';

      example = lib.literalExpression ''
        {
          log.level = "debug";
        }
      '';

      type = lib.types.attrs;
    };

    garbageCollectDates = lib.mkOption {
      default = "daily";

      description = ''
        Specification (in the format described by
        {manpage}`systemd.time(7)`) of the time at
        which the garbage collect will occur.
      '';

      type = lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = "127.0.0.1";
      description = "Docker registry host or ip to bind to.";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Opens the port used by the firewall.";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 5000;
      description = "Docker registry port to bind to.";
      type = lib.types.port;
    };

    redisPassword = lib.mkOption {
      default = "";
      description = "Set redis password.";
      type = lib.types.str;
    };

    redisUrl = lib.mkOption {
      default = "localhost:6379";
      description = "Set redis host and port.";
      type = lib.types.str;
    };

    storagePath = lib.mkOption {
      default = "/var/lib/docker-registry";

      description = ''
        Docker registry storage path for the filesystem storage backend. Set to
        null to configure another backend via extraConfig.
      '';

      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    services.dockerRegistry.extraConfig = lib.mkIf cfg.enableRedisCache {
      redis = {
        addr = "${cfg.redisUrl}";
        db = 0;
        dialtimeout = "10ms";
        password = "${cfg.redisPassword}";

        pool = {
          idletimeout = "300s";
          maxactive = 64;
          maxidle = 16;
        };

        readtimeout = "10ms";
        writetimeout = "10ms";
      };
    };

    systemd.services.docker-registry = {
      after = [ "network.target" ];
      description = "Docker Container Registry";

      serviceConfig = {
        AmbientCapabilities = lib.mkIf (cfg.port < 1024) "cap_net_bind_service";
        ExecStart = "${lib.getExe cfg.package} serve ${configFile}";
        User = "docker-registry";
        WorkingDirectory = cfg.storagePath;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.docker-registry-garbage-collect = {
      description = "Run Garbage Collection for docker registry";
      restartIfChanged = false;

      script = ''
        ${cfg.package}/bin/registry garbage-collect ${configFile}
        /run/current-system/systemd/bin/systemctl restart docker-registry.service
      '';

      serviceConfig.Type = "oneshot";
      startAt = lib.optional cfg.enableGarbageCollect cfg.garbageCollectDates;
      unitConfig.X-StopOnRemoval = false;
    };

    users.groups.docker-registry = { };

    users.users.docker-registry =
      (lib.optionalAttrs (cfg.storagePath != null) {
        createHome = true;
        home = cfg.storagePath;
      })
      // {
        group = "docker-registry";
        isSystemUser = true;
      };
  };
}
