{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.gocd-agent;
  opt = options.services.gocd-agent;
in
{
  options = {
    services.gocd-agent = {
      enable = lib.mkEnableOption "gocd-agent";

      agentConfig = lib.mkOption {
        default = "";

        description = ''
          Agent registration configuration.
        '';

        example = ''
          agent.auto.register.resources=ant,java
          agent.auto.register.environments=QA,Performance
          agent.auto.register.hostname=Agent01
        '';

        type = lib.types.str;
      };

      environment = lib.mkOption {
        default = { };

        description = ''
          Additional environment variables to be passed to the Go.CD agent process.
          As a base environment, Go.CD agent receives NIX_PATH from
          {option}`environment.sessionVariables`, NIX_REMOTE is set to
          "daemon".
        '';

        type = with lib.types; attrsOf str;
      };

      extraGroups = lib.mkOption {
        default = [ ];

        description = ''
          List of extra groups that the "gocd-agent" user should be a part of.
        '';

        example = [
          "wheel"
          "docker"
        ];

        type = lib.types.listOf lib.types.str;
      };

      extraOptions = lib.mkOption {
        default = [ ];

        description = ''
          Specifies additional command line arguments to pass to Go.CD agent
          java process.  Example contains debug and gcLog arguments.
        '';

        example = [
          "-X debug"
          "-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5006"
          "-verbose:gc"
          "-Xloggc:go-agent-gc.log"
          "-XX:+PrintGCTimeStamps"
          "-XX:+PrintTenuringDistribution"
          "-XX:+PrintGCDetails"
          "-XX:+PrintGC"
        ];

        type = lib.types.listOf lib.types.str;
      };

      goServer = lib.mkOption {
        default = "https://127.0.0.1:8154/go";

        description = ''
          URL of the GoCD Server to attach the Go.CD Agent to.
        '';

        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "gocd-agent";

        description = ''
          If the default user "gocd-agent" is configured then this is the primary
          group of that user.
        '';

        type = lib.types.str;
      };

      initialJavaHeapSize = lib.mkOption {
        default = "128m";

        description = ''
          Specifies the initial java heap memory size for the Go.CD agent java process.
        '';

        type = lib.types.str;
      };

      maxJavaHeapMemory = lib.mkOption {
        default = "256m";

        description = ''
          Specifies the java maximum heap memory size for the Go.CD agent java process.
        '';

        type = lib.types.str;
      };

      packages = lib.mkOption {
        default = [
          pkgs.stdenv
          pkgs.jre
          pkgs.git
          config.programs.ssh.package
          pkgs.nix
        ];

        defaultText = lib.literalExpression "[ pkgs.stdenv pkgs.jre pkgs.git config.programs.ssh.package pkgs.nix ]";

        description = ''
          Packages to add to PATH for the Go.CD agent process.
        '';

        type = lib.types.listOf lib.types.package;
      };

      startupOptions = lib.mkOption {
        default = [
          "-Xms${cfg.initialJavaHeapSize}"
          "-Xmx${cfg.maxJavaHeapMemory}"
          "-Djava.io.tmpdir=/tmp"
          "-Dcruise.console.publish.interval=10"
          "-Djava.security.egd=file:/dev/./urandom"
        ];

        defaultText = lib.literalExpression ''
          [
            "-Xms''${config.${opt.initialJavaHeapSize}}"
            "-Xmx''${config.${opt.maxJavaHeapMemory}}"
            "-Djava.io.tmpdir=/tmp"
            "-Dcruise.console.publish.interval=10"
            "-Djava.security.egd=file:/dev/./urandom"
          ]
        '';

        description = ''
          Specifies startup command line arguments to pass to Go.CD agent
          java process.
        '';

        type = lib.types.listOf lib.types.str;
      };

      user = lib.mkOption {
        default = "gocd-agent";

        description = ''
          User the Go.CD agent should execute under.
        '';

        type = lib.types.str;
      };

      workDir = lib.mkOption {
        default = "/var/lib/go-agent";

        description = ''
          Specifies the working directory in which the Go.CD agent java archive resides.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.gocd-agent = {
      after = [ "network.target" ];
      description = "GoCD Agent";

      environment =
        let
          selectedSessionVars = lib.filterAttrs (
            n: v: builtins.elem n [ "NIX_PATH" ]
          ) config.environment.sessionVariables;
        in
        selectedSessionVars
        // {
          AGENT_STARTUP_ARGS = "${lib.concatStringsSep " " cfg.startupOptions}";
          AGENT_WORK_DIR = cfg.workDir;
          LOG_DIR = cfg.workDir;
          LOG_FILE = "${cfg.workDir}/go-agent-start.log";
          NIX_REMOTE = "daemon";
        }
        // cfg.environment;

      path = cfg.packages;

      script = ''
        MPATH="''${PATH}";
        source /etc/profile
        export PATH="''${MPATH}:''${PATH}";

        if ! test -f ~/.nixpkgs/config.nix; then
          mkdir -p ~/.nixpkgs/
          echo "{ allowUnfree = true; }" > ~/.nixpkgs/config.nix
        fi

        mkdir -p config
        rm -f config/autoregister.properties
        ln -s "${pkgs.writeText "autoregister.properties" cfg.agentConfig}" config/autoregister.properties

        ${pkgs.git}/bin/git config --global --add http.sslCAinfo ${config.security.pki.caBundle}
        ${pkgs.jre}/bin/java ${lib.concatStringsSep " " cfg.startupOptions} \
                        ${lib.concatStringsSep " " cfg.extraOptions} \
                              -jar ${pkgs.gocd-agent}/go-agent/lib/agent-bootstrapper.jar \
                              -serverUrl ${cfg.goServer}
      '';

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 30;
        User = cfg.user;
        WorkingDirectory = cfg.workDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "gocd-agent") {
      gocd-agent.gid = config.ids.gids.gocd-agent;
    };

    users.users = lib.optionalAttrs (cfg.user == "gocd-agent") {
      gocd-agent = {
        createHome = true;
        description = "gocd-agent user";
        extraGroups = cfg.extraGroups;
        group = cfg.group;
        home = cfg.workDir;
        uid = config.ids.uids.gocd-agent;
        useDefaultShell = true;
      };
    };
  };
}
