{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;
let
  cfg = config.services.galene;
  opt = options.services.galene;
  defaultstateDir = "/var/lib/galene";
  defaultrecordingsDir = "${cfg.stateDir}/recordings";
  defaultgroupsDir = "${cfg.stateDir}/groups";
  defaultdataDir = "${cfg.stateDir}/data";
in
{
  options = {
    services.galene = {
      enable = mkEnableOption "Galene Service";
      package = mkPackageOption pkgs "galene" { };

      certFile = mkOption {
        default = null;

        description = ''
          Path to the server's certificate. The file is copied at runtime to
          Galene's data directory where it needs to reside.
        '';

        example = "/path/to/your/cert.pem";
        type = types.nullOr types.path;
      };

      dataDir = mkOption {
        default = defaultdataDir;
        defaultText = literalExpression ''"''${config.${opt.stateDir}}/data"'';
        description = "Data directory.";
        example = "/var/lib/galene/data";
        type = types.path;
      };

      group = mkOption {
        default = "galene";
        description = "Group under which galene runs.";
        type = types.str;
      };

      groupsDir = mkOption {
        default = defaultgroupsDir;
        defaultText = literalExpression ''"''${config.${opt.stateDir}}/groups"'';
        description = "Web server directory.";
        example = "/var/lib/galene/groups";
        type = types.path;
      };

      httpAddress = mkOption {
        default = "";
        description = "HTTP listen address for galene.";
        type = types.str;
      };

      httpPort = mkOption {
        default = 8443;
        description = "HTTP listen port.";
        type = types.port;
      };

      insecure = mkOption {
        default = false;

        description = ''
          Whether Galene should listen in http or in https. If left as the default
          value (false), Galene needs to be fed a private key and a certificate.
        '';

        type = types.bool;
      };

      keyFile = mkOption {
        default = null;

        description = ''
          Path to the server's private key. The file is copied at runtime to
          Galene's data directory where it needs to reside.
        '';

        example = "/path/to/your/key.pem";
        type = types.nullOr types.path;
      };

      recordingsDir = mkOption {
        default = defaultrecordingsDir;
        defaultText = literalExpression ''"''${config.${opt.stateDir}}/recordings"'';
        description = "Recordings directory.";
        example = "/var/lib/galene/recordings";
        type = types.path;
      };

      stateDir = mkOption {
        default = defaultstateDir;

        description = ''
          The directory where Galene stores its internal state. If left as the default
          value this directory will automatically be created before the Galene server
          starts, otherwise the sysadmin is responsible for ensuring the directory
          exists with appropriate ownership and permissions.
        '';

        type = types.path;
      };

      staticDir = mkOption {
        default = "${cfg.package.static}/static";
        defaultText = literalExpression ''"''${package.static}/static"'';
        description = "Web server directory.";
        example = "/var/lib/galene/static";
        type = types.path;
      };

      turnAddress = mkOption {
        default = "auto";
        description = "Built-in TURN server listen address and port. Set to \"\" to disable.";
        example = "127.0.0.1:1194";
        type = types.str;
      };

      user = mkOption {
        default = "galene";
        description = "User account under which galene runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.galene = {
      after = [ "network.target" ];
      description = "galene";

      preStart = ''
        ${optionalString (cfg.insecure != true && cfg.certFile != null && cfg.keyFile != null) ''
          install -m 700 -o '${cfg.user}' -g '${cfg.group}' ${cfg.certFile} ${cfg.dataDir}/cert.pem
          install -m 700 -o '${cfg.user}' -g '${cfg.group}' ${cfg.keyFile} ${cfg.dataDir}/key.pem
        ''}
      '';

      serviceConfig = mkMerge [
        {
          # Hardening
          CapabilityBoundingSet = [ "" ];
          DeviceAllow = [ "" ];

          ExecStart = ''
            ${cfg.package}/bin/galene \
            ${optionalString (cfg.insecure) "-insecure"} \
            -http ${cfg.httpAddress}:${toString cfg.httpPort} \
            -turn ${cfg.turnAddress} \
            -data ${cfg.dataDir} \
            -groups ${cfg.groupsDir} \
            -recordings ${cfg.recordingsDir} \
            -static ${cfg.staticDir}'';

          Group = cfg.group;
          # Upstream Requirements
          LimitNOFILE = 65536;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadWritePaths = cfg.recordingsDir;
          RemoveIPC = true;
          Restart = "always";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;

          StateDirectory =
            [ ]
            ++ optional (cfg.stateDir == defaultstateDir) "galene"
            ++ optional (cfg.dataDir == defaultdataDir) "galene/data"
            ++ optional (cfg.groupsDir == defaultgroupsDir) "galene/groups"
            ++ optional (cfg.recordingsDir == defaultrecordingsDir) "galene/recordings";

          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          Type = "simple";
          UMask = "0077";
          User = cfg.user;
          WorkingDirectory = cfg.stateDir;
        }
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.group == "galene") {
      galene = { };
    };

    users.users = mkIf (cfg.user == "galene") {
      galene = {
        description = "galene Service";
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ rgrunbla ];
}
