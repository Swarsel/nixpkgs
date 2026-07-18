{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.envision;
in
{

  options = {
    programs.envision = {
      enable = lib.mkEnableOption "envision";
      package = lib.mkPackageOption pkgs "envision" { };

      openFirewall = lib.mkEnableOption "the default ports in the firewall for the WiVRn server" // {
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 9757 ];
      allowedUDPPorts = [ 9757 ];
    };

    services.avahi = {
      enable = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };

    services.udev = {
      enable = true;

      packages = with pkgs; [
        xr-hardware
      ];
    };
  };

  meta.maintainers = pkgs.envision.meta.maintainers;
}
