{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.graylog;

  confFile = pkgs.writeText "graylog.conf" ''
    is_master = ${lib.boolToString cfg.isMaster}
    node_id_file = ${cfg.nodeIdFile}
    password_secret = ${cfg.passwordSecret}
    root_username = ${cfg.rootUsername}
    root_password_sha2 = ${cfg.rootPasswordSha2}
    elasticsearch_hosts = ${lib.concatStringsSep "," cfg.elasticsearchHosts}
    message_journal_dir = ${cfg.messageJournalDir}
    mongodb_uri = ${cfg.mongodbUri}
    plugin_dir = /var/lib/graylog/plugins
    data_dir = ${cfg.dataDir}

    ${cfg.extraConfig}
  '';

  glPlugins = pkgs.buildEnv {
    name = "graylog-plugins";
    paths = cfg.plugins;
  };

in

{
  ###### interface

  options = {

    services.graylog = {

      enable = lib.mkEnableOption "Graylog, a log management solution";

      package = lib.mkPackageOption pkgs "graylog" {
        example = "graylog-6_0";
      };

      dataDir = lib.mkOption {
        default = "/var/lib/graylog/data";
        description = "Directory used to store Graylog server state.";
        type = lib.types.str;
      };

      elasticsearchHosts = lib.mkOption {
        description = "List of valid URIs of the http ports of your elastic nodes. If one or more of your elasticsearch hosts require authentication, include the credentials in each node URI that requires authentication";
        example = lib.literalExpression ''[ "http://node1:9200" "http://user:password@node2:19200" ]'';
        type = lib.types.listOf lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Any other configuration options you might want to add";
        type = lib.types.lines;
      };

      isMaster = lib.mkOption {
        default = true;
        description = "Whether this is the master instance of your Graylog cluster";
        type = lib.types.bool;
      };

      messageJournalDir = lib.mkOption {
        default = "/var/lib/graylog/data/journal";
        description = "The directory which will be used to store the message journal. The directory must be exclusively used by Graylog and must not contain any other files than the ones created by Graylog itself";
        type = lib.types.str;
      };

      mongodbUri = lib.mkOption {
        default = "mongodb://localhost/graylog";
        description = "MongoDB connection string. See http://docs.mongodb.org/manual/reference/connection-string/ for details";
        type = lib.types.str;
      };

      nodeIdFile = lib.mkOption {
        default = "/var/lib/graylog/server/node-id";
        description = "Path of the file containing the graylog node-id";
        type = lib.types.str;
      };

      passwordSecret = lib.mkOption {
        description = ''
          You MUST set a secret to secure/pepper the stored user passwords here. Use at least 64 characters.
          Generate one by using for example: pwgen -N 1 -s 96
        '';

        type = lib.types.str;
      };

      plugins = lib.mkOption {
        default = [ ];
        description = "Extra graylog plugins";
        type = lib.types.listOf lib.types.package;
      };

      rootPasswordSha2 = lib.mkOption {
        description = ''
          You MUST specify a hash password for the root user (which you only need to initially set up the
          system and in case you lose connectivity to your authentication backend)
          This password cannot be changed using the API or via the web interface. If you need to change it,
          modify it here.
          Create one by using for example: echo -n yourpassword | shasum -a 256
          and use the resulting hash value as string for the option
        '';

        example = "e3c652f0ba0b4801205814f8b6bc49672c4c74e25b497770bb89b22cdeb4e952";
        type = lib.types.str;
      };

      rootUsername = lib.mkOption {
        default = "admin";
        description = "Name of the default administrator user";
        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "graylog";
        description = "User account under which graylog runs";
        type = lib.types.str;
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    # Note: when changing the default, make it conditional on
    # ‘system.stateVersion’ to maintain compatibility with existing
    # systems!
    services.graylog.package =
      let
        mkThrow = ver: throw "graylog-${ver} was removed, please upgrade your graylog version.";
        base =
          if lib.versionAtLeast config.system.stateVersion "25.05" then
            pkgs.graylog-6_0
          else if lib.versionAtLeast config.system.stateVersion "23.05" then
            mkThrow "5_1"
          else
            mkThrow "3_3";
      in
      lib.mkDefault base;

    systemd.services.graylog = {
      description = "Graylog Server";

      environment = {
        GRAYLOG_CONF = "${confFile}";
      };

      path = [
        pkgs.which
        pkgs.procps
      ];

      preStart = ''
        rm -rf /var/lib/graylog/plugins || true
        mkdir -p /var/lib/graylog/plugins -m 755

        mkdir -p "$(dirname ${cfg.nodeIdFile})"
        chown -R ${cfg.user} "$(dirname ${cfg.nodeIdFile})"

        for declarativeplugin in `ls ${glPlugins}/bin/`; do
          ln -sf ${glPlugins}/bin/$declarativeplugin /var/lib/graylog/plugins/$declarativeplugin
        done
        for includedplugin in `ls ${cfg.package}/plugin/`; do
          ln -s ${cfg.package}/plugin/$includedplugin /var/lib/graylog/plugins/$includedplugin || true
        done
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/graylogctl run";
        StateDirectory = "graylog";
        User = "${cfg.user}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.messageJournalDir}' - ${cfg.user} - - -"
    ];

    users.groups = lib.mkIf (cfg.user == "graylog") { graylog = { }; };

    users.users = lib.mkIf (cfg.user == "graylog") {
      graylog = {
        description = "Graylog server daemon user";
        group = "graylog";
        isSystemUser = true;
      };
    };
  };
}
