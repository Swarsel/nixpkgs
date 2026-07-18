{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.traefik;

  format = pkgs.formats.toml { };

  dynamicConfigFile =
    if cfg.dynamicConfigFile == null then
      format.generate "config.toml" cfg.dynamicConfigOptions
    else
      cfg.dynamicConfigFile;

  staticConfigFile =
    if cfg.staticConfigFile == null then
      format.generate "config.toml" (
        recursiveUpdate cfg.staticConfigOptions {
          providers.file.filename = "${dynamicConfigFile}";
        }
      )
    else
      cfg.staticConfigFile;

  finalStaticConfigFile =
    if cfg.environmentFiles == [ ] then staticConfigFile else "/run/traefik/config.toml";
in
{
  options.services.traefik = {
    enable = mkEnableOption "Traefik web server";
    package = mkPackageOption pkgs "traefik" { };

    dataDir = mkOption {
      default = "/var/lib/traefik";

      description = ''
        Location for any persistent data traefik creates, ie. acme
      '';

      type = types.path;
    };

    dynamicConfigFile = mkOption {
      default = null;

      description = ''
        Path to traefik's dynamic configuration to use.
        (Using that option has precedence over `dynamicConfigOptions`)
      '';

      example = literalExpression "/path/to/dynamic_config.toml";
      type = types.nullOr types.path;
    };

    dynamicConfigOptions = mkOption {
      default = { };

      description = ''
        Dynamic configuration for Traefik.
      '';

      example = {
        http.routers.router1 = {
          rule = "Host(`localhost`)";
          service = "service1";
        };

        http.services.service1.loadBalancer.servers = [ { url = "http://localhost:8080"; } ];
      };

      type = format.type;
    };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        Files to load as environment file. Environment variables from this file
        will be substituted into the static configuration file using envsubst.
      '';

      example = [ "/run/secrets/traefik.env" ];
      type = types.listOf types.path;
    };

    group = mkOption {
      default = "traefik";

      description = ''
        Set the group that traefik runs under.
        For the docker backend this needs to be set to `docker` instead.
      '';

      example = "docker";
      type = types.str;
    };

    staticConfigFile = mkOption {
      default = null;

      description = ''
        Path to traefik's static configuration to use.
        (Using that option has precedence over `staticConfigOptions` and `dynamicConfigOptions`)
      '';

      example = literalExpression "/path/to/static_config.toml";
      type = types.nullOr types.path;
    };

    staticConfigOptions = mkOption {
      default = {
        entryPoints.http.address = ":80";
      };

      description = ''
        Static configuration for Traefik.
      '';

      example = {
        api = { };
        entryPoints.http.address = ":80";
        entryPoints.web.address = ":8080";
      };

      type = format.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.traefik = {
      after = [ "network-online.target" ];
      description = "Traefik web server";

      serviceConfig = {
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${cfg.package}/bin/traefik --configfile=${finalStaticConfigFile}";

        ExecStartPre = lib.optional (cfg.environmentFiles != [ ]) (
          pkgs.writeShellScript "pre-start" ''
            umask 077
            ${pkgs.envsubst}/bin/envsubst -i "${staticConfigFile}" > "${finalStaticConfigFile}"
          ''
        );

        Group = cfg.group;
        LimitNOFILE = 1048576;
        LimitNPROC = 64;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "full";
        ReadWritePaths = [ cfg.dataDir ];
        Restart = "on-failure";
        RuntimeDirectory = "traefik";
        Type = "simple";
        User = "traefik";
        WorkingDirectory = cfg.dataDir;
      };

      startLimitBurst = 5;
      startLimitIntervalSec = 86400;
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0700 traefik traefik - -" ];
    users.groups.traefik = { };

    users.users.traefik = {
      createHome = true;
      group = "traefik";
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };
}
