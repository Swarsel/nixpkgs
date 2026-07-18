{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.gpu-screen-recorder;
  package = cfg.package.override {
    inherit (config.security) wrapperDir;
  };
in
{
  options = {
    programs.gpu-screen-recorder = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to install gpu-screen-recorder and generate setcap
          wrappers for promptless recording.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "gpu-screen-recorder" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers."gsr-kms-server" = {
      capabilities = "cap_sys_admin+ep";
      group = "root";
      owner = "root";
      source = lib.getExe' package "gsr-kms-server";
    };
  };

  meta.maintainers = with lib.maintainers; [ timschumi ];
}
