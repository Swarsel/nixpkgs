{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.pve;
  inherit (lib)
    mkOption
    types
    mkPackageOption
    optionalString
    optionalAttrs
    ;

  # pve exporter requires a config file so create an empty one if configFile is not provided
  emptyConfigFile = pkgs.writeTextFile {
    name = "pve.yml";
    text = "default:";
  };

  computedConfigFile = if cfg.configFile == null then emptyConfigFile else cfg.configFile;
in
{
  extraOpts = {
    package = mkPackageOption pkgs "prometheus-pve-exporter" { };

    collectors = {
      config = mkOption {
        default = true;

        description = ''
          Collect PVE onboot status
        '';

        type = types.bool;
      };

      cluster = mkOption {
        default = true;

        description = ''
          Collect PVE cluster info
        '';

        type = types.bool;
      };

      node = mkOption {
        default = true;

        description = ''
          Collect PVE node info
        '';

        type = types.bool;
      };

      replication = mkOption {
        default = true;

        description = ''
          Collect PVE replication info
        '';

        type = types.bool;
      };

      resources = mkOption {
        default = true;

        description = ''
          Collect PVE resources info
        '';

        type = types.bool;
      };

      status = mkOption {
        default = true;

        description = ''
          Collect Node/VM/CT status
        '';

        type = types.bool;
      };

      version = mkOption {
        default = true;

        description = ''
          Collect PVE version info
        '';

        type = types.bool;
      };
    };

    configFile = mkOption {
      default = null;

      description = ''
        Path to the service's config file. This path can either be a computed path in /nix/store or a path in the local filesystem.

        The config file should NOT be stored in /nix/store as it will contain passwords and/or keys in plain text.

        If both configFile and environmentFile are provided, the configFile option will be ignored.

        Configuration reference: <https://github.com/prometheus-pve/prometheus-pve-exporter/#authentication>
      '';

      example = "/etc/prometheus-pve-exporter/pve.yml";
      type = with types; nullOr path;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path to the service's environment file. This path can either be a computed path in /nix/store or a path in the local filesystem.

        The environment file should NOT be stored in /nix/store as it contains passwords and/or keys in plain text.

        Environment reference: <https://github.com/prometheus-pve/prometheus-pve-exporter#authentication>
      '';

      example = "/etc/prometheus-pve-exporter/pve.env";
      type = with types; nullOr path;
    };

    server = {
      certFile = mkOption {
        default = null;

        description = ''
          Path to a SSL certificate file for the server
        '';

        example = "/var/lib/prometheus-pve-exporter/full-chain.pem";
        type = with types; nullOr path;
      };

      keyFile = mkOption {
        default = null;

        description = ''
          Path to a SSL private key file for the server
        '';

        example = "/var/lib/prometheus-pve-exporter/privkey.key";
        type = with types; nullOr path;
      };
    };
  };

  port = 9221;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = cfg.environmentFile == null;

      ExecStart = ''
        ${cfg.package}/bin/pve_exporter \
          --${optionalString (!cfg.collectors.status) "no-"}collector.status \
          --${optionalString (!cfg.collectors.version) "no-"}collector.version \
          --${optionalString (!cfg.collectors.node) "no-"}collector.node \
          --${optionalString (!cfg.collectors.cluster) "no-"}collector.cluster \
          --${optionalString (!cfg.collectors.resources) "no-"}collector.resources \
          --${optionalString (!cfg.collectors.config) "no-"}collector.config \
          --${optionalString (!cfg.collectors.replication) "no-"}collector.replication \
          ${optionalString (cfg.server.keyFile != null) "--server.keyfile ${cfg.server.keyFile}"} \
          ${optionalString (cfg.server.certFile != null) "--server.certfile ${cfg.server.certFile}"} \
          --config.file %d/configFile \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port}
      '';

      LoadCredential = "configFile:${computedConfigFile}";
    }
    // optionalAttrs (cfg.environmentFile != null) {
      EnvironmentFile = cfg.environmentFile;
    };
  };
}
