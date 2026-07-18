{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    attrValues
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.metricbeat;

  settingsFormat = pkgs.formats.yaml { };

in
{
  options = {

    services.metricbeat = {

      enable = mkEnableOption "metricbeat";

      package = mkPackageOption pkgs "metricbeat" {
        example = "metricbeat7";
      };

      modules = mkOption {
        default = { };

        description = ''
          Metricbeat modules are responsible for reading metrics from the various sources.

          This is like `services.metricbeat.settings.metricbeat.modules`,
          but structured as an attribute set. This has the benefit that multiple
          NixOS modules can contribute settings to a single metricbeat module.

          A module can be specified multiple times by choosing a different `<name>`
          for each, but setting [](#opt-services.metricbeat.modules._name_.module) to the same value.

          See <https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-modules.html>.
        '';

        example = {
          system = {
            core.metrics = [ "percentages" ];

            cpu.metrics = [
              "percentages"
              "normalized_percentages"
            ];

            enabled = true;

            metricsets = [
              "cpu"
              "load"
              "memory"
              "network"
              "process"
              "process_summary"
              "uptime"
              "socket_summary"
            ];

            period = "10s";
            processes = [ ".*" ];
          };
        };

        type = types.attrsOf (
          types.submodule (
            { name, ... }:
            {
              options = {
                module = mkOption {
                  default = name;

                  description = ''
                    The name of the module.

                    Look for the value after `module:` on the individual
                    module pages linked from <https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-modules.html>.
                  '';

                  type = types.str;
                };
              };

              freeformType = settingsFormat.type;
            }
          )
        );
      };

      settings = mkOption {
        default = { };

        description = ''
          Configuration for metricbeat. See <https://www.elastic.co/guide/en/beats/metricbeat/current/configuring-howto-metricbeat.html> for supported values.
        '';

        type = types.submodule {
          options = {

            metricbeat.modules = mkOption {
              default = [ ];

              description = ''
                The metric collecting modules. Use [](#opt-services.metricbeat.modules) instead.

                See <https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-modules.html>.
              '';

              internal = true;
              type = types.listOf settingsFormat.type;
            };

            name = mkOption {
              default = "";

              description = ''
                Name of the beat. Defaults to the hostname.
                See <https://www.elastic.co/guide/en/beats/metricbeat/current/configuration-general-options.html#_name>.
              '';

              type = types.str;
            };

            tags = mkOption {
              default = [ ];

              description = ''
                Tags to place on the shipped metrics.
                See <https://www.elastic.co/guide/en/beats/metricbeat/current/configuration-general-options.html#_tags_2>.
              '';

              type = types.listOf types.str;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        # empty modules would cause a failure at runtime
        assertion = cfg.settings.metricbeat.modules != [ ];
        message = "services.metricbeat: You must configure one or more modules.";
      }
    ];

    services.metricbeat.settings.metricbeat.modules = attrValues cfg.modules;

    systemd.services.metricbeat = {
      description = "metricbeat metrics shipper";

      serviceConfig = {
        DynamicUser = true;

        ExecStart = ''
          ${cfg.package}/bin/metricbeat \
            -c ${settingsFormat.generate "metricbeat.yml" cfg.settings} \
            --path.data $STATE_DIRECTORY \
            --path.logs $LOGS_DIRECTORY \
            ;
        '';

        LogsDirectory = "metricbeat";
        ProtectHome = "tmpfs";
        ProtectSystem = "strict";
        Restart = "always";
        StateDirectory = "metricbeat";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
