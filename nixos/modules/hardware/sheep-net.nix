{
  config,
  lib,
  ...
}:

let
  cfg = config.hardware.sheep_net;
in
{
  options.hardware.sheep_net = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Enables sheep_net udev rules, ensures 'sheep_net' group exists, and adds
        sheep-net to boot.kernelModules and boot.extraModulePackages
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      config.boot.kernelPackages.sheep-net
    ];

    boot.kernelModules = [
      "sheep_net"
    ];

    services.udev.extraRules = ''
      KERNEL=="sheep_net", GROUP="sheep_net"
    '';

    users.groups.sheep_net = { };
  };

  meta.maintainers = with lib.maintainers; [ matthewcroughan ];
}
