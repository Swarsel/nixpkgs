{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.mail;
  inherit (lib)
    mkOption
    types
    mapAttrs'
    nameValuePair
    toLower
    filterAttrs
    removeAttrs
    escapeShellArg
    literalExpression
    mkIf
    concatStringsSep
    ;

  configFile =
    if cfg.configuration != null then configurationFile else (escapeShellArg cfg.configFile);

  configurationFile = pkgs.writeText "prometheus-mail-exporter.conf" (
    builtins.toJSON (
      # removes the _module attribute, null values and converts attrNames to lowercase
      mapAttrs' (
        name: value:
        if name == "servers" then
          nameValuePair (toLower name) (
            (map (
              srv:
              (mapAttrs' (n: v: nameValuePair (toLower n) v) (
                filterAttrs (n: v: !(n == "_module" || v == null)) srv
              ))
            ))
              value
          )
        else
          nameValuePair (toLower name) value
      ) (removeAttrs cfg.configuration [ "_module" ])
    )
  );

  serverOptions.options = {
    detectionDir = mkOption {
      description = ''
        Directory in which new mails for the exporter user are placed.
        Note that this needs to exist when the exporter starts.
      '';

      example = "/var/spool/mail/exporteruser/new";
      type = types.path;
    };

    from = mkOption {
      description = ''
        Content of 'From' Header for probing mails.
      '';

      example = "exporteruser@domain.tld";
      type = types.str;
    };

    login = mkOption {
      default = null;

      description = ''
        Username to use for SMTP authentication.
      '';

      example = "exporteruser@domain.tld";
      type = types.nullOr types.str;
    };

    name = mkOption {
      description = ''
        Value for label 'configname' which will be added to all metrics.
      '';

      type = types.str;
    };

    passphrase = mkOption {
      default = null;

      description = ''
        Password to use for SMTP authentication.
      '';

      type = types.nullOr types.str;
    };

    port = mkOption {
      description = ''
        Port to use for SMTP.
      '';

      example = 587;
      type = types.port;
    };

    server = mkOption {
      description = ''
        Hostname of the server that should be probed.
      '';

      type = types.str;
    };

    to = mkOption {
      description = ''
        Content of 'To' Header for probing mails.
      '';

      example = "exporteruser@domain.tld";
      type = types.str;
    };
  };

  exporterOptions.options = {
    disableFileDeletion = mkOption {
      default = false;

      description = ''
        Disables the exporter's function to delete probing mails.
      '';

      type = types.bool;
    };

    mailCheckTimeout = mkOption {
      description = ''
        Timeout until mails are considered "didn't make it".
      '';

      type = types.str;
    };

    monitoringInterval = mkOption {
      description = ''
        Time interval between two probe attempts.
      '';

      example = "10s";
      type = types.str;
    };

    servers = mkOption {
      default = [ ];

      description = ''
        List of servers that should be probed.

        *Note:* if your mailserver has {manpage}`rspamd(8)` configured,
        it can happen that emails from this exporter are marked as spam.

        It's possible to work around the issue with a config like this:
        ```
        {
          services.rspamd.locals."multimap.conf".text = '''
            ALLOWLIST_PROMETHEUS {
              filter = "email:domain:tld";
              type = "from";
              map = "''${pkgs.writeText "allowmap" "domain.tld"}";
              score = -100.0;
            }
          ''';
        }
        ```
      '';

      example = literalExpression ''
        [ {
          name = "testserver";
          server = "smtp.domain.tld";
          port = 587;
          from = "exporteruser@domain.tld";
          to = "exporteruser@domain.tld";
          detectionDir = "/path/to/Maildir/new";
        } ]
      '';

      type = types.listOf (types.submodule serverOptions);
    };
  };
in
{
  extraOpts = {
    configFile = mkOption {
      default = null;

      description = ''
        Specify the mailexporter configuration file to use.
      '';

      type = types.nullOr types.path;
    };

    configuration = mkOption {
      default = null;

      description = ''
        Specify the mailexporter configuration file to use.
      '';

      type = types.nullOr (types.submodule exporterOptions);
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        File containing env-vars to be substituted into the exporter's config.
      '';

      type = types.nullOr types.str;
    };

    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };
  };

  port = 9225;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;
      EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];

      ExecStart = ''
        ${pkgs.prometheus-mail-exporter}/bin/mailexporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --web.telemetry-path ${cfg.telemetryPath} \
          --config.file ''${RUNTIME_DIRECTORY}/mail-exporter.json \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      ExecStartPre = [
        "${pkgs.writeShellScript "subst-secrets-mail-exporter" ''
          umask 0077
          ${pkgs.envsubst}/bin/envsubst -i ${configFile} -o ''${RUNTIME_DIRECTORY}/mail-exporter.json
        ''}"
      ];

      RuntimeDirectory = "prometheus-mail-exporter";
    };
  };
}
