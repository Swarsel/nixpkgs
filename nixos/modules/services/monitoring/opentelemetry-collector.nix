{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    getExe
    isStorePath
    literalMD
    ;

  cfg = config.services.opentelemetry-collector;
  opentelemetry-collector = cfg.package;

  settingsFormat = pkgs.formats.yaml { };
  generatedConf =
    if cfg.configFile == null then
      settingsFormat.generate "config.yaml" cfg.settings
    else
      cfg.configFile;
  conf =
    if cfg.validateConfigFile then
      pkgs.runCommandLocal "config.yaml" { inherit generatedConf; } ''
        cp $generatedConf $out
        ${getExe opentelemetry-collector} validate --config=file:$out
      ''
    else
      generatedConf;
in
{
  options.services.opentelemetry-collector = {
    enable = mkEnableOption "Opentelemetry Collector";
    package = mkPackageOption pkgs "opentelemetry-collector" { };

    configFile = mkOption {
      default = null;

      description = ''
        Specify a path to a configuration file that Opentelemetry Collector should use.
      '';

      type = types.nullOr types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Specify the configuration for Opentelemetry Collector in Nix.

        See <https://opentelemetry.io/docs/collector/configuration/> for available options.
      '';

      type = settingsFormat.type;
    };

    validateConfigFile = lib.mkEnableOption "Validate configuration file" // {
      default = isStorePath cfg.configFile;
      defaultText = literalMD "`true` if `configFile` is a store path";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = ((cfg.settings == { }) != (cfg.configFile == null));

        message = ''
          Please specify a configuration for Opentelemetry Collector with either
          'services.opentelemetry-collector.settings' or
          'services.opentelemetry-collector.configFile'.
        '';
      }
    ];

    systemd.services.opentelemetry-collector = {
      description = "Opentelemetry Collector Service Daemon";

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${getExe opentelemetry-collector} --config=file:${conf}";
        NoNewPrivileges = true;
        ProtectSystem = "full";
        Restart = "always";
        StateDirectory = "opentelemetry-collector";

        SupplementaryGroups = [
          # allow to read the systemd journal for opentelemetry-collector
          "systemd-journal"
        ];

        WorkingDirectory = "%S/opentelemetry-collector";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
