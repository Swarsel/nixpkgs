{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    mkRemovedOptionModule
    types
    ;

  cfg = config.services.plantuml-server;

in

{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "plantuml-server"
      "allowPlantumlInclude"
    ] "This option has been removed from PlantUML.")
  ];

  options = {
    services.plantuml-server = {
      enable = mkEnableOption "PlantUML server";
      package = mkPackageOption pkgs "plantuml-server" { };
      graphvizPackage = mkPackageOption pkgs "graphviz" { };

      group = mkOption {
        default = "plantuml";
        description = "Group which runs PlantUML server.";
        type = types.str;
      };

      home = mkOption {
        default = "/var/lib/plantuml";
        description = "Home directory of the PlantUML server instance.";
        type = types.path;
      };

      httpAuthorization = mkOption {
        default = null;
        description = "When calling the proxy endpoint, the value of HTTP_AUTHORIZATION will be used to set the HTTP Authorization header.";
        type = types.nullOr types.str;
      };

      listenHost = mkOption {
        default = "127.0.0.1";
        description = "Host to listen on.";
        type = types.str;
      };

      listenPort = mkOption {
        default = 8080;
        description = "Port to listen on.";
        type = types.port;
      };

      packages = {
        jdk = mkPackageOption pkgs "jdk" { };

        jetty = mkPackageOption pkgs "jetty" {
          default = [ "jetty_12" ];
        };
      };

      plantumlLimitSize = mkOption {
        default = 4096;
        description = "Limits image width and height.";
        type = types.int;
      };

      plantumlStats = mkOption {
        default = false;
        description = "Set it to on to enable statistics report (https://plantuml.com/statistics-report).";
        type = types.bool;
      };

      user = mkOption {
        default = "plantuml";
        description = "User which runs PlantUML server.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.plantuml-server = {
      description = "PlantUML server";

      environment = {
        GRAPHVIZ_DOT = "${cfg.graphvizPackage}/bin/dot";
        HTTP_AUTHORIZATION = cfg.httpAuthorization;
        PLANTUML_LIMIT_SIZE = toString cfg.plantumlLimitSize;
        PLANTUML_STATS = if cfg.plantumlStats then "on" else "off";
      };

      script = ''
        ${cfg.packages.jdk}/bin/java \
          -jar ${cfg.packages.jetty}/start.jar \
            --module=http,ee11-deploy,ee11-jsp \
            -Djetty.home=${cfg.packages.jetty} \
            -Djetty.base=${cfg.package} \
            -Djetty.http.host=${cfg.listenHost} \
            -Djetty.http.port=${toString cfg.listenPort}
      '';

      serviceConfig = {
        # Hardening
        AmbientCapabilities = [ "" ];
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;
        Group = cfg.group;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = false;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = mkIf (cfg.home == "/var/lib/plantuml") "plantuml";
        StateDirectoryMode = mkIf (cfg.home == "/var/lib/plantuml") "0750";
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    truh
    anthonyroussel
  ];
}
