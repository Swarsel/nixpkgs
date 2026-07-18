{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.gamemode;
  settingsFormat = pkgs.formats.ini { listsAsDuplicateKeys = true; };
  configFile = settingsFormat.generate "gamemode.ini" cfg.settings;
in
{
  options = {
    programs.gamemode = {
      enable = lib.mkEnableOption "GameMode to optimise system performance on demand";
      package = lib.mkPackageOption pkgs "gamemode" { };

      enableRenice =
        lib.mkEnableOption "CAP_SYS_NICE on gamemoded to support lowering process niceness"
        // {
          default = true;
        };

      settings = lib.mkOption {
        default = { };

        description = ''
          System-wide configuration for GameMode (/etc/gamemode.ini).
          See {manpage}`gamemoded(8)` man page for available settings.
        '';

        example = lib.literalExpression ''
          {
            general = {
              renice = 10;
            };

            # Warning: GPU optimisations have the potential to damage hardware
            gpu = {
              apply_gpu_optimisations = "accept-responsibility";
              gpu_device = 0;
              amd_performance_level = "high";
            };

            custom = {
              start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
              end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
            };
          }
        '';

        type = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc."gamemode.ini".source = configFile;
      systemPackages = [ cfg.package ];
    };

    security = {
      polkit = {
        enable = true;
        enablePkexecWrapper = lib.mkDefault true;
      };

      wrappers = lib.mkIf cfg.enableRenice {
        gamemoded = {
          capabilities = "cap_sys_nice+ep";
          group = "root";
          owner = "root";
          source = "${cfg.package}/bin/gamemoded";
        };
      };
    };

    systemd = {
      packages = [ cfg.package ];

      user.services.gamemoded = {
        # Use pkexec from the security wrappers to allow users to
        # run libexec/cpugovctl & libexec/gpuclockctl as root with
        # the the actions defined in share/polkit-1/actions.
        #
        # This uses a link farm to make sure other wrapped executables
        # aren't included in PATH.
        environment.PATH = lib.mkForce (
          pkgs.linkFarm "pkexec" [
            {
              name = "pkexec";
              path = "${config.security.wrapperDir}/pkexec";
            }
          ]
        );

        serviceConfig.ExecStart = lib.mkIf cfg.enableRenice [
          "" # Tell systemd to clear the existing ExecStart list, to prevent appending to it.
          "${config.security.wrapperDir}/gamemoded"
        ];
      };
    };

    users.groups.gamemode = { };
  };

  meta = {
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
}
