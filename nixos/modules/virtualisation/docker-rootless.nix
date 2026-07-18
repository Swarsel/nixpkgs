{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.virtualisation.docker.rootless;
  proxy_env = config.networking.proxy.envVars;
  settingsFormat = pkgs.formats.json { };
  daemonSettingsFile = settingsFormat.generate "daemon.json" cfg.daemon.settings;

in

{
  ###### interface

  options.virtualisation.docker.rootless = {
    enable = lib.mkOption {
      default = false;

      description = ''
        This option enables docker in a rootless mode, a daemon that manages
        linux containers. To interact with the daemon, one needs to set
        {command}`DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock`.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "docker" { };

    daemon.settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for docker daemon. The attributes are serialized to JSON used as daemon.conf.
        See <https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file>
      '';

      example = {
        "fixed-cidr-v6" = "fd00::/80";
        ipv6 = true;
      };

      type = settingsFormat.type;
    };

    extraPackages = lib.mkOption {
      default = [ ];

      description = ''
        Extra packages to add to PATH for the docker daemon process.
      '';

      type = lib.types.listOf lib.types.package;
    };

    setSocketVariable = lib.mkOption {
      default = false;

      description = ''
        Point {command}`DOCKER_HOST` to rootless Docker instance for
        normal users by default.
      '';

      type = lib.types.bool;
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.extraInit = lib.optionalString cfg.setSocketVariable ''
      if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
        export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
      fi
    '';

    environment.systemPackages = [ cfg.package ];

    # Taken from https://github.com/moby/moby/blob/master/contrib/dockerd-rootless-setuptool.sh
    systemd.user.services.docker = {
      description = "Docker Application Container Engine (Rootless)";
      environment = proxy_env;
      # needs newuidmap from pkgs.shadow
      path = [ "/run/wrappers" ] ++ cfg.extraPackages;

      serviceConfig = {
        Delegate = true;
        ExecReload = "${pkgs.procps}/bin/kill -s HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/dockerd-rootless --config-file=${daemonSettingsFile}";
        KillMode = "mixed";
        LimitCORE = "infinity";
        LimitNOFILE = "infinity";
        LimitNPROC = "infinity";
        NotifyAccess = "all";
        Restart = "always";
        RestartSec = 2;
        TimeoutSec = 0;
        Type = "notify";
      };

      unitConfig = {
        # docker-rootless doesn't support running as root.
        ConditionUser = "!root";
        StartLimitInterval = "60s";
      };

      unitConfig = {
        StartLimitBurst = 3;
      };

      wantedBy = [ "default.target" ];
    };
  };

}
