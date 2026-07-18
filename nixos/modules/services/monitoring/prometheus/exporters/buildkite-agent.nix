{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.buildkite-agent;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    optionalString
    literalExpression
    ;
in
{
  extraOpts = {
    endpoint = mkOption {
      default = "https://agent.buildkite.com/v3";

      description = ''
        The Buildkite Agent API endpoint.
      '';

      type = types.str;
    };

    interval = mkOption {
      default = "30s";

      description = ''
        How often to update metrics.
      '';

      example = "1min";
      type = types.str;
    };

    queues = mkOption {
      default = null;

      description = ''
        Which specific queues to process.
      '';

      example = literalExpression ''[ "my-queue1" "my-queue2" ]'';
      type = with types; nullOr (listOf str);
    };

    tokenPath = mkOption {
      apply = final: if final == null then null else toString final;

      description = ''
        The token from your Buildkite "Agents" page.

        A run-time path to the token file, which is supposed to be provisioned
        outside of Nix store.
      '';

      type = types.nullOr types.path;
    };
  };

  port = 9876;

  serviceOpts = {
    script =
      let
        queues = concatStringsSep " " (map (q: "-queue ${q}") cfg.queues);
      in
      ''
        export BUILDKITE_AGENT_TOKEN="$(cat ${toString cfg.tokenPath})"
        exec ${pkgs.buildkite-agent-metrics}/bin/buildkite-agent-metrics \
          -backend prometheus \
          -interval ${cfg.interval} \
          -endpoint ${cfg.endpoint} \
          ${optionalString (cfg.queues != null) queues} \
          -prometheus-addr "${cfg.listenAddress}:${toString cfg.port}" ${concatStringsSep " " cfg.extraFlags}
      '';

    serviceConfig = {
      DynamicUser = false;
      RuntimeDirectory = "buildkite-agent-metrics";
    };
  };
}
