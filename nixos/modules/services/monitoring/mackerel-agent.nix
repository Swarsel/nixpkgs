{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mackerel-agent;
  settingsFmt = pkgs.formats.toml { };
in
{
  options.services.mackerel-agent = {
    enable = lib.mkEnableOption "mackerel.io agent";

    apiKeyFile = lib.mkOption {
      description = ''
        Path to file containing the Mackerel API key. The file should contain a
        single line of the following form:

        `apikey = "EXAMPLE_API_KEY"`
      '';

      example = "/run/keys/mackerel-api-key";
      type = lib.types.path;
    };

    autoRetirement = lib.mkEnableOption ''
      retiring the host upon OS shutdown
    '';

    # the upstream package runs as root, but doesn't seem to be strictly
    # necessary for basic functionality
    runAsRoot = lib.mkEnableOption "running as root";

    settings = lib.mkOption {
      default = { };

      description = ''
        Options for mackerel-agent.conf.

        Documentation:
        <https://mackerel.io/docs/entry/spec/agent>
      '';

      example = {
        silent = false;
        verbose = false;
      };

      type = lib.types.submodule {
        options.diagnostic = lib.mkEnableOption "collecting memory usage for the agent itself";

        options.host_status = {
          on_start = lib.mkOption {
            default = "working";
            description = "Host status after agent startup.";

            type = lib.types.enum [
              "working"
              "standby"
              "maintenance"
              "poweroff"
            ];
          };

          on_stop = lib.mkOption {
            default = "poweroff";
            description = "Host status after agent shutdown.";

            type = lib.types.enum [
              "working"
              "standby"
              "maintenance"
              "poweroff"
            ];
          };
        };

        freeformType = settingsFmt.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "mackerel-agent/conf.d/api-key.conf".source = cfg.apiKeyFile;

      "mackerel-agent/mackerel-agent.conf".source =
        settingsFmt.generate "mackerel-agent.conf" cfg.settings;
    };

    environment.systemPackages = with pkgs; [ mackerel-agent ];

    services.mackerel-agent.settings = {
      # conf.d stores the symlink to cfg.apiKeyFile
      include = lib.mkDefault "/etc/mackerel-agent/conf.d/*.conf";
      pidfile = lib.mkDefault "/run/mackerel-agent/mackerel-agent.pid";
      root = lib.mkDefault "/var/lib/mackerel-agent";
    };

    # upstream service file in https://github.com/mackerelio/mackerel-agent/blob/master/packaging/rpm/src/mackerel-agent.service
    systemd.services.mackerel-agent = {
      after = [
        "network-online.target"
        "nss-lookup.target"
      ];

      description = "mackerel.io agent";

      environment = {
        MACKEREL_PLUGIN_WORKDIR = lib.mkDefault "%C/mackerel-agent";
      };

      restartTriggers = [
        config.environment.etc."mackerel-agent/mackerel-agent.conf".source
      ];

      serviceConfig = {
        CacheDirectory = "mackerel-agent";
        ConfigurationDirectory = "mackerel-agent";
        DynamicUser = !cfg.runAsRoot;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.mackerel-agent}/bin/mackerel-agent supervise";
        ExecStopPost = lib.mkIf cfg.autoRetirement "${pkgs.mackerel-agent}/bin/mackerel-agent retire -force";
        LimitNOFILE = lib.mkDefault 65536;
        LimitNPROC = lib.mkDefault 65536;
        PrivateTmp = lib.mkDefault true;
        RuntimeDirectory = "mackerel-agent";
        StateDirectory = "mackerel-agent";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
