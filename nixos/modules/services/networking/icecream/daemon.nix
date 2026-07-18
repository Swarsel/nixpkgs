{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.icecream.daemon;
in
{

  ###### interface

  options = {

    services.icecream.daemon = {

      enable = mkEnableOption "Icecream Daemon";
      package = mkPackageOption pkgs "icecream" { };

      cacheLimit = mkOption {
        default = 256;

        description = ''
          Maximum size in Megabytes of cache used to store compile environments of compile clients.
        '';

        type = types.ints.u16;
      };

      extraArgs = mkOption {
        default = [ ];
        description = "Additional command line parameters.";
        example = [ "-v" ];
        type = types.listOf types.str;
      };

      hostname = mkOption {
        default = null;

        description = ''
          Hostname of the daemon in the icecream infrastructure.

          Uses the hostname retrieved via uname if set to null.
        '';

        type = types.nullOr types.str;
      };

      maxProcesses = mkOption {
        default = null;

        description = ''
          Maximum number of compile jobs started in parallel for this daemon.

          Uses the number of CPUs if set to null.
        '';

        type = types.nullOr types.ints.u16;
      };

      netName = mkOption {
        default = "ICECREAM";

        description = ''
          Network name to connect to. A scheduler with the same name needs to be running.
        '';

        type = types.str;
      };

      nice = mkOption {
        default = 5;

        description = ''
          The level of niceness to use.
        '';

        type = types.ints.between (-20) 19;
      };

      noRemote = mkOption {
        default = false;

        description = ''
          Prevent jobs from other nodes being scheduled on this daemon.
        '';

        type = types.bool;
      };

      openBroadcast = mkOption {
        description = ''
          Whether to automatically open the firewall for scheduler discovery.
        '';

        type = types.bool;
      };

      openFirewall = mkOption {
        description = ''
          Whether to automatically open receive port in the firewall.
        '';

        type = types.bool;
      };

      schedulerHost = mkOption {
        default = null;

        description = ''
          Explicit scheduler hostname, useful in firewalled environments.

          Uses scheduler autodiscovery via broadcast if set to null.
        '';

        type = types.nullOr types.str;
      };

      user = mkOption {
        default = "icecc";

        description = ''
          User to run the icecream daemon as. Set to root to enable receive of
          remote compile environments.
        '';

        type = types.str;
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 10245 ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openBroadcast [ 8765 ];

    systemd.services.icecc-daemon = {
      after = [ "network.target" ];
      description = "Icecream compile daemon";

      serviceConfig = {
        AmbientCapabilities = "CAP_SYS_CHROOT";
        CapabilityBoundingSet = "CAP_SYS_CHROOT";
        DynamicUser = true;

        ExecStart = escapeShellArgs (
          [
            "${getBin cfg.package}/bin/iceccd"
            "-b"
            "$STATE_DIRECTORY"
            "-u"
            "icecc"
            (toString cfg.nice)
          ]
          ++ optionals (cfg.schedulerHost != null) [
            "-s"
            cfg.schedulerHost
          ]
          ++ optionals (cfg.netName != null) [
            "-n"
            cfg.netName
          ]
          ++ optionals (cfg.cacheLimit != null) [
            "--cache-limit"
            (toString cfg.cacheLimit)
          ]
          ++ optionals (cfg.maxProcesses != null) [
            "-m"
            (toString cfg.maxProcesses)
          ]
          ++ optionals (cfg.hostname != null) [
            "-N"
            (cfg.hostname)
          ]
          ++ optional cfg.noRemote "--no-remote"
          ++ cfg.extraArgs
        );

        Group = "icecc";
        RuntimeDirectory = "icecc";
        StateDirectory = "icecc";
        User = "icecc";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ emantor ];
}
