{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dublin-traceroute;

in
{
  options = {
    programs.dublin-traceroute = {
      enable = lib.mkEnableOption "dublin-traceroute (including setcap wrapper)";
      package = lib.mkPackageOption pkgs "dublin-traceroute" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.dublin-traceroute = {
      capabilities = "cap_net_raw+p";
      group = "root";
      owner = "root";
      source = lib.getExe cfg.package;
    };
  };

  meta.maintainers = pkgs.dublin-traceroute.meta.maintainers;
}
