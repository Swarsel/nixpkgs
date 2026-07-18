{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bosun;

  configFile = pkgs.writeText "bosun.conf" ''
    ${lib.optionalString (cfg.opentsdbHost != null) "tsdbHost = ${cfg.opentsdbHost}"}
    ${lib.optionalString (cfg.influxHost != null) "influxHost = ${cfg.influxHost}"}
    httpListen = ${cfg.listenAddress}
    stateFile = ${cfg.stateFile}
    ledisDir = ${cfg.ledisDir}
    checkFrequency = ${cfg.checkFrequency}

    ${cfg.extraConfig}
  '';

in
{

  options = {

    services.bosun = {

      enable = lib.mkEnableOption "bosun";
      package = lib.mkPackageOption pkgs "bosun" { };

      checkFrequency = lib.mkOption {
        default = "5m";

        description = ''
          Bosun's check frequency
        '';

        type = lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra configuration options for Bosun. You should describe your
          desired templates, alerts, macros, etc through this configuration
          option.

          A detailed description of the supported syntax can be found at-spi2-atk
          <https://bosun.org/configuration.html>
        '';

        type = lib.types.lines;
      };

      group = lib.mkOption {
        default = "bosun";

        description = ''
          Group account under which bosun runs.
        '';

        type = lib.types.str;
      };

      influxHost = lib.mkOption {
        default = null;

        description = ''
          Host and port of the influxdb database.
        '';

        example = "localhost:8086";
        type = lib.types.nullOr lib.types.str;
      };

      ledisDir = lib.mkOption {
        default = "/var/lib/bosun/ledis_data";

        description = ''
          Path to bosun's ledis data dir
        '';

        type = lib.types.path;
      };

      listenAddress = lib.mkOption {
        default = ":8070";

        description = ''
          The host address and port that bosun's web interface will listen on.
        '';

        type = lib.types.str;
      };

      opentsdbHost = lib.mkOption {
        default = "localhost:4242";

        description = ''
          Host and port of the OpenTSDB database that stores bosun data.
          To disable opentsdb you can pass null as parameter.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      stateFile = lib.mkOption {
        default = "/var/lib/bosun/bosun.state";

        description = ''
          Path to bosun's state file.
        '';

        type = lib.types.path;
      };

      user = lib.mkOption {
        default = "bosun";

        description = ''
          User account under which bosun runs.
        '';

        type = lib.types.str;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.bosun = {
      description = "bosun metrics collector (part of Bosun)";

      preStart = ''
        mkdir -p "$(dirname "${cfg.stateFile}")";
        touch "${cfg.stateFile}"
        touch "${cfg.stateFile}.tmp"

        mkdir -p "${cfg.ledisDir}";

        if [ "$(id -u)" = 0 ]; then
          chown ${cfg.user}:${cfg.group} "${cfg.stateFile}"
          chown ${cfg.user}:${cfg.group} "${cfg.stateFile}.tmp"
          chown ${cfg.user}:${cfg.group} "${cfg.ledisDir}"
        fi
      '';

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/bosun -c ${configFile}
        '';

        Group = cfg.group;
        PermissionsStartOnly = true;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.bosun.gid = config.ids.gids.bosun;

    users.users.bosun = {
      description = "bosun user";
      group = "bosun";
      uid = config.ids.uids.bosun;
    };

  };

}
