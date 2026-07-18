{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  nncpCfgFile = "/run/nncp.hjson";
  programCfg = config.programs.nncp;
  callerCfg = config.services.nncp.caller;
  daemonCfg = config.services.nncp.daemon;
  settingsFormat = pkgs.formats.json { };
  jsonCfgFile = settingsFormat.generate "nncp.json" programCfg.settings;
  pkg = programCfg.package;
in
{
  options = {

    services.nncp = {
      caller = {
        enable = mkEnableOption ''
          cron'ed NNCP TCP daemon caller.
          The daemon will take configuration from
          [](#opt-programs.nncp.settings)
        '';

        extraArgs = mkOption {
          default = [ ];
          description = "Extra command-line arguments to pass to caller.";
          example = [ "-autotoss" ];
          type = with types; listOf str;
        };
      };

      daemon = {
        enable = mkEnableOption ''
          NNCP TCP synronization daemon.
          The daemon will take configuration from
          [](#opt-programs.nncp.settings)
        '';

        extraArgs = mkOption {
          default = [ ];
          description = "Extra command-line arguments to pass to daemon.";
          example = [ "-autotoss" ];
          type = with types; listOf str;
        };

        socketActivation = {
          enable = mkEnableOption "socket activation for nncp-daemon";

          listenStreams = mkOption {
            default = [ "5400" ];

            description = ''
              TCP sockets to bind to.
              See [](#opt-systemd.sockets._name_.listenStreams).
            '';

            type = with types; listOf str;
          };
        };
      };

    };
  };

  config = mkIf (programCfg.enable or callerCfg.enable or daemonCfg.enable) {

    assertions = [
      {
        assertion =
          with builtins;
          let
            callerCongfigured =
              let
                neigh = config.programs.nncp.settings.neigh or { };
              in
              lib.lists.any (x: hasAttr "calls" x && x.calls != [ ]) (attrValues neigh);
          in
          !callerCfg.enable || callerCongfigured;

        message = "NNCP caller enabled but call configuration is missing";
      }
    ];

    systemd.services."nncp-caller" = {
      inherit (callerCfg) enable;
      after = [ "network.target" ];
      description = "Croned NNCP TCP daemon caller.";
      documentation = [ "http://www.nncpgo.org/nncp_002dcaller.html" ];

      serviceConfig = {
        ExecStart = ''${pkg}/bin/nncp-caller -noprogress -cfg "${nncpCfgFile}" ${lib.strings.escapeShellArgs callerCfg.extraArgs}'';
        Group = "uucp";
        UMask = "0002";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."nncp-daemon" = mkIf daemonCfg.enable {
      enable = !daemonCfg.socketActivation.enable;
      after = [ "network.target" ];
      description = "NNCP TCP syncronization daemon.";
      documentation = [ "http://www.nncpgo.org/nncp_002ddaemon.html" ];

      serviceConfig = {
        ExecStart = ''${pkg}/bin/nncp-daemon -noprogress -cfg "${nncpCfgFile}" ${lib.strings.escapeShellArgs daemonCfg.extraArgs}'';
        Group = "uucp";
        Restart = "on-failure";
        UMask = "0002";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."nncp-daemon@" = mkIf daemonCfg.socketActivation.enable {
      after = [ "network.target" ];
      description = "NNCP TCP syncronization daemon.";
      documentation = [ "http://www.nncpgo.org/nncp_002ddaemon.html" ];

      serviceConfig = {
        ExecStart = ''${pkg}/bin/nncp-daemon -noprogress -ucspi -cfg "${nncpCfgFile}" ${lib.strings.escapeShellArgs daemonCfg.extraArgs}'';
        Group = "uucp";
        StandardError = "journal";
        StandardInput = "socket";
        StandardOutput = "inherit";
        UMask = "0002";
      };
    };

    systemd.sockets.nncp-daemon = mkIf daemonCfg.socketActivation.enable {
      inherit (daemonCfg.socketActivation) listenStreams;
      conflicts = [ "nncp-daemon.service" ];
      description = "socket for NNCP TCP syncronization.";
      socketConfig.Accept = true;
      wantedBy = [ "sockets.target" ];
    };
  };
}
