{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.zmap;
in
{
  options.programs.zmap = {
    enable = lib.mkEnableOption "ZMap, a network scanner designed for Internet-wide network surveys";
  };

  config = lib.mkIf cfg.enable {
    environment.etc."zmap/blacklist.conf".source = "${pkgs.zmap}/etc/zmap/blacklist.conf";
    environment.etc."zmap/zmap.conf".source = "${pkgs.zmap}/etc/zmap.conf";
    environment.systemPackages = [ pkgs.zmap ];
  };
}
