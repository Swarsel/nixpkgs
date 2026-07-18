# TODO: create a common module generator for Taler and Libeufin?
{
  servicesDB ? [ ],
  servicesNoDB ? [ ],
  talerComponent ? "",
  ...
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = cfgTaler.${talerComponent};
  cfgTaler = config.services.taler;

  settingsFormat = pkgs.formats.ini { };

  configFile = config.environment.etc."taler/taler.conf".source;
  componentConfigFile = settingsFormat.generate "generated-taler-${talerComponent}.conf" cfg.settings;

  services = servicesDB ++ servicesNoDB;

  dbName = "taler-${talerComponent}-httpd";
  groupName = "taler-${talerComponent}-services";

  inherit (cfgTaler) runtimeDir;
in
{
  options = {
    services.taler.${talerComponent} = {
      enable = lib.mkEnableOption "the GNU Taler ${talerComponent}";
      package = lib.mkPackageOption pkgs "taler-${talerComponent}" { };
      # TODO: make option accept multiple debugging levels?
      debug = lib.mkEnableOption "debug logging";

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to open ports in the firewall";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings."${talerComponent}".PORT ];
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ dbName ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = dbName;
        }
      ];
    };

    services.taler.enable = cfg.enable;
    services.taler.includes = [ componentConfigFile ];

    systemd.services = lib.mergeAttrsList [
      # Main services
      (lib.genAttrs (map (n: "taler-${talerComponent}-${n}") services) (name: {
        after = [ "taler-${talerComponent}-dbinit.service" ];

        documentation = [
          "man:taler-${talerComponent}-${name}(1)"
          "info:taler-${talerComponent}"
        ];

        requires = [ "taler-${talerComponent}-dbinit.service" ];

        serviceConfig = {
          CacheDirectory = name;
          DynamicUser = true;

          ExecStart = toString [
            (lib.getExe' cfg.package name)
            "-c ${configFile}"
            (lib.optionalString cfg.debug " -L debug")
          ];

          Group = groupName;
          ReadWritePaths = [ runtimeDir ];
          Restart = "always";
          RestartSec = "10s";
          RuntimeDirectory = name;
          StateDirectory = name;
          User = dbName;
        };

        wantedBy = [ "multi-user.target" ]; # TODO slice?
      }))
      # Database Initialisation
      {
        "taler-${talerComponent}-dbinit" = {
          after = [ "postgresql.target" ];

          documentation = [
            "man:taler-${talerComponent}-dbinit(1)"
            "info:taler-${talerComponent}"
          ];

          path = [ config.services.postgresql.package ];
          requires = [ "postgresql.target" ];

          serviceConfig = {
            DynamicUser = true;
            Group = groupName;
            Restart = "on-failure";
            RestartSec = "5s";
            Type = "oneshot";
            User = dbName;
          };
        };
      }
    ];

    systemd.tmpfiles.settings = {
      "10-taler-${talerComponent}" = {
        "${runtimeDir}" = {
          d = {
            group = groupName;
            mode = "070";
            user = "nobody";
          };
        };
      };
    };

    users.groups.${groupName} = { };
  };
}
