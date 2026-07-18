{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dragonflydb;
  dragonflydb = pkgs.dragonflydb;

  settings = {
    dir = "/var/lib/dragonflydb";
    keys_output_limit = cfg.keysOutputLimit;
    port = cfg.port;
  }
  // (lib.optionalAttrs (cfg.bind != null) { bind = cfg.bind; })
  // (lib.optionalAttrs (cfg.requirePass != null) { requirepass = cfg.requirePass; })
  // (lib.optionalAttrs (cfg.maxMemory != null) { maxmemory = cfg.maxMemory; })
  // (lib.optionalAttrs (cfg.memcachePort != null) { memcache_port = cfg.memcachePort; })
  // (lib.optionalAttrs (cfg.dbNum != null) { dbnum = cfg.dbNum; })
  // (lib.optionalAttrs (cfg.cacheMode != null) { cache_mode = cfg.cacheMode; });
in
{

  ###### interface

  options = {
    services.dragonflydb = {
      enable = lib.mkEnableOption "DragonflyDB";

      bind = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The IP interface to bind to.
          `null` means "all interfaces".
        '';

        type = with lib.types; nullOr str;
      };

      cacheMode = lib.mkOption {
        default = null;

        description = ''
          Once this mode is on, Dragonfly will evict items least likely to be stumbled
          upon in the future but only when it is near maxmemory limit.
        '';

        type = with lib.types; nullOr bool;
      };

      dbNum = lib.mkOption {
        default = null;
        description = "Maximum number of supported databases for `select`";
        type = with lib.types; nullOr ints.unsigned;
      };

      keysOutputLimit = lib.mkOption {
        default = 8192;

        description = ''
          Maximum number of returned keys in keys command.
          `keys` is a dangerous command.
          We truncate its result to avoid blowup in memory when fetching too many keys.
        '';

        type = lib.types.ints.unsigned;
      };

      maxMemory = lib.mkOption {
        default = null;

        description = ''
          The maximum amount of memory to use for storage (in bytes).
          `null` means this will be automatically set.
        '';

        type = with lib.types; nullOr ints.unsigned;
      };

      memcachePort = lib.mkOption {
        default = null;

        description = ''
          To enable memcached compatible API on this port.
          `null` means disabled.
        '';

        type = with lib.types; nullOr port;
      };

      port = lib.mkOption {
        default = 6379;
        description = "The TCP port to accept connections.";
        type = lib.types.port;
      };

      requirePass = lib.mkOption {
        default = null;
        description = "Password for database";
        example = "letmein!";
        type = with lib.types; nullOr str;
      };

      user = lib.mkOption {
        default = "dragonfly";
        description = "The user to run DragonflyDB as";
        type = lib.types.str;
      };
    };
  };

  ###### implementation

  config = lib.mkIf config.services.dragonflydb.enable {

    environment.systemPackages = [ dragonflydb ];

    systemd.services.dragonflydb = {
      after = [ "network.target" ];
      description = "DragonflyDB server";

      serviceConfig = {
        # Caps
        CapabilityBoundingSet = "";

        ExecStart = "${dragonflydb}/bin/dragonfly --alsologtostderr ${
          lib.concatStringsSep " " (lib.mapAttrsToList (n: v: "--${n} ${lib.escapeShellArg v}") settings)
        }";

        # Process Properties
        LimitMEMLOCK = "infinity";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        # Sandboxing
        ProtectSystem = "strict";
        # Filesystem access
        ReadWritePaths = [ settings.dir ];

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictRealtime = true;
        StateDirectory = "dragonflydb";
        StateDirectoryMode = "0700";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.user == "dragonfly") { dragonfly = { }; };

    users.users = lib.optionalAttrs (cfg.user == "dragonfly") {
      dragonfly.description = "DragonflyDB server user";
      dragonfly.group = "dragonfly";
      dragonfly.isSystemUser = true;
    };
  };
}
