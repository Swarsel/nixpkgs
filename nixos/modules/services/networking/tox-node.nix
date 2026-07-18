{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  pkg = pkgs.tox-node;
  cfg = config.services.tox-node;
  homeDir = "/var/lib/tox-node";

  configFile =
    let
      src = "${pkg.src}/tox_node/dpkg/config.yml";
      confJSON = pkgs.writeText "config.json" (
        builtins.toJSON {
          keys-file = cfg.keysFile;
          lan-discovery = cfg.lanDiscovery;
          log-type = cfg.logType;
          motd = cfg.motd;
          tcp-addresses = cfg.tcpAddresses;
          tcp-connections-limit = cfg.tcpConnectionLimit;
          threads = cfg.threads;
          udp-address = cfg.udpAddress;
        }
      );
    in
    with pkgs;
    runCommand "config.yml" { } ''
      ${remarshal}/bin/remarshal -if yaml -of json ${src} -o src.json
      ${jq}/bin/jq -s '(.[0] | with_entries( select(.key == "bootstrap-nodes"))) * .[1]' src.json ${confJSON} > $out
    '';

in
{
  options.services.tox-node = {
    enable = mkEnableOption "Tox Node service";

    keysFile = mkOption {
      default = "${homeDir}/keys";
      description = "Path to the file where DHT keys are stored.";
      type = types.str;
    };

    lanDiscovery = mkOption {
      default = true;
      description = "Enable local network discovery.";
      type = types.bool;
    };

    logType = mkOption {
      default = "Stderr";
      description = "Logging implementation.";

      type = types.enum [
        "Stderr"
        "Stdout"
        "Syslog"
        "None"
      ];
    };

    motd = mkOption {
      default = "Hi from tox-rs! I'm up {{uptime}}. TCP: incoming {{tcp_packets_in}}, outgoing {{tcp_packets_out}}, UDP: incoming {{udp_packets_in}}, outgoing {{udp_packets_out}}";
      description = "Message of the day";
      type = types.str;
    };

    tcpAddresses = mkOption {
      default = [ "0.0.0.0:33445" ];
      description = "TCP addresses to run TCP relay.";
      type = types.listOf types.str;
    };

    tcpConnectionLimit = mkOption {
      default = 8192;
      description = "Maximum number of active TCP connections relay can hold";
      type = types.int;
    };

    threads = mkOption {
      default = 1;
      description = "Number of threads for execution";
      type = types.int;
    };

    udpAddress = mkOption {
      default = "0.0.0.0:33445";
      description = "UDP address to run DHT node.";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.tox-node = {
      after = [ "network.target" ];
      description = "Tox Node";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkg}/bin/tox-node config ${configFile}";
        Restart = "always";
        StateDirectory = "tox-node";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
