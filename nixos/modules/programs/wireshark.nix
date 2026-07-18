{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.wireshark;
  wireshark = cfg.package;
in
{
  options = {
    programs.wireshark = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to add Wireshark to the global environment and create a 'wireshark'
          group. To configure what users can capture, set the `dumpcap.enable` and
          `usbmon.enable` options. By default, users in the 'wireshark' group are
          allowed to capture network traffic but not USB traffic.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "wireshark-cli" {
        example = "wireshark";
      };

      dumpcap.enable = lib.mkOption {
        default = true;

        description = ''
          Whether to allow users in the 'wireshark' group to capture network traffic. This
          configures a setcap wrapper for 'dumpcap' for users in the 'wireshark' group.
        '';

        type = lib.types.bool;
      };

      usbmon.enable = lib.mkOption {
        default = false;

        description = ''
          Whether to allow users in the 'wireshark' group to capture USB traffic. This adds
          udev rules to give users in the 'wireshark' group read permissions to all devices
          in the usbmon subsystem.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ wireshark ];

    security.wrappers.dumpcap = lib.mkIf cfg.dumpcap.enable {
      capabilities = "cap_net_raw,cap_net_admin+eip";
      group = "wireshark";
      owner = "root";
      permissions = "u+rx,g+x";
      source = "${wireshark}/bin/dumpcap";
    };

    services.udev.packages = lib.mkIf cfg.usbmon.enable [
      (pkgs.writeTextDir "etc/udev/rules.d/85-wireshark-usbmon.rules" ''
        SUBSYSTEM=="usbmon", MODE="0640", GROUP="wireshark"
      '')
    ];

    users.groups.wireshark = { };
  };
}
