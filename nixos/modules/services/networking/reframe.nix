{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.reframe;
  settingsFormat = pkgs.formats.ini { };
in
{
  options.services.reframe = {
    enable = lib.mkEnableOption "DRM/KMS based remote desktop for Linux that supports Wayland/NVIDIA/headless/login…";
    package = lib.mkPackageOption pkgs "reframe" { };

    configs = lib.mkOption {
      default = { };
      description = "Configurations for ReFrame";

      example = ''
        {
          main = {
            reframe = {
              card = "card0";
              connector = "eDP-1";
              rotation = 0;
              desktop-width = 1920;
              desktop-height = 1080;
              monitor-x = 0;
              monitor-y = 0;
              default-width = 1920;
              default-height = 1080;
              resize = true;
              cursor = true;
              wakeup = true;
              damage = "cpu";
              fps = 30;
            };
            vnc = {
              ip = "0.0.0.0";
              port = 5933;
              password = "password";
              type = "libvncserver";
            };
          };
        }
      '';

      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "reframe/${name}.conf" {
        group = "root";
        mode = "0644";
        source = settingsFormat.generate "${name}.conf" value;
        user = "root";
      }
    ) cfg.configs;

    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "reframe-server@${name}" {
        wantedBy = [ "multi-user.target" ];
      }
    ) cfg.configs;

    systemd.tmpfiles.packages = [ cfg.package ];
    users.groups.reframe = { };

    users.users.reframe = {
      description = "ReFrame Remote Desktop";
      group = "reframe";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    bitbloxhub
  ];
}
