{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jenkins;
  jenkinsUrl = "http://${cfg.listenAddress}:${toString cfg.port}${cfg.prefix}";
in
{
  options = {
    services.jenkins = {
      enable = lib.mkEnableOption "Jenkins, a continuous integration server";
      package = lib.mkPackageOption pkgs "jenkins" { };

      environment = lib.mkOption {
        default = { };

        description = ''
          Additional environment variables to be passed to the jenkins process.
          As a base environment, jenkins receives NIX_PATH from
          {option}`environment.sessionVariables`, NIX_REMOTE is set to
          "daemon" and JENKINS_HOME is set to the value of
          {option}`services.jenkins.home`.
          This option has precedence and can be used to override those
          mentioned variables.
        '';

        type = with lib.types; attrsOf str;
      };

      extraGroups = lib.mkOption {
        default = [ ];

        description = ''
          List of extra groups that the "jenkins" user should be a part of.
        '';

        example = [
          "wheel"
          "dialout"
        ];

        type = lib.types.listOf lib.types.str;
      };

      extraJavaOptions = lib.mkOption {
        default = [ ];

        description = ''
          Additional command line arguments to pass to the Java run time (as opposed to Jenkins).
        '';

        example = [ "-Xmx80m" ];
        type = lib.types.listOf lib.types.str;
      };

      extraOptions = lib.mkOption {
        default = [ ];

        description = ''
          Additional command line arguments to pass to Jenkins.
        '';

        example = [ "--debug=9" ];
        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "jenkins";

        description = ''
          If the default user "jenkins" is configured then this is the primary
          group of that user.
        '';

        type = lib.types.str;
      };

      home = lib.mkOption {
        default = "/var/lib/jenkins";

        description = ''
          The path to use as JENKINS_HOME. If the default user "jenkins" is configured then
          this is the home of the "jenkins" user.
        '';

        type = lib.types.path;
      };

      javaPackage = lib.mkPackageOption pkgs "jdk25" { };

      listenAddress = lib.mkOption {
        default = "0.0.0.0";

        description = ''
          Specifies the bind address on which the jenkins HTTP interface listens.
          The default is the wildcard address.
        '';

        example = "localhost";
        type = lib.types.str;
      };

      packages = lib.mkOption {
        default = [ ];

        description = ''
          Packages to add to PATH for the jenkins process.
        '';

        example = lib.literalExpression ''
          [
            pkgs.stdenv
            pkgs.git
            pkgs.jdk25
            config.programs.ssh.package
            pkgs.nix
          ]
        '';

        type = lib.types.listOf lib.types.package;
      };

      plugins = lib.mkOption {
        default = null;

        description = ''
          A set of plugins to activate. Note that this will completely
          remove and replace any previously installed plugins. If you
          have manually-installed plugins that you want to keep while
          using this module, set this option to
          `null`. You can generate this set with a
          tool such as `jenkinsPlugins2nix`.
        '';

        example = lib.literalExpression ''
          import path/to/jenkinsPlugins2nix-generated-plugins.nix { inherit (pkgs) fetchurl stdenv; }
        '';

        type = lib.types.nullOr (lib.types.attrsOf lib.types.package);
      };

      port = lib.mkOption {
        default = 8080;

        description = ''
          Specifies port number on which the jenkins HTTP interface listens.
          The default is 8080.
        '';

        type = lib.types.port;
      };

      prefix = lib.mkOption {
        default = "";

        description = ''
          Specifies a urlPrefix to use with jenkins.
          If the example /jenkins is given, the jenkins server will be
          accessible using localhost:8080/jenkins.
        '';

        example = "/jenkins";
        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "jenkins";

        description = ''
          User the jenkins server should execute under.
        '';

        type = lib.types.str;
      };

      withCLI = lib.mkOption {
        default = false;

        description = ''
          Whether to make the CLI available.

          More info about the CLI available at
          [
          https://www.jenkins.io/doc/book/managing/cli](https://www.jenkins.io/doc/book/managing/cli) .
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # server references the dejavu fonts
      systemPackages = [
        pkgs.dejavu_fonts
      ]
      ++ lib.optional cfg.withCLI cfg.package;

      variables =
        { }
        // lib.optionalAttrs cfg.withCLI {
          # Make it more convenient to use the `jenkins-cli`.
          JENKINS_URL = jenkinsUrl;
        };
    };

    systemd.services.jenkins = {
      after = [ "network.target" ];
      description = "Jenkins Continuous Integration Server";

      environment =
        let
          selectedSessionVars = lib.filterAttrs (
            n: v: builtins.elem n [ "NIX_PATH" ]
          ) config.environment.sessionVariables;
        in
        selectedSessionVars
        // {
          JENKINS_HOME = cfg.home;
          NIX_REMOTE = "daemon";
        }
        // cfg.environment;

      path = cfg.packages;

      postStart = ''
        until [[ $(${pkgs.curl.bin}/bin/curl -L -s --head -w '\n%{http_code}' ${jenkinsUrl} | tail -n1) =~ ^(200|403)$ ]]; do
          sleep 1
        done
      '';

      # Force .war (re)extraction, or else we might run stale Jenkins.
      preStart =
        let
          replacePlugins = lib.optionalString (cfg.plugins != null) (
            let
              pluginCmds = lib.mapAttrsToList (n: v: "cp ${v} ${cfg.home}/plugins/${n}.jpi") cfg.plugins;
            in
            ''
              rm -r ${cfg.home}/plugins || true
              mkdir -p ${cfg.home}/plugins
              ${lib.concatStringsSep "\n" pluginCmds}
            ''
          );
        in
        ''
          rm -rf ${cfg.home}/war
          ${replacePlugins}
        '';

      # For reference: https://wiki.jenkins.io/display/JENKINS/JenkinsLinuxStartupScript
      script = ''
        ${cfg.javaPackage}/bin/java ${lib.concatStringsSep " " cfg.extraJavaOptions} -jar ${cfg.package}/webapps/jenkins.war --httpListenAddress=${cfg.listenAddress} \
                                                  --httpPort=${toString cfg.port} \
                                                  --prefix=${cfg.prefix} \
                                                  -Djava.awt.headless=true \
                                                  ${lib.concatStringsSep " " cfg.extraOptions}
      '';

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        Group = cfg.group;
        LockPersonality = true;
        # MemoryDenyWriteExecute = false;   Breaks execution;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        ReadWritePaths = [
          cfg.home
        ];

        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # For (possible) socket use
        RuntimeDirectory = "jenkins";
        RuntimeDirectoryMode = "750";
        StateDirectory = lib.mkIf (lib.hasPrefix "/var/lib/jenkins" cfg.home) "jenkins";
        StateDirectoryMode = "750";
        SystemCallArchitectures = "native";
        UMask = 27;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "jenkins") {
      jenkins.gid = config.ids.gids.jenkins;
    };

    users.users = lib.optionalAttrs (cfg.user == "jenkins") {
      jenkins = {
        createHome = true;
        description = "jenkins user";
        extraGroups = cfg.extraGroups;
        group = cfg.group;
        home = cfg.home;
        uid = config.ids.uids.jenkins;
        useDefaultShell = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    felixsinger
  ];
}
