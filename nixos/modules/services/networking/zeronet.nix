{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    generators
    literalExpression
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    recursiveUpdate
    types
    ;
  cfg = config.services.zeronet;
  dataDir = "/var/lib/zeronet";
  configFile = pkgs.writeText "zeronet.conf" (
    generators.toINI { } (recursiveUpdate defaultSettings cfg.settings)
  );

  defaultSettings = {
    global = {
      data_dir = dataDir;
      fileserver_port = cfg.fileserverPort;
      log_dir = dataDir;

      tor =
        if !cfg.tor then
          "disable"
        else if cfg.torAlways then
          "always"
        else
          "enable";

      ui_port = cfg.port;
    };
  };
in
with lib;
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "zeronet"
      "dataDir"
    ] "Zeronet will store data by default in /var/lib/zeronet")
    (mkRemovedOptionModule [
      "services"
      "zeronet"
      "logDir"
    ] "Zeronet will log by default in /var/lib/zeronet")
  ];

  options.services.zeronet = {
    enable = mkEnableOption "zeronet";
    package = mkPackageOption pkgs "zeronet" { };

    fileserverPort = mkOption {
      default = 12261;
      description = "Zeronet fileserver port.";
      # Not optional: when absent zeronet tries to write one to the
      # read-only config file and crashes
      type = types.port;
    };

    port = mkOption {
      default = 43110;
      description = "Optional zeronet web UI port.";
      type = types.port;
    };

    settings = mkOption {
      default = { };

      description = ''
        {file}`zeronet.conf` configuration. Refer to
        <https://zeronet.readthedocs.io/en/latest/faq/#is-it-possible-to-use-a-configuration-file>
        for details on supported values;
      '';

      example = literalExpression "{ global.tor = enable; }";

      type =
        with types;
        attrsOf (
          attrsOf (oneOf [
            str
            int
            bool
            (listOf str)
          ])
        );
    };

    tor = mkOption {
      default = false;
      description = "Use TOR for zeronet traffic where possible.";
      type = types.bool;
    };

    torAlways = mkOption {
      default = false;
      description = "Use TOR for all zeronet traffic.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services.tor = mkIf cfg.tor {
      enable = true;

      settings = {
        CacheDirectoryGroupReadable = true;
        ControlPort = 9051;
        CookieAuthFileGroupReadable = true;
        CookieAuthentication = true;
      };
    };

    systemd.services.zeronet = {
      after = [ "network.target" ] ++ optional cfg.tor "tor.service";
      description = "zeronet";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/zeronet --config_file ${configFile}";
        StateDirectory = "zeronet";
        SupplementaryGroups = mkIf cfg.tor [ "tor" ];
        User = "zeronet";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    inherit (pkgs.zeronet.meta) maintainers;
  };
}
