{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.collectd;

  baseDirLine = ''BaseDir "${cfg.dataDir}"'';
  unvalidated_conf = pkgs.writeText "collectd-unvalidated.conf" cfg.extraConfig;

  conf =
    if cfg.validateConfig then
      pkgs.runCommand "collectd.conf" { } ''
        echo testing ${unvalidated_conf}
        cp ${unvalidated_conf} collectd.conf
        # collectd -t fails if BaseDir does not exist.
        substituteInPlace collectd.conf --replace ${lib.escapeShellArgs [ baseDirLine ]} 'BaseDir "."'
        ${package}/bin/collectd -t -C collectd.conf
        cp ${unvalidated_conf} $out
      ''
    else
      unvalidated_conf;

  package = if cfg.buildMinimalPackage then minimalPackage else cfg.package;

  minimalPackage = cfg.package.override {
    enabledPlugins = [ "syslog" ] ++ builtins.attrNames cfg.plugins;
  };

in
{
  options.services.collectd = with lib.types; {
    enable = lib.mkEnableOption "collectd agent";
    package = lib.mkPackageOption pkgs "collectd" { };

    autoLoadPlugin = lib.mkOption {
      default = false;

      description = ''
        Enable plugin autoloading.
      '';

      type = bool;
    };

    buildMinimalPackage = lib.mkOption {
      default = false;

      description = ''
        Build a minimal collectd package with only the configured `services.collectd.plugins`
      '';

      type = bool;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/collectd";

      description = ''
        Data directory for collectd agent.
      '';

      type = path;
    };

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra configuration for collectd. Use mkBefore to add lines before the
        default config, and mkAfter to add them below.
      '';

      type = lines;
    };

    finalPackage = lib.mkOption {
      default = minimalPackage;

      defaultText = lib.literalExpression ''
        if config.services.collectd.buildMinimalPackage then
          cfg.package.override {
            enabledPlugins = [ "syslog" ] ++ builtins.attrNames cfg.plugins;
          }
        else
          cfg.package
      '';

      description = "The final package being used after applying plugins and minimalPackage.";
      readOnly = true;
    };

    include = lib.mkOption {
      default = [ ];

      description = ''
        Additional paths to load config from.
      '';

      type = listOf str;
    };

    plugins = lib.mkOption {
      default = { };

      description = ''
        Attribute set of plugin names to plugin config segments
      '';

      example = {
        cpu = "";
        memory = "";
        network = "Server 192.168.1.1 25826";
      };

      type = attrsOf lines;
    };

    user = lib.mkOption {
      default = "collectd";

      description = ''
        User under which to run collectd.
      '';

      type = nullOr str;
    };

    validateConfig = lib.mkOption {
      default = true;

      description = ''
        Validate the syntax of collectd configuration file at build time.
        Disable this if you use the Include directive on files unavailable in
        the build sandbox, or when cross-compiling.
      '';

      type = types.bool;
    };

  };

  config = lib.mkIf cfg.enable {
    # 1200 is after the default (1000) but before mkAfter (1500).
    services.collectd.extraConfig = lib.mkOrder 1200 ''
      ${baseDirLine}
      AutoLoadPlugin ${lib.boolToString cfg.autoLoadPlugin}
      Hostname "${config.networking.hostName}"

      LoadPlugin syslog
      <Plugin "syslog">
        LogLevel "info"
        NotifyLevel "OKAY"
      </Plugin>

      ${lib.concatStrings (
        lib.mapAttrsToList (plugin: pluginConfig: ''
          LoadPlugin ${plugin}
          <Plugin "${plugin}">
          ${pluginConfig}
          </Plugin>
        '') cfg.plugins
      )}

      ${lib.concatMapStrings (f: ''
        Include "${f}"
      '') cfg.include}
    '';

    systemd.services.collectd = {
      after = [ "network.target" ];
      description = "Collectd Monitoring Agent";

      serviceConfig = {
        ExecStart = "${package}/sbin/collectd -C ${conf} -f";
        Restart = "on-failure";
        RestartSec = 3;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - ${cfg.user} - - -"
    ];

    users.groups = lib.optionalAttrs (cfg.user == "collectd") {
      collectd = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "collectd") {
      collectd = {
        group = "collectd";
        isSystemUser = true;
      };
    };
  };
}
