{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.netdata;

  wrappedPlugins = pkgs.runCommand "wrapped-plugins" { preferLocalBuild = true; } ''
    mkdir -p $out/libexec/netdata/plugins.d
    ln -s /run/wrappers/bin/apps.plugin $out/libexec/netdata/plugins.d/apps.plugin
    ln -s /run/wrappers/bin/cgroup-network $out/libexec/netdata/plugins.d/cgroup-network
    ln -s /run/wrappers/bin/debugfs.plugin $out/libexec/netdata/plugins.d/debugfs.plugin
    ln -s /run/wrappers/bin/freeipmi.plugin $out/libexec/netdata/plugins.d/freeipmi.plugin
    ln -s /run/wrappers/bin/logs-management.plugin $out/libexec/netdata/plugins.d/logs-management.plugin
    ln -s /run/wrappers/bin/network-viewer.plugin $out/libexec/netdata/plugins.d/network-viewer.plugin
    ln -s /run/wrappers/bin/otel-plugin $out/libexec/netdata/plugins.d/otel-plugin
    ln -s /run/wrappers/bin/perf.plugin $out/libexec/netdata/plugins.d/perf.plugin
    ln -s /run/wrappers/bin/slabinfo.plugin $out/libexec/netdata/plugins.d/slabinfo.plugin
    ln -s /run/wrappers/bin/systemd-journal.plugin $out/libexec/netdata/plugins.d/systemd-journal.plugin
  '';

  plugins = [
    "${cfg.package}/libexec/netdata/plugins.d"
    "${wrappedPlugins}/libexec/netdata/plugins.d"
  ]
  ++ cfg.extraPluginPaths;

  configDirectory = pkgs.runCommand "netdata-config-d" { } ''
    mkdir $out
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (path: file: ''
        mkdir -p "$out/$(dirname ${path})"
        ${if path == "apps_groups.conf" then "cp" else "ln -s"} "${file}" "$out/${path}"
      '') cfg.configDir
    )}
  '';

  localConfig = {
    global = {
      "config directory" = "/etc/netdata/conf.d";
      "plugins directory" = lib.concatStringsSep " " plugins;
    };

    "plugin:cgroups" = {
      "script to get cgroup network interfaces" =
        "${wrappedPlugins}/libexec/netdata/plugins.d/cgroup-network";

      "use unified cgroups" = "yes";
    };

    web = {
      "web files group" = "root";
      "web files owner" = "root";
    };
  };
  mkConfig = lib.generators.toINI { } (lib.recursiveUpdate localConfig cfg.config);
  configFile = pkgs.writeText "netdata.conf" (
    if cfg.configText != null then cfg.configText else mkConfig
  );

  defaultUser = "netdata";

  isThereAnyWireGuardTunnels =
    config.networking.wireguard.enable
    || lib.any (
      c: lib.hasAttrByPath [ "netdevConfig" "Kind" ] c && c.netdevConfig.Kind == "wireguard"
    ) (builtins.attrValues config.systemd.network.netdevs);

  extraNdsudoPathsEnv = pkgs.buildEnv {
    name = "netdata-ndsudo-env";
    paths = cfg.extraNdsudoPackages;
    pathsToLink = [ "/bin" ];
  };

