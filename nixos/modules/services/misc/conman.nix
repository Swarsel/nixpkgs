{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    services.conman = {
      config = lib.mkOption {
        default = null;

        description = ''
          The configuration object.

          Either `configFile` or `config` must be specified.

          See <https://github.com/dun/conman/wiki/Man-5-conman.conf#files>.
        '';

        example = ''
          server coredump=off
          server keepalive=on
          server loopback=off
          server timestamp=1h

          # global config
          global log="/var/log/conman/%N.log"
          global seropts="9600,8n1"
          global ipmiopts="U:<user>,P:<password>"
        '';

        type = lib.types.nullOr lib.types.lines;
      };

      enable = lib.mkEnableOption ''
        Enable the conman Console manager.

        Either `configFile` or `config` must be specified.
      '';

      package = lib.mkPackageOption pkgs "conman" { };

      configFile = lib.mkOption {
        default = null;

        description = ''
          The absolute path to the configuration file.

          Either `configFile` or `config` must be specified.

          See <https://github.com/dun/conman/wiki/Man-5-conman.conf#files>.
        '';

        example = "/run/secrets/conman.conf";
        type = lib.types.nullOr lib.types.path;
      };
    };
  };

  config =
    let
      cfg = config.services.conman;
      configFile =
        if cfg.configFile != null then
          cfg.configFile
        else
          pkgs.writeTextFile {
            name = "conman.conf";
            text = cfg.config;
          };
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            (cfg.configFile != null) && (cfg.config == null) || (cfg.configFile == null && cfg.config != null);

          message = "Either but not both `configFile` and `config` must be specified for conman.";
        }
      ];

      environment.systemPackages = [ cfg.package ];

      systemd.services.conmand = {
        description = "serial console management program";
        documentation = [ "man:conman(8)" ];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/conmand -F -c ${configFile}";
          KillMode = "process";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.maintainers = with lib.maintainers; [
    frantathefranta
  ];
}
