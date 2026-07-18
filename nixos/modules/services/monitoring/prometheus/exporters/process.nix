{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.process;
  inherit (lib)
    mkOption
    types
    literalExpression
    concatStringsSep
    ;
  configFile = pkgs.writeText "process-exporter.yaml" (builtins.toJSON cfg.settings);
in
{
  extraOpts = {
    settings.process_names = mkOption {
      default = [ ];

      description = ''
        All settings expressed as an Nix attrset.

        Check the official documentation for the corresponding YAML
        settings that can all be used here: <https://github.com/ncabatoff/process-exporter>
      '';

      example = literalExpression ''
        [
          # Remove nix store path from process name
          { name = "{{.Matches.Wrapped}} {{ .Matches.Args }}"; cmdline = [ "^/nix/store[^ ]*/(?P<Wrapped>[^ /]*) (?P<Args>.*)" ]; }
        ]
      '';

      type = types.listOf types.anything;
    };
  };

  port = 9256;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;

      ExecStart = ''
        ${pkgs.prometheus-process-exporter}/bin/process-exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --config.path ${configFile} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      NoNewPrivileges = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = true;
    };
  };
}
