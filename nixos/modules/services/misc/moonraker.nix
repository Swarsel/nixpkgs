{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.moonraker;
  pkg = cfg.package;
  opt = options.services.moonraker;
  format = pkgs.formats.ini {
    # https://github.com/NixOS/nixpkgs/pull/121613#issuecomment-885241996
    listToValue =
      l:
      if builtins.length l == 1 then
        lib.generators.mkValueStringDefault { } (lib.head l)
      else
        lib.concatMapStrings (s: "\n  ${lib.generators.mkValueStringDefault { } s}") l;

    mkKeyValue = lib.generators.mkKeyValueDefault { } ":";
  };

  unifiedConfigDir = cfg.stateDir + "/config";
in
{
  options = {
    services.moonraker = {
      enable = lib.mkEnableOption "Moonraker, an API web server for Klipper";

      package = lib.mkPackageOption pkgs "moonraker" {
        example = "moonraker.override { useGpiod = true; }";
        nullable = true;
      };

      address = lib.mkOption {
        default = "127.0.0.1";
        description = "The IP or host to listen on.";
        example = "0.0.0.0";
        type = lib.types.str;
      };

      allowSystemControl = lib.mkOption {
        default = false;

        description = ''
          Whether to allow Moonraker to perform system-level operations.

          Moonraker exposes APIs to perform system-level operations, such as
          reboot, shutdown, and management of systemd units. See the
          [documentation](https://moonraker.readthedocs.io/en/latest/web_api/#machine-commands)
          for details on what clients are able to do.
        '';

        type = lib.types.bool;
      };

      analysis.enable = lib.mkEnableOption "Runtime analysis with klipper-estimator";

      configDir = lib.mkOption {
        default = null;

        description = ''
          Deprecated directory containing client-writable configuration files.

          Clients will be able to edit files in this directory via the API. This directory must be writable.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      group = lib.mkOption {
        default = "moonraker";
        description = "Group account under which Moonraker runs.";
        type = lib.types.str;
      };

      klipperSocket = lib.mkOption {
        default = config.services.klipper.apiSocket;
        defaultText = lib.literalExpression "config.services.klipper.apiSocket";
        description = "Path to Klipper's API socket.";
        type = lib.types.path;
      };

      port = lib.mkOption {
        default = 7125;
        description = "The port to listen on.";
        type = lib.types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for Moonraker. See the [documentation](https://moonraker.readthedocs.io/en/latest/configuration/)
          for supported values.
        '';

        example = {
          authorization = {
            cors_domains = [
              "https://app.fluidd.xyz"
              "https://my.mainsail.xyz"
            ];

            trusted_clients = [ "10.0.0.0/24" ];
          };
        };

        type = format.type;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/moonraker";
        description = "The directory containing the Moonraker databases.";
        type = lib.types.path;
      };

      user = lib.mkOption {
        default = "moonraker";
        description = "User account under which Moonraker runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.allowSystemControl -> config.security.polkit.enable;
        message = "services.moonraker.allowSystemControl requires polkit to be enabled (security.polkit.enable).";
      }
    ];

    environment.etc."moonraker.cfg".source =
      let
        forcedConfig = {
          machine = {
            validate_service = false;
          };

          server = {
            host = cfg.address;
            klippy_uds_address = cfg.klipperSocket;
            port = cfg.port;
          };
        }
        // (lib.optionalAttrs (cfg.configDir != null) {
          file_manager = {
            config_path = cfg.configDir;
          };
        });
        fullConfig = lib.recursiveUpdate cfg.settings forcedConfig;
      in
      format.generate "moonraker.cfg" fullConfig;

    security.polkit.extraConfig = lib.optionalString cfg.allowSystemControl ''
      // nixos/moonraker: Allow Moonraker to perform system-level operations
      //
      // This was enabled via services.moonraker.allowSystemControl.
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.systemd1.manage-units" ||
             action.id == "org.freedesktop.login1.power-off" ||
             action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
             action.id == "org.freedesktop.login1.reboot" ||
             action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
             action.id.startsWith("org.freedesktop.packagekit.")) &&
             subject.user == "${cfg.user}") {
          return polkit.Result.YES;
        }
      });
    '';

    services.moonraker.settings = {
      # enable analysis with our own klipper-estimator, disable updating it
      analysis = lib.mkIf (cfg.analysis.enable) {
        enable_estimator_updates = false;
        platform = "linux";
      };

      # set this to false, otherwise we'll get a warning indicating that `/etc/klipper.cfg`
      # is not located in the moonraker config directory.
      file_manager.check_klipper_config_path = lib.mkIf (!config.services.klipper.mutableConfig) false;
      # suppress PolicyKit warnings if system control is disabled
      machine.provider = lib.mkIf (!cfg.allowSystemControl) (lib.mkDefault "none");
    };

    systemd.services.moonraker = {
      after = [ "network.target" ] ++ lib.optional config.services.klipper.enable "klipper.service";
      description = "Moonraker, an API web server for Klipper";
      # Needs `ip` command
      path = [ pkgs.iproute2 ];

      # Moonraker really wants its own config to be writable...
      script = ''
        config_path=${
          # Deprecated separate config dir
          if cfg.configDir != null then
            "${cfg.configDir}/moonraker-temp.cfg"
          # Config in unified data path
          else
            "${unifiedConfigDir}/moonraker-temp.cfg"
        }
        mkdir -p $(dirname "$config_path")
        cp /etc/moonraker.cfg "$config_path"
        chmod u+w "$config_path"
        exec ${pkg}/bin/moonraker -d ${cfg.stateDir} -c "$config_path"
      '';

      serviceConfig = {
        Group = cfg.group;
        PrivateTmp = true;
        User = cfg.user;
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' - ${cfg.user} ${cfg.group} - -"
    ]
    ++ lib.optional (cfg.configDir != null) "d '${cfg.configDir}' - ${cfg.user} ${cfg.group} - -"
    ++ lib.optionals cfg.analysis.enable [
      "d '${cfg.stateDir}/tools' - ${cfg.user} ${cfg.group} - -"
      "d '${cfg.stateDir}/tools/klipper_estimator' - ${cfg.user} ${cfg.group} - -"
      "L+ '${cfg.stateDir}/tools/klipper_estimator/klipper_estimator_linux' - - - - ${lib.getExe pkgs.klipper-estimator}"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "moonraker") {
      moonraker.gid = config.ids.gids.moonraker;
    };

    users.users = lib.optionalAttrs (cfg.user == "moonraker") {
      moonraker = {
        group = cfg.group;
        uid = config.ids.uids.moonraker;
      };
    };

    warnings =
      [ ]
      ++ (lib.optional (lib.head (cfg.settings.update_manager.enable_system_updates or [ false ])) ''
        Enabling system updates is not supported on NixOS and will lead to non-removable warnings in some clients.
      '')
      ++ (lib.optional (cfg.configDir != null) ''
        services.moonraker.configDir has been deprecated upstream and will be removed.

        Action: ${
          if cfg.configDir == unifiedConfigDir then
            "Simply remove services.moonraker.configDir from your config."
          else
            "Move files from `${cfg.configDir}` to `${unifiedConfigDir}` then remove services.moonraker.configDir from your config."
        }
      '');
  };

  meta.maintainers = with lib.maintainers; [
    cab404
    vtuan10
    zhaofengli
  ];
}
