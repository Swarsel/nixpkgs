{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.syncthing.relay;

  dataDirectory = "/var/lib/syncthing-relay";

  relayOptions = [
    "--keys=${dataDirectory}"
    "--listen=${cfg.listenAddress}:${toString cfg.port}"
    "--status-srv=${cfg.statusListenAddress}:${toString cfg.statusPort}"
    "--provided-by=${escapeShellArg cfg.providedBy}"
  ]
  ++ optional (cfg.pools != null) "--pools=${escapeShellArg (concatStringsSep "," cfg.pools)}"
  ++ optional (cfg.globalRateBps != null) "--global-rate=${toString cfg.globalRateBps}"
  ++ optional (cfg.perSessionRateBps != null) "--per-session-rate=${toString cfg.perSessionRateBps}"
  ++ cfg.extraOptions;
in
{
  ###### interface

  options.services.syncthing.relay = {
    enable = mkEnableOption "Syncthing relay service";

    extraOptions = mkOption {
      default = [ ];

      description = ''
        Extra command line arguments to pass to strelaysrv.
      '';

      type = types.listOf types.str;
    };

    globalRateBps = mkOption {
      default = null;

      description = ''
        Global bandwidth rate limit in bytes per second.
      '';

      type = types.nullOr types.ints.positive;
    };

    listenAddress = mkOption {
      default = "";

      description = ''
        Address to listen on for relay traffic.
      '';

      example = "1.2.3.4";
      type = types.str;
    };

    perSessionRateBps = mkOption {
      default = null;

      description = ''
        Per session bandwidth rate limit in bytes per second.
      '';

      type = types.nullOr types.ints.positive;
    };

    pools = mkOption {
      default = null;

      description = ''
        Relay pools to join. If null, uses the default global pool.
      '';

      type = types.nullOr (types.listOf types.str);
    };

    port = mkOption {
      default = 22067;

      description = ''
        Port to listen on for relay traffic. This port should be added to
        `networking.firewall.allowedTCPPorts`.
      '';

      type = types.port;
    };

    providedBy = mkOption {
      default = "";

      description = ''
        Human-readable description of the provider of the relay (you).
      '';

      type = types.str;
    };

    statusListenAddress = mkOption {
      default = "";

      description = ''
        Address to listen on for serving the relay status API.
      '';

      example = "1.2.3.4";
      type = types.str;
    };

    statusPort = mkOption {
      default = 22070;

      description = ''
        Port to listen on for serving the relay status API. This port should be
        added to `networking.firewall.allowedTCPPorts`.
      '';

      type = types.port;
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.services.syncthing-relay = {
      after = [ "network.target" ];
      description = "Syncthing relay service";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.syncthing-relay}/bin/strelaysrv ${concatStringsSep " " relayOptions}";
        Restart = "on-failure";
        StateDirectory = baseNameOf dataDirectory;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
