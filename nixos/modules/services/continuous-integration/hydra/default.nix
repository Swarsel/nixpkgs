{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.hydra;

  baseDir = "/var/lib/hydra";

  hydraConf = pkgs.writeScript "hydra.conf" cfg.extraConfig;

  hydraEnv = {
    HYDRA_CONFIG = "${baseDir}/hydra.conf";
    HYDRA_DATA = "${baseDir}";
    HYDRA_DBI = cfg.dbi;
  };

  env = {
    NIX_REMOTE = "daemon";
    NIX_REMOTE_SYSTEMS = lib.concatStringsSep ":" cfg.buildMachinesFiles;
    PGPASSFILE = "${baseDir}/pgpass";
  }
  // lib.optionalAttrs (cfg.smtpHost != null) {
    EMAIL_SENDER_TRANSPORT = "SMTP";
    EMAIL_SENDER_TRANSPORT_host = cfg.smtpHost;
  }
  // hydraEnv
  // cfg.extraEnv;

  serverEnv =
    env
    // {
      COLUMNS = "80";
      HYDRA_TRACKER = cfg.tracker;
      PGPASSFILE = "${baseDir}/pgpass-www"; # grrr
      XDG_CACHE_HOME = "${baseDir}/www/.cache";
    }
    // (lib.optionalAttrs cfg.debugServer { DBIC_TRACE = "1"; });

  localDB = "dbi:Pg:dbname=hydra;user=hydra;";

  haveLocalDB = cfg.dbi == localDB;

  hydra-package =
    let
      makeWrapperArgs = lib.concatStringsSep " " (
        lib.mapAttrsToList (key: value: "--set-default \"${key}\" \"${value}\"") hydraEnv
      );
    in
    pkgs.buildEnv rec {
      name = "hydra-env";
      nativeBuildInputs = [ pkgs.makeWrapper ];
      paths = [ cfg.package ];

      postBuild = ''
        if [ -L "$out/bin" ]; then
            unlink "$out/bin"
        fi
        mkdir -p "$out/bin"

        for path in ${lib.concatStringsSep " " paths}; do
          if [ -d "$path/bin" ]; then
            cd "$path/bin"
            for prg in *; do
              if [ -f "$prg" ]; then
                rm -f "$out/bin/$prg"
                if [ -x "$prg" ]; then
                  makeWrapper "$path/bin/$prg" "$out/bin/$prg" ${makeWrapperArgs}
                fi
              fi
            done
          fi
        done
      '';
    };

in

