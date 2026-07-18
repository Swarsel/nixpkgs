{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.espanso;
in
{
  options = {
    services.espanso = {
      enable = lib.mkEnableOption "Espanso";

      package = lib.mkPackageOption pkgs "espanso" {
        example = "pkgs.espanso-wayland";
      };

      extraPackages = lib.mkOption {
        default = [ ];
        description = "Extra packages to be added to Espanso service path.";
        example = lib.literalExpression "with pkgs; [ bash curl python3 ];";
        type = lib.types.listOf lib.types.package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.espanso = lib.mkIf (cfg.package.waylandSupport or false) {
      capabilities = "cap_dac_override+p";
      group = "root";
      owner = "root";
      source = lib.getExe (cfg.package.override { securityWrapperPath = config.security.wrapperDir; });
    };

    systemd.user.services.espanso = {
      description = "Espanso daemon";
      path = cfg.extraPackages;

      serviceConfig = {
        ExecStart = "${
          if (cfg.package.waylandSupport or false) then
            "${config.security.wrapperDir}/espanso"
          else
            lib.getExe cfg.package
        } daemon";

        Restart = "on-failure";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      n8henrie
      numkem
    ];
  };
}
