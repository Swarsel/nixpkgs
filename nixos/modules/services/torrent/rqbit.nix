{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkPackageOption
    mkIf
    ;

  cfg = config.services.rqbit;
  stateDir = "/var/lib/rqbit";
  defaultDownloadDir = "${stateDir}/downloads";
in
{
  options.services.rqbit = {
    enable = mkEnableOption "rqbit BitTorrent daemon";
    package = mkPackageOption pkgs "rqbit" { };

    downloadDir = mkOption {
      default = defaultDownloadDir;
      description = "Directory where to download torrents.";
      example = "/mnt/storage/torrents";
      type = types.path;
    };

    group = mkOption {
      default = "rqbit";
      description = "Group account under which rqbit runs.";
      type = types.str;
    };

    httpHost = mkOption {
      default = "127.0.0.1";
      description = "The listen host for the HTTP API.";
      example = "0.0.0.0";
      type = types.str;
    };

    httpPort = mkOption {
      default = 3030;
      description = "The listen port for the HTTP API.";
      type = types.port;
    };

    openFirewall = mkEnableOption "opening of the HTTP and Peer ports in the firewall";

    peerPort = mkOption {
      default = 4240;
      description = "The port to listen for incoming BitTorrent peer connections (TCP and uTP).";
      type = types.port;
    };

    user = mkOption {
      default = "rqbit";
      description = "User account under which rqbit runs.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.httpPort
        cfg.peerPort
      ];

      allowedUDPPorts = [ cfg.peerPort ];
    };

    systemd.services.rqbit = {
      after = [ "network.target" ];
      description = "rqbit BitTorrent Service";

      environment = {
        HOME = stateDir;

        RQBIT_HTTP_API_LISTEN_ADDR = "${
          if (lib.hasInfix ":" cfg.httpHost) then "[${cfg.httpHost}]" else cfg.httpHost
        }:${toString cfg.httpPort}";

        RQBIT_LISTEN_PORT = toString cfg.peerPort;
        RQBIT_SESSION_PERSISTENCE_LOCATION = stateDir;
      };

      serviceConfig = {
        CapabilityBoundingSet = "";
        ExecStart = "${lib.getExe cfg.package} server start ${cfg.downloadDir}";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        # systemd-analyze security rqbit
        ReadWritePaths = mkIf (cfg.downloadDir != defaultDownloadDir) [ cfg.downloadDir ];
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "rqbit";
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@network-io"
          "@file-system"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0027";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups = mkIf (cfg.group == "rqbit") { rqbit = { }; };

      users = mkIf (cfg.user == "rqbit") {
        rqbit = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ CodedNil ];
}