in
{
  options = {
    services.netdata = {
      config = lib.mkOption {
        default = { };
        description = "netdata.conf configuration as nix attributes. cannot be combined with configText.";

        example = lib.literalExpression ''
          global = {
            "debug log" = "syslog";
            "access log" = "syslog";
            "error log" = "syslog";
          };
        '';

        type = lib.types.attrsOf lib.types.attrs;
      };

      enable = lib.mkEnableOption "netdata";
      package = lib.mkPackageOption pkgs "netdata" { };

      claimTokenFile = lib.mkOption {
        default = null;

        description = ''
          If set, automatically registers the agent using the given claim token
          file.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      configDir = lib.mkOption {
        default = { };

        description = ''
          Complete netdata config directory except netdata.conf.
          The default configuration is merged with changes
          defined in this option.
          Each top-level attribute denotes a path in the configuration
          directory as in environment.etc.
          Its value is the absolute path and must be readable by netdata.
          Cannot be combined with configText.
        '';

        example = lib.literalExpression ''
          "health_alarm_notify.conf" = pkgs.writeText "health_alarm_notify.conf" '''
            sendmail="/path/to/sendmail"
          ''';
          "health.d" = "/run/secrets/netdata/health.d";
        '';

        type = lib.types.attrsOf lib.types.path;
      };

      configText = lib.mkOption {
        default = null;
        description = "Verbatim netdata.conf, cannot be combined with config.";

        example = ''
          [global]
          debug log = syslog
          access log = syslog
          error log = syslog
        '';

        type = lib.types.nullOr lib.types.lines;
      };

      deadlineBeforeStopSec = lib.mkOption {
        default = 120;

        description = ''
          In order to detect when netdata is misbehaving, we run a concurrent task pinging netdata (wait-for-netdata-up)
          in the systemd unit.

          If after a while, this task does not succeed, we stop the unit and mark it as failed.

          You can control this deadline in seconds with this option, it's useful to bump it
          if you have (1) a lot of data (2) doing upgrades (3) have low IOPS/throughput.
        '';

        type = lib.types.int;
      };

      enableAnalyticsReporting = lib.mkOption {
        default = false;

        description = ''
          Enable reporting of anonymous usage statistics to Netdata Inc. via either
          Google Analytics (in versions prior to 1.29.4), or Netdata Inc.'s
          self-hosted PostHog (in versions 1.29.4 and later).
          See: <https://learn.netdata.cloud/docs/agent/anonymous-statistics>
        '';

        type = lib.types.bool;
      };

      extraNdsudoPackages = lib.mkOption {
        default = [ ];

        description = ''
          Extra packages to add to `PATH` to make available to `ndsudo`.
          ::: {.warning}
          `ndsudo` has SUID privileges, be careful what packages you list here.
          :::

          ::: {.note}
          `cfg.package` must be built with `withNdsudo = true`
          :::
        '';

        example = ''
          [
            pkgs.smartmontools
            pkgs.nvme-cli
          ]
        '';

        type = lib.types.listOf lib.types.package;
      };

      extraPluginPaths = lib.mkOption {
        default = [ ];

        description = ''
          Extra paths to add to the netdata global "plugins directory"
          option.  Useful for when you want to include your own
          collection scripts.

          Details about writing a custom netdata plugin are available at:
          <https://docs.netdata.cloud/collectors/plugins.d/>

          Cannot be combined with configText.
        '';

        example = lib.literalExpression ''
          [ "/path/to/plugins.d" ]
        '';

        type = lib.types.listOf lib.types.path;
      };

      group = lib.mkOption {
        default = "netdata";
        description = "Group under which netdata runs.";
        type = lib.types.str;
      };

      python = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Whether to enable python-based plugins
          '';

          type = lib.types.bool;
        };

        extraPackages = lib.mkOption {
          default = ps: [ ];
          defaultText = lib.literalExpression "ps: []";

          description = ''
            Extra python packages available at runtime
            to enable additional python plugins.
          '';

          example = lib.literalExpression ''
            ps: [
              ps.psycopg2
              ps.docker
              ps.dnspython
            ]
          '';

          type = lib.types.functionTo (lib.types.listOf lib.types.package);
        };

        recommendedPythonPackages = lib.mkOption {
          default = false;

          description = ''
            Whether to enable a set of recommended Python plugins
            by installing extra Python packages.
          '';

          type = lib.types.bool;
        };
      };

      user = lib.mkOption {
        default = "netdata";
        description = "User account under which netdata runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.config != { } -> cfg.configText == null;
        message = "Cannot specify both config and configText";
      }
    ];

    environment.etc."netdata/conf.d".source = configDirectory;
    environment.etc."netdata/netdata.conf".source = configFile;

    security.pam.loginLimits = [
      {
        domain = "netdata";
        item = "nofile";
        type = "soft";
        value = "10000";
      }
      {
        domain = "netdata";
        item = "nofile";
        type = "hard";
        value = "30000";
      }
    ];

    security.wrappers = {
      "apps.plugin" = {
        capabilities = "cap_dac_read_search,cap_sys_ptrace+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/apps.plugin.org";
      };

      "cgroup-network" = {
        capabilities = "cap_setuid+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/cgroup-network.org";
      };

      "debugfs.plugin" = {
        capabilities = "cap_dac_read_search+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/debugfs.plugin.org";
      };

      "perf.plugin" = {
        capabilities = "cap_sys_admin+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/perf.plugin.org";
      };

      "slabinfo.plugin" = {
        capabilities = "cap_dac_override+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/slabinfo.plugin.org";
      };
    }
    // lib.optionalAttrs (cfg.package.withIpmi) {
      "freeipmi.plugin" = {
        capabilities = "cap_dac_override,cap_fowner,cap_sys_rawio+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/freeipmi.plugin.org";
      };
    }
    // lib.optionalAttrs (cfg.package.withNetworkViewer) {
      "network-viewer.plugin" = {
        capabilities = "cap_sys_admin,cap_dac_read_search,cap_sys_ptrace+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/network-viewer.plugin.org";
      };
    }
    // lib.optionalAttrs (cfg.package.withNdsudo) {
      "ndsudo" = {
        group = cfg.group;
        owner = "root";
        permissions = "u+rx,g+x,o-rwx";
        setuid = true;
        source = "${cfg.package}/libexec/netdata/plugins.d/ndsudo.org";
      };
    }
    // lib.optionalAttrs (cfg.package.withOtel) {
      "otel-plugin" = {
        group = cfg.group;
        owner = "root";
        permissions = "u+rx,g+x,o-rwx";
        setuid = true;
        source = "${cfg.package}/libexec/netdata/plugins.d/otel-plugin.org";
      };
    }
    // lib.optionalAttrs (cfg.package.withSystemdJournal) {
      "systemd-journal.plugin" = {
        capabilities = "cap_dac_read_search,cap_syslog+ep";
        group = cfg.group;
        owner = cfg.user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${cfg.package}/libexec/netdata/plugins.d/systemd-journal.plugin.org";
      };
    };

    services.netdata.configDir.".opt-out-from-anonymous-statistics" = lib.mkIf (
      !cfg.enableAnalyticsReporting
    ) (pkgs.writeText ".opt-out-from-anonymous-statistics" "");

    # Includes a set of recommended Python plugins in exchange of imperfect disk consumption.
    services.netdata.python.extraPackages = lib.mkIf cfg.python.recommendedPythonPackages (ps: [
      ps.requests
      ps.pandas
      ps.numpy
      ps.psycopg2
      ps.python-ldap
      ps.netdata-pandas
    ]);

    systemd.services.netdata = {
      after = [
        "network.target"
        "suid-sgid-wrappers.service"
      ];

      description = "Real time performance monitoring";

      environment = {
        NETDATA_PIPENAME = "/run/netdata/ipc";
        PYTHONPATH = "${cfg.package}/libexec/netdata/python.d/python_modules";
      }
      // lib.optionalAttrs (!cfg.enableAnalyticsReporting) {
        DO_NOT_TRACK = "1";
      };

      path =
        (with pkgs; [
          curl
          gawk
          iproute2
          which
          procps
          bash
          nvme-cli # for go.d
          iw # for charts.d
          apcupsd # for charts.d
          # TODO: firehol # for FireQoS -- this requires more NixOS module support.
          util-linux # provides logger command; required for syslog health alarms
        ])
        ++ lib.optional cfg.python.enable (pkgs.python3.withPackages cfg.python.extraPackages)
        ++ lib.optional config.virtualisation.libvirtd.enable config.virtualisation.libvirtd.package
        ++ lib.optional config.virtualisation.docker.enable config.virtualisation.docker.package
        ++ lib.optionals config.virtualisation.podman.enable [
          pkgs.jq
          config.virtualisation.podman.package
        ]
        ++ lib.optional config.boot.zfs.enabled config.boot.zfs.package;

      # No wrapper means no "useful" netdata.
      requires = [ "suid-sgid-wrappers.service" ];

      restartTriggers = [
        config.environment.etc."netdata/netdata.conf".source
        config.environment.etc."netdata/conf.d".source
      ];

      serviceConfig = {
        # AmbientCapabilities
        AmbientCapabilities = lib.optional isThereAnyWireGuardTunnels "CAP_NET_ADMIN";
        # Cache directory and mode
        CacheDirectory = "netdata";
        CacheDirectoryMode = "0750";

        # Capabilities
        CapabilityBoundingSet = [
          "CAP_DAC_OVERRIDE" # is required for freeipmi and slabinfo plugins
          "CAP_DAC_READ_SEARCH" # is required for apps and systemd-journal plugin
          "CAP_NET_RAW" # is required for fping app
          "CAP_PERFMON" # is required for perf plugin
          "CAP_SETPCAP" # is required for apps, perf and slabinfo plugins
          "CAP_SETUID" # is required for cgroups and cgroups-network plugins
          "CAP_SYSLOG" # is required for systemd-journal plugin
          "CAP_SYS_ADMIN" # is required for perf plugin
          "CAP_SYS_CHROOT" # is required for cgroups plugin
          "CAP_SYS_PTRACE" # is required for apps plugin
          "CAP_SYS_RESOURCE" # is required for ebpf plugin
        ]
        ++ lib.optionals cfg.package.withIpmi [
          "CAP_FOWNER"
          "CAP_SYS_RAWIO"
        ]
        ++ lib.optional isThereAnyWireGuardTunnels "CAP_NET_ADMIN";

        # Configuration directory and mode
        ConfigurationDirectory = "netdata";
        ConfigurationDirectoryMode = "0755";
        ExecReload = "${pkgs.util-linux}/bin/kill -s HUP -s USR1 -s USR2 $MAINPID";
        ExecStart = "${cfg.package}/bin/netdata -P /run/netdata/netdata.pid -D -c /etc/netdata/netdata.conf";

        ExecStartPost = pkgs.writeShellScript "wait-for-netdata-up" ''
          while [ "$(${cfg.package}/bin/netdatacli ping)" != pong ]; do sleep 0.5; done
        '';

        Group = cfg.group;
        # Performance
        LimitNOFILE = "30000";
        # Logs directory and mode
        LogsDirectory = "netdata";
        LogsDirectoryMode = "0750";
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = "read-only";
        # Sandboxing
        ProtectSystem = "full";
        Restart = "on-failure";
        # Runtime directory and mode
        RuntimeDirectory = "netdata";
        RuntimeDirectoryMode = "0750";
        # State directory and mode
        StateDirectory = "netdata";
        StateDirectoryMode = "0750";
        TimeoutStopSec = cfg.deadlineBeforeStopSec;
        # User and group
        User = cfg.user;
      }
      // (lib.optionalAttrs (cfg.claimTokenFile != null) {
        ExecStartPre = pkgs.writeShellScript "netdata-claim" ''
          set -euo pipefail

          if [[ -f /var/lib/netdata/cloud.d/claimed_id ]]; then
            # Already registered
            exit
          fi

          exec ${cfg.package}/bin/netdata-claim.sh \
            -token="$(< "$CREDENTIALS_DIRECTORY/netdata_claim_token")" \
            -url=https://app.netdata.cloud \
            -daemon-not-running
        '';

        LoadCredential = [
          "netdata_claim_token:${cfg.claimTokenFile}"
        ];
      });

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings = lib.mkIf cfg.package.withNdsudo {
      "95-netdata-ndsudo" = {
        "/var/lib/netdata/ndsudo" = {
          "d" = {
            group = cfg.group;
            mode = "0550";
            user = cfg.user;
          };
        };

        "/var/lib/netdata/ndsudo/ndsudo" = {
          "L+" = {
            argument = "/run/wrappers/bin/ndsudo";
          };
        };

        "/var/lib/netdata/ndsudo/runtime-dependencies" = {
          "L+" = {
            argument = "${extraNdsudoPathsEnv}/bin";
          };
        };
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    users.users = lib.optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        extraGroups =
          lib.optional config.virtualisation.docker.enable "docker"
          ++ lib.optional config.virtualisation.podman.enable "podman";

        group = defaultUser;
        isSystemUser = true;
      };
    };

  };
}
