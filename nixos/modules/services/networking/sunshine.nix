{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    literalExpression
    mkIf
    mkDefault
    types
    optionals
    getExe
    ;
  inherit (utils) escapeSystemdExecArgs;
  cfg = config.services.sunshine;

  # ports used are offset from a single base port, see https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html#port
  generatePorts = port: offsets: map (offset: port + offset) offsets;
  defaultPort = 47989;

  appsFormat = pkgs.formats.json { };
  settingsFormat = pkgs.formats.keyValue { };

  appsFile = appsFormat.generate "apps.json" cfg.applications;
  configFile = settingsFormat.generate "sunshine.conf" cfg.settings;
in
{
  options.services.sunshine = with types; {
    enable = mkEnableOption "Sunshine, a self-hosted game stream host for Moonlight";
    package = mkPackageOption pkgs "sunshine" { };

    applications = mkOption {
      default = { };

      description = ''
        Configuration for applications to be exposed to Moonlight. If this is set, no configuration is possible from the web UI, and must be by the `settings` option.
      '';

      example = literalExpression ''
        {
          env = {
            PATH = "$(PATH):$(HOME)/.local/bin";
          };
          apps = [
            {
              name = "1440p Desktop";
              prep-cmd = [
                {
                  do = "''${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.2560x1440@144";
                  undo = "''${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.3440x1440@144";
                }
              ];
              exclude-global-prep-cmd = "false";
              auto-detach = "true";
            }
          ];
        }
      '';

      type = submodule {
        options = {
          apps = mkOption {
            default = [ ];

            description = ''
              Applications to be exposed to Moonlight.
            '';

            type = listOf attrs;
          };

          env = mkOption {
            default = { };

            description = ''
              Environment variables to be set for the applications.
            '';

            type = attrsOf str;
          };
        };
      };
    };

    autoStart = mkOption {
      default = true;

      description = ''
        Whether sunshine should be started automatically.
      '';

      type = bool;
    };

    capSysAdmin = mkOption {
      default = false;

      description = ''
        Whether to give the Sunshine binary CAP_SYS_ADMIN, required for DRM/KMS screen capture.
      '';

      type = bool;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Whether to automatically open ports in the firewall.
      '';

      type = bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        Settings to be rendered into the configuration file. If this is set, no configuration is possible from the web UI.

        See <https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html> for syntax.
      '';

      example = literalExpression ''
        {
          sunshine_name = "nixos";
        }
      '';

      type = submodule (settings: {
        options.port = mkOption {
          default = defaultPort;

          description = ''
            Base port -- others used are offset from this one, see <https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html#port> for details.
          '';

          type = port;
        };

        freeformType = settingsFormat.type;
      });
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    hardware.uinput.enable = true;

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = generatePorts cfg.settings.port [
        (-5)
        0
        1
        21
      ];

      allowedUDPPorts = generatePorts cfg.settings.port [
        9
        10
        11
        13
        21
      ];
    };

    security.wrappers.sunshine = mkIf cfg.capSysAdmin {
      capabilities = "cap_sys_admin+p";
      group = "root";
      owner = "root";
      source = getExe cfg.package;
    };

    services.avahi = {
      enable = mkDefault true;

      publish = {
        enable = mkDefault true;
        userServices = mkDefault true;
      };
    };

    services.sunshine.settings.file_apps = mkIf (cfg.applications.apps != [ ]) "${appsFile}";
    services.udev.packages = [ cfg.package ];

    systemd.user.services.sunshine = {
      after = [ "graphical-session.target" ];
      description = "Self-hosted game stream host for Moonlight";
      environment.PATH = lib.mkForce null; # don't use default PATH, needed for tray icon menu links to work
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        # only add configFile if an application or a setting other than the default port is set to allow configuration from web UI
        ExecStart = escapeSystemdExecArgs (
          [
            (if cfg.capSysAdmin then "${config.security.wrapperDir}/sunshine" else "${getExe cfg.package}")
          ]
          ++ optionals (
            cfg.applications.apps != [ ]
            || (builtins.length (builtins.attrNames cfg.settings) > 1 || cfg.settings.port != defaultPort)
          ) [ "${configFile}" ]
        );

        Restart = "on-failure";
        RestartSec = "5s";
      };

      startLimitBurst = 5;
      startLimitIntervalSec = 500;
      wantedBy = mkIf cfg.autoStart [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
    };
  };
}
