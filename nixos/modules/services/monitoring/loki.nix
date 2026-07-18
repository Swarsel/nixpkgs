{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    escapeShellArgs
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.loki;

  prettyJSON =
    conf:
    pkgs.runCommand "loki-config.json" { } ''
      echo '${builtins.toJSON conf}' | ${pkgs.jq}/bin/jq 'del(._module)' > $out
    '';

in
{
  options.services.loki = {
    enable = mkEnableOption "Grafana Loki";
    package = lib.mkPackageOption pkgs "grafana-loki" { };

    configFile = mkOption {
      default = null;

      description = ''
        Specify a configuration file that Loki should use.

        Cannot be specified together with {option}`services.loki.configuration`.
      '';

      type = types.nullOr types.path;
    };

    configuration = mkOption {
      default = { };

      description = ''
        Specify the configuration for Loki in Nix.

        See [documentation of Grafana Loki](https://grafana.com/docs/loki/latest/configure/) for all available options.

        Cannot be specified together with {option}`services.loki.configFile`.
      '';

      type = (pkgs.formats.json { }).type;
    };

    dataDir = mkOption {
      default = "/var/lib/loki";

      description = ''
        Specify the data directory for Loki.
      '';

      type = types.path;
    };

    extraFlags = mkOption {
      default = [ ];

      description = ''
        Specify a list of additional command line flags,
        which get escaped and are then passed to Loki.
      '';

      example = [ "--server.http-listen-port=3101" ];
      type = types.listOf types.str;
    };

    group = mkOption {
      default = "loki";

      description = ''
        Group under which the Loki service runs.
      '';

      type = types.str;
    };

    user = mkOption {
      default = "loki";

      description = ''
        User under which the Loki service runs.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (
          (cfg.configuration == { } -> cfg.configFile != null)
          && (cfg.configFile != null -> cfg.configuration == { })
        );

        message = ''
          Please specify either
          'services.loki.configuration' or
          'services.loki.configFile'.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ]; # logcli

    systemd.services.loki = {
      after = [ "network-online.target" ];
      description = "Loki Service Daemon";

      serviceConfig =
        let
          conf =
            if cfg.configFile == null then
              # Config validation may fail when using extraFlags = [ "-config.expand-env=true" ].
              # To work around this, we simply skip it when extraFlags is not empty.
              if cfg.extraFlags == [ ] then
                validateConfig (prettyJSON cfg.configuration)
              else
                prettyJSON cfg.configuration
            else
              cfg.configFile;
          validateConfig =
            file:
            pkgs.runCommand "validate-loki-conf"
              {
                nativeBuildInputs = [ cfg.package ];
              }
              ''
                loki -verify-config -config.file "${file}"
                ln -s "${file}" "$out"
              '';
        in
        {
          DevicePolicy = "closed";
          ExecStart = "${cfg.package}/bin/loki --config.file=${conf} ${escapeShellArgs cfg.extraFlags}";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "full";
          Restart = "always";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      createHome = true;
      description = "Loki Service User";
      group = cfg.group;
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };
}
