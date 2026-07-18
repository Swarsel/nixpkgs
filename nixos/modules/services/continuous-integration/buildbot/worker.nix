# NixOS module for Buildbot Worker.
{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.buildbot-worker;
  opt = options.services.buildbot-worker;

  package = pkgs.python3.pkgs.toPythonModule cfg.package;
  python = package.pythonModule;

  tacFile = pkgs.writeText "aur-buildbot-worker.tac" ''
    import os
    from io import open

    from buildbot_worker.bot import Worker
    from twisted.application import service

    basedir = '${cfg.buildbotDir}'

    # note: this line is matched against to check that this is a worker
    # directory; do not edit it.
    application = service.Application('buildbot-worker')

    master_url_split = '${cfg.masterUrl}'.split(':')
    buildmaster_host = master_url_split[0]
    port = int(master_url_split[1])
    workername = '${cfg.workerUser}'

    with open('${cfg.workerPassFile}', 'r', encoding='utf-8') as passwd_file:
        passwd = passwd_file.read().strip('\r\n')
    keepalive = ${toString cfg.keepalive}
    umask = None
    maxdelay = 300
    numcpus = None
    allow_shutdown = None

    s = Worker(buildmaster_host, port, workername, passwd, basedir,
               keepalive, umask=umask, maxdelay=maxdelay,
               numcpus=numcpus, allow_shutdown=allow_shutdown)
    s.setServiceParent(application)
  '';

in
{
  options = {
    services.buildbot-worker = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the Buildbot Worker.";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "buildbot-worker" { };

      adminMessage = lib.mkOption {
        default = null;
        description = "Name of the administrator of this worker";
        type = lib.types.nullOr lib.types.str;
      };

      buildbotDir = lib.mkOption {
        default = "${cfg.home}/worker";
        defaultText = lib.literalExpression ''"''${config.${opt.home}}/worker"'';
        description = "Specifies the Buildbot directory.";
        type = lib.types.path;
      };

      extraGroups = lib.mkOption {
        default = [ ];
        description = "List of extra groups that the Buildbot Worker user should be a part of.";
        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "bbworker";
        description = "Primary group of buildbot Worker user.";
        type = lib.types.str;
      };

      home = lib.mkOption {
        default = "/home/bbworker";
        description = "Buildbot home directory.";
        type = lib.types.path;
      };

      hostMessage = lib.mkOption {
        default = null;
        description = "Description of this worker";
        type = lib.types.nullOr lib.types.str;
      };

      keepalive = lib.mkOption {
        default = 600;

        description = ''
          This is a number that indicates how frequently keepalive messages should be sent
          from the worker to the buildmaster, expressed in seconds.
        '';

        type = lib.types.int;
      };

      masterUrl = lib.mkOption {
        default = "localhost:9989";
        description = "Specifies the Buildbot Worker connection string.";
        type = lib.types.str;
      };

      packages = lib.mkOption {
        default = with pkgs; [ git ];
        defaultText = lib.literalExpression "[ pkgs.git ]";
        description = "Packages to add to PATH for the buildbot process.";
        type = lib.types.listOf lib.types.package;
      };

      user = lib.mkOption {
        default = "bbworker";
        description = "User the buildbot Worker should execute under.";
        type = lib.types.str;
      };

      workerPass = lib.mkOption {
        default = "pass";
        description = "Specifies the Buildbot Worker password.";
        type = lib.types.str;
      };

      workerPassFile = lib.mkOption {
        description = "File used to store the Buildbot Worker password";
        type = lib.types.path;
      };

      workerUser = lib.mkOption {
        default = "example-worker";
        description = "Specifies the Buildbot Worker user.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.buildbot-worker.workerPassFile = lib.mkDefault (
      pkgs.writeText "buildbot-worker-password" cfg.workerPass
    );

    systemd.services.buildbot-worker = {
      after = [
        "network.target"
        "buildbot-master.service"
      ];

      description = "Buildbot Worker.";
      environment.PYTHONPATH = "${python.withPackages (p: [ package ])}/${python.sitePackages}";
      path = cfg.packages;

      preStart = ''
        mkdir -vp "${cfg.buildbotDir}/info"
        ${lib.optionalString (cfg.hostMessage != null) ''
          ln -sf "${pkgs.writeText "buildbot-worker-host" cfg.hostMessage}" "${cfg.buildbotDir}/info/host"
        ''}
        ${lib.optionalString (cfg.adminMessage != null) ''
          ln -sf "${pkgs.writeText "buildbot-worker-admin" cfg.adminMessage}" "${cfg.buildbotDir}/info/admin"
        ''}
      '';

      serviceConfig = {
        # NOTE: call twistd directly with stdout logging for systemd
        ExecStart = "${python.pkgs.twisted}/bin/twistd --nodaemon --pidfile= --logfile - --python ${tacFile}";
        Group = cfg.group;
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.home;
      };

      wantedBy = [ "multi-user.target" ];

    };

    users.groups = lib.optionalAttrs (cfg.group == "bbworker") {
      bbworker = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "bbworker") {
      bbworker = {
        createHome = true;
        description = "Buildbot Worker User.";
        extraGroups = cfg.extraGroups;
        group = cfg.group;
        home = cfg.home;
        isNormalUser = true;
        useDefaultShell = true;
      };
    };
  };

  meta.teams = [ lib.teams.buildbot ];

}
