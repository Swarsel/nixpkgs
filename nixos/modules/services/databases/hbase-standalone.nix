{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.hbase-standalone;
  opt = options.services.hbase-standalone;

  buildProperty =
    configAttr:
    (builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: ''
        <property>
          <name>${name}</name>
          <value>${toString value}</value>
        </property>
      '') configAttr
    ));

  configFile = pkgs.writeText "hbase-site.xml" ''
    <configuration>
            ${buildProperty (opt.settings.default // cfg.settings)}
          </configuration>
  '';

  configDir = pkgs.runCommand "hbase-config-dir" { preferLocalBuild = true; } ''
    mkdir -p $out
    cp ${cfg.package}/conf/* $out/
    rm $out/hbase-site.xml
    ln -s ${configFile} $out/hbase-site.xml
  '';

in
{

  imports = [
    (lib.mkRenamedOptionModule [ "services" "hbase" ] [ "services" "hbase-standalone" ])
  ];

  ###### interface

  options = {
    services.hbase-standalone = {

      enable = lib.mkEnableOption ''
        HBase master in standalone mode with embedded regionserver and zookeper.
        Do not use this configuration for production nor for evaluating HBase performance
      '';

      package = lib.mkPackageOption pkgs "hbase" { };

      dataDir = lib.mkOption {
        default = "/var/lib/hbase";

        description = ''
          Specifies location of HBase database files. This location should be
          writable and readable for the user the HBase service runs as
          (hbase by default).
        '';

        type = lib.types.path;
      };

      group = lib.mkOption {
        default = "hbase";

        description = ''
          Group account under which HBase runs.
        '';

        type = lib.types.str;
      };

      logDir = lib.mkOption {
        default = "/var/log/hbase";

        description = ''
          Specifies the location of HBase log files.
        '';

        type = lib.types.path;
      };

      settings = lib.mkOption {
        default = {
          "hbase.rootdir" = "file://${cfg.dataDir}/hbase";
          "hbase.zookeeper.property.dataDir" = "${cfg.dataDir}/zookeeper";
        };

        defaultText = lib.literalExpression ''
          {
            "hbase.rootdir" = "file://''${config.${opt.dataDir}}/hbase";
            "hbase.zookeeper.property.dataDir" = "''${config.${opt.dataDir}}/zookeeper";
          }
        '';

        description = ''
          configurations in hbase-site.xml, see <https://github.com/apache/hbase/blob/master/hbase-server/src/test/resources/hbase-site.xml> for details.
        '';

        type =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
      };

      user = lib.mkOption {
        default = "hbase";

        description = ''
          User account under which HBase runs.
        '';

        type = lib.types.str;
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.hbase = {
      description = "HBase Server";

      environment = {
        HBASE_LOG_DIR = cfg.logDir;
        # JRE 15 removed option `UseConcMarkSweepGC` which is needed.
        JAVA_HOME = "${pkgs.jre8}";
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/hbase --config ${configDir} master start";
        Group = cfg.group;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - ${cfg.user} ${cfg.group} - -"
      "d '${cfg.logDir}' - ${cfg.user} ${cfg.group} - -"
    ];

    users.groups.hbase.gid = config.ids.gids.hbase;

    users.users.hbase = {
      description = "HBase Server user";
      group = "hbase";
      uid = config.ids.uids.hbase;
    };

  };
}
