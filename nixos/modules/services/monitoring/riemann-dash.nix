{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.riemann-dash;

  conf = pkgs.writeText "config.rb" ''
    riemann_base = "${cfg.dataDir}"
    config.store[:ws_config] = "#{riemann_base}/config/config.json"
    ${cfg.config}
  '';

  launcher = pkgs.writeScriptBin "riemann-dash" ''
    #!/bin/sh
    exec ${pkgs.riemann-dash}/bin/riemann-dash ${conf}
  '';

in
{

  options = {

    services.riemann-dash = {
      config = lib.mkOption {
        description = ''
          Contents added to the end of the riemann-dash configuration file.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable the riemann-dash dashboard daemon.
        '';

        type = lib.types.bool;
      };

      dataDir = lib.mkOption {
        default = "/var/riemann-dash";

        description = ''
          Location of the riemann-base dir. The dashboard configuration file is
          is stored to this directory. The directory is created automatically on
          service start, and owner is set to the riemanndash user.
        '';

        type = lib.types.str;
      };
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.riemann-dash = {
      after = [ "riemann.service" ];

      preStart = ''
        mkdir -p '${cfg.dataDir}/config'
      '';

      serviceConfig = {
        ExecStart = "${launcher}/bin/riemann-dash";
        User = "riemanndash";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "riemann.service" ];
    };

    systemd.tmpfiles.settings."10-riemanndash".${cfg.dataDir}.d = {
      group = "riemanndash";
      user = "riemanndash";
    };

    users.groups.riemanndash.gid = config.ids.gids.riemanndash;

    users.users.riemanndash = {
      description = "riemann-dash daemon user";
      group = "riemanndash";
      uid = config.ids.uids.riemanndash;
    };

  };

}
