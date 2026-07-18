{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.iotop;
in
{
  options = {
    programs.iotop = {
      enable = lib.mkEnableOption "iotop + setcap wrapper";
      package = lib.mkPackageOption pkgs "iotop" { example = "iotop-c"; };

      enableDelayacct = lib.mkEnableOption ''
        the task_delayacct kernel task delay accounting in order to show all
        statistics'';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = lib.mkIf cfg.enableDelayacct { "kernel.task_delayacct" = 1; };

    security.wrappers.iotop = {
      capabilities = "cap_net_admin+p";
      group = "root";
      owner = "root";
      source = lib.getExe cfg.package;
    };
  };
}
