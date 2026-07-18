{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bpftune;
in
{
  options = {
    services.bpftune = {
      enable = lib.mkEnableOption "bpftune BPF driven auto-tuning";
      package = lib.mkPackageOption pkgs "bpftune" { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ cfg.package ];

    systemd.services.bpftune = {
      path = [ pkgs.kmod ]; # bpftune calls modprobe
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
