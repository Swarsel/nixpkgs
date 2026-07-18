# Systemd services for docker.

{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let

  cfg = config.virtualisation.docker;
  proxy_env = config.networking.proxy.envVars;
  settingsFormat = pkgs.formats.json { };
  daemonSettingsFile = settingsFormat.generate "daemon.json" cfg.daemon.settings;
in

{
  imports = [
    (mkRemovedOptionModule [
      "virtualisation"
      "docker"
      "socketActivation"
    ] "This option was removed and socket activation is now always active")
    (mkAliasOptionModule
      [ "virtualisation" "docker" "liveRestore" ]
      [ "virtualisation" "docker" "daemon" "settings" "live-restore" ]
    )
  ];

  ###### interface
  options.virtualisation.docker = {
    enable = mkOption {
      default = false;

      description = ''
        This option enables docker, a daemon that manages
        linux containers. Users in the "docker" group can interact with
        the daemon (e.g. to start or stop containers) using the
        {command}`docker` command line tool.
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "docker" { };

    autoPrune = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to periodically prune Docker resources. If enabled, a
          systemd timer will run `docker system prune -f`
          as specified by the `dates` option.

          NOTE: by default this does not prune volumes. Anonymous volumes
          can be pruned by passing "--volumes" to [autoPrune.flags](#opt-virtualisation.docker.autoPrune.flags).

          To prune all volumes (not just anonymous ones) [`autoPrune.allVolumes.enable`](#opt-virtualisation.docker.autoPrune.allVolumes.enable)
          must be used.

          See [upstream documentation](https://docs.docker.com/reference/cli/docker/system/prune/#description) for further information.
        '';

        type = types.bool;
      };

      allVolumes = {
        enable = mkOption {
          default = false;

          description = ''
            Whether to periodically prune all Docker volumes when auto pruning other docker resources
            by running {command}`docker volume prune --force --all`

            To prune only anonymous volumes, instead pass `--volumes` to `autoPrune.flags`
          '';

          type = types.bool;
        };

        flags = mkOption {
          default = [ ];

          description = ''
            Any additional flags passed to {command}`docker volume prune --force --all`.
          '';

          example = [ "--filter=label=<label>" ];
          type = types.listOf types.str;
        };
      };

      dates = mkOption {
        default = "weekly";

        description = ''
          Specification (in the format described by
          {manpage}`systemd.time(7)`) of the time at
          which the prune will occur.
        '';

        type = types.str;
      };

      flags = mkOption {
        default = [ ];

        description = ''
          Any additional flags passed to {command}`docker system prune`.
        '';

        example = [ "--all" ];
        type = types.listOf types.str;
      };

      persistent = mkOption {
        default = true;

        description = ''
          Takes a boolean argument. If true, the time when the service
          unit was last triggered is stored on disk. When the timer is
          activated, the service unit is triggered immediately if it
          would have been triggered at least once during the time when
          the timer was inactive. Such triggering is nonetheless
          subject to the delay imposed by RandomizedDelaySec=. This is
          useful to catch up on missed runs of the service when the
          system was powered down.
        '';

        example = false;
        type = types.bool;
      };

      randomizedDelaySec = mkOption {
        default = "0";

        description = ''
          Add a randomized delay before each auto prune.
          The delay will be chosen between zero and this value.
          This value must be a time span in the format specified by
          {manpage}`systemd.time(7)`
        '';

        example = "45min";
        type = types.singleLineStr;
      };
    };

    daemon.settings = mkOption {
      default = { };

      description = ''
        Configuration for docker daemon. The attributes are serialized to JSON used as daemon.conf.
        See <https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file>
      '';

      example = {
        "fixed-cidr-v6" = "fd00::/80";
        ipv6 = true;
        "live-restore" = true;
      };

      type = types.submodule {
        options = {
          live-restore = mkOption {
            # Prior to NixOS 24.11, this was set to true by default, while upstream defaulted to false.
            # Keep the option unset to follow upstream defaults
            default = versionOlder config.system.stateVersion "24.11";
            defaultText = literalExpression "lib.versionOlder config.system.stateVersion \"24.11\"";

            description = ''
              Allow dockerd to be restarted without affecting running container.
              This option is incompatible with docker swarm.
            '';

            type = types.bool;
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    enableNvidia = mkOption {
      default = false;

      description = ''
        **Deprecated**, please use {option}`hardware.nvidia-container-toolkit.enable` instead.

        Enable Nvidia GPU support inside docker containers.
      '';

      type = types.bool;
    };

    enableOnBoot = mkOption {
      default = true;

      description = ''
        When enabled dockerd is started on boot. This is required for
        containers which are created with the
        `--restart=always` flag to work. If this option is
        disabled, docker might be started on demand by socket activation.
      '';

      type = types.bool;
    };

    extraOptions = mkOption {
      default = "";

      description = ''
        The extra command-line options to pass to
        {command}`docker` daemon.
      '';

      type = types.separatedString " ";
    };

    extraPackages = mkOption {
      default = [ ];

      description = ''
        Extra packages to add to PATH for the docker daemon process.
      '';

      example = literalExpression "with pkgs; [ criu ]";
      type = types.listOf types.package;
    };

    listenOptions = mkOption {
      default = [ "/run/docker.sock" ];

      description = ''
        A list of unix and tcp docker should listen to. The format follows
        ListenStream as described in {manpage}`systemd.socket(5)`.
      '';

      type = types.listOf types.str;
    };

    logDriver = mkOption {
      default = "journald";

      description = ''
        This option determines which Docker log driver to use.
      '';

      type = types.enum [
        "none"
        "json-file"
        "syslog"
        "journald"
        "gelf"
        "fluentd"
        "awslogs"
        "splunk"
        "etwlogs"
        "gcplogs"
        "local"
      ];
    };

    storageDriver = mkOption {
      default = null;

      description = ''
        This option determines which Docker
        [storage driver](https://docs.docker.com/storage/storagedriver/select-storage-driver/)
        to use.
        By default it lets docker automatically choose the preferred storage
        driver.
        However, it is recommended to specify a storage driver explicitly, as
        docker's default varies over versions.

        ::: {.warning}
        Changing the storage driver will cause any existing containers
        and images to become inaccessible.
        :::
      '';

      type = types.nullOr (
        types.enum [
          "aufs"
          "btrfs"
          "devicemapper"
          "overlay"
          "overlay2"
          "zfs"
        ]
      );
    };
  };

  ###### implementation
  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion =
            cfg.enableNvidia && pkgs.stdenv.hostPlatform.isx86_64
            -> config.hardware.graphics.enable32Bit or false;

          message = "Option enableNvidia on x86_64 requires 32-bit support libraries";
        }
        {
          assertion = cfg.autoPrune.allVolumes.enable -> cfg.autoPrune.enable;
          message = "Option autoPrune.allVolumes.enable requires autoPrune.enable";
        }
      ];

      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = mkOverride 98 true;
        "net.ipv4.conf.default.forwarding" = mkOverride 98 true;
      };

      boot.kernelModules = [
        "bridge"
        "veth"
        "br_netfilter"
        "xt_nat"
      ];

      environment.systemPackages = [ cfg.package ];
      systemd.packages = [ cfg.package ];

      systemd.services.docker = {
        after = [
          "network.target"
          "docker.socket"
        ];

        environment = proxy_env;

        path = [
          pkgs.kmod
        ]
        ++ optional (cfg.storageDriver == "zfs") config.boot.zfs.package
        ++ cfg.extraPackages;

        requires = [ "docker.socket" ];

        serviceConfig = {
          ExecReload = [
            ""
            "${pkgs.procps}/bin/kill -s HUP $MAINPID"
          ];

          ExecStart = [
            ""
            ''
              ${cfg.package}/bin/dockerd \
                --config-file=${daemonSettingsFile} \
                ${cfg.extraOptions}
            ''
          ];

          Type = "notify";
        };

        wantedBy = optional cfg.enableOnBoot "multi-user.target";
      };

      systemd.services.docker-prune = {
        after = [ "docker.service" ];
        description = "Prune docker resources";
        requires = [ "docker.service" ];
        restartIfChanged = false;

        serviceConfig = {
          ExecStart = [
            (utils.escapeSystemdExecArgs (
              [
                (lib.getExe cfg.package)
                "system"
                "prune"
                "-f"
              ]
              ++ cfg.autoPrune.flags
            ))
          ]
          ++ (optionals cfg.autoPrune.allVolumes.enable [
            (utils.escapeSystemdExecArgs (
              [
                (lib.getExe cfg.package)
                "volume"
                "prune"
                "--force"
                "--all"
              ]
              ++ cfg.autoPrune.allVolumes.flags
            ))
          ]);

          Type = "oneshot";
        };

        startAt = optional cfg.autoPrune.enable cfg.autoPrune.dates;
        unitConfig.X-StopOnRemoval = false;
      };

      systemd.sockets.docker = {
        description = "Docker Socket for the API";

        socketConfig = {
          ListenStream = cfg.listenOptions;
          SocketGroup = "docker";
          SocketMode = "0660";
          SocketUser = "root";
        };

        wantedBy = [ "sockets.target" ];
      };

      systemd.timers.docker-prune = mkIf cfg.autoPrune.enable {
        timerConfig = {
          Persistent = cfg.autoPrune.persistent;
          RandomizedDelaySec = cfg.autoPrune.randomizedDelaySec;
        };
      };

      users.groups.docker.gid = config.ids.gids.docker;

      virtualisation.docker.daemon.settings = {
        group = "docker";
        hosts = [ "fd://" ];
        log-driver = mkDefault cfg.logDriver;

        runtimes = mkIf cfg.enableNvidia {
          nvidia = {
            # Use the legacy nvidia-container-runtime wrapper to allow
            # the `--runtime=nvidia` approach to expose
            # GPU's. Starting with Docker > 25, CDI can be used
            # instead, removing the need for runtime wrappers.
            path = lib.getExe' (lib.getOutput "tools" config.hardware.nvidia-container-toolkit.package) "nvidia-container-runtime";
          };
        };

        storage-driver = mkIf (cfg.storageDriver != null) (mkDefault cfg.storageDriver);
      };

      # Docker 25.0.0 supports CDI by default
      # (https://docs.docker.com/engine/release-notes/25.0/#new). Encourage
      # moving to CDI as opposed to having deprecated runtime
      # wrappers.
      warnings =
        lib.optionals (cfg.enableNvidia && (lib.strings.versionAtLeast cfg.package.version "25"))
          [
            ''
              You have set virtualisation.docker.enableNvidia. This option is deprecated, please set hardware.nvidia-container-toolkit.enable instead.
            ''
          ];
    }
  ]);
}
