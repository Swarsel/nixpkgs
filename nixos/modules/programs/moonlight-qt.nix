{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.moonlight-qt;
in
{
  options.programs.moonlight-qt = {
    enable = lib.mkEnableOption "Moonlight Qt, a client for playing your PC games on almost any device";
    package = lib.mkPackageOption pkgs "moonlight-qt" { };

    capSysNice = lib.mkOption {
      default = false;

      description = ''
        Add the CAP_SYS_NICE capability to Moonlight Qt so that it may raise
        its scheduling priority.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.moonlight = lib.mkIf cfg.capSysNice {
      capabilities = "cap_sys_nice+ep";
      group = "root";
      owner = "root";
      source = lib.getExe cfg.package;
    };
  };

  meta.maintainers = with lib.maintainers; [ aaravrav ];
}
