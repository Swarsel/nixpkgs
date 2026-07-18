{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let
  cfg = config.services.gocd-server;
  opt = options.services.gocd-server;
in
{
  options = {
    services.gocd-server = {
      enable = mkEnableOption "gocd-server";

      environment = mkOption {
        default = { };

        description = ''
          Additional environment variables to be passed to the gocd-server process.
          As a base environment, gocd-server receives NIX_PATH from
          {option}`environment.sessionVariables`, NIX_REMOTE is set to
          "daemon".
        '';

        type = with types; attrsOf str;
      };

      extraGroups = mkOption {
        default = [ ];

        description = ''
          List of extra groups that the "gocd-server" user should be a part of.
        '';

        example = [
          "wheel"
          "docker"
        ];

        type = types.listOf types.str;
      };

      extraOptions = mkOption {
        default = [ ];

        description = ''
          Specifies additional command line arguments to pass to Go.CD server's
          java process.  Example contains debug and gcLog arguments.
        '';

        example = [
          "-X debug"
          "-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
          "-verbose:gc"
          "-Xloggc:go-server-gc.log"
          "-XX:+PrintGCTimeStamps"
          "-XX:+PrintTenuringDistribution"
          "-XX:+PrintGCDetails"
          "-XX:+PrintGC"
        ];

        type = types.listOf types.str;
      };

      group = mkOption {
        default = "gocd-server";

        description = ''
          If the default user "gocd-server" is configured then this is the primary group of that user.
        '';

        type = types.str;
      };

      initialJavaHeapSize = mkOption {
        default = "512m";

        description = ''
          Specifies the initial java heap memory size for the Go.CD server's java process.
        '';

        type = types.str;
      };

      listenAddress = mkOption {
        default = "0.0.0.0";

        description = ''
          Specifies the bind address on which the Go.CD server HTTP interface listens.
        '';

        example = "localhost";
        type = types.str;
      };

      maxJavaHeapMemory = mkOption {
        default = "1024m";

        description = ''
          Specifies the java maximum heap memory size for the Go.CD server's java process.
        '';

        type = types.str;
      };

      packages = mkOption {
        default = [
          pkgs.stdenv
          pkgs.jre
          pkgs.git
          config.programs.ssh.package
          pkgs.nix
        ];

        defaultText = literalExpression "[ pkgs.stdenv pkgs.jre pkgs.git config.programs.ssh.package pkgs.nix ]";

        description = ''
          Packages to add to PATH for the Go.CD server's process.
        '';

        type = types.listOf types.package;
      };

      port = mkOption {
        default = 8153;

        description = ''
          Specifies port number on which the Go.CD server HTTP interface listens.
        '';

        type = types.port;
      };

      sslPort = mkOption {
        default = 8154;

        description = ''
          Specifies port number on which the Go.CD server HTTPS interface listens.
        '';

        type = types.port;
      };

      startupOptions = mkOption {
        default = [
          "-Xms${cfg.initialJavaHeapSize}"
          "-Xmx${cfg.maxJavaHeapMemory}"
          "-Dcruise.listen.host=${cfg.listenAddress}"
          "-Duser.language=en"
          "-Djruby.rack.request.size.threshold.bytes=30000000"
          "-Duser.country=US"
          "-Dcruise.config.dir=${cfg.workDir}/conf"
          "-Dcruise.config.file=${cfg.workDir}/conf/cruise-config.xml"
          "-Dcruise.server.port=${toString cfg.port}"
          "-Dcruise.server.ssl.port=${toString cfg.sslPort}"
          "--add-opens=java.base/java.lang=ALL-UNNAMED"
          "--add-opens=java.base/java.util=ALL-UNNAMED"
        ];

        defaultText = literalExpression ''
          [
            "-Xms''${config.${opt.initialJavaHeapSize}}"
            "-Xmx''${config.${opt.maxJavaHeapMemory}}"
            "-Dcruise.listen.host=''${config.${opt.listenAddress}}"
            "-Duser.language=en"
            "-Djruby.rack.request.size.threshold.bytes=30000000"
            "-Duser.country=US"
            "-Dcruise.config.dir=''${config.${opt.workDir}}/conf"
            "-Dcruise.config.file=''${config.${opt.workDir}}/conf/cruise-config.xml"
            "-Dcruise.server.port=''${toString config.${opt.port}}"
            "-Dcruise.server.ssl.port=''${toString config.${opt.sslPort}}"
            "--add-opens=java.base/java.lang=ALL-UNNAMED"
            "--add-opens=java.base/java.util=ALL-UNNAMED"
          ]
        '';

        description = ''
          Specifies startup command line arguments to pass to Go.CD server
          java process.
        '';

        type = types.listOf types.str;
      };

      user = mkOption {
        default = "gocd-server";

        description = ''
          User the Go.CD server should execute under.
        '';

        type = types.str;
      };

      workDir = mkOption {
        default = "/var/lib/go-server";

        description = ''
          Specifies the working directory in which the Go.CD server java archive resides.
        '';

        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gocd-server = {
      after = [ "network.target" ];
      description = "GoCD Server";

      environment =
        let
          selectedSessionVars = lib.filterAttrs (
            n: v: builtins.elem n [ "NIX_PATH" ]
          ) config.environment.sessionVariables;
        in
        selectedSessionVars
        // {
          NIX_REMOTE = "daemon";
        }
        // cfg.environment;

      path = cfg.packages;

      script = ''
        ${pkgs.git}/bin/git config --global --add http.sslCAinfo ${config.security.pki.caBundle}
        ${pkgs.jre}/bin/java -server ${concatStringsSep " " cfg.startupOptions} \
                               ${concatStringsSep " " cfg.extraOptions}  \
                              -jar ${pkgs.gocd-server}/go-server/lib/go.jar
      '';

      serviceConfig = {
        Group = cfg.group;
        User = cfg.user;
        WorkingDirectory = cfg.workDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = optionalAttrs (cfg.group == "gocd-server") {
      gocd-server.gid = config.ids.gids.gocd-server;
    };

    users.users = optionalAttrs (cfg.user == "gocd-server") {
      gocd-server = {
        createHome = true;
        description = "gocd-server user";
        extraGroups = cfg.extraGroups;
        group = cfg.group;
        home = cfg.workDir;
        uid = config.ids.uids.gocd-server;
        useDefaultShell = true;
      };
    };
  };
}
