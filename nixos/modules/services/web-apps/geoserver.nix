{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.geoserver;

in
{
  options = {
    services.geoserver = {
      enable = mkEnableOption "Geoserver service";
      package = lib.mkPackageOption pkgs "geoserver" { };

      group = mkOption {
        default = "geoserver";
        description = "The user's group.";
        type = types.str;
      };

      jettyOpts = mkOption {
        default = "";
        description = "Any options passed to the Jetty web server via the `JETTY_OPTS` environment variable. See [startup.sh](https://github.com/geoserver/geoserver/blob/main/src/release/bin/startup.sh) for details.";
        example = "jetty.http.port=1234";
        type = types.lines;
      };

      jvmOpts = mkOption {
        default = "";
        description = "Any options passed to the JVM via the `JAVA_OPTS` environment variable. See [startup.sh](https://github.com/geoserver/geoserver/blob/main/src/release/bin/startup.sh) for details.";
        type = types.lines;
      };

      user = mkOption {
        default = "geoserver";
        description = "The (system) user that will run the service.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.geoserver = {
      description = "Geoserver";

      environment = {
        GEOSERVER_DATA_DIR = "/var/lib/geoserver";
        GEOSERVER_HOME = "${cfg.package}/share/geoserver";
        JAVA_OPTS = "${cfg.jvmOpts}";
        JETTY_OPTS = "${cfg.jettyOpts}";
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/geoserver-startup";
        Group = cfg.group;
        NoNewPrivileges = true;
        ProtectHome = true; # true=deny access to /home, /root, /run/user
        StateDirectory = "geoserver";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups."${cfg.group}" = { };

    users.users."${cfg.user}" = {
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta.teams = [ lib.teams.geospatial ];
}
