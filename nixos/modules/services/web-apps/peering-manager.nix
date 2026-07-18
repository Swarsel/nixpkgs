{
  config,
  lib,
  pkgs,
  buildEnv,
  ...
}:

let
  cfg = config.services.peering-manager;

  pythonFmt = pkgs.formats.pythonVars { };
  settingsFile = pythonFmt.generate "peering-manager-settings.py" cfg.settings;
  extraConfigFile = pkgs.writeTextFile {
    name = "peering-manager-extraConfig.py";
    text = cfg.extraConfig;
  };
  configFile = pkgs.concatText "configuration.py" [
    settingsFile
    extraConfigFile
  ];
  finalConfigFile =
    if (cfg.environmentFile != null) then "/var/lib/peering-manager/configuration.py" else configFile;

  pkg =
    (pkgs.peering-manager.overrideAttrs (old: {
      postInstall = ''
        ln -s ${finalConfigFile} $out/opt/peering-manager/peering_manager/configuration.py
      ''
      + lib.optionalString cfg.enableLdap ''
        ln -s ${cfg.ldapConfigPath} $out/opt/peering-manager/peering_manager/ldap_config.py
      '';
    })).override
      {
        inherit (cfg) plugins;
      };
  peeringManagerManageScript = pkgs.writeScriptBin "peering-manager-manage" ''
    #!${pkgs.stdenv.shell}
    export PYTHONPATH=${pkg.pythonPath}
    sudo -u peering-manager ${pkg}/bin/peering-manager "$@"
  '';

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "peering-manager" "enableOidc" ] ''
      The enableOidc option has been removed, since peering-manager has OIDC support builtin since version >= 1.9.0.

      Make sure to update your OIDC configuration according to the documentation:
      https://peering-manager.readthedocs.io/en/v1.9.3/administration/authentication/oidc/
    '')
    (lib.mkRemovedOptionModule [ "services" "peering-manager" "oidcConfigPath" ] ''
      The oidcConfigPath option has been removed, since peering-manager has OIDC support builtin since version >= 1.9.0.

      The new config settings for OIDC are explained in the documentation:
      https://peering-manager.readthedocs.io/en/v1.9.3/administration/authentication/oidc/
    '')
  ];

  options.services.peering-manager = with lib; {
    enable = mkOption {
      default = false;

      description = ''
        Enable Peering Manager.

        This module requires a reverse proxy that serves `/static` separately.
        See this [example](https://github.com/peering-manager/contrib/blob/main/nginx.conf) on how to configure this.
      '';

      type = types.bool;
    };

    enableLdap = mkOption {
      default = false;

      description = ''
        Enable LDAP-Authentication for Peering Manager.

        This requires a configuration file being pass through `ldapConfigPath`.
      '';

      type = types.bool;
    };

    enableScheduledTasks = mkOption {
      default = true;

      description = ''
        Set up [scheduled tasks](https://peering-manager.readthedocs.io/en/stable/setup/8-scheduled-tasks/)
      '';

      type = types.bool;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.

        Secrets may be passed to the service without adding them to the world-readable
        Nix store, by specifying placeholder variables as the option value in Nix and
        setting these variables accordingly in the environment file.

        ```
          # snippet of peering-manager-related config
          services.peering-manager.settings.SOCIAL_AUTH_OIDC_SECRET = "$PM_OIDC_SECRET";
        ```

        ```
          # content of the environment file
          PM_OIDC_SECRET=topsecret
        ```

        Note that this file needs to be available on the host on which
        `peering-manager` is running.
      '';

      example = "/run/secrets/peering-manager.env";
      type = with types; nullOr path;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Additional lines of configuration appended to the `configuration.py`.
        See the [documentation](https://peering-manager.readthedocs.io/en/stable/configuration/optional-settings/) for more possible options.
      '';

      type = types.lines;
    };

    ldapConfigPath = mkOption {
      description = ''
        Path to the Configuration-File for LDAP-Authentication, will be loaded as `ldap_config.py`.
        See the [documentation](https://peering-manager.readthedocs.io/en/stable/setup/6-ldap/#configuration) for possible options.
      '';

      type = types.path;
    };

    listenAddress = mkOption {
      default = "[::1]";

      description = ''
        Address the server will listen on.
      '';

      type = types.str;
    };

    peeringdbApiKeyFile = mkOption {
      default = null;

      description = ''
        Path to a file containing the PeeringDB API key.
      '';

      type = with types; nullOr path;
    };

    plugins = mkOption {
      default = _: [ ];

      defaultText = literalExpression ''
        python3Packages: with python3Packages; [];
      '';

      description = ''
        List of plugin packages to install.
      '';

      type = types.functionTo (types.listOf types.package);
    };

    port = mkOption {
      default = 8001;

      description = ''
        Port the server will listen on.
      '';

      type = types.port;
    };

    secretKeyFile = mkOption {
      description = ''
        Path to a file containing the secret key.
      '';

      type = types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration options to set in `configuration.py`.
        See the [documentation](https://peering-manager.readthedocs.io/en/stable/configuration/optional-settings/) for more possible options.
      '';

      type = lib.types.submodule {
        options = {
          ALLOWED_HOSTS = lib.mkOption {
            default = [ "*" ];

            description = ''
              A list of valid fully-qualified domain names (FQDNs) and/or IP
              addresses that can be used to reach the peering manager service.
            '';

            type = with lib.types; listOf str;
          };
        };

        freeformType = pythonFmt.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ peeringManagerManageScript ];

    services.peering-manager = {
      extraConfig = ''
        with open("${cfg.secretKeyFile}", "r") as file:
          SECRET_KEY = file.readline()
      ''
      + lib.optionalString (cfg.peeringdbApiKeyFile != null) ''
        with open("${cfg.peeringdbApiKeyFile}", "r") as file:
          PEERINGDB_API_KEY = file.readline()
      '';

      plugins = (ps: (lib.optionals cfg.enableLdap [ ps.django-auth-ldap ]));

      settings = {
        DATABASE = {
          HOST = "/run/postgresql";
          NAME = "peering-manager";
          USER = "peering-manager";
        };

        # Redis database settings. Redis is used for caching and for queuing background tasks such as webhook events. A separate
        # configuration exists for each. Full connection details are required in both sections, and it is strongly recommended
        # to use two separate database IDs.
        REDIS = {
          caching = {
            DATABASE = 1;
            UNIX_SOCKET_PATH = config.services.redis.servers.peering-manager.unixSocket;
          };

          tasks = {
            DATABASE = 0;
            UNIX_SOCKET_PATH = config.services.redis.servers.peering-manager.unixSocket;
          };
        };
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "peering-manager" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "peering-manager";
        }
      ];
    };

    services.redis.servers.peering-manager.enable = true;
    system.build.peeringManagerPkg = pkg;

    systemd.services =
      let
        defaults = {
          environment = {
            PYTHONPATH = pkg.pythonPath;
          };

          serviceConfig = {
            Group = "peering-manager";
            Restart = "on-failure";
            StateDirectory = "peering-manager";
            StateDirectoryMode = "0750";
            User = "peering-manager";
            WorkingDirectory = "/var/lib/peering-manager";
          };
        };
      in
      {
        peering-manager = lib.recursiveUpdate defaults {
          after = [
            "peering-manager-migration.service"
          ]
          ++ lib.optionals (cfg.environmentFile != null) [ "peering-manager-config.service" ];

          description = "Peering Manager WSGI Service";

          preStart = ''
            ${pkg}/bin/peering-manager remove_stale_contenttypes --no-input
          '';

          serviceConfig = {
            ExecStart = ''
              ${pkg.python.pkgs.gunicorn}/bin/gunicorn peering_manager.wsgi \
                --bind ${cfg.listenAddress}:${toString cfg.port} \
                --pythonpath ${pkg}/opt/peering-manager
            '';
          };

          wantedBy = [ "peering-manager.target" ];
        };

        peering-manager-config = lib.mkIf (cfg.environmentFile != null) (
          lib.recursiveUpdate defaults {
            description = "Peering Manager config file setup";

            serviceConfig = {
              EnvironmentFile = [ cfg.environmentFile ];
              ExecStart = "${lib.getExe pkgs.envsubst} -i ${configFile} -o ${finalConfigFile}";
              Type = "oneshot";
            };

            wantedBy = [ "peering-manager.target" ];
          }
        );

        peering-manager-configuration-deployment = lib.recursiveUpdate defaults {
          after = [ "peering-manager.service" ];
          description = "Push configuration to routers";

          serviceConfig = {
            ExecStart = "${pkg}/bin/peering-manager configure_routers";
            Type = "oneshot";
          };
        };

        peering-manager-housekeeping = lib.recursiveUpdate defaults {
          after = [ "peering-manager.service" ];
          description = "Peering Manager housekeeping job";

          serviceConfig = {
            ExecStart = "${pkg}/bin/peering-manager housekeeping";
            Type = "oneshot";
          };
        };

        peering-manager-migration = lib.recursiveUpdate defaults {
          after = lib.mkIf (cfg.environmentFile != null) [ "peering-manager-config.service" ];
          description = "Peering Manager migrations";

          serviceConfig = {
            ExecStart = "${pkg}/bin/peering-manager migrate";
            Type = "oneshot";
          };

          wantedBy = [ "peering-manager.target" ];
        };

        peering-manager-peeringdb-sync = lib.recursiveUpdate defaults {
          after = [ "peering-manager.service" ];
          description = "PeeringDB sync";

          serviceConfig = {
            ExecStart = "${pkg}/bin/peering-manager peeringdb_sync";
            Type = "oneshot";
          };
        };

        peering-manager-prefix-fetch = lib.recursiveUpdate defaults {
          after = [ "peering-manager.service" ];
          description = "Fetch IRR AS-SET prefixes";

          serviceConfig = {
            ExecStart = "${pkg}/bin/peering-manager get_irr_data";
            Type = "oneshot";
          };
        };

        peering-manager-rq = lib.recursiveUpdate defaults {
          after = [ "peering-manager.service" ];
          description = "Peering Manager Request Queue Worker";
          serviceConfig.ExecStart = "${pkg}/bin/peering-manager rqworker high default low";
          wantedBy = [ "peering-manager.target" ];
        };

        peering-manager-session-poll = lib.recursiveUpdate defaults {
          after = [ "peering-manager.service" ];
          description = "Poll peering sessions from routers";

          serviceConfig = {
            ExecStart = "${pkg}/bin/peering-manager poll_bgp_sessions";
            Type = "oneshot";
          };
        };
      };

    systemd.targets.peering-manager = {
      after = [
        "network-online.target"
        "redis-peering-manager.service"
      ];

      description = "Target for all Peering Manager services";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.timers = {
      peering-manager-configuration-deployment = {
        enable = lib.mkDefault cfg.enableScheduledTasks;
        description = "Push router configuration every hour 5 minutes before full hour";
        timerConfig.OnCalendar = "*:55:00";
        wantedBy = [ "timers.target" ];
      };

      peering-manager-housekeeping = {
        description = "Run Peering Manager housekeeping job";
        timerConfig.OnCalendar = "daily";
        wantedBy = [ "timers.target" ];
      };

      peering-manager-peeringdb-sync = {
        enable = lib.mkDefault cfg.enableScheduledTasks;
        description = "Sync PeeringDB at 2:30";
        timerConfig.OnCalendar = "02:30:00";
        wantedBy = [ "timers.target" ];
      };

      peering-manager-prefix-fetch = {
        enable = lib.mkDefault cfg.enableScheduledTasks;
        description = "Fetch IRR AS-SET prefixes at 4:30";
        timerConfig.OnCalendar = "04:30:00";
        wantedBy = [ "timers.target" ];
      };

      peering-manager-session-poll = {
        enable = lib.mkDefault cfg.enableScheduledTasks;
        description = "Poll peering sessions from routers every hour";
        timerConfig.OnCalendar = "*:00:00";
        wantedBy = [ "timers.target" ];
      };
    };

    users.groups."${config.services.redis.servers.peering-manager.user}".members = [
      "peering-manager"
    ];

    users.groups.peering-manager = { };

    users.users.peering-manager = {
      group = "peering-manager";
      home = "/var/lib/peering-manager";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ yureka-wdz ];
}