{
  ###### interface
  options = {

    services.hydra = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to run Hydra services.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "hydra" { };

      buildMachinesFiles = lib.mkOption {
        default = lib.optional (config.nix.buildMachines != [ ]) "/etc/nix/machines";
        defaultText = lib.literalExpression ''lib.optional (config.nix.buildMachines != []) "/etc/nix/machines"'';
        description = "List of files containing build machines.";

        example = [
          "/etc/nix/machines"
          "/var/lib/hydra/provisioner/machines"
        ];

        type = lib.types.listOf lib.types.path;
      };

      dbi = lib.mkOption {
        default = localDB;

        description = ''
          The DBI string for Hydra database connection.

          NOTE: Attempts to set `application_name` will be overridden by
          `hydra-TYPE` (where TYPE is e.g. `evaluator`, `queue-runner`,
          etc.) in all hydra services to more easily distinguish where
          queries are coming from.
        '';

        example = "dbi:Pg:dbname=hydra;host=postgres.example.org;user=foo;";
        type = lib.types.str;
      };

      debugServer = lib.mkOption {
        default = false;
        description = "Whether to run the server in debug mode.";
        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        description = "Extra lines for the Hydra configuration.";
        type = lib.types.lines;
      };

      extraEnv = lib.mkOption {
        default = { };
        description = "Extra environment variables for Hydra.";
        type = lib.types.attrsOf lib.types.str;
      };

      gcRootsDir = lib.mkOption {
        default = "/nix/var/nix/gcroots/hydra";
        description = "Directory that holds Hydra garbage collector roots.";
        type = lib.types.path;
      };

      hydraURL = lib.mkOption {
        description = ''
          The base URL for the Hydra webserver instance. Used for links in emails.
        '';

        type = lib.types.str;
      };

      listenHost = lib.mkOption {
        default = "*";

        description = ''
          The hostname or address to listen on or `*` to listen
          on all interfaces.
        '';

        example = "localhost";
        type = lib.types.str;
      };

      logo = lib.mkOption {
        default = null;

        description = ''
          Path to a file containing the logo of your Hydra instance.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      maxServers = lib.mkOption {
        default = 25;
        description = "Maximum number of starman workers to spawn.";
        type = lib.types.int;
      };

      maxSpareServers = lib.mkOption {
        default = 5;
        description = "Maximum number of spare starman workers to keep.";
        type = lib.types.int;
      };

      minSpareServers = lib.mkOption {
        default = 4;
        description = "Minimum number of spare starman workers to keep.";
        type = lib.types.int;
      };

      minimumDiskFree = lib.mkOption {
        default = 0;

        description = ''
          Threshold of minimum disk space (GiB) to determine if the queue runner should run or not.
        '';

        type = lib.types.int;
      };

      minimumDiskFreeEvaluator = lib.mkOption {
        default = 0;

        description = ''
          Threshold of minimum disk space (GiB) to determine if the evaluator should run or not.
        '';

        type = lib.types.int;
      };

      notificationSender = lib.mkOption {
        description = ''
          Sender email address used for email notifications.
        '';

        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 3000;

        description = ''
          TCP port the web server should listen to.
        '';

        type = lib.types.port;
      };

      smtpHost = lib.mkOption {
        default = null;

        description = ''
          Hostname of the SMTP server to use to send email.
        '';

        example = "localhost";
        type = lib.types.nullOr lib.types.str;
      };

      tracker = lib.mkOption {
        default = "";

        description = ''
          Piece of HTML that is included on all pages.
        '';

        type = lib.types.str;
      };

      useSubstitutes = lib.mkOption {
        default = false;

        description = ''
          Whether to use binary caches for downloading store paths. Note that
          binary substitutions trigger (a potentially large number of) additional
          HTTP requests that slow down the queue monitor thread significantly.
          Also, this Hydra instance will serve those downloaded store paths to
          its users with its own signature attached as if it had built them
          itself, so don't enable this feature unless your active binary caches
          are absolute trustworthy.
        '';

        type = lib.types.bool;
      };
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.maxServers != 0 && cfg.maxSpareServers != 0 && cfg.minSpareServers != 0;
        message = "services.hydra.{minSpareServers,maxSpareServers,minSpareServers} cannot be 0";
      }
      {
        assertion = cfg.minSpareServers < cfg.maxSpareServers;
        message = "services.hydra.minSpareServers cannot be bigger than services.hydra.maxSpareServers";
      }
    ];

    environment.systemPackages = [ hydra-package ];
    environment.variables = hydraEnv;

    nix.settings = lib.mkMerge [
      {
        keep-derivations = true;
        keep-outputs = true;
        trusted-users = [ "hydra-queue-runner" ];
      }

      (lib.mkIf (lib.versionOlder (lib.getVersion config.nix.package.out) "2.4pre") {
        # The default (`true') slows Nix down a lot since the build farm
        # has so many GC roots.
        gc-check-reachability = false;
      })
    ];

    services.hydra.extraConfig = ''
      using_frontend_proxy = 1
      base_uri = ${cfg.hydraURL}
      notification_sender = ${cfg.notificationSender}
      max_servers = ${toString cfg.maxServers}
      ${lib.optionalString (cfg.logo != null) ''
        hydra_logo = ${cfg.logo}
      ''}
      gc_roots_dir = ${cfg.gcRootsDir}
      use-substitutes = ${if cfg.useSubstitutes then "1" else "0"}
    '';

    services.postgresql.authentication = lib.optionalString haveLocalDB ''
      local all hydra peer map=hydra
    '';

    services.postgresql.enable = lib.mkIf haveLocalDB true;

    services.postgresql.identMap = lib.optionalString haveLocalDB ''
      hydra hydra hydra
      hydra hydra-queue-runner hydra
      hydra hydra-www hydra
      hydra root hydra
    '';

    # If there is less than a certain amount of free disk space, stop
    # the queue/evaluator to prevent builds from failing or aborting.
    systemd.services.hydra-check-space = {
      script = ''
        if [ $(($(stat -f -c '%a' /nix/store) * $(stat -f -c '%S' /nix/store))) -lt $((${toString cfg.minimumDiskFree} * 1024**3)) ]; then
            echo "stopping Hydra queue runner due to lack of free space..."
            systemctl stop hydra-queue-runner
        fi
        if [ $(($(stat -f -c '%a' /nix/store) * $(stat -f -c '%S' /nix/store))) -lt $((${toString cfg.minimumDiskFreeEvaluator} * 1024**3)) ]; then
            echo "stopping Hydra evaluator due to lack of free space..."
            systemctl stop hydra-evaluator
        fi
      '';

      serviceConfig.Slice = "system-hydra.slice";
      startAt = "*:0/5";
    };

    # Periodically compress build logs. The queue runner compresses
    # logs automatically after a step finishes, but this doesn't work
    # if the queue runner is stopped prematurely.
    systemd.services.hydra-compress-logs = {
      path = [
        pkgs.bzip2
        pkgs.zstd
      ];

      script = ''
        set -eou pipefail
        compression=$(sed -nr 's/compress_build_logs_compression = ()/\1/p' ${baseDir}/hydra.conf)
        if [[ $compression == "" || $compression == bzip2 ]]; then
          compressionCmd=(bzip2)
        elif [[ $compression == zstd ]]; then
          compressionCmd=(zstd --rm)
        fi
        find ${baseDir}/build-logs -ignore_readdir_race -type f -name "*.drv" -mtime +3 -size +0c -print0 | xargs -0 -r "''${compressionCmd[@]}" --force --quiet
      '';

      serviceConfig.Slice = "system-hydra.slice";
      startAt = "Sun 01:45";
    };

    systemd.services.hydra-evaluator = {
      after = [
        "hydra-init.service"
        "network.target"
        "network-online.target"
      ];

      environment = env // {
        HYDRA_DBI = "${env.HYDRA_DBI};application_name=hydra-evaluator";
      };

      path = with pkgs; [
        hostname-debian
        hydra-package
        jq
      ];

      requires = [ "hydra-init.service" ];
      restartTriggers = [ hydraConf ];

      serviceConfig = {
        ExecStart = "@${hydra-package}/bin/hydra-evaluator hydra-evaluator";
        Restart = "always";
        Slice = "system-hydra.slice";
        User = "hydra";
        WorkingDirectory = baseDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.services.hydra-init = {
      after = lib.optional haveLocalDB "postgresql.target";

      environment = env // {
        HYDRA_DBI = "${env.HYDRA_DBI};application_name=hydra-init";
      };

      path = [ pkgs.util-linux ];

      preStart = ''
        mkdir -p ${baseDir}
        chown hydra:hydra ${baseDir}
        chmod 0750 ${baseDir}

        ln -sf ${hydraConf} ${baseDir}/hydra.conf

        mkdir -m 0700 ${baseDir}/www || true
        chown hydra-www:hydra ${baseDir}/www

        mkdir -m 0700 ${baseDir}/queue-runner || true
        mkdir -m 0750 ${baseDir}/build-logs || true
        mkdir -m 0750 ${baseDir}/runcommand-logs || true
        chown hydra-queue-runner:hydra \
          ${baseDir}/queue-runner \
          ${baseDir}/build-logs \
          ${baseDir}/runcommand-logs

        ${lib.optionalString haveLocalDB ''
          if ! [ -e ${baseDir}/.db-created ]; then
            runuser -u ${config.services.postgresql.superUser} ${config.services.postgresql.package}/bin/createuser hydra
            runuser -u ${config.services.postgresql.superUser} ${config.services.postgresql.package}/bin/createdb -- -O hydra hydra
            touch ${baseDir}/.db-created
          fi
          echo "create extension if not exists pg_trgm" | runuser -u ${config.services.postgresql.superUser} -- ${config.services.postgresql.package}/bin/psql hydra
        ''}

        if [ ! -e ${cfg.gcRootsDir} ]; then

          # Move legacy roots directory.
          if [ -e /nix/var/nix/gcroots/per-user/hydra/hydra-roots ]; then
            mv /nix/var/nix/gcroots/per-user/hydra/hydra-roots ${cfg.gcRootsDir}
          fi

          mkdir -p ${cfg.gcRootsDir}
        fi

        # Move legacy hydra-www roots.
        if [ -e /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots ]; then
          find /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots/ -type f -print0 \
            | xargs -0 -r mv -f -t ${cfg.gcRootsDir}/
          rmdir /nix/var/nix/gcroots/per-user/hydra-www/hydra-roots
        fi

        chown hydra:hydra ${cfg.gcRootsDir}
        chmod 2775 ${cfg.gcRootsDir}
      '';

      requires = lib.optional haveLocalDB "postgresql.target";
      serviceConfig.ExecStart = "${hydra-package}/bin/hydra-init";
      serviceConfig.PermissionsStartOnly = true;
      serviceConfig.RemainAfterExit = true;
      serviceConfig.Slice = "system-hydra.slice";
      serviceConfig.Type = "oneshot";
      serviceConfig.User = "hydra";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.hydra-notify = {
      after = [ "hydra-init.service" ];

      environment = env // {
        HYDRA_DBI = "${env.HYDRA_DBI};application_name=hydra-notify";
        PGPASSFILE = "${baseDir}/pgpass-queue-runner";
      };

      path = [ pkgs.zstd ];
      requires = [ "hydra-init.service" ];
      restartTriggers = [ hydraConf ];

      serviceConfig = {
        ExecStart = "@${hydra-package}/bin/hydra-notify hydra-notify";
        Restart = "always";
        RestartSec = 5;
        Slice = "system-hydra.slice";
        # FIXME: run this under a less privileged user?
        User = "hydra-queue-runner";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.hydra-queue-runner = {
      after = [
        "hydra-init.service"
        "network.target"
      ];

      environment = env // {
        HYDRA_DBI = "${env.HYDRA_DBI};application_name=hydra-queue-runner";
        IN_SYSTEMD = "1"; # to get log severity levels
        PGPASSFILE = "${baseDir}/pgpass-queue-runner"; # grrr
      };

      path = [
        config.nix.package
        hydra-package
        pkgs.bzip2
        pkgs.hostname-debian
        pkgs.openssh
      ];

      requires = [ "hydra-init.service" ];
      restartTriggers = [ hydraConf ];

      serviceConfig = {
        ExecStart = "@${hydra-package}/bin/hydra-queue-runner hydra-queue-runner -v";
        ExecStopPost = "${hydra-package}/bin/hydra-queue-runner --unlock";
        # Ensure we can get core dumps.
        LimitCORE = "infinity";
        Restart = "always";
        Slice = "system-hydra.slice";
        User = "hydra-queue-runner";
        WorkingDirectory = "${baseDir}/queue-runner";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.hydra-send-stats = {
      after = [ "hydra-init.service" ];

      environment = env // {
        HYDRA_DBI = "${env.HYDRA_DBI};application_name=hydra-send-stats";
      };

      serviceConfig = {
        ExecStart = "@${hydra-package}/bin/hydra-send-stats hydra-send-stats";
        Slice = "system-hydra.slice";
        User = "hydra";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.hydra-server = {
      after = [ "hydra-init.service" ];

      environment = serverEnv // {
        HYDRA_DBI = "${serverEnv.HYDRA_DBI};application_name=hydra-server";
      };

      requires = [ "hydra-init.service" ];
      restartTriggers = [ hydraConf ];

      serviceConfig = {
        ExecStart =
          "@${hydra-package}/bin/hydra-server hydra-server -f -h '${cfg.listenHost}' "
          + "-p ${toString cfg.port} --min_spare_servers ${toString cfg.minSpareServers} --max_spare_servers ${toString cfg.maxSpareServers} "
          + "--max_servers ${toString cfg.maxServers} --max_requests 100 ${lib.optionalString cfg.debugServer "-d"}";

        PermissionsStartOnly = true;
        Restart = "always";
        Slice = "system-hydra.slice";
        User = "hydra-www";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.hydra-update-gc-roots = {
      after = [ "hydra-init.service" ];

      environment = env // {
        HYDRA_DBI = "${env.HYDRA_DBI};application_name=hydra-update-gc-roots";
      };

      requires = [ "hydra-init.service" ];

      serviceConfig = {
        ExecStart = "@${hydra-package}/bin/hydra-update-gc-roots hydra-update-gc-roots";
        Slice = "system-hydra.slice";
        User = "hydra";
      };

      startAt = "2,14:15";
    };

    systemd.slices.system-hydra = {
      description = "Hydra CI Server Slice";

      documentation = [
        "file://${cfg.package}/share/doc/hydra/index.html"
        "https://nixos.org/hydra/manual/"
      ];
    };

    users.groups.hydra = {
      gid = config.ids.gids.hydra;
    };

    users.users.hydra = {
      description = "Hydra";
      group = "hydra";
      # We don't enable `createHome` here because the creation of the home directory is handled by the hydra-init service below.
      home = baseDir;
      uid = config.ids.uids.hydra;
      useDefaultShell = true;
    };

    users.users.hydra-queue-runner = {
      description = "Hydra queue runner";
      group = "hydra";
      home = "${baseDir}/queue-runner"; # really only to keep SSH happy
      uid = config.ids.uids.hydra-queue-runner;
      useDefaultShell = true;
    };

    users.users.hydra-www = {
      description = "Hydra web server";
      group = "hydra";
      uid = config.ids.uids.hydra-www;
      useDefaultShell = true;
    };

  };

}
