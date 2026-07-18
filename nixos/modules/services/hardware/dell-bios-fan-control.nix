{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hardware.dell-bios-fan-control;
in
{
  options.services.hardware.dell-bios-fan-control = {
    enable = lib.mkEnableOption "One-shot service to disable dell bios fan control on startup";
    package = lib.mkPackageOption pkgs "dell-bios-fan-control" { };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "i8k" ];
    environment.systemPackages = [ cfg.package ];

    # see ref in aur: https://aur.archlinux.org/cgit/aur.git/tree/dell-bios-fan-control.service?h=dell-bios-fan-control-git
    systemd.services.dell-bios-fan-control = {
      before = [ "i8kmon.service" ];
      description = "Disables BIOS control of fans at boot.";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} 0";
        ExecStop = "${lib.getExe cfg.package} 1";
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "dell-bios-fan-control-resume.service" ];
    };

    # see ref in aur: https://aur.archlinux.org/cgit/aur.git/tree/dell-bios-fan-control-resume.service?h=dell-bios-fan-control-git
    systemd.services.dell-bios-fan-control-resume = {
      after = [ "suspend.target" ];
      description = "Restart dell-bios-fan-control on resume.";

      serviceConfig = {
        ExecStart = "${config.systemd.package}/bin/systemctl restart dell-bios-fan-control.service";
        # re: sleep, see: https://github.com/NixOS/nixpkgs/pull/439978#discussion_r2404279441
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 30";
        Type = "oneshot";
      };

      wantedBy = [ "suspend.target" ];
      wants = [ "dell-bios-fan-control.service" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ rickyelopez ];
}
