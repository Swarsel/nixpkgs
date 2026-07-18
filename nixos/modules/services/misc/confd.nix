{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.confd;

  confdConfig = ''
    backend = "${cfg.backend}"
    confdir = "${cfg.confDir}"
    interval = ${toString cfg.interval}
    nodes = [ ${lib.concatMapStringsSep "," (s: ''"${s}"'') cfg.nodes}, ]
    prefix = "${cfg.prefix}"
    log-level = "${cfg.logLevel}"
    watch = ${lib.boolToString cfg.watch}
  '';

in
{
  options.services.confd = {
    enable = lib.mkEnableOption "confd, a service to manage local application configuration files using templates and data from etcd/consul/redis/zookeeper";
    package = lib.mkPackageOption pkgs "confd" { };

    backend = lib.mkOption {
      default = "etcd";
      description = "Confd config storage backend to use.";

      type = lib.types.enum [
        "etcd"
        "consul"
        "redis"
        "zookeeper"
      ];
    };

    confDir = lib.mkOption {
      default = "/etc/confd";
      description = "The path to the confd configs.";
      type = lib.types.path;
    };

    interval = lib.mkOption {
      default = 10;
      description = "Confd check interval.";
      type = lib.types.int;
    };

    logLevel = lib.mkOption {
      default = "info";
      description = "Confd log level.";

      type = lib.types.enum [
        "info"
        "debug"
      ];
    };

    nodes = lib.mkOption {
      default = [ "http://127.0.0.1:2379" ];
      description = "Confd list of nodes to connect to.";
      type = lib.types.listOf lib.types.str;
    };

    prefix = lib.mkOption {
      default = "/";
      description = "The string to prefix to keys.";
      type = lib.types.path;
    };

    watch = lib.mkOption {
      default = true;
      description = "Confd, whether to watch etcd config for changes.";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "confd/confd.toml".text = confdConfig;
    };

    environment.systemPackages = [ cfg.package ];
    services.etcd.enable = lib.mkIf (cfg.backend == "etcd") (lib.mkDefault true);

    systemd.services.confd = {
      after = [ "network.target" ];
      description = "Confd Service.";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/confd";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
