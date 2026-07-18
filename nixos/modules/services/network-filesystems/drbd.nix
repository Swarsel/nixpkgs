# Support for DRBD, the Distributed Replicated Block Device.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.drbd;
in

{

  ###### interface

  options = {

    services.drbd.config = lib.mkOption {
      default = "";

      description = ''
        Contents of the {file}`drbd.conf` configuration file.
      '';

      type = lib.types.lines;
    };

    services.drbd.enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable support for DRBD, the Distributed Replicated
        Block Device.
      '';

      type = lib.types.bool;
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    boot.extraModprobeConfig = ''
      options drbd usermode_helper=/run/current-system/sw/bin/drbdadm
    '';

    boot.kernelModules = [ "drbd" ];

    environment.etc."drbd.conf" = {
      source = pkgs.writeText "drbd.conf" cfg.config;
    };

    environment.systemPackages = [ pkgs.drbd ];
    services.udev.packages = [ pkgs.drbd ];

    systemd.services.drbd = {
      after = [
        "systemd-udev.settle.service"
        "network.target"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.drbd}/bin/drbdadm up all";
        ExecStop = "${pkgs.drbd}/bin/drbdadm down all";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "systemd-udev.settle.service" ];
    };
  };
}
