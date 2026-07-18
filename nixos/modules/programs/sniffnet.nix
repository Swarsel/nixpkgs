{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.sniffnet;
in

{
  options = {
    programs.sniffnet = {
      enable = lib.mkEnableOption "sniffnet, a network traffic monitor application";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sniffnet ];

    security.wrappers.sniffnet = {
      capabilities = "cap_net_raw,cap_net_admin=eip";
      group = "root";
      owner = "root";
      source = "${pkgs.sniffnet}/bin/sniffnet";
    };
  };

  meta.maintainers = [ ];
}
