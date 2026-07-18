# NixOS module for Buildbot continuous integration server.
{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.buildbot-master;
  opt = options.services.buildbot-master;

  package = cfg.package.python.pkgs.toPythonModule cfg.package;
  python = cfg.package.python;

  escapeStr = lib.escape [ "'" ];

  defaultMasterCfg = pkgs.writeText "master.cfg" ''
    from buildbot.plugins import *
    ${cfg.extraImports}
    factory = util.BuildFactory()
    c = BuildmasterConfig = dict(
     workers       = [${lib.concatStringsSep "," cfg.workers}],
     protocols     = { 'pb': {'port': ${toString cfg.pbPort} } },
     title         = '${escapeStr cfg.title}',
     titleURL      = '${escapeStr cfg.titleUrl}',
     buildbotURL   = '${escapeStr cfg.buildbotUrl}',
     db            = dict(db_url='${escapeStr cfg.dbUrl}'),
     www           = dict(port=${toString cfg.port}),
     change_source = [ ${lib.concatStringsSep "," cfg.changeSource} ],
     schedulers    = [ ${lib.concatStringsSep "," cfg.schedulers} ],
     builders      = [ ${lib.concatStringsSep "," cfg.builders} ],
     services      = [ ${lib.concatStringsSep "," cfg.reporters} ],
     configurators = [ ${lib.concatStringsSep "," cfg.configurators} ],
    )
    for step in [ ${lib.concatStringsSep "," cfg.factorySteps} ]:
      factory.addStep(step)

    ${cfg.extraConfig}
  '';

  tacFile = pkgs.writeText "buildbot-master.tac" ''
    import os

    from twisted.application import service
    from buildbot.master import BuildMaster

    basedir = '${cfg.buildbotDir}'

    configfile = '${cfg.masterCfg}'

    # Default umask for server
    umask = None

    # note: this line is matched against to check that this is a buildmaster
    # directory; do not edit it.
    application = service.Application('buildmaster')

    m = BuildMaster(basedir, configfile, umask)
    m.setServiceParent(application)
  '';

in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "buildbot-master" "bpPort" ]
      [ "services" "buildbot-master" "pbPort" ]
    )
    (lib.mkRemovedOptionModule [ "services" "buildbot-master" "status" ] ''
      Since Buildbot 0.9.0, status targets are deprecated and ignored.
      Review your configuration and migrate to reporters (available at services.buildbot-master.reporters).
    '')
  ];

  options = {
    services.buildbot-master = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the Buildbot continuous integration server.";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "buildbot-full" {
        example = "buildbot";
      };

      buildbotDir = lib.mkOption {
        default = "${cfg.home}/master";
        defaultText = lib.literalExpression ''"''${config.${opt.home}}/master"'';
        description = "Specifies the Buildbot directory.";
        type = lib.types.path;
      };

      buildbotUrl = lib.mkOption {
        default = "http://localhost:8010/";
        description = "Specifies the Buildbot URL.";
        type = lib.types.str;
      };

      builders = lib.mkOption {
        default = [
          "util.BuilderConfig(name='runtests',workernames=['example-worker'],factory=factory)"
        ];

        description = "List of Builders.";
        type = lib.types.listOf lib.types.str;
      };

      changeSource = lib.mkOption {
        default = [ ];
        description = "List of Change Sources.";

        example = [
          "changes.GitPoller('https://github.com/buildbot/pyflakes.git', workdir='gitpoller-workdir', branch='master', pollinterval=300)"
        ];

        type = lib.types.listOf lib.types.str;
      };

      configurators = lib.mkOption {
        default = [ ];
        description = "Configurator Steps, see <https://docs.buildbot.net/latest/manual/configuration/configurators.html>";

        example = [
          "util.JanitorConfigurator(logHorizon=timedelta(weeks=4), hour=12, dayOfWeek=6)"
        ];

        type = lib.types.listOf lib.types.str;
      };

      dbUrl = lib.mkOption {
        default = "sqlite:///state.sqlite";
        description = "Specifies the database connection string.";
        type = lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "c['buildbotNetUsageData'] = None";
        description = "Extra configuration to append to master.cfg";
        type = lib.types.lines;
      };

      extraGroups = lib.mkOption {
        default = [ ];
        description = "List of extra groups that the buildbot user should be a part of.";
        type = lib.types.listOf lib.types.str;
      };

      extraImports = lib.mkOption {
        default = "";
        description = "Extra python imports to prepend to master.cfg";
        example = "from buildbot.process.project import Project";
        type = lib.types.lines;
      };

      factorySteps = lib.mkOption {
        default = [ ];
        description = "Factory Steps";

        example = [
          "steps.Git(repourl='https://github.com/buildbot/pyflakes.git', mode='incremental')"
          "steps.ShellCommand(command=['trial', 'pyflakes'])"
        ];

        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "buildbot";
        description = "Primary group of buildbot user.";
        type = lib.types.str;
      };

      home = lib.mkOption {
        default = "/home/buildbot";
        description = "Buildbot home directory.";
        type = lib.types.path;
      };

      listenAddress = lib.mkOption {
        default = "0.0.0.0";
        description = "Specifies the bind address on which the buildbot HTTP interface listens.";
        type = lib.types.str;
      };

      masterCfg = lib.mkOption {
        default = defaultMasterCfg;
        defaultText = lib.literalMD "generated configuration file";
        description = "Optionally pass master.cfg path. Other options in this configuration will be ignored.";
        example = "/etc/nixos/buildbot/master.cfg";
        type = lib.types.path;
      };

      packages = lib.mkOption {
        default = [ pkgs.git ];
        defaultText = lib.literalExpression "[ pkgs.git ]";
        description = "Packages to add to PATH for the buildbot process.";
        type = lib.types.listOf lib.types.package;
      };

      pbPort = lib.mkOption {
        default = 9989;

        description = ''
          The buildmaster will listen on a TCP port of your choosing
          for connections from workers.
          It can also use this port for connections from remote Change Sources,
          status clients, and debug tools.
          This port should be visible to the outside world, and you’ll need to tell
          your worker admins about your choice.
          If put in (single) quotes, this can also be used as a connection string,
          as defined in the [ConnectionStrings guide](https://twistedmatrix.com/documents/current/core/howto/endpoints.html).
        '';

        example = "'tcp:9990:interface=127.0.0.1'";
        type = lib.types.either lib.types.str lib.types.port;
      };

      port = lib.mkOption {
        default = 8010;
        description = "Specifies port number on which the buildbot HTTP interface listens.";
        type = lib.types.port;
      };

      pythonPackages = lib.mkOption {
        default = pythonPackages: [ ];
        defaultText = lib.literalExpression "pythonPackages: with pythonPackages; [ ]";
        description = "Packages to add the to the PYTHONPATH of the buildbot process.";
        example = lib.literalExpression "pythonPackages: with pythonPackages; [ requests ]";
        type = lib.types.functionTo (lib.types.listOf lib.types.package);
      };

      reporters = lib.mkOption {
        default = [ ];
        description = "List of reporter objects used to present build status to various users.";
        type = lib.types.listOf lib.types.str;
      };

      schedulers = lib.mkOption {
        default = [
          "schedulers.SingleBranchScheduler(name='all', change_filter=util.ChangeFilter(branch='master'), treeStableTimer=None, builderNames=['runtests'])"
          "schedulers.ForceScheduler(name='force',builderNames=['runtests'])"
        ];

        description = "List of Schedulers.";
        type = lib.types.listOf lib.types.str;
      };

      title = lib.mkOption {
        default = "Buildbot";
        description = "Specifies the Buildbot Title.";
        type = lib.types.str;
      };

      titleUrl = lib.mkOption {
        default = "Buildbot";
        description = "Specifies the Buildbot TitleURL.";
        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "buildbot";
        description = "User the buildbot server should execute under.";
        type = lib.types.str;
      };

      workers = lib.mkOption {
        default = [ "worker.Worker('example-worker', 'pass')" ];
        description = "List of Workers.";
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.buildbot-master = {
      after = [ "network.target" ];
      description = "Buildbot Continuous Integration Server.";

      environment.PYTHONPATH = "${
        python.withPackages (self: cfg.pythonPackages self ++ [ package ])
      }/${python.sitePackages}";

      path = cfg.packages ++ cfg.pythonPackages python.pkgs;

      preStart = ''
        mkdir -vp "${cfg.buildbotDir}"
        # Link the tac file so buildbot command line tools recognize the directory
        ln -sf "${tacFile}" "${cfg.buildbotDir}/buildbot.tac"
        ${cfg.package}/bin/buildbot create-master --db "${cfg.dbUrl}" "${cfg.buildbotDir}"
        rm -f buildbot.tac.new master.cfg.sample
      '';

      serviceConfig = {
        # To reload on upgrade, set the following in your configuration:
        # systemd.services.buildbot-master.reloadIfChanged = true;
        ExecReload = [
          "${pkgs.coreutils}/bin/ln -sf ${tacFile} ${cfg.buildbotDir}/buildbot.tac"
          "${pkgs.coreutils}/bin/kill -HUP $MAINPID"
        ];

        # NOTE: call twistd directly with stdout logging for systemd
        ExecStart = "${python.pkgs.twisted}/bin/twistd -o --nodaemon --pidfile= --logfile - --python ${cfg.buildbotDir}/buildbot.tac";
        Group = cfg.group;
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.home;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "buildbot") {
      buildbot = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "buildbot") {
      buildbot = {
        inherit (cfg) home group extraGroups;
        createHome = true;
        description = "Buildbot User.";
        isNormalUser = true;
        useDefaultShell = true;
      };
    };
  };

  meta.teams = [ lib.teams.buildbot ];
}
