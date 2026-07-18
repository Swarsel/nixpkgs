{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.opentsdb;

  configFile = pkgs.writeText "opentsdb.conf" cfg.config;

in
{

  ###### interface

  options = {

    services.opentsdb = {

      config = lib.mkOption {
        default = ''
          tsd.core.auto_create_metrics = true
          tsd.http.request.enable_chunked  = true
        '';

        description = ''
          The contents of OpenTSDB's configuration file
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "OpenTSDB";
      package = lib.mkPackageOption pkgs "opentsdb" { };

      group = lib.mkOption {
        default = "opentsdb";

        description = ''
          Group account under which OpenTSDB runs.
        '';

        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 4242;

        description = ''
          Which port OpenTSDB listens on.
        '';

        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "opentsdb";

        description = ''
          User account under which OpenTSDB runs.
        '';

        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf config.services.opentsdb.enable {

    systemd.services.opentsdb = {
      description = "OpenTSDB Server";
      environment.JAVA_HOME = "${pkgs.jre}";
      path = [ pkgs.gnuplot ];

      preStart = ''
        COMPRESSION=NONE HBASE_HOME=${config.services.hbase.package} ${cfg.package}/share/opentsdb/tools/create_table.sh
      '';

      requires = [ "hbase.service" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/tsdb tsd --staticroot=${cfg.package}/share/opentsdb/static --cachedir=/tmp/opentsdb --port=${toString cfg.port} --config=${configFile}";
        Group = cfg.group;
        PermissionsStartOnly = true;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.opentsdb.gid = config.ids.gids.opentsdb;

    users.users.opentsdb = {
      description = "OpenTSDB Server user";
      group = "opentsdb";
      uid = config.ids.uids.opentsdb;
    };

  };
}
