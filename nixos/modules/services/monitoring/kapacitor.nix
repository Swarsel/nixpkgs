{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.kapacitor;

  kapacitorConf = pkgs.writeTextFile {
    name = "kapacitord.conf";

    text = ''
      hostname="${config.networking.hostName}"
      data_dir="${cfg.dataDir}"

      [http]
        bind-address = "${cfg.bind}:${toString cfg.port}"
        log-enabled = false
        auth-enabled = false

      [task]
        dir = "${cfg.dataDir}/tasks"
        snapshot-interval = "${cfg.taskSnapshotInterval}"

      [replay]
        dir = "${cfg.dataDir}/replay"

      [storage]
        boltdb = "${cfg.dataDir}/kapacitor.db"

      ${lib.optionalString (cfg.loadDirectory != null) ''
        [load]
          enabled = true
          dir = "${cfg.loadDirectory}"
      ''}

      ${lib.optionalString (cfg.defaultDatabase.enable) ''
        [[influxdb]]
          name = "default"
          enabled = true
          default = true
          urls = [ "${cfg.defaultDatabase.url}" ]
          username = "${cfg.defaultDatabase.username}"
          password = "${cfg.defaultDatabase.password}"
      ''}

      ${lib.optionalString (cfg.alerta.enable) ''
        [alerta]
          enabled = true
          url = "${cfg.alerta.url}"
          token = "${cfg.alerta.token}"
          environment = "${cfg.alerta.environment}"
          origin = "${cfg.alerta.origin}"
      ''}

      ${cfg.extraConfig}
    '';
  };
in
{
  options.services.kapacitor = {
    enable = lib.mkEnableOption "kapacitor";

    alerta = {
      enable = lib.mkEnableOption "kapacitor alerta integration";

      environment = lib.mkOption {
        default = "Production";
        description = "Default Alerta environment";
        type = lib.types.str;
      };

      origin = lib.mkOption {
        default = "kapacitor";
        description = "Default origin of alert";
        type = lib.types.str;
      };

      token = lib.mkOption {
        default = "";
        description = "Default Alerta authentication token";
        type = lib.types.str;
      };

      url = lib.mkOption {
        default = "http://localhost:5000";
        description = "The URL to the Alerta REST API";
        type = lib.types.str;
      };
    };

    bind = lib.mkOption {
      default = "";
      description = "Address to bind to. The default is to bind to all addresses";
      example = "0.0.0.0";
      type = lib.types.str;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/kapacitor";
      description = "Location where Kapacitor stores its state";
      type = lib.types.path;
    };

    defaultDatabase = {
      enable = lib.mkEnableOption "kapacitor.defaultDatabase";

      password = lib.mkOption {
        description = "The password to connect to the remote InfluxDB server";
        type = lib.types.str;
      };

      url = lib.mkOption {
        description = "The URL to an InfluxDB server that serves as the default database";
        example = "http://localhost:8086";
        type = lib.types.str;
      };

      username = lib.mkOption {
        description = "The username to connect to the remote InfluxDB server";
        type = lib.types.str;
      };
    };

    extraConfig = lib.mkOption {
      default = "";
      description = "These lines go into kapacitord.conf verbatim.";
      type = lib.types.lines;
    };

    group = lib.mkOption {
      default = "kapacitor";
      description = "Group under which Kapacitor runs";
      type = lib.types.str;
    };

    loadDirectory = lib.mkOption {
      default = null;
      description = "Directory where to load services from, such as tasks, templates and handlers (or null to disable service loading on startup)";
      type = lib.types.nullOr lib.types.path;
    };

    port = lib.mkOption {
      default = 9092;
      description = "Port of Kapacitor";
      type = lib.types.port;
    };

    taskSnapshotInterval = lib.mkOption {
      default = "1m0s";
      description = "Specifies how often to snapshot the task state  (in InfluxDB time units)";
      type = lib.types.str;
    };

    user = lib.mkOption {
      default = "kapacitor";
      description = "User account under which Kapacitor runs";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.kapacitor ];

    systemd.services.kapacitor = {
      after = [ "network.target" ];
      description = "Kapacitor Real-Time Stream Processing Engine";

      serviceConfig = {
        ExecStart = "${pkgs.kapacitor}/bin/kapacitord -config ${kapacitorConf}";
        Group = "kapacitor";
        User = "kapacitor";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-kapacitor".${cfg.dataDir}.d = {
      inherit (cfg) user group;
    };

    users.groups.kapacitor = {
      gid = config.ids.gids.kapacitor;
    };

    users.users.kapacitor = {
      description = "Kapacitor user";
      home = cfg.dataDir;
      uid = config.ids.uids.kapacitor;
    };
  };
}
