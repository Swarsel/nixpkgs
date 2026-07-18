{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.immersed;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [
        "programs"
        "immersed-vr"
      ]
      [
        "programs"
        "immersed"
      ]
    )
  ];

  options = {
    programs.immersed = {
      enable = lib.mkEnableOption "immersed";
      package = lib.mkPackageOption pkgs "immersed" { };

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to open firewall ports for Immersed";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      extraModprobeConfig = ''
        options v4l2loopback exclusive_caps=1 card_label="v4l2loopback Virtual Camera"
      '';

      extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

      kernelModules = [
        "v4l2loopback"
        "snd-aloop"
      ];
    };

    environment.systemPackages = [ cfg.package ];

    # https://immersed.helpscoutdocs.com/article/23-connection-troubleshooting-linux
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 21000 ];

      allowedUDPPorts = [
        21000
        21010
      ];
    };
  };

  meta.maintainers = pkgs.immersed.meta.maintainers;
}
