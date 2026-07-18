{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.node-cert;
  inherit (lib) mkOption types concatStringsSep;
in
{
  extraOpts = {
    excludeGlobs = mkOption {
      default = [ ];

      description = ''
        List files matching a pattern to include. Uses Go blob pattern.
      '';

      type = types.listOf types.str;
    };

    excludePaths = mkOption {
      default = [ ];

      description = ''
        List of paths to exclute from searching for SSL certificates.
      '';

      type = types.listOf types.str;
    };

    includeGlobs = mkOption {
      default = [ ];

      description = ''
        List files matching a pattern to include. Uses Go blob pattern.
      '';

      type = types.listOf types.str;
    };

    paths = mkOption {
      description = ''
        List of paths to search for SSL certificates.
      '';

      type = types.listOf types.str;
    };

    user = mkOption {
      default = "acme";

      description = ''
        User owning the certs.
      '';

      type = types.str;
    };
  };

  port = 9141;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${lib.getExe pkgs.prometheus-node-cert-exporter} \
          --listen ${toString cfg.listenAddress}:${toString cfg.port} \
          --path ${concatStringsSep "," cfg.paths} \
          --exclude-path "${concatStringsSep "," cfg.excludePaths}" \
          --include-glob "${concatStringsSep "," cfg.includeGlobs}" \
          --exclude-glob "${concatStringsSep "," cfg.excludeGlobs}" \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      User = cfg.user;
    };
  };
}
