/*
  This file is for NixOS-specific options and configs.

  Code that is shared with nix-darwin goes in common.nix.
*/

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.services.hercules-ci-agent;

  command = "${cfg.package}/bin/hercules-ci-agent --config ${cfg.tomlFile}";
  testCommand = "${command} --test-configuration";

in
{
  imports = [
    ./common.nix
    (lib.mkRenamedOptionModule
      [ "services" "hercules-ci-agent" "user" ]
      [ "systemd" "services" "hercules-ci-agent" "serviceConfig" "User" ]
    )
  ];

  config = mkIf cfg.enable {
    # Trusted user allows simplified configuration and better performance
    # when operating in a cluster.
    nix.settings.trusted-users = [ config.systemd.services.hercules-ci-agent.serviceConfig.User ];

    services.hercules-ci-agent = {
      settings = {
        labels =
          let
            mkIfNotNull = x: mkIf (x != null) x;
          in
          {
            nixos.codeName = config.system.nixos.codeName;
            nixos.configurationRevision = mkIfNotNull config.system.configurationRevision;
            nixos.label = mkIfNotNull config.system.nixos.label;
            nixos.release = config.system.nixos.release;
            nixos.systemName = mkIfNotNull config.system.name;
            nixos.tags = config.system.nixos.tags;
          };

        nixUserIsTrusted = true;
      };
    };

    # Changes in the secrets do not affect the unit in any way that would cause
    # a restart, which is currently necessary to reload the secrets.
    systemd.paths.hercules-ci-agent-restart-files = {
      pathConfig = {
        PathChanged = [
          cfg.settings.clusterJoinTokenPath
          cfg.settings.binaryCachesPath
        ];

        Unit = "hercules-ci-agent-restarter.service";
      };

      wantedBy = [ "hercules-ci-agent.service" ];
    };

    systemd.services.hercules-ci-agent = {
      after = [ "network-online.target" ];
      path = [ config.nix.package ];

      serviceConfig = {
        ExecStart = command;
        ExecStartPre = testCommand;
        # Work around excessive stack use by libstdc++ regex
        # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=86164
        # A 256 MiB stack allows between 400 KiB and 1.5 MiB file to be matched by ".*".
        LimitSTACK = 256 * 1024 * 1024;
        # If a worker goes OOM, don't kill the main process. It needs to
        # report the failure and it's unlikely to be part of the problem.
        OOMPolicy = "continue";
        Restart = "on-failure";
        RestartSec = 120;
        User = "hercules-ci-agent";
      };

      startLimitBurst = 30 * 1000000; # practically infinite
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.services.hercules-ci-agent-restarter = {
      script = ''
        # Wait a bit, with the effect of bundling up file changes into a single
        # run of this script and hopefully a single restart.
        sleep 10
        if systemctl is-active --quiet hercules-ci-agent.service; then
          if ${testCommand}; then
            systemctl restart hercules-ci-agent.service
          else
            echo 1>&2 "WARNING: Not restarting agent because config is not valid at this time."
          fi
        else
          echo 1>&2 "Not restarting hercules-ci-agent despite config file update, because it is not already active."
        fi
      '';

      serviceConfig.Type = "oneshot";
    };

    users.groups.hercules-ci-agent = { };

    users.users.hercules-ci-agent = {
      createHome = true;
      description = "Hercules CI Agent system user";
      group = "hercules-ci-agent";
      home = cfg.settings.baseDirectory;
      isSystemUser = true;
    };
  };

  meta.maintainers = [ lib.maintainers.roberth ];
}
