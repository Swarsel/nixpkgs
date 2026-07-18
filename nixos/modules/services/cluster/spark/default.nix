{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.spark;
in
{
  options = {
    services.spark = {
      package = lib.mkPackageOption pkgs "spark" {
        example = ''
          spark.overrideAttrs (super: rec {
            pname = "spark";
            version = "2.4.4";

            src = pkgs.fetchzip {
              url    = "mirror://apache/spark/"''${pname}-''${version}/''${pname}-''${version}-bin-without-hadoop.tgz";
              sha256 = "1a9w5k0207fysgpxx6db3a00fs5hdc2ncx99x4ccy2s0v5ndc66g";
            };
          })
        '';
      };

      confDir = lib.mkOption {
        default = "${cfg.package}/conf";
        defaultText = lib.literalExpression ''"''${package}/conf"'';
        description = "Spark configuration directory. Spark will use the configuration files (spark-defaults.conf, spark-env.sh, log4j.properties, etc) from this directory.";
        type = lib.types.path;
      };

      logDir = lib.mkOption {
        default = "/var/log/spark";
        description = "Spark log directory.";
        type = lib.types.path;
      };

      master = {
        enable = lib.mkEnableOption "Spark master service";

        bind = lib.mkOption {
          default = "127.0.0.1";
          description = "Address the spark master binds to.";
          example = "0.0.0.0";
          type = lib.types.str;
        };

        extraEnvironment = lib.mkOption {
          default = { };
          description = "Extra environment variables to pass to spark master. See spark-standalone documentation.";

          example = {
            SPARK_MASTER_OPTS = "-Dspark.deploy.defaultCores=5";
            SPARK_MASTER_WEBUI_PORT = 8181;
          };

          type = lib.types.attrsOf lib.types.str;
        };

        restartIfChanged = lib.mkOption {
          default = true;

          description = ''
            Automatically restart master service on config change.
            This can be set to false to defer restarts on clusters running critical applications.
            Please consider the security implications of inadvertently running an older version,
            and the possibility of unexpected behavior caused by inconsistent versions across a cluster when disabling this option.
          '';

          type = lib.types.bool;
        };
      };

      worker = {
        enable = lib.mkEnableOption "Spark worker service";

        extraEnvironment = lib.mkOption {
          default = { };
          description = "Extra environment variables to pass to spark worker.";

          example = {
            SPARK_WORKER_CORES = 5;
            SPARK_WORKER_MEMORY = "2g";
          };

          type = lib.types.attrsOf lib.types.str;
        };

        master = lib.mkOption {
          default = "127.0.0.1:7077";
          description = "Address of the spark master.";
          type = lib.types.str;
        };

        restartIfChanged = lib.mkOption {
          default = true;

          description = ''
            Automatically restart worker service on config change.
            This can be set to false to defer restarts on clusters running critical applications.
            Please consider the security implications of inadvertently running an older version,
            and the possibility of unexpected behavior caused by inconsistent versions across a cluster when disabling this option.
          '';

          type = lib.types.bool;
        };

        workDir = lib.mkOption {
          default = "/var/lib/spark";
          description = "Spark worker work dir.";
          type = lib.types.path;
        };
      };
    };
  };

  config = lib.mkIf (cfg.worker.enable || cfg.master.enable) {
    environment.systemPackages = [ cfg.package ];

    systemd = {
      services = {
        spark-master = lib.mkIf cfg.master.enable {
          after = [ "network.target" ];
          description = "spark master service.";

          environment = cfg.master.extraEnvironment // {
            SPARK_CONF_DIR = cfg.confDir;
            SPARK_LOG_DIR = cfg.logDir;
            SPARK_MASTER_HOST = cfg.master.bind;
          };

          path = with pkgs; [
            procps
            openssh
            net-tools
          ];

          restartIfChanged = cfg.master.restartIfChanged;

          serviceConfig = {
            ExecStart = "${cfg.package}/sbin/start-master.sh";
            ExecStop = "${cfg.package}/sbin/stop-master.sh";
            Group = "spark";
            Restart = "always";
            TimeoutSec = 300;
            Type = "forking";
            User = "spark";
            WorkingDirectory = "${cfg.package}/";
          };

          unitConfig = {
            StartLimitBurst = 10;
          };

          wantedBy = [ "multi-user.target" ];
        };

        spark-worker = lib.mkIf cfg.worker.enable {
          after = [ "network.target" ];
          description = "spark master service.";

          environment = cfg.worker.extraEnvironment // {
            SPARK_CONF_DIR = cfg.confDir;
            SPARK_LOG_DIR = cfg.logDir;
            SPARK_MASTER = cfg.worker.master;
            SPARK_WORKER_DIR = cfg.worker.workDir;
          };

          path = with pkgs; [
            procps
            openssh
            net-tools
            rsync
          ];

          restartIfChanged = cfg.worker.restartIfChanged;

          serviceConfig = {
            ExecStart = "${cfg.package}/sbin/start-worker.sh spark://${cfg.worker.master}";
            ExecStop = "${cfg.package}/sbin/stop-worker.sh";
            Restart = "always";
            TimeoutSec = 300;
            Type = "forking";
            User = "spark";
            WorkingDirectory = "${cfg.package}/";
          };

          unitConfig = {
            StartLimitBurst = 10;
          };

          wantedBy = [ "multi-user.target" ];
        };
      };

      tmpfiles.rules = [
        "d '${cfg.worker.workDir}' - spark spark - -"
        "d '${cfg.logDir}' - spark spark - -"
      ];
    };

    users = {
      groups.spark = { };

      users.spark = {
        description = "spark user.";
        group = "spark";
        isSystemUser = true;
      };
    };
  };
}
