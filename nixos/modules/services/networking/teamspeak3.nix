{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  ts3 = pkgs.teamspeak_server;
  cfg = config.services.teamspeak3;
  user = "teamspeak";
  group = "teamspeak";
in

{

  ###### interface

  options = {

    services.teamspeak3 = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to run the Teamspeak3 voice communication server daemon.
        '';

        type = types.bool;
      };

      dataDir = mkOption {
        default = "/var/lib/teamspeak3-server";

        description = ''
          Directory to store TS3 database and other state/data files.
        '';

        type = types.path;
      };

      defaultVoicePort = mkOption {
        default = 9987;

        description = ''
          Default UDP port for clients to connect to virtual servers - used for first virtual server, subsequent ones will open on incrementing port numbers by default.
        '';

        type = types.port;
      };

      fileTransferIP = mkOption {
        default = null;

        description = ''
          IP on which the server instance will listen for incoming file transfer connections. Defaults to any IP.
        '';

        example = "[::]";
        type = types.nullOr types.str;
      };

      fileTransferPort = mkOption {
        default = 30033;

        description = ''
          TCP port opened for file transfers.
        '';

        type = types.port;
      };

      logPath = mkOption {
        default = "/var/log/teamspeak3-server/";

        description = ''
          Directory to store log files in.
        '';

        type = types.path;
      };

      openFirewall = mkOption {
        default = false;
        description = "Open ports in the firewall for the TeamSpeak3 server.";
        type = types.bool;
      };

      openFirewallServerQuery = mkOption {
        default = false;
        description = "Open ports in the firewall for the TeamSpeak3 serverquery (administration) system. Requires openFirewall.";
        type = types.bool;
      };

      queryHttpPort = mkOption {
        default = 10080;

        description = ''
          TCP port opened for ServerQuery connections using the HTTP protocol.
        '';

        type = types.port;
      };

      queryIP = mkOption {
        default = null;

        description = ''
          IP on which the server instance will listen for incoming ServerQuery connections. Defaults to any IP.
        '';

        example = "0.0.0.0";
        type = types.nullOr types.str;
      };

      queryPort = mkOption {
        default = 10011;

        description = ''
          TCP port opened for ServerQuery connections using the raw telnet protocol.
        '';

        type = types.port;
      };

      querySshPort = mkOption {
        default = 10022;

        description = ''
          TCP port opened for ServerQuery connections using the SSH protocol.
        '';

        type = types.port;
      };

      voiceIP = mkOption {
        default = null;

        description = ''
          IP on which the server instance will listen for incoming voice connections. Defaults to any IP.
        '';

        example = "[::]";
        type = types.nullOr types.str;
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.fileTransferPort
      ]
      ++ (map (port: mkIf cfg.openFirewallServerQuery port) [
        cfg.queryPort
        cfg.querySshPort
        cfg.queryHttpPort
      ]);

      # subsequent vServers will use the incremented voice port, let's just open the next 10
      allowedUDPPortRanges = [
        {
          from = cfg.defaultVoicePort;
          to = cfg.defaultVoicePort + 10;
        }
      ];
    };

    systemd.services.teamspeak3-server = {
      after = [ "network.target" ];
      description = "Teamspeak3 voice communication server daemon";

      serviceConfig = {
        ExecStart = ''
          ${ts3}/bin/ts3server \
            dbsqlpath=${ts3}/lib/teamspeak/sql/ \
            logpath=${cfg.logPath} \
            license_accepted=1 \
            default_voice_port=${toString cfg.defaultVoicePort} \
            filetransfer_port=${toString cfg.fileTransferPort} \
            query_port=${toString cfg.queryPort} \
            query_ssh_port=${toString cfg.querySshPort} \
            query_http_port=${toString cfg.queryHttpPort} \
            ${optionalString (cfg.voiceIP != null) "voice_ip=${cfg.voiceIP}"} \
            ${optionalString (cfg.fileTransferIP != null) "filetransfer_ip=${cfg.fileTransferIP}"} \
            ${optionalString (cfg.queryIP != null) "query_ip=${cfg.queryIP}"} \
            ${optionalString (cfg.queryIP != null) "query_ssh_ip=${cfg.queryIP}"} \
            ${optionalString (cfg.queryIP != null) "query_http_ip=${cfg.queryIP}"}
        '';

        Group = group;
        Restart = "on-failure";
        User = user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.logPath}' - ${user} ${group} - -"
    ];

    users.groups.teamspeak = {
      gid = config.ids.gids.teamspeak;
    };

    users.users.teamspeak = {
      createHome = true;
      description = "Teamspeak3 voice communication server daemon";
      group = group;
      home = cfg.dataDir;
      uid = config.ids.uids.teamspeak;
    };
  };

  meta.maintainers = with lib.maintainers; [ arobyn ];
}
