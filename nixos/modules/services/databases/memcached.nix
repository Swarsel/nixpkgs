{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.memcached;

  memcached = pkgs.memcached;

in

{

  imports = [
    (lib.mkRemovedOptionModule [ "services" "memcached" "socket" ] ''
      This option was replaced by a fixed unix socket path at /run/memcached/memcached.sock enabled using services.memcached.enableUnixSocket.
    '')
  ];

  ###### interface
  options = {

    services.memcached = {
      enable = lib.mkEnableOption "Memcached";
      enableUnixSocket = lib.mkEnableOption "Unix Domain Socket at /run/memcached/memcached.sock instead of listening on an IP address and port. The `listen` and `port` options are ignored";

      extraOptions = lib.mkOption {
        default = [ ];
        description = "A list of extra options that will be added as a suffix when running memcached.";
        type = lib.types.listOf lib.types.str;
      };

      listen = lib.mkOption {
        default = "127.0.0.1";
        description = "The IP address to bind to.";
        type = lib.types.str;
      };

      maxConnections = lib.mkOption {
        default = 1024;
        description = "The maximum number of simultaneous connections.";
        type = lib.types.ints.unsigned;
      };

      maxMemory = lib.mkOption {
        default = 64;
        description = "The maximum amount of memory to use for storage, in MiB (1024×1024 bytes).";
        type = lib.types.ints.unsigned;
      };

      port = lib.mkOption {
        default = 11211;
        description = "The port to bind to.";
        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "memcached";
        description = "The user to run Memcached as";
        type = lib.types.str;
      };
    };

  };

  ###### implementation
  config = lib.mkIf config.services.memcached.enable {

    environment.systemPackages = [ memcached ];

    systemd.services.memcached = {
      after = [ "network.target" ];
      description = "Memcached server";

      serviceConfig = {
        # Caps
        CapabilityBoundingSet = "";

        ExecStart =
          let
            networking =
              if cfg.enableUnixSocket then
                "-s /run/memcached/memcached.sock"
              else
                "-l ${cfg.listen} -p ${toString cfg.port}";
          in
          "${memcached}/bin/memcached ${networking} -m ${toString cfg.maxMemory} -c ${toString cfg.maxConnections} ${lib.concatStringsSep " " cfg.extraOptions}";

        # Misc.
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
        # Filesystem access
        ProtectSystem = "strict";
        RestrictRealtime = true;
        RuntimeDirectory = "memcached";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.user == "memcached") { memcached = { }; };

    users.users = lib.optionalAttrs (cfg.user == "memcached") {
      memcached.description = "Memcached server user";
      memcached.group = "memcached";
      memcached.isSystemUser = true;
    };
  };

}
