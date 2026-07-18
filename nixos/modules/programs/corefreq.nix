{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.corefreq;
  kernelPackages = config.boot.kernelPackages;
in
{
  options = {
    programs.corefreq = {
      enable = lib.mkEnableOption "Whether to enable the corefreq daemon and kernel module";

      package = lib.mkOption {
        default = kernelPackages.corefreq;
        defaultText = lib.literalExpression "config.boot.kernelPackages.corefreq";

        description = ''
          The corefreq package to use.
        '';

        type = lib.types.package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.package ];
    boot.kernelModules = [ "corefreqk" ];
    environment.systemPackages = [ cfg.package ];

    # Create a systemd service for the corefreq daemon
    systemd.services.corefreq = {
      description = "CoreFreq daemon";

      serviceConfig = {
        ExecStart = lib.getExe' cfg.package "corefreqd";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
