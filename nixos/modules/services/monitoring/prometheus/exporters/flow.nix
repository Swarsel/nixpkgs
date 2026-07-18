{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.flow;
  inherit (lib)
    mkOption
    types
    literalExpression
    concatStringsSep
    optionalString
    ;
in
{
  extraOpts = {
    asn = mkOption {
      description = "The ASN being monitored.";
      example = 65542;
      type = types.ints.positive;
    };

    brokers = mkOption {
      description = "List of Kafka brokers to connect to.";
      example = literalExpression ''[ "kafka.example.org:19092" ]'';
      type = types.listOf types.str;
    };

    partitions = mkOption {
      default = [ ];

      description = ''
        The number of the partitions to consume, none means all.
      '';

      type = types.listOf types.int;
    };

    topic = mkOption {
      description = "The Kafka topic to consume from.";
      example = "pmacct.acct";
      type = types.str;
    };
  };

  port = 9590;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = true;

      ExecStart = ''
        ${pkgs.prometheus-flow-exporter}/bin/flow-exporter \
          -asn ${toString cfg.asn} \
          -topic ${cfg.topic} \
          -brokers ${concatStringsSep "," cfg.brokers} \
          ${optionalString (cfg.partitions != [ ]) "-partitions ${concatStringsSep "," cfg.partitions}"} \
          -addr ${cfg.listenAddress}:${toString cfg.port} ${concatStringsSep " " cfg.extraFlags}
      '';
    };
  };
}
