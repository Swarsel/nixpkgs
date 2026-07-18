{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    attrValues
    literalExpression
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.filebeat;

  json = pkgs.formats.json { };
in
{
  options = {

    services.filebeat = {

      enable = mkEnableOption "filebeat";

      package = mkPackageOption pkgs "filebeat" {
        example = "filebeat7";
      };

      inputs = mkOption {
        default = { };

        description = ''
          Inputs specify how Filebeat locates and processes input data.

          This is like `services.filebeat.settings.filebeat.inputs`,
          but structured as an attribute set. This has the benefit
          that multiple NixOS modules can contribute settings to a
          single filebeat input.

          An input type can be specified multiple times by choosing a
          different `<name>` for each, but setting
          [](#opt-services.filebeat.inputs._name_.type)
          to the same value.

          See <https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html>.
        '';

        example = literalExpression ''
          {
            journald.id = "everything";  # Only for filebeat7
            log = {
              enabled = true;
              paths = [
                "/var/log/*.log"
              ];
            };
          };
        '';

        type = types.attrsOf (
          types.submodule (
            { name, ... }:
            {
              options = {
                type = mkOption {
                  default = name;

                  description = ''
                    The input type.

                    Look for the value after `type:` on
                    the individual input pages linked from
                    <https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html>.
                  '';

                  type = types.str;
                };
              };

              freeformType = json.type;
            }
          )
        );
      };

      modules = mkOption {
        default = { };

        description = ''
          Filebeat modules provide a quick way to get started
          processing common log formats. They contain default
          configurations, Elasticsearch ingest pipeline definitions,
          and Kibana dashboards to help you implement and deploy a log
          monitoring solution.

          This is like `services.filebeat.settings.filebeat.modules`,
          but structured as an attribute set. This has the benefit
          that multiple NixOS modules can contribute settings to a
          single filebeat module.

          A module can be specified multiple times by choosing a
          different `<name>` for each, but setting
          [](#opt-services.filebeat.modules._name_.module)
          to the same value.

          See <https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-modules.html>.
        '';

        example = literalExpression ''
          {
            nginx = {
              access = {
                enabled = true;
                var.paths = [ "/path/to/log/nginx/access.log*" ];
              };
              error = {
                enabled = true;
                var.paths = [ "/path/to/log/nginx/error.log*" ];
              };
            };
          };
        '';

        type = types.attrsOf (
          types.submodule (
            { name, ... }:
            {
              options = {
                module = mkOption {
                  default = name;

                  description = ''
                    The name of the module.

                    Look for the value after `module:` on
                    the individual input pages linked from
                    <https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-modules.html>.
                  '';

                  type = types.str;
                };
              };

              freeformType = json.type;
            }
          )
        );
      };

      settings = mkOption {
        default = { };

        description = ''
          Configuration for filebeat. See
          <https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-reference-yml.html>
          for supported values.

          Options containing secret data should be set to an attribute
          set containing the attribute `_secret` - a
          string pointing to a file containing the value the option
          should be set to. See the example to get a better picture of
          this: in the resulting
          {file}`filebeat.yml` file, the
          `output.elasticsearch.password`
          key will be set to the contents of the
          {file}`/var/keys/elasticsearch_password` file.
        '';

        example = literalExpression ''
          {
            settings = {
              output.elasticsearch = {
                hosts = [ "myEShost:9200" ];
                username = "filebeat_internal";
                password = { _secret = "/var/keys/elasticsearch_password"; };
              };
              logging.level = "info";
            };
          };
        '';

        type = types.submodule {
          options = {

            filebeat = {
              inputs = mkOption {
                default = [ ];

                description = ''
                  Inputs specify how Filebeat locates and processes
                  input data. Use [](#opt-services.filebeat.inputs) instead.

                  See <https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html>.
                '';

                internal = true;
                type = types.listOf json.type;
              };

              modules = mkOption {
                default = [ ];

                description = ''
                  Filebeat modules provide a quick way to get started
                  processing common log formats. They contain default
                  configurations, Elasticsearch ingest pipeline
                  definitions, and Kibana dashboards to help you
                  implement and deploy a log monitoring solution.

                  Use [](#opt-services.filebeat.modules) instead.

                  See <https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-modules.html>.
                '';

                internal = true;
                type = types.listOf json.type;
              };
            };

            output.elasticsearch.hosts = mkOption {
              default = [ "127.0.0.1:9200" ];

              description = ''
                The list of Elasticsearch nodes to connect to.

                The events are distributed to these nodes in round
                robin order. If one node becomes unreachable, the
                event is automatically sent to another node. Each
                Elasticsearch node can be defined as a URL or
                IP:PORT. For example:
                `http://192.15.3.2`,
                `https://es.found.io:9230` or
                `192.24.3.2:9300`. If no port is
                specified, `9200` is used.
              '';

              example = [ "myEShost:9200" ];
              type = with types; listOf str;
            };
          };

          freeformType = json.type;
        };
      };
    };
  };

  config = mkIf cfg.enable {

    services.filebeat.settings.filebeat.inputs = attrValues cfg.inputs;
    services.filebeat.settings.filebeat.modules = attrValues cfg.modules;

    systemd.services.filebeat = {
      after = [ "elasticsearch.service" ];
      description = "Filebeat log shipper";

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/filebeat -e \
            -c "/var/lib/filebeat/filebeat.yml" \
            --path.data "/var/lib/filebeat"
        '';

        ExecStartPre = pkgs.writeShellScript "filebeat-exec-pre" ''
          set -euo pipefail

          umask u=rwx,g=,o=

          ${utils.genJqSecretsReplacementSnippet cfg.settings "/var/lib/filebeat/filebeat.yml"}
        '';

        Restart = "always";
        StateDirectory = "filebeat";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "elasticsearch.service" ];
    };
  };
}
